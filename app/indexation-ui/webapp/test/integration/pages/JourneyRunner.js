sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"cpq/indexation/indexationui/test/integration/pages/QuotesList",
	"cpq/indexation/indexationui/test/integration/pages/QuotesObjectPage"
], function (JourneyRunner, QuotesList, QuotesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('cpq/indexation/indexationui') + '/test/flp.html#app-preview',
        pages: {
			onTheQuotesList: QuotesList,
			onTheQuotesObjectPage: QuotesObjectPage
        },
        async: true
    });

    return runner;
});

