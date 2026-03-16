using { indexation as db } from '../db/schema';

type PreviewRef {
  previewId : UUID;
  status    : String(20);
}

type OperationResult {
  success : Boolean;
  status  : String(20);
  message : String(500);
}

type ConfirmPreviewResult {
  success               : Boolean;
  previewId             : UUID;
  sourceQuoteId         : Integer;
  sourceQuoteNumber     : String;
  newQuoteId            : Integer;
  newQuoteNumber        : String;
  percentageApplied     : Decimal(9,3);
  itemsUpdated          : Integer;
  revisionCreated       : Boolean;
  totalAmount           : Decimal(15,6);
  totalNetPrice         : Decimal(15,6);
  currencyCode          : String(3);
  statusName            : String;
  dateCreated           : Timestamp;
  dateModified          : Timestamp;
  isActiveRevision      : Boolean;
  message               : String(500);
}

service IndexationService {
  entity Quotes as projection on db.Quotes actions {
    action CreatePreview(percentage : Decimal(9,3)) returns PreviewRef;
  };

  entity QuoteItems as projection on db.QuoteItems;

  entity Previews as projection on db.Previews actions {
    action Confirm() returns ConfirmPreviewResult;
    action Cancel() returns OperationResult;
  };

  entity PreviewItems as projection on db.PreviewItems;
}