namespace indexation;

type Money : Decimal(15,2);

entity Quotes {
  key QuoteId          : Integer;
      QuoteNumber      : String;
      RevisionNumber   : String;
      StatusName       : String;
      DateCreated      : Timestamp;
      DateModified     : Timestamp;
      IsActiveRevision : Boolean;
      TotalAmount      : Money;
      TotalNetPrice    : Money;
      CurrencyCode     : String;

      items            : Association to many QuoteItems
                           on items.QuoteId = $self.QuoteId;
}

entity QuoteItems {
  key ItemId           : Integer;
      QuoteId          : Integer;
      ItemNumber       : Integer;
      ProductName      : String;
      Description      : String;
      Quantity         : Decimal(15,2);
      NetPrice         : Money;
      ExtendedAmount   : Money;
      Indexation       : Decimal(9,3);
      CurrencyCode     : String;
}