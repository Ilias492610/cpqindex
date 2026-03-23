/* checksum : 1e418d8df9f3a41f49c284182957744a */
@Capabilities.BatchSupported : false
@Capabilities.KeyAsSegmentSupported : true
@Core.Description : 'Quotes'
@Core.SchemaVersion : '1.0'
@Core.LongDescription : 'These APIs allow clients to create and delete quotes, retrieve quote data, update, approve, or edit quotes, and so on.  On top of the actions used for managing the quote itself, it is also possible to retrieve quote revisions or different entities related to the quote or the generated documents pertaining to a specific quote. In addition, these APIs allow adding, deleting, or editing the items in the quote. These APIs are used in a variety of integrations between SAP applications and represent a standard to be used in any future integrations of the SAP Configure Price Quote quote with other applications.'
service Quotes {
  @Common.Label : 'Quotes'
  @Core.Description : 'Gets quote revisions.'
  @openapi.path : '/api/v1/quotes/{quoteId}/revisions'
  function api_v1_quotes__revisions(
    @description : 'Quote ID'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteRevisionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets the documents generated from the quote.'
  @openapi.path : '/api/v1/quotes/{quoteId}/documents'
  function api_v1_quotes__documents(
    @description : 'Quote ID'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_GeneratedDocumentInfoVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets Quote''s attachments'
  @openapi.path : '/api/v1/quotes/{quoteId}/attachments'
  function api_v1_quotes__attachments(
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_AttachmentInfoVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets prepeared attachment for download'
  @openapi.path : '/api/v1/quotes/{quoteId}/attachments/{attachmentId}'
  function api_v1_quotes__attachments_(
    @description : 'Id of Quote where attachment is located'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'Id of attachment'
    @openapi.in : 'path'
    attachmentId : Integer
  ) returns Boolean;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets prepared document for download'
  @openapi.path : '/api/v1/quotes/{quoteId}/documents/{documentId}/file'
  function api_v1_quotes__documents__file(
    @description : 'Quote ID'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'Document ID'
    @openapi.in : 'path'
    documentId : Integer
  ) returns Boolean;

  @Common.Label : 'Quotes'
  @Core.Description : 'Executes the action (either standard or custom, both are supported).'
  @Core.LongDescription : ```
  The following actions don’t need additional parameters: <b>New Active Revision (actionId: 64) </b>, <b>Set Active (actionId: 15) </b>,<b>Copy (actionId: 4)</b>, <b>Delete (actionId: 2)</b>, <b>Place Order (actionId: 10)</b>, <b>Create/Update Objects From Quote Items (actionId: 2517)</b>, <b>Create Assets (actionId: 54)</b>, <b>Create Update SAP Sales Quote (actionId: 1811)</b>, <b>Create/Update Opportunity (actionId: 2500)</b>, <b>Create Custom Object From Quote (actionId: 2519)</b>, <b>CreateQuoteInCRM (actionId: 2523)</b>, <b>Detach From Opportunity (actionId: 36)</b>, <b>Upgrade to New Product Version (actionId: 51)</b>, <b>Post Quote Notes Into Account Chatter (actionId: 57)</b>, <b>Post Quote Notes Into Opportunity Chatter (actionId: 55)</b>, <b>Send Document to CRM (actionId: 1655)</b>, <b>Update SAP Opportunity (actionId: 1810)</b>, <b>Attach Document To SAP Opportunity (actionId: 1820)</b>, <b>Attach Document To SAP Sales Quote (actionId: 1821)</b>, <b>Attach Document To SAP Opportunity And Sales Quote (actionId: 1822)</b>, <b>Place order to ERP (actionId: 1823)</b>, <b>Update Sales Quote (actionId: 1825)</b>, <b>Make Primary (actionId: 73)</b> and <b>Release Quote To SAP Commerce (actionId: 1826)</b>.\r
  <br /><br />The following actions require additional parameters in the request body:\r
  <br />- <b>New Active Revision (actionId: 64) </b> should contain the <b>NewRevisionName</b> parameter. This parameter is optional, and it contains the name of the newly created revision.\r
  <br />- <b>Reassign (actionId: 6) </b> must contain the <b>NewUserId</b> parameter. This parameter is mandatory, and it contains the ID of the user to whom the quote should be assigned.\r
  <br />- <b>Change Status (actionId: 12) </b> must contain the <b>NewStatusId</b> parameter. This parameter is mandatory, and it contains the ID of the new status of the quote.\r
  <br />- <b>Integration Change Quote Status (actionId: 1922) </b> must contain the <b>NewStatusId</b> parameter. This parameter is mandatory, and it contains the ID of the new status of the quote.  <b>NewStatusId</b> must correspond with the Workflow settings. Available statuses are Order Placed, Order Created With Errors and Creating Order Failed. The Integration Change Quote Status can also contain the following optional parameters: <b>SalesOrderID</b>, which contains the ID of the sales order, and <b>RemovePreviousMessages</b>, which is a boolean (default value is false) used to remove existing error messages from the quote. The <b>ErrorMessage</b> that is logged after Creating Order Failed or Order Created With Errors is triggered from SAP Billing and Revenue Innovation Management. The message describes the issue that caused the quote synchronization to fail. \r
  <br />- <b>Order Status Update (actionId: 1923) </b> must contain the <b>SalesOrderID</b> parameter. This parameter is mandatory, and it contains the ID of the sales order.\r
  <br />- <b>Creating Order Failed (actionId: 1924) </b> must contains these parameters: <b>SalesOrderID</b> parameter is mandatory, and it contains the ID of the sales order. <b>ErrorMessage</b> that is being logged after Creating Order Failed is triggered from Billing Revenue and Innovation Management.The message describes the issue that caused the quote synchronization to fail.\r
  <br />- <b>Release Quote And Proposal To SAP Commerce (actionId: 1824) </b> must contain the <b>ProposalMessage</b> parameter. This parameter is required, and it contains the message that will be sent with the quote and the proposal.\r
  <br />- <b>Submit for Approval (actionId: 25) </b> must contain the list of approval rules. Each rule must contain these parameters: <b>Rule</b> contains the rule ID, <b>Approvers</b> contains the list of approvers (user IDs) and <b>Comment</b> contains the rule comment.\r
  <br />- <b>Approve or Reject Quote (Approve Quote Action Id: 26, Reject Quote Action Id: 27) </b> must contain the list of <b>ApproversResponsibilities</b>. Each responsibility must contain these parameters: <b>ResponsibilityId</b> contains the Responsibility ID, <b>Comment</b> contains the Responsibility comment.\r
  <br />- <b>Get Status of Placed Order (actionId: 1926) </b> must contain these parameters: <b>SalesOrderID</b> parameter is mandatory, and it contains the ID of the sales order.\r
  <br />- <b>Retract approval (actionId: 53) </b> must contain the <b>Comment</b> parameter. Payload example : { "Comment" : "some comment" }
  ```
  @openapi.path : '/api/v1/quotes/{quoteId}/actions/{actionId}/invoke'
  action api_v1_quotes__actions__invoke_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The action identifier.'
    @openapi.in : 'path'
    actionId : Integer,
    @openapi.in : 'body'
    body : { }
  ) returns Quotes_types.Webcom_API_Public_Quote_VM_NewQuoteVMResponse;

  @Common.Label : 'Quotes'
  @Core.Description : 'Executes the Quote table action (either standard or custom, both are supported).'
  @Core.LongDescription : `<br />\r
<br />The following actions require additional parameters in the request body:\r
            <br />- <b>Copy row (actionId: 34) </b> must contain the <b>RowId</b> parameter.`
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/actions/{actionId}/invoke'
  action api_v1_quotes__quoteTables__actions__invoke_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The request.'
    @openapi.in : 'path'
    tableName : String,
    @description : 'The action identifier.'
    @openapi.in : 'path'
    actionId : Integer,
    @openapi.in : 'body'
    body : { }
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Get custom actions.'
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/actions'
  function api_v1_quotes__quoteTables__actions(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The request.'
    @openapi.in : 'path'
    tableName : String
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableActionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets available standard and custom actions for the quote.'
  @openapi.path : '/api/v1/quotes/{quoteId}/actions'
  function api_v1_quotes__actions(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_WorkflowActionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Creates new quote.'
  @Core.LongDescription : ```
  If <b>MarketId</b> is not provided, the system will resolve MarketId based on provided <b>MarketCode</b> and <b>CurrencyCode</b>, if none are provided, the default market will be used for the logged in user.\r
  <b>CustomerId</b> takes priority over <b>CustomerCode</b> so if both are provided, the system disregards the <b>CustomerCode</b> and looks for the customer based on the <b>CustomerId</b>.\r
  Customer <b>RoleType</b> accepts <em>1</em> for billto customer, <em>2</em> for shipto customer, and <em>3</em> for enduser.\r
  <br /><b>PricebookId</b> takes priority over <b>DistributionChannel</b> so if both are provided, the system disregards the <b>DistributionChannel</b> and looks for the pricebook based on the <b>PricebookId</b>.\r
  SAP CPQ looks for the pricebook with the respective <b>DistributionChannel</b> in the market provided in <b>MarketId</b>.
  ```
  @openapi.path : '/api/v1/quotes'
  action api_v1_quotes_post(
    @openapi.in : 'body'
    body : Quotes_types.Webcom_API_Public_Quote_VM_QuoteVMRequest
  ) returns Quotes_types.SAP_CPQ_API_Quote_VM_CreateNewQuoteVMResponse;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get collaboration comments for the quote.'
  @openapi.path : '/api/v1/quotes/{quoteId}/comments'
  function api_v1_quotes__comments(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Post collaboration comments for the quote.'
  @openapi.path : '/api/v1/quotes/{quoteId}/comments'
  action api_v1_quotes__comments_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'body'
    body : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets the quote item comments.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/comments'
  function api_v1_quotes__items__comments(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Posts quote item comments.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/comments'
  action api_v1_quotes__items__comments_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The item identifier.'
    @openapi.in : 'path'
    itemId : Integer,
    @openapi.in : 'body'
    body : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets the quote.'
  @Core.LongDescription : `The following query parameter is supported: <br />\r
\$expand: use this parameter to specify the comma separated list of sub nodes which need to be included in the response.<br />\r
Possible value for \$expand is PricingConditions.`
  @openapi.path : '/api/v1/quotes/{quoteId}'
  function api_v1_quotes_(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns Quotes_types.Webcom_API_Public_Quote_VM_QuoteVMResponse;

  @Common.Label : 'Quotes'
  @Core.Description : 'Delete Quote'
  @Core.LongDescription : 'Deletes Quote following standard Workflow procedures.'
  @openapi.method : 'DELETE'
  @openapi.path : '/api/v1/quotes/{quoteId}'
  action api_v1_quotes__delete(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Update Quote standard and custom fields'
  @Core.LongDescription : 'All quote standard and custom fields need to be editable before sending request.<br />'
  @openapi.method : 'PATCH'
  @openapi.path : '/api/v1/quotes/{quoteId}'
  action api_v1_quotes__patch(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'body'
    body : { }
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Updates Customer standard and custom fields on Quote.'
  @Core.LongDescription : ```
  There are three types of Customers (roleId):<br />\r
   - Bill To (roleId 1) <br />\r
   - Ship To (roleId 2) <br />\r
   - End User (roleId 3) <br />\r
   \r
  Customer needs to be editable and needs to be added to Quote before sending request.<br />
  ```
  @openapi.method : 'PATCH'
  @openapi.path : '/api/v1/quotes/{quoteId}/customers/{roleId}'
  action api_v1_quotes__customers__patch(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The role identifier.'
    @openapi.in : 'path'
    roleId : Integer,
    @openapi.in : 'body'
    body : { }
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Get the items from the quote.'
  @Core.LongDescription : ```
  This endpoint supports OData filtering. <br />\r
  The following attribute properties are available to OData, and they have a specific support for the \$filter option. <br />\r
              \r
      changeprocessgroupcode - \$filter eq, ne, like\r
      contractchangeprocessingstatus - \$filter eq, lt, gt, ge, le\r
              \r
  Additional OData options are available for these properties:\r
              \r
      \$orderby={properties name} {desc/asc}\r
      \$top={number, max 100}\r
      \$skip={number}\r
      \$expand=SelectedAttributes\r
      \$expand=PricingConditions\r
      \$expand=ExternalConfigurations
  ```
  @openapi.path : '/api/v1/quotes/{quoteId}/items'
  function api_v1_quotes__items(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemSapStandardVm;

  @Common.Label : 'Quotes'
  @Core.Description : 'Add items to quote'
  @Core.LongDescription : 'If both <b>PartNumber</b> and <b>ProductSystemId</b> are provided, the system disregards the <b>PartNumber</b> and looks for the item based on the <b>ProductSystemId</b> as this field takes priority.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items'
  action api_v1_quotes__items_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'body'
    body : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemRequestVM
  ) returns many Quotes_types.SAP_CPQ_Quote_Common_DTO_RFQ_QuoteItemResponse;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get the specific item from the quote.'
  @Core.LongDescription : `The following query parameter is supported: <br />\r
\$expand: use this parameter to specify the comma separated list of sub nodes which need to be included in the response.<br />\r
Possible values for \$expand are: SelectedAttributes, PricingConditions, ExternalConfigurations.`
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}'
  function api_v1_quotes__items_(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The unique item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemSapStandardVm;

  @Common.Label : 'Quotes'
  @Core.Description : 'Delete Quote Item'
  @openapi.method : 'DELETE'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}'
  action api_v1_quotes__items__delete(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Update Quote item fields and custom fields.'
  @Core.LongDescription : ```
  All quote item fields and custom fields need to be editable before sending request.<br />\r
  \r
  Fields with invalid values are returned in the response in the following format:<br />\r
  \`\`\`\r
      {\r
          "ItemFields": {\r
              "FieldName": "ErrorMessage",\r
              "FieldName2": "ErrorMessage"\r
          }\r
       }\r
  \`\`\`\r
  Fields with valid values will be updated and not included in the response.\r
  \r
  Quote item custom fields of type Date need to be in the format "yyyy-MM-dd".
  ```
  @openapi.method : 'PATCH'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}'
  action api_v1_quotes__items__patch(
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'path'
    itemId : Integer,
    @openapi.in : 'body'
    body : { }
  ) returns Quotes_types.Webcom_API_Public_Quote_VM_ItemsUpdateResponse;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets product types'
  @Core.LongDescription : ```
  The following properties are available for pagination: <br />\r
              \r
       \$orderby={properties name} {desc/asc}\r
       \$top={number} {default is 10, max is 100}\r
       \$skip={number}
  ```
  @openapi.path : '/api/v1/quotes/{quoteId}/productTypes'
  function api_v1_quotes__productTypes(
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_ProductTypeVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets product types count'
  @openapi.path : '/api/v1/quotes/{quoteId}/productTypes/$count'
  function api_v1_quotes__productTypes__count(
    @openapi.in : 'path'
    quoteId : Integer
  ) returns Integer;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get Quote Table'
  @Core.LongDescription : ```
  The following properties are available for pagination: <br />\r
              \r
       \$top={number} {default is 10}\r
       \$skip={number} {default is 0)
  ```
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/rows'
  function api_v1_quotes__quoteTables__rows(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The quote table name.'
    @openapi.in : 'path'
    tableName : String
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Inserts new row in quote table.'
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/rows'
  action api_v1_quotes__quoteTables__rows_post(
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'path'
    tableName : String,
    @openapi.in : 'body'
    body : many Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableRowRequest
  ) returns Quotes_types.SAP_CPQ_API_Quote_VM_QuoteTableRowGenericResponseVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Delete Quote Table Row'
  @openapi.method : 'DELETE'
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/rows/{rowId}'
  action api_v1_quotes__quoteTables__rows__delete(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The quote table name.'
    @openapi.in : 'path'
    tableName : String,
    @description : 'The row id'
    @openapi.in : 'path'
    rowId : Integer
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Updates single row in quote table.'
  @openapi.method : 'PATCH'
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/rows/{rowId}'
  action api_v1_quotes__quoteTables__rows__patch(
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'path'
    tableName : String,
    @openapi.in : 'path'
    rowId : Integer,
    @openapi.in : 'body'
    body : many Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableCellRequestObject
  ) returns Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get Quote Table'
  @openapi.path : '/api/v1/quotes/{quoteId}/quoteTables/{tableName}/rows/$count'
  function api_v1_quotes__quoteTables__rows__count(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The quote table name.'
    @openapi.in : 'path'
    tableName : String
  ) returns Integer;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get the items count from the quote.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/$count'
  function api_v1_quotes__items__count(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns Integer;

  @Common.Label : 'Quotes'
  @Core.Description : 'Get the selected attributes for the quote item.'
  @Core.LongDescription : 'Gets all attributes on an item, including those without a selected attribute value. The Values node is populated with the selected attribute values.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/selectedAttributes'
  function api_v1_quotes__items__selectedAttributes(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The unique item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_SelectedAttributesVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets quote item pricing conditions.'
  @Core.LongDescription : 'An array of pricing conditions or empty array if quote item field to pricing condition mappings are not defined for quote pricing procedure.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/pricingConditions'
  function api_v1_quotes__items__pricingConditions(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The unique item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_PricingConditionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets quote header pricing conditions.'
  @Core.LongDescription : 'An array of pricing conditions or empty array if quote header field to pricing condition mappings are not defined for quote pricing procedure.'
  @openapi.path : '/api/v1/quotes/{quoteId}/pricingConditions'
  function api_v1_quotes__pricingConditions(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_PricingConditionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets the involved parties on the quote.'
  @Core.LongDescription : 'Gets the details of all involved parties on the quote (for example, partner function ID and key, partner function name, business partner ID, and so on).'
  @openapi.path : '/api/v1/quotes/{quoteId}/involvedParties'
  function api_v1_quotes__involvedParties(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Adds the involved party to the specified quote.'
  @Core.LongDescription : ```
  If the partner function with the specified key exists in the <b>Setup</b>, the system searches for the business partner with the business partner ID specified in the body. If there is a business partner with that ID in the <b>Setup</b>, the system uses it to create the involved party. The details of the business partner defined in the <b>Setup</b> are overwritten on the quote with the details sent in the body. If there aren't any business partners with that ID in the <b>Setup</b>, an adequate response is sent.\r
  <br /><br />If the body of the request doesn’t contain the business partner ID, the system uses the partner ID to find the business partner. If there is a business partner with the matching partner ID in the <b>Setup</b>, the system uses it to create the involved party. The details of the business partner defined in the <b>Setup</b> are overwritten on the quote with the details sent in the body.\r
  <br /><br />If there is a matching business partner ID in the <b>Setup</b>, but the partner ID from the body doesn’t match any of the partner IDs in the <b>Setup</b>, the system overwrites the partner ID of the business partner with the ID from the body.\r
  <br /><br />If the body of the request doesn’t contain the business partner ID nor the partner ID, the system uses the external ID to find the business partner. If there is a business partner with the matching external ID in the <b>Setup</b>, the system uses it to create the involved party. The details of the business partner defined in the <b>Setup</b> are overwritten on the quote with the details sent in the body.\r
  <br /><br />If there is a matching business partner ID and partner ID in the <b>Setup</b>, but the external ID from the body doesn’t match any of the external IDs in the <b>Setup</b>, the system overwrites the external ID of the business partner with the ID from the body.\r
  <br /><br />If the request body doesn’t contain the business partner ID nor the partner ID nor the external ID, the system creates a new business partner on the quote with the details sent in the body. This scenario is applicable only if the <b>Allow adding business partners on quotes without creating them first in Setup</b> parameter is enabled in the tenant.
  ```
  @openapi.path : '/api/v1/quotes/{quoteId}/involvedParties'
  action api_v1_quotes__involvedParties_post(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @openapi.in : 'body'
    body : Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyVM
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Deletes involved party.'
  @Core.LongDescription : 'Removes the involved party from the quote, while the business partner and the partner function remain unchanged in the Setup.'
  @openapi.method : 'DELETE'
  @openapi.path : '/api/v1/quotes/{quoteId}/involvedParties/{involvedPartyId}'
  action api_v1_quotes__involvedParties__delete(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The involved party identifier.'
    @openapi.in : 'path'
    involvedPartyId : Integer
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Updates involved party.'
  @Core.LongDescription : `Updates the partner function and business partner details on the quote while they stay unchanged in the Setup. You can't create new business partners through this API, you can only update the existing ones.\r
Names of custom fields must be prefixed with 'cf_' like  'cf_CustomFieldName'`
  @openapi.method : 'PATCH'
  @openapi.path : '/api/v1/quotes/{quoteId}/involvedParties/{involvedPartyId}'
  action api_v1_quotes__involvedParties__patch(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The involved party identifier.'
    @openapi.in : 'path'
    involvedPartyId : Integer,
    @openapi.in : 'body'
    body : { }
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets available actions for quote item.'
  @Core.LongDescription : 'Gets the list of available quote item actions. If the quote Id and item Id exist, user gets the list of available actions with status 200.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/actions'
  function api_v1_quotes__items__actions(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The unique item identifier.'
    @openapi.in : 'path'
    itemId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_WorkflowItemActionVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Invokes selected actions on quote item'
  @Core.LongDescription : 'Executes quote item action. In case the quote, item and action Id exist, action is successfully executed with status 200.'
  @openapi.path : '/api/v1/quotes/{quoteId}/items/{itemId}/actions/{actionId}/invoke'
  action api_v1_quotes__items__actions__invoke_post(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer,
    @description : 'The unique item identifier.'
    @openapi.in : 'path'
    itemId : Integer,
    @description : 'The unique action identifier.'
    @openapi.in : 'path'
    actionId : Integer
  );

  @Common.Label : 'Quotes'
  @Core.Description : 'Get quote approval history.'
  @Core.LongDescription : 'If there is no approval history on the quote, the payload is empty and the response is Status 200.'
  @openapi.path : '/api/v1/quotes/{quoteId}/approvals/history'
  function api_v1_quotes__approvals_history(
    @description : 'The unique quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_ApprovalHistoryVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets broken rules.'
  @Core.LongDescription : 'Gets the approval rules broken by user that''s logged in. If there are no broken rules, the payload is empty and the response is Status 200.'
  @openapi.path : '/api/v1/quotes/{quoteId}/approvals'
  function api_v1_quotes__approvals(
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_ApprovalVM;

  @Common.Label : 'Quotes'
  @Core.Description : 'Gets broken rules ready for approval.'
  @Core.LongDescription : 'List of IDs of broken approval rules that the logged in user needs to approve or reject. If there are no approval rules, the payload is empty and the response is Status 200.'
  @openapi.path : '/api/v1/quotes/{quoteId}/approvals/responsibilities'
  function api_v1_quotes__approvals_responsibilities(
    @description : 'The quote identifier.'
    @openapi.in : 'path'
    quoteId : Integer
  ) returns many Quotes_types.Webcom_API_Public_Quote_VM_ApproversResponsibilityVM;
};

@description : 'Quote revision'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteRevisionVM {
  @description : 'Quote ID'
  QuoteId : String;
  @description : 'Owner ID'
  OwnerId : String;
  @description : 'Name of revision'
  Name : String;
  @description : 'Description'
  Description : String;
  @description : 'Date when quote revision was created'
  DateCreated : String;
  @description : 'Date when quote revision was last modified'
  DateModified : String;
  @description : 'Revision number'
  RevisionNumber : Integer;
  @description : 'Parent revision'
  ParentRevision : String;
  @description : 'Is revision active'
  IsActive : Boolean;
  @description : 'Status info'
  Status : Quotes_types.Webcom_API_Public_Quote_VM_QuoteStatusVM;
  @description : 'Market info'
  Market : Quotes_types.Webcom_API_Public_Quote_VM_MarketVM;
  @description : 'Total amount info'
  TotalAmount : Quotes_types.Webcom_API_Public_Quote_VM_TotalAmountVM;
};

@description : 'Quote status'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteStatusVM {
  Id : Integer;
  Name : String;
};

@description : 'Market info'
type Quotes_types.Webcom_API_Public_Quote_VM_MarketVM {
  @description : 'Market ID'
  Id : Integer;
  @description : 'Market name'
  Name : String;
};

@description : 'Total amount info'
type Quotes_types.Webcom_API_Public_Quote_VM_TotalAmountVM {
  @description : 'Currency code'
  CurrencyCode : String;
  @description : 'Total amount value'
  Value : String;
  @description : '{CurrencySign}{Value} example: $500.00'
  FormattedValue : String;
};

type Quotes_types.Webcom_API_Public_Quote_VM_GeneratedDocumentInfoVM {
  @description : 'Generated document ID'
  DocumentId : Integer;
  @description : 'Name of the file'
  Filename : String;
  @description : 'Size of file in KB'
  Filesize : String;
  @description : 'Date of generated document'
  DateCreated : String;
};

@description : 'Quote attachment view model'
type Quotes_types.Webcom_API_Public_Quote_VM_AttachmentInfoVM {
  @description : 'Gets or sets the identifier.'
  Id : Integer;
  @description : 'Gets or sets the name of the file.'
  FileName : String;
  @description : 'Gets or sets the date created.'
  DateCreated : String;
};

type Quotes_types.Webcom_API_Public_Quote_VM_NewQuoteVMResponse {
  NewQuoteId : Integer;
};

@description : 'Quote Table Action VM'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableActionVM {
  @description : 'The identifier.'
  Id : Integer;
  @description : 'Name of action.'
  Name : String;
};

@description : 'Workflow action view model'
type Quotes_types.Webcom_API_Public_Quote_VM_WorkflowActionVM {
  @description : 'The identifier.'
  Id : Integer;
  @description : 'Name of action.'
  Name : String;
  @description : 'System ID.'
  SystemId : String;
};

@description : 'The Quote Request'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteVMRequest {
  @description : 'Get or set external id.'
  ExternalId : String;
  @description : 'Get or set external system id.'
  ExternalSystemId : String;
  @description : 'Get or set market id.'
  MarketId : Integer;
  @description : 'Gets or sets market code.'
  MarketCode : String;
  @description : 'Gets or sets Currency Code'
  CurrencyCode : String;
  @description : 'Get or sets pricebook id.'
  PricebookId : Integer;
  @description : 'Get or set distribution channel.'
  DistributionChannel : String;
  @description : 'Get or set global comment.'
  GlobalComment : String;
  @description : 'Get or set origin.'
  Origin : String;
  @description : 'Get or set opportunity identifier'
  OpportunityId : String;
  @description : 'Get or set opportunity name'
  OpportunityName : String;
  @description : 'Get or set opportunity to be primary'
  IsPrimary : Boolean;
  @description : 'Get or set error message'
  ErrorMessage : String;
  @description : 'List of collaboration comments.'
  Comments : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentRequestVM;
  @description : 'List of customers.'
  Customers : many Quotes_types.Webcom_API_Public_Quote_VM_CustomerRequestVM;
  @description : 'List of custom fields.'
  CustomFields : many Quotes_types.Webcom_API_Public_Quote_VM_CustomFieldVM;
  @description : 'List of quote''s items.'
  Items : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemRequestVM;
  @description : 'Gets or sets the involved parties.'
  InvolvedParties : many Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyVM;
  @description : 'Gets or sets the quote tables.'
  QuoteTables : many Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableRequest;
};

@description : 'Quote Comment Request view model'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentRequestVM {
  @description : 'User Full Name.'
  UserFullName : String;
  @description : 'User Email.'
  UserEmail : String;
  @description : 'User Company'
  UserCompany : String;
  @description : 'Comment text'
  Comment : String;
  @description : 'Comment creator'
  Source : Integer;
};

@description : 'Customer Request view model'
type Quotes_types.Webcom_API_Public_Quote_VM_CustomerRequestVM {
  @description : 'Gets or sets Id'
  Id : Integer;
  @description : 'Get or set Customer Code'
  CustomerCode : String;
  @description : 'Get or set Role Type'
  RoleType : String;
};

@description : 'Quote Item Request'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemRequestVM {
  @description : 'Gets or sets the quantity.'
  Quantity : Integer;
  @description : 'Gets or sets the part number.'
  PartNumber : String;
  @description : 'Gets or sets the product system identifier.'
  ProductSystemId : String;
  @description : 'Gets or sets the configuration identifier.'
  @Core.Example.$Type : 'Core.PrimitiveExampleValue'
  @Core.Example.Value : '00000000-0000-0000-0000-000000000000'
  ConfigurationId : UUID;
  @description : 'Gets or sets the external item identifier.'
  ExternalConfigurationId : String;
  @description : 'Quote Item Comments'
  Comments : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM;
};

@description : 'Involved party view model'
type Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyVM {
  @description : 'Partner Function Id'
  PartnerFunctionId : Integer;
  @description : 'Partner Function Key'
  PartnerFunctionKey : String;
  @description : 'Partner Function Name'
  PartnerFunctionName : String;
  @description : 'Business Partner Id'
  BusinessPartnerId : Integer;
  @description : 'External Id'
  ExternalId : String;
  @description : 'Name'
  Name : String;
  @description : 'First Name'
  FirstName : String;
  @description : 'Last Name'
  LastName : String;
  @description : 'Country'
  Country : String;
  @description : 'State'
  State : String;
  @description : 'Region'
  Region : String;
  @description : 'City Name'
  CityName : String;
  @description : 'Postal Code'
  PostalCode : String;
  @description : 'Time Zone'
  TimeZone : String;
  @description : 'Address Name'
  AddressName : String;
  @description : 'Address Additional Name'
  AddressAdditionalName : String;
  @description : 'Email Address'
  EmailAddress : String;
  @description : 'Phone'
  Phone : String;
  @description : 'VAT Number'
  VATNumber : String;
  @description : 'Tax Number 1'
  TaxNumber1 : String;
  @description : 'Tax Number 1'
  TaxNumber2 : String;
  @description : 'Fax'
  Fax : String;
  @description : 'Bank Account 1'
  BankAccount1 : String;
  @description : 'Bank Account 2'
  BankAccount2 : String;
  @description : 'Primary Industry'
  PrimaryIndustry : String;
  @description : 'System Id'
  SystemId : String;
  @description : 'Identifier (auto-increment)'
  Id : Integer;
  @description : 'Partner ID'
  PartnerId : String;
  @description : 'The form of address.'
  FormOfAddress : String;
  @description : 'The address name 3.'
  AddressName3 : String;
  @description : 'The address name 4.'
  AddressName4 : String;
  @description : 'The tax jurisdiction.'
  TaxJurisdiction : String;
  @description : 'The PO box postal code.'
  POBoxPostalCode : String;
  @description : 'The PO box.'
  POBox : String;
  @description : 'The district.'
  District : String;
  @description : 'The street prefix name.'
  StreetPrefixName : String;
  @description : 'The additional street prefix name.'
  AdditionalStreetPrefixName : String;
  @description : 'The street name.'
  StreetName : String;
  @description : 'The street suffix name.'
  StreetSuffixName : String;
  @description : 'The additional street suffix name.'
  AdditionalStreetSuffixName : String;
  @description : 'The house number.'
  HouseNumber : String;
  @description : 'The transport zone.'
  TransportZone : String;
  @description : 'The correspondence language.'
  CorrespondenceLanguage : String;
  @description : 'The mobile phone.'
  MobilePhone : String;
  @description : 'The partner number.'
  PartnerNumber : String;
  @description : 'List of custom fields'
  InvolvedPartyCustomFields : many Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyCustomFieldVM;
};

type Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableRequest {
  Name : String;
  Rows : many Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableRowRequest;
};

@description : 'View model for Custom Fields on Involved Parties'
type Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyCustomFieldVM {
  @description : 'Custom field name'
  Name : String;
  @description : 'Custom field value'
  Value : String;
};

type Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableRowRequest {
  Cells : many Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableCellRequestObject;
};

type Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableCellRequestObject {
  ColumnName : String;
  Value : { };
};

@description : 'Create New Quote Response'
type Quotes_types.SAP_CPQ_API_Quote_VM_CreateNewQuoteVMResponse {
  @description : 'The quote identifier.'
  QuoteId : Integer;
  @description : 'The quote number.'
  QuoteNumber : String;
};

@description : 'Quote Response'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteVMResponse {
  @description : 'The quote identifier.'
  QuoteId : Integer;
  @description : 'Gets or sets the comment.'
  Comment : String;
  @description : 'Gets or sets the date created.'
  DateCreated : String;
  @description : 'Gets or sets the date modified.'
  DateModified : String;
  @description : 'Gets or sets the date ordered.'
  DateOrdered : String;
  @description : 'Gets or sets the date closed.'
  DateClosed : String;
  @description : 'Gets or sets the effective date.'
  EffectiveDate : String;
  @description : 'Gets or sets the external identifier.'
  ExternalId : String;
  @description : 'Gets or sets the external system identifier.'
  ExternalSystemId : String;
  @description : 'Gets or sets the market code.'
  MarketCode : String;
  @description : 'Gets or sets the currency code.'
  CurrencyCode : String;
  @description : 'Gets or sets the market identifier.'
  MarketId : Integer;
  @description : 'Gets or sets the origin.'
  Origin : String;
  @description : 'Gets or sets the owner identifier.'
  OwnerId : Integer;
  @description : 'Gets or sets the price book identifier.'
  PriceBookId : Integer;
  @description : 'Gets or sets the distribution channel.'
  DistributionChannel : String;
  @description : 'Gets or sets the status identifier.'
  StatusId : Integer;
  @description : 'Gets or sets the name of the status.'
  StatusName : String;
  @description : 'Gets or sets the quote number.'
  QuoteNumber : String;
  @description : 'Gets or sets the name of the revision.'
  RevisionNumber : String;
  @description : 'Get or set opportunity identifier'
  OpportunityId : String;
  @description : 'Get or set opporutnity name'
  OpportunityName : String;
  @description : 'Get or set opportunity to be primary'
  IsPrimary : Boolean;
  @description : 'Get or set errror message'
  ErrorMessage : String;
  @description : 'Gets or sets the customers.'
  Customers : many Quotes_types.Webcom_API_Public_Quote_VM_CustomerVM;
  @description : 'Gets or sets the comments.'
  Comments : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM;
  @description : 'Gets or sets the involved parties.'
  InvolvedParties : many Quotes_types.Webcom_API_Public_Quote_VM_InvolvedPartyVM;
  @description : 'Gets or sets the quote tables.'
  QuoteTables : many String;
  @description : 'Gets or sets the custom fields.'
  CustomFields : many Quotes_types.Webcom_API_Public_Quote_VM_CustomFieldVM;
  @description : 'Gets or sets the total amount.'
  TotalAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total MRC amount.'
  TotalMrcAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total list price.'
  TotalListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total MRC list price.'
  TotalMRCListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total net price.'
  TotalNetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total MRC net price.'
  TotalMRCNetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the cost.'
  Cost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total MRC cost.'
  TotalMRCCost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total product discount amount.'
  TotalProductDiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the total MRC product discount amount.'
  TotalMRCProductDiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the average product discount percent.'
  AverageProductDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the average MRC product discount percent.'
  AverageMRCProductDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the average gross margin percent.'
  AverageGrossMarginPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the average MRC gross margin percent.'
  AverageMRCGrossMarginPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the order id'
  OrderId : String;
  @description : 'Gets or sets the Recurring Net Price Monthly.'
  RecurringNetPriceMonthly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring Net Price Yearly.'
  RecurringNetPriceYearly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring Cost Monthly.'
  RecurringCostMonthly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring Cost Yearly.'
  RecurringCostYearly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring Discount Amount Monthly.'
  RecurringDiscountAmountMonthly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring Discount Amount Yearly.'
  RecurringDiscountAmountYearly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring List Price Monthly.'
  RecurringListPriceMonthly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Recurring List Price Yearly.'
  RecurringListPriceYearly : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the Estimated Contract Total Value.'
  EstimatedContractTotalValue : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Gets or sets the pricing conditions.'
  PricingConditions : many Quotes_types.Webcom_API_Public_Quote_VM_PricingConditionVM;
  @description : 'Get or set the division'
  Division : String;
};

@description : 'Price view model, powered by SAP API standard.'
type Quotes_types.Webcom_API_Public_Quote_VM_PriceVm {
  @description : 'Price value.'
  Value : String;
  @description : 'Currency code value.'
  Currency : String;
  @description : 'Period value.'
  Period : String;
  @description : 'The PriceUnit node is visible only when the integration with SAP Variant Configuration and Pricing is enabled.'
  PriceUnit : Quotes_types.Webcom_API_Public_Quote_VM_PriceUnitVm;
};

@description : 'Pricing condition data.'
type Quotes_types.Webcom_API_Public_Quote_VM_PricingConditionVM {
  @description : 'Get or set Pricing Procedure Step.'
  PricingProcedureStep : Integer;
  @description : 'Get or set Pricing Procedure Step Counter.'
  PricingProcedureStepCounter : Integer;
  @description : 'Get or set Condition Base.'
  ConditionBase : String;
  @description : 'Get or set Condition Type.'
  ConditionType : String;
  @description : 'Get or set Condition Type Description.'
  ConditionTypeDescription : String;
  @description : 'Get or set Condition Rate.'
  ConditionRate : String;
  @description : 'Get or set Condition Value.'
  ConditionValue : String;
  @description : 'Get or set Condition Currency.'
  ConditionCurrency : String;
  @description : 'Get or set Condition Unit.'
  ConditionUnit : String;
  @description : 'Get or set Condition Unit Quantity.'
  ConditionUnitQuantity : String;
  @description : 'Get or set whether condition is variant.'
  IsVariantCondition : Boolean;
};

type Quotes_types.SAP_CPQ_Quote_Common_DTO_RFQ_QuoteItemResponse {
  Id : Integer;
  ExternalItemId : String;
  ParentItemId : Integer;
  IsMainItem : Boolean;
  Description : String;
};

@description : 'View model for quote item.'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteItemSapStandardVm {
  @description : 'Get or set Item Id'
  ItemId : Integer;
  @description : 'Get or set item raning number in the quote'
  ItemNumber : Integer;
  @description : 'Get or set Parent Item Id'
  ParentItemId : Integer;
  @description : 'Get or set parent Rolled Up Item number.'
  ParentRolledUpItemNumber : String;
  @description : 'Get or set parent item raning number in the quote'
  ParentItemNumber : Integer;
  @description : 'Get or set Rolled Up Item Number. This is item ID that users see on a quote, which takes into account items hierarchy. For example: 1.1.1.'
  RolledUpItemNumber : String;
  @description : 'Gets or sets item ID from an external system where the item is sourced from'
  ExternalItemId : String;
  @description : 'Get or set Date Added'
  DateAdded : String;
  @description : 'Get or set Description'
  Description : String;
  @description : 'Get or set Description Long'
  DescriptionLong : String;
  @description : 'Get or set Display Type'
  DisplayType : String;
  @description : 'Get or set Is Line Item'
  IsLineItem : Boolean;
  @description : 'Get or set Is Main Item'
  IsMainItem : Boolean;
  @description : 'Get or set Is Optional item'
  IsOptional : Boolean;
  @description : 'Get or set Is Variant'
  IsVariant : Boolean;
  @description : 'Get or set Is Alternative'
  IsAlternative : Boolean;
  @description : 'Get or set Is Subscription Item'
  IsSubscriptionItem : Boolean;
  @description : 'Get or set Item Type'
  ItemClassificationType : String;
  @description : 'Get or set Item Type'
  ItemType : String;
  @description : 'Get or set Quantity'
  Quantity : String;
  @description : 'Get or set Unit of Measure code'
  UnitOfMeasure : String;
  @description : 'Get or set Part Number'
  PartNumber : String;
  @description : 'Get or set Product System Id'
  ProductSystemId : String;
  @description : 'Get or set Product External Id'
  ProductExternalId : String;
  @description : 'Get or set Product Id'
  ProductId : Integer;
  @description : 'Get or set Product Name'
  ProductName : String;
  @description : 'Get or set Product Name Translated'
  ProductNameTranslated : String;
  @description : 'Get or set Product Type Id'
  ProductTypeId : Integer;
  @description : 'Get or set Product Type Name'
  ProductTypeName : String;
  @description : 'Get or set Product Type Name Translated'
  ProductTypeNameTranslated : String;
  @description : 'Get or set item comment'
  Comment : String;
  @description : 'Returns team collaboration comments'
  CollaborationComments : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM;
  @description : 'Get or set Pricing Details'
  PricingDetails : Quotes_types.Webcom_API_Public_Quote_VM_FixedAndRecurringPricingSapStandardVm;
  @description : 'Get or set Subscription Details'
  SubscriptionDetails : Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionDetailsVM;
  @description : 'Get or set quote item Custom Fields'
  CustomFields : many Quotes_types.Webcom_API_Public_Quote_VM_CustomFieldVM;
  @description : 'Get or set Configuration Id'
  ConfigurationId : String;
  @description : 'Get or set External Configuraiton Id'
  ExternalConfigurationId : String;
  @description : 'Get or set Synced From Back Office'
  SyncedFromBackOffice : Boolean;
  @description : 'Get or set Contract Duration Value'
  ContractDurationValue : String;
  @description : 'Get or set Contract Duration Unit'
  ContractDurationUnit : String;
  @description : 'Get or set Contract Start Date'
  ContractStartDate : String;
  @description : 'Get or set Contract End Date'
  ContractEndDate : String;
  @description : 'Get or set Billing Cycle'
  BillingCycle : String;
  @description : 'Get or set Billing Cycle Code'
  BillingCycleCode : String;
  @description : 'Get or set Service Profile Value'
  ServiceProfileValue : String;
  @description : 'Get or set Service Profile Code'
  ServiceProfileCode : String;
  @description : 'Get or set Service Profile Price'
  ServiceProfilePrice : Double;
  @description : 'Get or set Response Profile Value'
  ResponseProfileValue : String;
  @description : 'Get or set Response Profile Code'
  ResponseProfileCode : String;
  @description : 'Get or set Response Profile Price'
  ResponseProfilePrice : Double;
  @description : 'Get or set Service Contract Duration Value'
  ServiceContractDurationValue : String;
  @description : 'Get or set Service Contract Duration Unit'
  ServiceContractDurationUnit : String;
  @description : 'Get or set Settlement Period'
  SettlementPeriodValue : String;
  @description : 'Get or set Settlement Period Code'
  SettlementPeriodCode : String;
  @description : 'Get or set Billing Date Value'
  BillingDateValue : String;
  @description : 'Get or set Billing Date Code'
  BillingDateCode : String;
  @description : 'Get or set Estimated Total Contract Value'
  EstimatedTotalContractValue : String;
  @description : 'Get or set item selected attributes'
  SelectedAttributes : many Quotes_types.Webcom_API_Public_Quote_VM_SelectedAttributesVM;
  @description : 'Get or set item pricing conditions'
  PricingConditions : many Quotes_types.Webcom_API_Public_Quote_VM_PricingConditionVM;
  @description : 'Get or set external configuration item id'
  ExternalConfigurationItemId : Integer;
  @description : 'Get or set external configuration'
  ExternalConfiguration : String;
  @description : 'Gets or sets the subscription contract number.'
  SubscriptionContractNumber : String;
  @description : 'Gets or sets the subscription contract item number.'
  SubscriptionContractItemNumber : String;
  @description : 'Gets or sets the change process group code.'
  ChangeProcessGroupCode : String;
  @description : ```
  Gets or sets the contract change processing status.\r
  Applicable only to items relate to contract changes, possible values are:\r
  -1 - Error\r
  0 - Unknown\r
  1 - Sucessfull
  ```
  ContractChangeProcessingStatus : Integer;
  @description : 'Contract auto renewal indicator'
  ContractAutoRenewalIndicator : Boolean;
  @description : 'Contract extension'
  ContractExtensionPeriodValue : Integer;
  @description : 'Contract extension unit'
  ContractExtensionPeriodUnit : String;
  @description : 'Subscription contract cancellation id'
  CancellationId : Integer;
  @description : 'Subscription contract cancellation description'
  CancellationDescription : String;
  @description : 'Subscription contract cancelling party code'
  CancellingParty : String;
  @description : 'Subscription contract cancellation reason code'
  CancellationReason : String;
  @description : 'Subscription contract cancellation procedure code'
  CancellationProcedure : String;
  @description : 'Subscription contract cancellation request date'
  CancellationRequestDate : String;
  @description : ```
  Order item type of item product:\r
  0 - Sales\r
  1 - Subscription\r
  2 - Subscription Billing\r
  4 - Service contract
  ```
  OrderItemType : Integer;
  @description : 'Gets or sets the subscription contract document number.'
  SubscriptionContractDocumentNumber : String;
  @description : 'Get or set Contract Change Activation Date'
  ContractChangeActivationDate : String;
  @description : ```
  Product configuration type.\r
  0 - Standard\r
  1 - Variant\r
  2 - External
  ```
  ConfigurationType : Integer;
};

@description : 'Composition of fixed and recurring pricing details'
type Quotes_types.Webcom_API_Public_Quote_VM_FixedAndRecurringPricingSapStandardVm {
  @description : 'Get or set Fixed pricing'
  Fixed : Quotes_types.Webcom_API_Public_Quote_VM_PricingDetailsSapStandardVm;
  @description : 'Get or set Recurring pricing'
  Recurring : Quotes_types.Webcom_API_Public_Quote_VM_PricingDetailsSapStandardVm;
};

@description : 'SelectedAttributesVM'
type Quotes_types.Webcom_API_Public_Quote_VM_SelectedAttributesVM {
  @description : 'Attribute ID'
  Id : Integer;
  @description : 'Attribute System ID'
  SystemId : String;
  @description : 'Data type for attribute values'
  ValueDataType : String;
  @description : 'Attribute values'
  Values : many Quotes_types.Webcom_API_Public_Quote_VM_SelectedAttributeValuesVM;
  @description : 'Get or set Synced From Back Office'
  SyncedFromBackOffice : Boolean;
};

@description : 'Data of item pricing'
type Quotes_types.Webcom_API_Public_Quote_VM_PricingDetailsSapStandardVm {
  @description : 'Get or set List Price. This is a unit price of an item before applying discount and multiplying by quantity.'
  ListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Net Price. This is item unit price after applying discount.'
  NetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Extended List Price. This is unit item price multiplied by quantity.'
  ExtendedListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Extended Price. This is total item price after applying quantity, discount and multiplier.'
  ExtendedAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Discount Percent.'
  DiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Default Discount Percent'
  DefaultDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Min Discount Percent'
  MinDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Max Discount Percent'
  MaxDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Unit Discount Amount. This is discount amount per item unit.'
  UnitDiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Discount Amount. This is total discount amount for an item.'
  DiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Cost. This is item unit cost.'
  Cost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Extended Cost. This is item cost multiplied by quantity.'
  ExtendedCost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Margin Percent'
  MarginPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Rolled Up List Price'
  RolledUpListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Rolled Up Net Price'
  RolledUpNetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Rolled Up Extended List Price'
  RolledUpExtendedListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Rolled Up Extended Amount'
  RolledUpExtendedAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set RolledUp Discount Percent'
  RolledUpDiscountPercent : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set RolledUp Discount Amount'
  RolledUpDiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set Rolled Up Margin Percent'
  RolledUpGrossMargin : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set RolledUp Cost'
  RolledUpCost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Get or set RolledUp Extended Cost'
  RolledUpExtendedCost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
};

type Quotes_types.Webcom_API_Public_Quote_VM_SelectedAttributeValuesVM {
  @description : 'Attribute value or value code'
  Value : String;
  @description : 'Value of attribute''s System ID'
  SystemId : String;
  @description : 'Attribute quantity'
  Quantity : Double;
  @description : 'Attribute contract duration unit'
  ContractDurationUnit : String;
  @description : 'Attribute billing period'
  BillingPeriod : String;
  @description : 'Variant condition key in case of CPS attribute values'
  VariantConditionKey : String;
  @description : 'Variant condition key factor in case of CPS attribute values'
  VariantConditionKeyFactor : Double;
  @description : 'Author in case of CPS attribute values'
  Author : String;
};

type Quotes_types.Webcom_API_Public_Quote_VM_ItemsUpdateResponse {
  @description : 'Gets or sets the item fields.'
  ItemFields : { };
};

@description : 'Product Type VM'
type Quotes_types.Webcom_API_Public_Quote_VM_ProductTypeVM {
  @description : 'Gets or sets the custom fields.'
  CustomFields : { };
  @description : 'Product Type Id'
  ProductTypeId : Integer;
  @description : 'Product Type Name'
  ProductTypeName : String;
  @description : 'List Price'
  ListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Discount Percent'
  DiscountPercent : Double;
  @description : 'Discount Amount'
  DiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Net Price'
  NetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Cost'
  Cost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Mrc List Price'
  MrcListPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Mrc Cost'
  MrcCost : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Mrc Discount Percent'
  MrcDiscountPercent : Double;
  @description : 'Mrc Discount Amount'
  MrcDiscountAmount : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Mrc Net Price'
  MrcNetPrice : Quotes_types.Webcom_API_Public_Quote_VM_PriceVm;
  @description : 'Min Discount Percent'
  MinDiscountPercent : Double;
  @description : 'Max Discount Percent'
  MaxDiscountPercent : Double;
  @description : 'Default Discount Percent'
  DefaultDiscountPercent : Double;
  @description : 'Min Mrc Discount Percent'
  MinMrcDiscountPercent : Double;
  @description : 'Max Mrc Discount Percent'
  MaxMrcDiscountPercent : Double;
  @description : 'Default Mrc Discount Percent'
  DefaultMrcDiscountPercent : Double;
  @description : 'Gross Margin Percent'
  GrossMarginPercent : Double;
  @description : 'Mrc Gross Margin Percent'
  MrcGrossMarginPercent : Double;
};

@description : 'QuoteTableRowVM class'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowVM {
  @description : 'Get or set Id'
  Id : Integer;
  @description : 'Get or set cells'
  Cells : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowVM_QuoteTableCellObjectVM;
};

type Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowVM_QuoteTableCellObjectVM {
  @description : 'Get or set column name'
  ColumnName : String;
  @description : 'Get or set value'
  Value : { };
  @description : 'Get or set currency powered by SAP standard'
  Currency : String;
};

@description : 'Generic API response with list of objects'
type Quotes_types.Webcom_API_Common_Models_GenericResponse_Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM_ {
  List : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM;
};

@description : 'Row Response class'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM {
  Request : Quotes_types.SAP_CPQ_Quote_Common_DTO_QuoteTableCellRequestObject;
  @description : 'Value'
  ErrorMessage : String;
};

type Quotes_types.SAP_CPQ_API_Quote_VM_QuoteTableRowGenericResponse {
  List : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM;
};

@description : 'Workflow action view model'
type Quotes_types.Webcom_API_Public_Quote_VM_WorkflowItemActionVM {
  @description : 'The identifier.'
  Id : Integer;
  @description : 'Name of action.'
  Name : String;
};

@description : 'Approval history view model'
type Quotes_types.Webcom_API_Public_Quote_VM_ApprovalHistoryVM {
  @description : 'Gets or sets the status.'
  Status : String;
  @description : 'Gets or sets the submition date.'
  SubmitionDate : String;
  @description : 'Gets or sets the submitted by.'
  SubmittedBy : String;
  @description : 'Gets or sets the approval rule.'
  ApprovalRule : String;
  @description : 'Gets or sets the description.'
  Description : String;
  @description : 'Gets or sets the performed by.'
  PerformedBy : String;
  @description : 'Gets or sets the approver.'
  Approver : String;
  @description : 'Gets or sets the resolving date.'
  ResolvingDate : String;
  @description : 'Gets or sets the comment.'
  Comment : String;
};

type Quotes_types.Webcom_API_Public_Quote_VM_ApprovalVM {
  @description : 'Gets or sets the identifier.'
  Id : Integer;
  @description : 'Gets or sets the name of the rule.'
  RuleName : String;
  @description : 'Gets or sets the description.'
  Description : String;
  @description : 'Gets or sets the message.'
  CanChooseApprover : String;
  @description : 'Gets or sets the responsible approvers.'
  ResponsibleApprovers : many Quotes_types.Webcom_API_Public_Quote_VM_ResponsibleApproverVM;
};

type Quotes_types.Webcom_API_Public_Quote_VM_ResponsibleApproverVM {
  @description : 'Gets or sets the identifier.'
  Id : Integer;
  @description : 'Gets or sets the name.'
  Name : String;
};

type Quotes_types.Webcom_API_Public_Quote_VM_ApproversResponsibilityVM {
  @description : 'Gets or sets the identifier.'
  Id : Integer;
  @description : 'Gets or sets the name of the rule.'
  RuleName : String;
  @description : 'Gets or sets the description.'
  Description : String;
  @description : 'Gets or sets the submission date.'
  SubmissionDate : String;
  @description : 'Gets or sets the submitted by.'
  SubmittedBy : String;
  @description : 'Gets or sets the comment.'
  Comment : String;
};

@description : 'Customer data'
type Quotes_types.Webcom_API_Public_Quote_VM_CustomerVM {
  @description : 'Get or set Role Type'
  RoleType : String;
  @description : 'Get or set whether customer is Active'
  Active : Boolean;
  @description : 'Get or set Company Name'
  CompanyName : String;
  @description : 'Get or set First Name'
  FirstName : String;
  @description : 'Get or set Last Name'
  LastName : String;
  @description : 'Get or set customer Title'
  Title : String;
  @description : 'Get or set the first Address Line'
  AddressLine1 : String;
  @description : 'Get or set the second Address Line'
  AddressLine2 : String;
  @description : 'Get or set City'
  City : String;
  @description : 'Get or set Zip Code'
  ZipCode : String;
  @description : 'Get or set State'
  State : String;
  @description : 'Get or set Province'
  Province : String;
  @description : 'Get or set Country'
  Country : String;
  @description : 'Get or set Phone'
  Phone : String;
  @description : 'Get or set Fax'
  Fax : String;
  @description : 'Get or set Email'
  Email : String;
  @description : 'Get or set Primary Industry'
  PrimaryIndustry : String;
  @description : 'Get or set Territory Name'
  TerritoryName : String;
  @description : 'Get or set CRM Account Id'
  CRMAccountId : String;
  @description : 'Get or set CRM Contact Id'
  CRMContactId : String;
  @description : 'Get or set Customer Code'
  CustomerCode : String;
  @description : 'Get or set Custom Fields'
  CustomFields : many Quotes_types.Webcom_API_Public_Quote_VM_CustomFieldVM;
};

type Quotes_types.Webcom_Common_Util_Exceptions_DetailsErrorContent {
  code : String;
  message : String;
  target : String;
  details : many Quotes_types.Webcom_Common_Util_Exceptions_BasicErrorContent;
  internalMessage : String;
};

type Quotes_types.Webcom_Common_Util_Exceptions_BasicErrorContent {
  code : String;
  message : String;
};

@description : 'Quote Comment view model'
type Quotes_types.Webcom_API_Public_Quote_VM_QuoteCommentVM {
  @description : 'The identifier.'
  Id : Integer;
  @description : 'Item Id.'
  ItemId : Integer;
  @description : 'User Full Name.'
  UserFullName : String;
  @description : 'User Email.'
  UserEmail : String;
  @description : 'User Company'
  UserCompany : String;
  @description : 'Date Created'
  DateCreated : String;
  @description : 'Comment text'
  Comment : String;
  @description : 'Comment creator'
  Source : Integer;
};

@description : 'Data of quote item custom field'
type Quotes_types.Webcom_API_Public_Quote_VM_CustomFieldVM {
  @description : 'Get or set custom field Name'
  Name : String;
  @description : 'Get or set custom field Content'
  Content : String;
  @description : 'Get or set Price Unit'
  PriceUnit : Quotes_types.Webcom_API_Public_Quote_VM_PriceUnitVm;
};

@description : 'The PriceUnit node is visible only when the integration with SAP Variant Configuration and Pricing is enabled.'
type Quotes_types.Webcom_API_Public_Quote_VM_PriceUnitVm {
  @description : 'Quantity.'
  Quantity : String;
  @description : 'Unit of measure.'
  UnitOfMeasure : String;
};

@description : 'Subscription details data'
type Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionDetailsVM {
  @description : 'Get or set Effective Date'
  EffectiveDate : String;
  @description : 'Get or set Rate Plan ID'
  RatePlanId : String;
  @description : 'Get or set Contract Start Date'
  ContractStartDate : String;
  @description : 'Get or set Contract End Date'
  ContractEndDate : String;
  @description : 'Get or set Contract Length'
  ContractLength : String;
  @description : 'Get or set Minimum Contract End Date'
  MinimumContractEndDate : String;
  @description : 'Get or set Minimum Contract Length'
  MinimumContractLength : String;
  @description : 'Get or set Subscription Parameters'
  SubscriptionParameters : many Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionParameterVM;
  @description : 'Get or set'
  Pricing : Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionPricingVM;
};

type Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionParameterVM {
  Code : String;
  Value : String;
};

@description : 'Subcription pricing data'
type Quotes_types.Webcom_API_Public_Quote_VM_SubscriptionPricingVM {
  @description : 'Get or set Rate Plan Snapshot Effective Date'
  RatePlanSnapshotEffectiveDate : String;
  @description : 'Get or set Pricing Parameters'
  PricingParameters : many Quotes_types.Webcom_API_Public_Quote_VM_PricingParameterVM;
};

type Quotes_types.Webcom_API_Public_Quote_VM_PricingParameterVM {
  Code : String;
  Value : String;
};

type Quotes_types.SAP_CPQ_API_Quote_VM_QuoteTableRowGenericResponseVM {
  List : many Quotes_types.Webcom_API_Public_Quote_VM_QuoteTableRowResponseVM;
};

