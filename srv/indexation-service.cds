using { indexation as db } from '../db/schema';

type ApplyIndexationResult {
  result                : String;
  sourceQuoteId         : Integer;
  newQuoteId            : Integer;
  baseQuoteNumber       : String;
  newQuoteNumber        : String;
  percentageApplied     : Decimal(9,3);
  itemsUpdated          : Integer;
  returnedItemsCount    : Integer;
  revisionCreated       : Boolean;
  calculatedTotalAmount : Decimal(15,6);

  statusName            : String;
  dateCreated           : Timestamp;
  dateModified          : Timestamp;
  isActiveRevision      : Boolean;
  totalAmount           : Decimal(15,6);
  totalNetPrice         : Decimal(15,6);
  currencyCode          : String(3);
}

service IndexationService {
  entity Quotes as projection on db.Quotes actions {
    action ApplyIndexation(percentage : Decimal(9,3)) returns ApplyIndexationResult;
  };

  entity QuoteItems as projection on db.QuoteItems;
}