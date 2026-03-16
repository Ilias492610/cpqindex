using { cuid, managed } from '@sap/cds/common';

namespace indexation;

entity Quotes {
  key QuoteId          : Integer;
      QuoteNumber      : String(20);
      RevisionNumber   : String(10);
      StatusName       : String(50);
      DateCreated      : Timestamp;
      DateModified     : Timestamp;
      IsActiveRevision : Boolean;
      TotalAmount      : Decimal(15,6);
      TotalNetPrice    : Decimal(15,6);
      CurrencyCode     : String(3);

      items            : Association to many QuoteItems
                           on items.QuoteId = $self.QuoteId;
}

entity QuoteItems {
  key ItemId          : Integer;
      QuoteId         : Integer;
      ItemNumber      : Integer;
      ProductName     : String(255);
      Description     : String(500);
      Quantity        : Decimal(15,2);
      NetPrice        : Decimal(15,6);
      ExtendedAmount  : Decimal(15,6);
      Indexation      : Decimal(9,3);
      CurrencyCode    : String(3);
}

entity Previews : cuid, managed {
      quoteId                 : Integer not null;
      quoteNumber             : String(20);
      percentage              : Decimal(9,3) not null;
      status                  : String(20) default 'DRAFT';
      currencyCode            : String(3);

      originalTotal           : Decimal(15,6);
      previewTotal            : Decimal(15,6);
      deltaTotal              : Decimal(15,6);
      itemCount               : Integer;

      sourceQuoteDateModified : Timestamp;

      confirmedNewQuoteId     : Integer;
      confirmedNewQuoteNumber : String(20);
      cpqResult               : String(50);

      errorMessage            : String(1000);

      items                   : Composition of many PreviewItems
                                  on items.preview = $self;
}

entity PreviewItems : cuid, managed {
      preview                : Association to Previews not null;

      cpqItemId              : Integer;
      quoteId                : Integer;
      itemNumber             : Integer;
      productName            : String(255);
      description            : String(500);
      quantity               : Decimal(15,2);

      originalNetPrice       : Decimal(15,6);
      previewNetPrice        : Decimal(15,6);

      originalExtendedAmount : Decimal(15,6);
      previewExtendedAmount  : Decimal(15,6);

      deltaAmount            : Decimal(15,6);
      percentage             : Decimal(9,3);
      currencyCode           : String(3);
}