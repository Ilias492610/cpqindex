require('dotenv').config();
const cds = require('@sap/cds');

const CPQ_BASE_URL = (process.env.CPQ_BASE_URL || 'https://cangurusolutions-tst.cpq.cloud.sap').replace(/\/$/, '');
const CPQ_TOKEN_URL = process.env.CPQ_TOKEN_URL || `${CPQ_BASE_URL}/oauth2/token`;
const CPQ_CLIENT_ID = process.env.CPQ_CLIENT_ID;
const CPQ_CLIENT_SECRET = process.env.CPQ_CLIENT_SECRET;
const CPQ_INDEXATION_SCRIPT_PATH = normalizePath(
  process.env.CPQ_INDEXATION_SCRIPT_PATH || '/customapi/executescript?scriptname=ApplyIndexationPOC'
);

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

function mapQuote(rawQuote) {
  const q = rawQuote?.PagedRecords?.[0] || rawQuote?.Records?.[0] || rawQuote || {};

  return {
    QuoteId: toNumber(q.Id ?? q.QuoteId, 0),
    QuoteNumber: toText(q.QuoteNumber),
    RevisionNumber: toText(q.RevisionNumber),
    StatusName: toText(q.StatusName),
    DateCreated: q.DateCreated ?? null,
    DateModified: q.DateModified ?? null,
    IsActiveRevision: q.IsActiveRevision ?? null,
    TotalAmount: toNumber(q.TotalAmount?.Value ?? q.TotalAmount, 0),
    TotalNetPrice: toNumber(q.TotalNetPrice?.Value ?? q.TotalNetPrice, 0),
    CurrencyCode: q.TotalAmount?.Currency ?? q.CurrencyCode ?? null
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
    CurrencyCode: rawItem.PricingDetails?.Fixed?.NetPrice?.Currency ?? null
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
      return mapQuote(data);
    }

    const data = await cpqGet('/api/v1/quotes');
    const records = getRecords(data);

    return records.map(mapQuote);
  });

  this.on('READ', 'QuoteItems', async req => {
    const quoteId = extractQuoteId(req);

    if (!quoteId) {
      console.log('[CPQ] QuoteItems called without quoteId');
      return [];
    }

    const data = await cpqGet(`/api/v1/quotes/${quoteId}/items`);
    const records = getRecords(data);

    return records.map(item => mapItem(item, quoteId));
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