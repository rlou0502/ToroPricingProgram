/**
 * ToroTestData
 *
 * helper class for creating test data
 *
 * @author Scott
 */
public with sharing class ToroTestData {
    public static final String CURRENCY_CODE       = 'USD';
    public static final String CNODE_TYPE_CATALOG  = 'Catalog';
    public static final String CNODE_TYPE_CATEGORY = 'Category';
    public static final String CNODE_TYPE_PRODUCT  = 'Product';

    public static final String CNODE_ATTR_TYPE_INT = 'Integer';
    public static final String CNODE_ATTR_TYPE_DEC = 'Decimal';
    public static final String CNODE_ATTR_TYPE_TEXT = 'Text';
    public static final String CNODE_ATTR_TYPE_BOOL = 'Boolean';

    private static Boolean insertedBaseData = false;
    private static Account account;
    private static Opportunity opportunity;
    private static REVVY__MnCatalogNode__c catalog;
    private static Map<String,REVVY__MnCatalogNode__c> productMap;
    private static Map<String,REVVY__MnCatalogAttribute__c> catalogAttributeMap;
    private static Map<String,Map<String,REVVY__MnCatalogNodeAttr__c>> catalogNodeAttributeMap;
    private static REVVY__MnPriceList__c priceList;

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static void setupTestData() {
        if (Test.isRunningTest()) {
            insertBaseData();
            insertModel();
        }
	}

    /**
     *
     * description
     *
     * @param  name    description
     * @return return_type
     */
    public static void insertLargePackageQuote() {

    }

    /**
     *
     * description
     *
     * @param  name    description
     * @return return_type
     */
    private static void insertModel() {
       REVVY__MnConfigEngineModel__c model = new REVVY__MnConfigEngineModel__c(
            REVVY__Id__c = 'TestModel'
        );
        insert model;

        REVVY__MnCatalogNode__c product1 = new REVVY__MnCatalogNode__c(
            Name                      = 'FinishedGood1'
            , REVVY__Id__c            = 'FinishedGood1'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = CNODE_TYPE_PRODUCT
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
            , Toro_Product_Tier__c    = 'Tier 1'
            , Toro_Product_Type__c    = 'Finished Good'
        );
        REVVY__MnCatalogNode__c product2 = new REVVY__MnCatalogNode__c(
            Name                      = 'FinishedGood2'
            , REVVY__Id__c            = 'FinishedGood2'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = CNODE_TYPE_PRODUCT
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
            , Toro_Product_Tier__c    = 'Tier 2'
            , Toro_Product_Type__c    = 'Finished Good'
        );
        REVVY__MnCatalogNode__c product3 = new REVVY__MnCatalogNode__c(
            Name                      = 'SemiFinishedGoodParts'
            , REVVY__Id__c            = 'SemiFinishedGoodParts'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = CNODE_TYPE_PRODUCT
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
            , Toro_Product_Tier__c    = 'Parts'
            , Toro_Product_Type__c    = 'Semi-Finished Good'
        );
        productMap.put(product1.REVVY__Id__c, product1);
        productMap.put(product2.REVVY__Id__c, product2);
        productMap.put(product3.REVVY__Id__c, product3);
        insert productMap.values();

        // ============================================================================
        // Pricelist Line
        insert new List<REVVY__MnPriceListLine__c> {
            createPriceListLine(pricelist, product1, 1000.00, 2000.00)
            , createPriceListLine(pricelist, product2, 2000.00, 4000.00)
            , createPriceListLine(pricelist, product3, 3000.00, 6000.00)
        };
    }


    // ============================================================================
    // methods for getting the test data
    // ============================================================================

    public static Account getAccount() {
        if (account == null) {
            account = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        }

        return account;
    }

    public static Opportunity getOpportunity() {
        if (opportunity == null) {
            opportunity = [SELECT Id FROM Opportunity WHERE Name = 'TestOpportunity' LIMIT 1];
        }

        return opportunity;
    }

    private static REVVY__MnCatalogNode__c getCatalog() {
        if (catalog == null) {
            catalog = [SELECT Id FROM REVVY__MnCatalogNode__c WHERE REVVY__Type__c = :CNODE_TYPE_CATALOG LIMIT 1];
        }

        return catalog;
    }

    /**
     *
     * @return Revvy ID => Catalog Node
     */
    public static Map<String,REVVY__MnCatalogNode__c> getProductMap() {
        if (productMap == null) {
            productMap = new Map<String,REVVY__MnCatalogNode__c>();
            final List<REVVY__MnCatalogNode__c> catalogNodes = Database.query(ToroQuoteDAO.buildQuery(ToroQuoteDAO.CATALOG_NODE_FIELDS, 'REVVY__MnCatalogNode__c', 'REVVY__Type__c = \'' + CNODE_TYPE_PRODUCT + '\''));
            for (REVVY__MnCatalogNode__c catalogNode : catalogNodes) {
                productMap.put(catalogNode.REVVY__Id__c, catalogNode);
            }
        }

        return productMap;
    }

    /**
     *
     * @return Revvy ID => Catalog Attribute
     */
    public static Map<String,REVVY__MnCatalogAttribute__c> getCatalogAttributeMap() {
        if (catalogAttributeMap == null) {
            catalogAttributeMap = new Map<String,REVVY__MnCatalogAttribute__c>();
            List<REVVY__MnCatalogAttribute__c> catalogAttributes = [SELECT Id, REVVY__Id__c FROM REVVY__MnCatalogAttribute__c];
            for (REVVY__MnCatalogAttribute__c catalogAttribute : catalogAttributes) {
                catalogAttributeMap.put(catalogAttribute.REVVY__Id__c, catalogAttribute);
            }
        }

        return catalogAttributeMap;
    }

    /**
     *
     * @return Catalog Node Revvy ID => (Catalog Attribute Revvy ID => Catalog Node Attribute)
     */
    public static Map<String,Map<String,REVVY__MnCatalogNodeAttr__c>> getCatalogNodettributeMap() {
        if (catalogNodeAttributeMap == null) {
            catalogNodeAttributeMap = new Map<String,Map<String,REVVY__MnCatalogNodeAttr__c>>();
            final List<REVVY__MnCatalogNodeAttr__c> catalogNodeAttribues = Database.query(ToroQuoteDAO.buildQuery(ToroQuoteDAO.CATALOG_NODE_ATTRIBUTE_FIELDS, 'REVVY__MnCatalogNodeAttr__c'));
            System.assert(catalogNodeAttribues.size() > 0);
            for (REVVY__MnCatalogNodeAttr__c catalogNodeAttr: catalogNodeAttribues) {
                if (catalogNodeAttributeMap.containsKey(catalogNodeAttr.REVVY__Catalog_Node__r.REVVY__Id__c)) {
                    catalogNodeAttributeMap.get(catalogNodeAttr.REVVY__Catalog_Node__r.REVVY__Id__c).put(
                        catalogNodeAttr.REVVY__Catalog_Attribute__r.REVVY__Id__c, catalogNodeAttr
                    );
                }

                else {
                    catalogNodeAttributeMap.put(catalogNodeAttr.REVVY__Catalog_Node__r.REVVY__Id__c
                        , new Map<String,REVVY__MnCatalogNodeAttr__c> {
                            catalogNodeAttr.REVVY__Catalog_Attribute__r.REVVY__Id__c => catalogNodeAttr
                        }
                    );
                }
            }
        }

        return catalogNodeAttributeMap;
    }

    /**
     *
     * inserts base CPQ/CLM data
     *
     * @return void
     */
    private static void insertBaseData() {
        if (insertedBaseData) return;
        insertedBaseData = true;

        productMap = new Map<String,REVVY__MnCatalogNode__c>();
        catalogAttributeMap = new Map<String,REVVY__MnCatalogAttribute__c>();

        // ============================================================================
        // Insert base CLM Data
        insert new REVVY__MnLifeCycle__c(
            Name                   = 'Contract - NDA Lifecycle Configuration'
            , REVVY__Object__c     = 'MnContract__c'
            , REVVY__RecordType__c = 'SalesContract'
            , REVVY__Status__c     = 'Active'
        );

        account = new Account(
            Name                = 'TestAccount'
            , BillingStreet     = '1600 Seaport Boulevard, Suite 400'
            , BillingCity       = 'Redwood City'
            , BillingState      = 'California'
            , BillingPostalCode = '94063'
            , BillingCountry    = 'United States'
        );
        insert account;

        opportunity = new Opportunity(
            Name        = 'TestOpportunity'
            , closeDate = System.Today().addDays(30)
            , stageName = 'Prospecting'
            , AccountId = account.Id
        );
        insert opportunity;

        // ============================================================================
        // Insert base CPQ Data
        List<REVVY__MnProperty__c> revvyProperties = new List<REVVY__MnProperty__c> {
            new REVVY__MnProperty__c(
                Name            = 'CatalogNodeHierarchies',
                REVVY__Value__c = 'Product'
            ),
            new REVVY__MnProperty__c(
                Name            = 'CatalogNodeHierarchy.Product',
                REVVY__Value__c = 'Product Family,Sub Family,Root,MPN'
            ),
            new REVVY__MnProperty__c(
                Name            = 'CatalogNodeSubType.Product Family',
                REVVY__Value__c = 'Description__c'
            )
        };
        insert revvyProperties;

        // ============================================================================
        // Insert categories
        catalog = new REVVY__MnCatalogNode__c(
            Name                = 'TestCatalog'
            , REVVY__Id__c      = 'TestCatalog'
            , REVVY__Type__c    = CNODE_TYPE_CATALOG
            , REVVY__SubType__c = null
        );
        REVVY__MnCatalogNode__c category1 = new REVVY__MnCatalogNode__c(
            Name                = 'TestCategory1'
            , REVVY__Id__c      = 'TestCategory1'
            , REVVY__Type__c    = CNODE_TYPE_CATEGORY
            , REVVY__SubType__c = null
        );
        REVVY__MnCatalogNode__c category2 = new REVVY__MnCatalogNode__c(
            Name                = 'TestCategory2'
            , REVVY__Id__c      = 'TestCategory2'
            , REVVY__Type__c    = CNODE_TYPE_CATEGORY
            , REVVY__SubType__c = null
        );
        List<REVVY__MnCatalogNode__c> categories = new List<REVVY__MnCatalogNode__c> { catalog, category1, category2 };
        insert categories;

        priceList = createPriceList('TestPriceList', 'General');
        insert priceList;
    }

    // ============================================================================
    // HELPER METHODS FOR CREATING RECORDS
    // ============================================================================
    public static REVVY__MnQuoteItem__c createQuoteItem(REVVY__MnQuote__c quote, String productExtId, Decimal costPrice, Decimal unitPrice) {
        return new REVVY__MnQuoteItem__c(
            REVVY__Catalog_Node__c = getProductMap().get(productExtId).Id
            , REVVY__Quantity__c   = 1
            , REVVY__Quote__c      = quote.Id
            , REVVY__CostPrice__c  = costPrice
            , REVVY__Unit_Price__c = unitPrice
        );
    }

    public static REVVY__MnQuoteItemSubLine__c createSubline(REVVY__MnQuoteItem__c parentQuoteItem, String productExtId, Decimal costPrice, Decimal unitPrice) {
        return new REVVY__MnQuoteItemSubLine__c(
            REVVY__QuoteItem__c = parentQuoteItem.Id
            , REVVY__Catalog_Node__c = getProductMap().get(productExtId).Id
            , REVVY__Quantity__c = 1
            , REVVY__CostPrice__c = costPrice
            , REVVY__Unit_Price__c = unitPrice
        );
    }

    private static REVVY__MnCatalogAttribute__c createCatalogAttribute(String revvyId
                                                                     , String attribType)
    {
        return new REVVY__MnCatalogAttribute__c(
            Name               = revvyId
            , REVVY__Id__c     = revvyId
            , REVVY__Format__c = attribType
        );
    }

    private static REVVY__MnCatalogNodeAttr__c createCatalogNodeAttribute(REVVY__MnCatalogNode__c product
                                                                        , REVVY__MnCatalogAttribute__c catalogAttribute
                                                                        , String value)
    {
        return new REVVY__MnCatalogNodeAttr__c(
            REVVY__Catalog_Node__c               = product.Id
            , REVVY__Catalog_Attribute__c        = catalogAttribute.Id
            , REVVY__Value__c                    = value
            , REVVY__IsServiceFilterAttribute__c = false
            , REVVY__Id__c                       = (String)product.Id + (String)catalogAttribute.Id
        );
    }

    public static REVVY__MnQuoteItemAttribute__c createQuoteItemAttribute(REVVY__MnQuoteItem__c quoteItem
                                                                        , String catalogAttributeName
                                                                        , String value)
    {
        return new REVVY__MnQuoteItemAttribute__c(
                REVVY__QuoteItem__c        = quoteItem.Id
              , REVVY__CatalogAttribute__c = getCatalogAttributeMap().get(catalogAttributeName).Id
              , REVVY__ActualValue__c      = value
              , REVVY__AttributeValue__c   = value
        );
    }

    public static REVVY__MnQiSubLineAttribute__c createSublineAttribute(REVVY__MnQuoteItemSubLine__c subline
                                                                        , String catalogAttributeName
                                                                        , String value)
    {
        return new REVVY__MnQiSubLineAttribute__c(
                REVVY__QuoteItemSubLine__c = subline.Id
              , REVVY__CatalogAttribute__c = getCatalogAttributeMap().get(catalogAttributeName).Id
            //   , REVVY__ActualValue__c      = value
              , REVVY__AttributeValue__c   = value // the quote wrapper refers to REVVY__ActualValue__c but the managed package overwrites REVVY__ActualValue__c with REVVY__AttributeValue__c
        );
    }

    private static REVVY__MnPriceList__c createPriceList(String name
                                                       , String segment)
    {
        return new REVVY__MnPriceList__c(
            Name                   = name
            , REVVY__Currency__c   = CURRENCY_CODE
            , REVVY__Id__c         = name
            , REVVY__Segment__c    = segment
            , REVVY__Start_Date__c = System.today()
            , REVVY__End_Date__c   = System.today().addDays(30)
            , REVVY__Status__c     = 'Active'
        );
    }

    private static REVVY__MnPriceListLine__c createPriceListLine(REVVY__MnPriceList__c priceList
                                                               , REVVY__MnCatalogNode__c product
                                                               , Decimal costPrice
                                                               , Decimal listPrice)
    {
        return new REVVY__MnPriceListLine__c(
              REVVY__PriceList__c   = priceList.Id
            , REVVY__Product__c     = product.Id
            , REVVY__CostPrice__c   = costPrice
            , REVVY__ListedPrice__c = listPrice
            , REVVY__Start_Date__c  = System.today()
            , REVVY__End_Date__c    = System.today().addDays(30)
        );
    }

    private static REVVY__MnQuoteSolutionAttribute__c createQuoteSolutionAttribute(REVVY__MnQuoteSolution__c quoteSolution
                                                                                 , String catalogAttributeName
                                                                                 , String value)
    {
        return new REVVY__MnQuoteSolutionAttribute__c(
            REVVY__ActualValue__c        = value
            , REVVY__AttributeValue__c   = value
            , REVVY__CatalogAttribute__c = getCatalogAttributeMap().get(catalogAttributeName).Id
            , REVVY__QuoteSolution__c    = quoteSolution.Id
        );
    }
}