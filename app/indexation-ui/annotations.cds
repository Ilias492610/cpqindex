using IndexationService as service from '../../srv/indexation-service';

annotate service.Quotes with @(
    UI.HeaderInfo : {
        TypeName       : 'Quote',
        TypeNamePlural : 'Quotes',
        Title          : {
            $Type : 'UI.DataField',
            Value : QuoteNumber
        }
    },

    UI.SelectionFields : [
        QuoteNumber,
        DateModified,
        IsActiveRevision
    ],

    Capabilities.InsertRestrictions : {
        Insertable : false
    },

    Capabilities.UpdateRestrictions : {
        Updatable : false
    },

    Capabilities.DeleteRestrictions : {
        Deletable : false
    },

    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Quote Number',
            Value : QuoteNumber
        },
        {
            $Type : 'UI.DataField',
            Label : 'Last Changed On',
            Value : DateModified
        },
        {
            $Type : 'UI.DataField',
            Label : 'Active Revision',
            Value : IsActiveRevision
        },
        {
            $Type : 'UI.DataField',
            Label : 'Total Amount',
            Value : TotalAmount
        }
    ],

    UI.FieldGroup #General : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Label : 'Quote ID',
                Value : QuoteId
            },
            {
                $Type : 'UI.DataField',
                Label : 'Quote Number',
                Value : QuoteNumber
            },
            {
                $Type : 'UI.DataField',
                Label : 'Revision Number',
                Value : RevisionNumber
            },
            {
                $Type : 'UI.DataField',
                Label : 'Status',
                Value : StatusName
            },
            {
                $Type : 'UI.DataField',
                Label : 'Active Revision',
                Value : IsActiveRevision
            },
            {
                $Type : 'UI.DataField',
                Label : 'Created On',
                Value : DateCreated
            },
            {
                $Type : 'UI.DataField',
                Label : 'Last Changed On',
                Value : DateModified
            },
            {
                $Type : 'UI.DataField',
                Label : 'Total Net Price',
                Value : TotalNetPrice
            },
            {
                $Type : 'UI.DataField',
                Label : 'Total Amount',
                Value : TotalAmount
            },
            {
                $Type : 'UI.DataField',
                Label : 'Currency',
                Value : CurrencyCode
            }
        ]
    },

    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneralInformation',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#General'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'QuoteItems',
            Label  : 'Items',
            Target : 'items/@UI.LineItem'
        }
    ]
) {
    QuoteId @Common.Label : 'Quote ID';

    QuoteNumber @Common.Label : 'Quote Number';

    RevisionNumber @Common.Label : 'Revision Number';

    StatusName @Common.Label : 'Status';

    DateCreated @Common.Label : 'Created On';

    DateModified @Common.Label : 'Last Changed On';

    IsActiveRevision @Common.Label : 'Active Revision';

    TotalAmount
      @Common.Label : 'Total Amount'
      @Measures.ISOCurrency : CurrencyCode;

    TotalNetPrice
      @Common.Label : 'Total Net Price'
      @Measures.ISOCurrency : CurrencyCode;

    CurrencyCode @Common.Label : 'Currency';

    items @Common.Label : 'Items';
};

annotate service.QuoteItems with @(
    Capabilities.InsertRestrictions : {
        Insertable : false
    },

    Capabilities.UpdateRestrictions : {
        Updatable : false
    },

    Capabilities.DeleteRestrictions : {
        Deletable : false
    },

    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'Item No.',
            Value : ItemNumber
        },
        {
            $Type : 'UI.DataField',
            Label : 'Product',
            Value : ProductName
        },
        {
            $Type : 'UI.DataField',
            Label : 'Description',
            Value : Description
        },
        {
            $Type : 'UI.DataField',
            Label : 'Quantity',
            Value : Quantity
        },
        {
            $Type : 'UI.DataField',
            Label : 'Net Price',
            Value : NetPrice
        },
        {
            $Type : 'UI.DataField',
            Label : 'Extended Amount',
            Value : ExtendedAmount
        },
        {
            $Type : 'UI.DataField',
            Label : 'Indexation',
            Value : Indexation
        }
    ]
) {
    ItemId @Common.Label : 'Item ID';

    QuoteId @Common.Label : 'Quote ID';

    ItemNumber @Common.Label : 'Item No.';

    ProductName @Common.Label : 'Product';

    Description @Common.Label : 'Description';

    Quantity @Common.Label : 'Quantity';

    NetPrice
      @Common.Label : 'Net Price'
      @Measures.ISOCurrency : CurrencyCode;

    ExtendedAmount
      @Common.Label : 'Extended Amount'
      @Measures.ISOCurrency : CurrencyCode;

    Indexation @Common.Label : 'Indexation';

    CurrencyCode @Common.Label : 'Currency';
};