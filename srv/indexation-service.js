require('dotenv').config();
const cds = require('@sap/cds');

const CPQ_BASE_URL = (process.env.CPQ_BASE_URL || 'https://cangurusolutions-tst.cpq.cloud.sap').replace(/\/$/, '');
const CPQ_TOKEN_URL = process.env.CPQ_TOKEN_URL || `${CPQ_BASE_URL}/oauth2/token`;
const CPQ_CLIENT_ID = process.env.CPQ_CLIENT_ID;
const CPQ_CLIENT_SECRET = process.env.CPQ_CLIENT_SECRET;
const CPQ_INDEXATION_SCRIPT_PATH = normalizePath(
  process.env.CPQ_INDEXATION_SCRIPT_PATH || '/customapi/executescript?scriptname=ApplyIndexationPOC'
);

const CPQ_MAX_PAGE_SIZE = 100;
const CPQ_QUOTES_MAX_PAGE_SIZE = 100;
const CPQ_QUOTES_DEFAULT_PAGE_SIZE = Number(process.env.CPQ_QUOTES_DEFAULT_PAGE_SIZE || 10);

let tokenCache = {
  accessToken: null,
  expiresAt: 0
};

function normalizePath(path) {
  if (!path) return '';
  return path.startsWith('/') ? path : `/${path}`;
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function toNumber(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function toText(value, fallback = '') {
  return value === null || value === undefined ? fallback : String(value);
}

function toBoolean(value, fallback = null) {
  if (value === true || value === false) return value;
  if (value === 1 || value === '1') return true;
  if (value === 0 || value === '0') return false;

  if (typeof value === 'string') {
    const v = value.trim().toLowerCase();

    if (['true', 'yes', 'ja', 'y'].includes(v)) return true;
    if (['false', 'no', 'nee', 'n'].includes(v)) return false;
  }

  return fallback;
}

function getRecords(payload) {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.PagedRecords)) return payload.PagedRecords;
  if (Array.isArray(payload?.Records)) return payload.Records;
  return [];
}

function getIndexationValue(customFields) {
  const field = (customFields || []).find(f => f?.Name === 'Indexation');
  return toNumber(field?.Content ?? field?.Value ?? 0, 0);
}

function getPaging(req) {
  const limit = req.query?.SELECT?.limit;

  const top =
    Number(limit?.rows?.val ?? req?._queryOptions?.$top ?? 0) || null;

  const skip =
    Number(limit?.offset?.val ?? req?._queryOptions?.$skip ?? 0) || 0;

  return { top, skip };
}

async function readPayload(response) {
  const text = await response.text().catch(() => '');
  if (!text) return {};
  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

function formatPayload(payload) {
  if (typeof payload === 'string') return payload;
  try {
    return JSON.stringify(payload);
  } catch {
    return String(payload);
  }
}

async function getAccessToken(forceRefresh = false) {
  if (!CPQ_CLIENT_ID || !CPQ_CLIENT_SECRET) {
    throw new Error('Missing CPQ_CLIENT_ID or CPQ_CLIENT_SECRET environment variables');
  }

  if (
    !forceRefresh &&
    tokenCache.accessToken &&
    Date.now() < tokenCache.expiresAt - 30_000
  ) {
    return tokenCache.accessToken;
  }

  const basicAuth = Buffer.from(`${CPQ_CLIENT_ID}:${CPQ_CLIENT_SECRET}`).toString('base64');

  const response = await fetch(CPQ_TOKEN_URL, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${basicAuth}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'grant_type=client_credentials'
  });

  const data = await readPayload(response);

  if (!response.ok) {
    throw new Error(`Token request failed: ${response.status} ${formatPayload(data)}`);
  }

  if (!data.access_token) {
    throw new Error(`Token response did not contain access_token: ${formatPayload(data)}`);
  }

  const expiresInSeconds = toNumber(data.expires_in, 300);
  tokenCache = {
    accessToken: data.access_token,
    expiresAt: Date.now() + expiresInSeconds * 1000
  };

  return tokenCache.accessToken;
}

async function cpqRequest(method, path, body, attempt = 0) {
  const started = Date.now();

  try {
    const token = await getAccessToken(attempt > 0);

    const headers = {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`
    };

    const options = {
      method,
      headers
    };

    if (body !== undefined) {
      headers['Content-Type'] = 'application/json';
      options.body = JSON.stringify(body);
    }

    const response = await fetch(`${CPQ_BASE_URL}${path}`, options);
    const data = await readPayload(response);
    const duration = Date.now() - started;

    if (response.status === 401 && attempt === 0) {
      console.warn(`[CPQ] ${method} ${path} -> 401, refreshing token and retrying once`);
      tokenCache = { accessToken: null, expiresAt: 0 };
      return cpqRequest(method, path, body, attempt + 1);
    }

    if (!response.ok) {
      console.error(`[CPQ] ${method} ${path} failed -> ${response.status} (${duration} ms)`);
      throw new Error(`${method} ${path} failed: ${response.status} ${formatPayload(data)}`);
    }

    console.log(`[CPQ] ${method} ${path} -> ${response.status} (${duration} ms)`);
    return data;
  } catch (error) {
    const duration = Date.now() - started;
    console.error(
      `[CPQ] ${method} ${path} failed -> UNKNOWN (${duration} ms): ${error.message}`
    );
    throw new Error(`CPQ call failed for ${path}: ${error.message}`);
  }
}

async function cpqGet(path) {
  return cpqRequest('GET', path);
}

async function cpqPost(path, body) {
  return cpqRequest('POST', path, body);
}

async function withRetries(label, fn, attempts = 3, delayMs = 700) {
  let lastError;

  for (let attempt = 1; attempt <= attempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;

      if (attempt === attempts) {
        break;
      }

      console.warn(`[CPQ] ${label} attempt ${attempt} failed, retrying in ${delayMs} ms`);
      await sleep(delayMs);
    }
  }

  throw lastError;
}

async function getQuotesWindow(skip = 0, top = CPQ_QUOTES_DEFAULT_PAGE_SIZE) {
  const safeSkip = Math.max(0, toNumber(skip, 0));
  const safeTop = Math.min(
    CPQ_QUOTES_MAX_PAGE_SIZE,
    Math.max(1, toNumber(top, CPQ_QUOTES_DEFAULT_PAGE_SIZE))
  );

  const data = await cpqGet(`/api/v1/quotes?$skip=${safeSkip}&$top=${safeTop}`);

  return {
    records: getRecords(data),
    totalCount: toNumber(data?.TotalNumberOfRecords, null)
  };
}

async function getQuotesForRequest(req) {
  const { top, skip } = getPaging(req);
  const countRequested = Boolean(req.query?.SELECT?.count);
  const effectiveTop = top ?? CPQ_QUOTES_DEFAULT_PAGE_SIZE;

  const { records, totalCount } = await getQuotesWindow(skip, effectiveTop);

  return {
    records,
    totalCount: countRequested ? totalCount ?? records.length : null
  };
}

async function findQuoteInQuoteList(quoteId, quoteNumber) {
  const { totalCount } = await getQuotesWindow(0, CPQ_QUOTES_DEFAULT_PAGE_SIZE);
  const total = Math.max(0, toNumber(totalCount, 0));

  for (let skip = 0; skip < total; skip += CPQ_QUOTES_DEFAULT_PAGE_SIZE) {
    const { records } = await getQuotesWindow(skip, CPQ_QUOTES_DEFAULT_PAGE_SIZE);

    const match =
      records.find(r => toNumber(r.QuoteId ?? r.Id, 0) === toNumber(quoteId, 0)) ||
      records.find(r => toText(r.QuoteNumber) === toText(quoteNumber));

    if (match) {
      return match;
    }

    if (records.length < CPQ_QUOTES_DEFAULT_PAGE_SIZE) {
      break;
    }
  }

  return null;
}

async function getQuoteItemsCount(quoteId) {
  const raw = await cpqGet(`/api/v1/quotes/${quoteId}/items/$count`);
  return toNumber(raw, 0);
}

async function getQuoteItemsWindow(quoteId, skip = 0, top = CPQ_MAX_PAGE_SIZE) {
  const safeSkip = Math.max(0, toNumber(skip, 0));
  const safeTop = Math.min(CPQ_MAX_PAGE_SIZE, Math.max(1, toNumber(top, CPQ_MAX_PAGE_SIZE)));

  const data = await cpqGet(
    `/api/v1/quotes/${quoteId}/items?$skip=${safeSkip}&$top=${safeTop}`
  );

  return getRecords(data);
}

async function getAllQuoteItems(quoteId) {
  const totalCount = await getQuoteItemsCount(quoteId);

  if (totalCount <= 0) {
    return [];
  }

  const chunks = [];
  for (let skip = 0; skip < totalCount; skip += CPQ_MAX_PAGE_SIZE) {
    const batch = await getQuoteItemsWindow(quoteId, skip, CPQ_MAX_PAGE_SIZE);
    chunks.push(...batch);

    if (batch.length < CPQ_MAX_PAGE_SIZE) {
      break;
    }
  }

  return chunks;
}

async function getQuoteItemsForRequest(quoteId, req) {
  const { top, skip } = getPaging(req);
  const countRequested = Boolean(req.query?.SELECT?.count);

  if (top !== null) {
    const totalCount = countRequested ? await getQuoteItemsCount(quoteId) : null;
    const records = await getQuoteItemsWindow(quoteId, skip, top);

    return {
      records,
      totalCount
    };
  }

  const records = await getAllQuoteItems(quoteId);

  return {
    records,
    totalCount: countRequested ? records.length : null
  };
}

async function getQuoteListActiveRevision(quoteId, quoteNumber) {
  const match = await findQuoteInQuoteList(quoteId, quoteNumber);

  if (!match) {
    return null;
  }

  return toBoolean(
    match.IsActiveRevision ??
    match.ActiveRevision ??
    match.IsCurrentRevision ??
    match.IsActive,
    null
  );
}

function mapQuote(rawQuote) {
  const q = rawQuote?.PagedRecords?.[0] || rawQuote?.Records?.[0] || rawQuote || {};

  return {
    QuoteId: toNumber(q.Id ?? q.QuoteId, 0),
    QuoteNumber: toText(q.QuoteNumber),
    RevisionNumber: toText(q.RevisionNumber),
    StatusName: toText(q.StatusName),
    DateCreated: q.DateCreated ?? null,
    DateModified: q.DateModified ?? null,
    IsActiveRevision: toBoolean(
      q.IsActiveRevision ??
      q.ActiveRevision ??
      q.IsCurrentRevision ??
      q.IsActive,
      null
    ),
    TotalAmount: toNumber(q.TotalAmount?.Value ?? q.TotalAmount, 0),
    TotalNetPrice: toNumber(q.TotalNetPrice?.Value ?? q.TotalNetPrice, 0),
    CurrencyCode:
      q.TotalAmount?.Currency ??
      q.TotalNetPrice?.Currency ??
      q.CurrencyCode ??
      q.Currency ??
      q.TransactionCurrency ??
      null
  };
}

function mapItem(rawItem, quoteId) {
  return {
    ItemId: toNumber(rawItem.Id ?? rawItem.ItemId, 0),
    QuoteId: toNumber(quoteId, 0),
    ItemNumber: toNumber(rawItem.ItemNumber, 0),
    ProductName: toText(rawItem.ProductName ?? rawItem.PartNumber),
    Description: toText(rawItem.Description),
    Quantity: toNumber(rawItem.Quantity, 0),
    NetPrice: toNumber(rawItem.PricingDetails?.Fixed?.NetPrice?.Value, 0),
    ExtendedAmount: toNumber(rawItem.PricingDetails?.Fixed?.ExtendedAmount?.Value, 0),
    Indexation: getIndexationValue(rawItem.CustomFields),
    CurrencyCode:
      rawItem.PricingDetails?.Fixed?.NetPrice?.Currency ??
      rawItem.PricingDetails?.Fixed?.ExtendedAmount?.Currency ??
      null
  };
}

function extractQuoteId(req) {
  return (
    req?.data?.quoteId ||
    req?.data?.QuoteId ||
    req?.params?.[0]?.quoteId ||
    req?.params?.[0]?.QuoteId ||
    req?.req?.query?.quoteId ||
    req?._queryOptions?.quoteId ||
    null
  );
}

function extractQuoteKey(req) {
  return (
    req?.data?.QuoteId ||
    req?.data?.quoteId ||
    req?.params?.[0]?.QuoteId ||
    req?.params?.[0]?.quoteId ||
    null
  );
}

function extractBoundQuoteId(req) {
  return (
    req?.params?.[0]?.QuoteId ||
    req?.params?.[0]?.quoteId ||
    req?.data?.QuoteId ||
    req?.data?.quoteId ||
    null
  );
}

module.exports = cds.service.impl(function () {
  this.on('READ', 'Quotes', async req => {
    const quoteId = extractQuoteKey(req);

    if (quoteId) {
      const data = await cpqGet(`/api/v1/quotes/${quoteId}`);
      const quote = mapQuote(data);

      if (quote.IsActiveRevision === null) {
        try {
          const activeRevision = await getQuoteListActiveRevision(
            quote.QuoteId || quoteId,
            quote.QuoteNumber
          );

          return {
            ...quote,
            IsActiveRevision: activeRevision
          };
        } catch (err) {
          console.warn(
            `[CPQ] Failed to enrich IsActiveRevision for quote ${quoteId}: ${err.message}`
          );
        }
      }

      return quote;
    }

    const countRequested = Boolean(req.query?.SELECT?.count);
    const { records, totalCount } = await getQuotesForRequest(req);

    console.log(
      `[CPQ] Quotes returned=${records.length}, countRequested=${countRequested}, totalCount=${totalCount}`
    );

    const summaries = records.map(r => ({
      QuoteId: toNumber(r.Id ?? r.QuoteId, 0),
      QuoteNumber: toText(r.QuoteNumber),
      RevisionNumber: toText(r.RevisionNumber),
      StatusName: toText(r.StatusName),
      DateCreated: r.DateCreated ?? null,
      DateModified: r.DateModified ?? null,
      IsActiveRevision: toBoolean(
        r.IsActiveRevision ??
        r.ActiveRevision ??
        r.IsCurrentRevision ??
        r.IsActive,
        null
      ),
      TotalAmount: 0,
      TotalNetPrice: 0,
      CurrencyCode: null
    }));

    const enrichedQuotes = await Promise.all(
      summaries.map(async quote => {
        if (!quote.QuoteId) {
          return quote;
        }

        try {
          const detailRaw = await cpqGet(`/api/v1/quotes/${quote.QuoteId}`);
          const detail = mapQuote(detailRaw);

          return {
            ...quote,
            RevisionNumber: detail.RevisionNumber || quote.RevisionNumber,
            StatusName: detail.StatusName || quote.StatusName,
            IsActiveRevision: detail.IsActiveRevision ?? quote.IsActiveRevision,
            TotalAmount: detail.TotalAmount,
            TotalNetPrice: detail.TotalNetPrice,
            CurrencyCode: detail.CurrencyCode
          };
        } catch (err) {
          console.warn(`[CPQ] Failed to enrich quote ${quote.QuoteId}: ${err.message}`);
          return quote;
        }
      })
    );

    if (countRequested) {
      enrichedQuotes.$count = totalCount ?? enrichedQuotes.length;
    }

    return enrichedQuotes;
  });

  this.on('READ', 'QuoteItems', async req => {
    const quoteId = extractQuoteId(req);

    if (!quoteId) {
      console.log('[CPQ] QuoteItems called without quoteId');
      return [];
    }

    const { top, skip } = getPaging(req);
    const countRequested = Boolean(req.query?.SELECT?.count);

    const { records, totalCount } = await getQuoteItemsForRequest(quoteId, req);

    console.log(
      `[CPQ] QuoteItems quoteId=${quoteId}, returned=${records.length}, skip=${skip}, top=${top}, countRequested=${countRequested}, totalCount=${totalCount}`
    );

    const mapped = records.map(item => mapItem(item, quoteId));

    if (countRequested) {
      mapped.$count = totalCount ?? mapped.length;
    }

    return mapped;
  });

  this.on('ApplyIndexation', async req => {
    const quoteId = Number(extractBoundQuoteId(req));
    const percentage = Number(req.data.percentage);

    if (!Number.isInteger(quoteId) || quoteId <= 0) {
      return req.reject({
        status: 400,
        message: 'quoteId must be a positive integer',
        target: 'QuoteId'
      });
    }

    if (!Number.isFinite(percentage)) {
      return req.reject({
        status: 400,
        message: 'percentage must be a number',
        target: 'percentage'
      });
    }

    if (percentage < 0 || percentage > 100) {
      return req.reject({
        status: 400,
        message: 'percentage must be between 0 and 100',
        target: 'percentage'
      });
    }

    const scriptResponse = await cpqPost(CPQ_INDEXATION_SCRIPT_PATH, {
      Param: JSON.stringify({
        quoteId,
        percentage
      })
    });

    if (scriptResponse?.Result !== 'Success') {
      return req.reject({
        status: 502,
        message: scriptResponse?.Error || scriptResponse?.Result || 'CPQ indexation script failed'
      });
    }

    const newQuoteId = Number(scriptResponse?.newQuoteId);

    if (!Number.isInteger(newQuoteId) || newQuoteId <= 0) {
      return req.reject({
        status: 502,
        message: 'CPQ script did not return a valid newQuoteId'
      });
    }

    const [newQuoteRaw, newItemsRaw] = await Promise.all([
      withRetries(
        `GET /api/v1/quotes/${newQuoteId}`,
        () => cpqGet(`/api/v1/quotes/${newQuoteId}`)
      ),
      withRetries(
        `GET /api/v1/quotes/${newQuoteId}/items`,
        () => cpqGet(`/api/v1/quotes/${newQuoteId}/items`)
      )
    ]);

    const newQuote = mapQuote(newQuoteRaw);
    const newItems = getRecords(newItemsRaw).map(item => mapItem(item, newQuoteId));

    console.log(
      `[CPQ] ApplyIndexation success -> sourceQuoteId=${quoteId}, newQuoteId=${newQuoteId}, items=${newItems.length}`
    );

    return {
      result: toText(scriptResponse.Result, 'Success'),
      sourceQuoteId: toNumber(scriptResponse.sourceQuoteId ?? quoteId, quoteId),
      newQuoteId,
      baseQuoteNumber: toText(scriptResponse.baseQuoteNumber),
      newQuoteNumber: toText(scriptResponse.newQuoteNumber || newQuote.QuoteNumber),
      percentageApplied: toNumber(scriptResponse.percentageApplied ?? percentage, percentage),
      itemsUpdated: toNumber(scriptResponse.itemsUpdated ?? newItems.length, newItems.length),
      returnedItemsCount: newItems.length,
      revisionCreated: Boolean(scriptResponse.revisionCreated),
      calculatedTotalAmount: toNumber(
        scriptResponse.calculatedTotalAmount,
        newQuote.TotalAmount
      ),
      statusName: newQuote.StatusName,
      dateCreated: newQuote.DateCreated,
      dateModified: newQuote.DateModified,
      isActiveRevision: newQuote.IsActiveRevision,
      totalAmount: newQuote.TotalAmount,
      totalNetPrice: newQuote.TotalNetPrice,
      currencyCode: newQuote.CurrencyCode
    };
  });
});