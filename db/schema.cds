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