sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'cpq.indexation.indexationui',
            componentId: 'QuotesObjectPage',
            contextPath: '/Quotes'
        },
        CustomPageDefinitions
    );
});