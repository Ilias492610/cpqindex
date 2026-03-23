const cds = require('@sap/cds');

let CPQ;


const DESTINATION_NAME = process.env.CPQ_DESTINATION_NAME || 'CPQ_DEST';
const CPQ_INDEXATION_SCRIPT_PATH = normalizePath(
  process.env.CPQ_INDEXATION_SCRIPT_PATH || '/customapi/executescript?scriptname=ApplyIndexationPOC'
);

const CPQ_MAX_PAGE_SIZE = 100;
const CPQ_QUOTES_MAX_PAGE_SIZE = 100;
const CPQ_QUOTES_DEFAULT_PAGE_SIZE = 10;

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

function round6(value) {
  return Math.round((Number(value) + Number.EPSILON) * 1_000_000) / 1_000_000;
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

function formatPayload(payload) {
  if (typeof payload === 'string') return payload;
  try {
    return JSON.stringify(payload);
  } catch {
    return String(payload);
  }
}

function extractErrorMessage(error) {
  if (!error) return 'Unknown error';

  const sdkResponse =
    error?.response?.data ||
    error?.cause?.response?.data ||
    error?.rootCause?.response?.data;

  if (sdkResponse) {
    if (typeof sdkResponse === 'string') return sdkResponse;
    try {
      return JSON.stringify(sdkResponse);
    } catch {
      return String(sdkResponse);
    }
  }

  return error.message || String(error);
}

async function cpqRequest(method, path, body, contentType = 'application/json') {
  const started = Date.now();

  try {
    if (!CPQ) {
      CPQ = await cds.connect.to('Quotes');
    }

    const headers = {
      Accept: 'application/json'
    };

    if (body !== undefined && contentType) {
      headers['Content-Type'] = contentType;
    }

    const response = await CPQ.send({
      method,
      path,
      data: body,
      headers
    });

    const duration = Date.now() - started;
    console.log(`[CPQ] ${method} ${path} -> OK (${duration} ms)`);

    return response;
  } catch (error) {
    const duration = Date.now() - started;
    const message = extractErrorMessage(error);
    console.error(`[CPQ] ${method} ${path} -> FAILED (${duration} ms): ${message}`);
    throw new Error(`${method} ${path} failed: ${message}`);
  }
}

async function cpqGet(path) {
  return cpqRequest('GET', path);
}

async function cpqPost(path, body) {
  return cpqRequest('POST', path, body, 'application/json');
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

function buildPreviewItem(rawItem, quoteId, percentage) {
  const mapped = mapItem(rawItem, quoteId);

  const previewNetPrice = round6(mapped.NetPrice * (1 + percentage / 100));
  const previewExtendedAmount = round6(previewNetPrice * mapped.Quantity);
  const deltaAmount = round6(previewExtendedAmount - mapped.ExtendedAmount);

  return {
    cpqItemId: mapped.ItemId,
    quoteId: mapped.QuoteId,
    itemNumber: mapped.ItemNumber,
    productName: mapped.ProductName,
    description: mapped.Description,
    quantity: mapped.Quantity,
    originalNetPrice: mapped.NetPrice,
    previewNetPrice,
    originalExtendedAmount: mapped.ExtendedAmount,
    previewExtendedAmount,
    deltaAmount,
    percentage: round6(percentage),
    currencyCode: mapped.CurrencyCode
  };
}

function validatePercentage(value) {
  const percentage = Number(value);

  if (!Number.isFinite(percentage)) {
    throw new Error('percentage must be a number');
  }

  if (percentage < 0 || percentage > 100) {
    throw new Error('percentage must be between 0 and 100');
  }

  return percentage;
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

function extractPreviewId(req) {
  return (
    req?.params?.[0]?.ID ||
    req?.params?.[0]?.id ||
    req?.data?.ID ||
    req?.data?.id ||
    req?.data?.previewId ||
    null
  );
}

module.exports = cds.service.impl(function () {
  const { Previews, PreviewItems } = cds.entities('indexation');

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

  this.on('CreatePreview', 'Quotes', async req => {
    const tx = cds.tx(req);
    const quoteId = Number(extractBoundQuoteId(req));

    if (!Number.isInteger(quoteId) || quoteId <= 0) {
      return req.reject({
        status: 400,
        message: 'quoteId must be a positive integer',
        target: 'QuoteId'
      });
    }

    let percentage;
    try {
      percentage = validatePercentage(req.data.percentage);
    } catch (e) {
      return req.reject({
        status: 400,
        message: e.message,
        target: 'percentage'
      });
    }

    const [quoteRaw, itemsRaw] = await Promise.all([
      cpqGet(`/api/v1/quotes/${quoteId}`),
      getAllQuoteItems(quoteId)
    ]);

    if (!itemsRaw.length) {
      return req.reject({
        status: 400,
        message: 'Quote has no items'
      });
    }

    const quote = mapQuote(quoteRaw);
    const previewItems = itemsRaw.map(item => buildPreviewItem(item, quoteId, percentage));

    const originalTotal = round6(
      previewItems.reduce((sum, item) => sum + Number(item.originalExtendedAmount || 0), 0)
    );

    const previewTotal = round6(
      previewItems.reduce((sum, item) => sum + Number(item.previewExtendedAmount || 0), 0)
    );

    const deltaTotal = round6(previewTotal - originalTotal);
    const previewId = cds.utils.uuid();

    await tx.run(
      UPDATE(Previews)
        .set({
          status: 'CANCELLED',
          errorMessage: 'Superseded by newer preview'
        })
        .where({
          quoteId,
          createdBy: req.user.id,
          status: 'DRAFT'
        })
    );

    await tx.run(
      INSERT.into(Previews).entries({
        ID: previewId,
        quoteId,
        quoteNumber: quote.QuoteNumber,
        percentage: round6(percentage),
        status: 'DRAFT',
        currencyCode: quote.CurrencyCode,
        originalTotal,
        previewTotal,
        deltaTotal,
        itemCount: previewItems.length,
        sourceQuoteDateModified: quote.DateModified
      })
    );

    await tx.run(
      INSERT.into(PreviewItems).entries(
        previewItems.map(item => ({
          ID: cds.utils.uuid(),
          preview_ID: previewId,
          ...item
        }))
      )
    );

    console.log(
      `[PREVIEW] Created preview ${previewId} for quote ${quoteId} with ${previewItems.length} items`
    );

    return {
      previewId,
      status: 'DRAFT'
    };
  });

  this.on('Confirm', 'Previews', async req => {
    const tx = cds.tx(req);
    const previewId = extractPreviewId(req);

    if (!previewId) {
      return req.reject(400, 'Missing preview ID');
    }

    const preview = await tx.run(
      SELECT.one.from(Previews).where({
        ID: previewId,
        createdBy: req.user.id
      })
    );

    if (!preview) {
      return req.reject(404, 'Preview not found');
    }

    const updated = await tx.run(
      UPDATE(Previews)
        .set({
          status: 'APPLYING',
          errorMessage: null
        })
        .where({
          ID: previewId,
          createdBy: req.user.id,
          status: 'DRAFT'
        })
    );

    if (!updated) {
      return req.reject(409, 'Preview is already processed or no longer in DRAFT status');
    }

    try {
      const scriptResponse = await cpqPost(CPQ_INDEXATION_SCRIPT_PATH, {
        Param: JSON.stringify({
          quoteId: preview.quoteId,
          percentage: Number(preview.percentage)
        })
      });

      if (scriptResponse?.Result !== 'Success') {
        throw new Error(
          scriptResponse?.Error ||
          scriptResponse?.Result ||
          'CPQ indexation script failed'
        );
      }

      const newQuoteId = Number(scriptResponse?.newQuoteId);

      if (!Number.isInteger(newQuoteId) || newQuoteId <= 0) {
        throw new Error('CPQ script did not return a valid newQuoteId');
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

      await tx.run(
        UPDATE(Previews)
          .set({
            status: 'CONFIRMED',
            confirmedNewQuoteId: newQuoteId,
            confirmedNewQuoteNumber: newQuote.QuoteNumber,
            cpqResult: toText(scriptResponse?.Result, 'Success'),
            errorMessage: null
          })
          .where({ ID: previewId })
      );

      console.log(
        `[PREVIEW] Confirmed preview ${previewId}: sourceQuoteId=${preview.quoteId}, newQuoteId=${newQuoteId}`
      );

      return {
        success: true,
        previewId,
        sourceQuoteId: preview.quoteId,
        sourceQuoteNumber: preview.quoteNumber,
        newQuoteId,
        newQuoteNumber: toText(scriptResponse?.newQuoteNumber || newQuote.QuoteNumber),
        percentageApplied: toNumber(scriptResponse?.percentageApplied ?? preview.percentage, preview.percentage),
        itemsUpdated: toNumber(scriptResponse?.itemsUpdated ?? newItems.length, newItems.length),
        revisionCreated: Boolean(scriptResponse?.revisionCreated),
        totalAmount: newQuote.TotalAmount,
        totalNetPrice: newQuote.TotalNetPrice,
        currencyCode: newQuote.CurrencyCode,
        statusName: newQuote.StatusName,
        dateCreated: newQuote.DateCreated,
        dateModified: newQuote.DateModified,
        isActiveRevision: newQuote.IsActiveRevision,
        message: 'Indexation applied successfully'
      };
    } catch (error) {
      const message = extractErrorMessage(error).slice(0, 1000);

      await tx.run(
        UPDATE(Previews)
          .set({
            status: 'FAILED',
            errorMessage: message
          })
          .where({ ID: previewId })
      );

      return req.reject({
        status: 502,
        message
      });
    }
  });

  this.on('Cancel', 'Previews', async req => {
    const tx = cds.tx(req);
    const previewId = extractPreviewId(req);

    if (!previewId) {
      return req.reject(400, 'Missing preview ID');
    }

    const updated = await tx.run(
      UPDATE(Previews)
        .set({
          status: 'CANCELLED'
        })
        .where({
          ID: previewId,
          createdBy: req.user.id,
          status: 'DRAFT'
        })
    );

    if (!updated) {
      return req.reject(409, 'Only DRAFT previews can be cancelled');
    }

    return {
      success: true,
      status: 'CANCELLED',
      message: 'Preview cancelled'
    };
  });
});