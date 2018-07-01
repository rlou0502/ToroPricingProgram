/**
 * ToroTestData
 *
 * helper class for creating test data
 *
 * @author Roy Lou
 */
public with sharing class ToroTestData {
    public  static final String CURRENCY_CODE               = 'USD';
    private static final Id RECTYPE_ACCOUNT_CHANNEL_PARTNER = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
    private static final Id RECTYPE_ACCOUNT_END_USER        = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();

    /**
     *
     * load base test data
     *
     */
    public static void loadTestData() {
        if (!Test.isRunningTest()) return;
		List<sObject> user            = Test.loadData(User.sObjectType, 'TestData_PP_User');
		List<sObject> disti = Test.loadData(Account.sObjectType, 'TestData_PP_Distributor');
		List<User_Distributor__c> userDistributors = new List<User_Distributor__c>();
		for (sObject s : disti) {
			Account a = (Account) s;
			a.recordTypeId = RECTYPE_ACCOUNT_CHANNEL_PARTNER;
			userDistributors.add(
                new User_Distributor__c(
                      User_Name__c   = UserInfo.getUserId()
                    , Distributor__c = s.Id
                )
            );
		}
		update disti;
		insert userDistributors;

		List<sObject> corporateAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CorporateAccount');
		for (sObject s : corporateAccount) {
			Account a = (Account) s;
			a.recordTypeId = RECTYPE_ACCOUNT_END_USER;
		}
		update corporateAccount;

		List<sObject> customerAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CustomerAccount');
		for (sObject s : customerAccount) {
			Account a = (Account) s;
			a.recordtypeid = RECTYPE_ACCOUNT_END_USER;
		}
		update customerAccount;
		Test.loadData(Toro_PricingProgramHelperFactory__c.sObjectType, 'TestData_PP_Helper');
		List<sObject> priceList          = Test.loadData(Revvy__MnPriceList__c.sObjectType, 'TestData_PP_PriceList');
		List<sObject> pricingProgram     = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_PricingProgram');
		List<sObject> pricingProgramChildren     = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_ChildPricingProgram');
		List<sObject> eligilibility      = Test.loadData(Revvy__MnStrategy3__c.sObjectType, 'TestData_PP_Eligibility');
		List<sObject> pricingProgramLine = Test.loadData(Revvy__MnStrategy2__c.sObjectType, 'TestData_PP_PricingProgramLine');
		
		Test.loadData(Revvy__MnConfigEngineModel__c.sObjectType, 'TestData_PP_Model');
		List<sObject> products           = Test.loadData(Revvy__MnCatalogNode__c.sObjectType, 'TestData_PP_CatalogNode');
		Test.loadData(Revvy__MnPriceListLine__c.sObjectType, 'TestData_PP_PriceListLine');
    }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static void loadQuoteTestData() {
		
		
		List<User> users = [select UserName from User where UserName = 'standarduser_pp@testorg.com'];
		system.debug(users);
		List<sObject> quote            = Test.loadData(Revvy__MnQuote__c.sObjectType, 'TestData_PP_Quote');
		List<sObject> quoteItem        = Test.loadData(Revvy__MnQuoteItem__c.sObjectType, 'TestData_PP_QuoteItem');
		List<sObject> quoteItemSubline = Test.loadData(Revvy__MnQuoteItemSubline__c.sObjectType, 'TestData_PP_QuoteItemSubline');
	}

	public static void loadGenericTestData() {
        // ============================================================================
        // Insert base CLM Data
		insert new REVVY__MnLifeCycle__c(
            Name                   = 'Contract - NDA Lifecycle Configuration'
            , REVVY__Object__c     = 'MnContract__c'
            , REVVY__RecordType__c = 'SalesContract'
            , REVVY__Status__c     = 'Active'
        );

        Account account = new Account(
            Name                = 'TestAccount'
            , BillingStreet     = '1600 Seaport Boulevard, Suite 400'
            , BillingCity       = 'Redwood City'
            , BillingState      = 'California'
            , BillingPostalCode = '94063'
            , BillingCountry    = 'United States'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
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
        REVVY__MnCatalogNode__c catalog = new REVVY__MnCatalogNode__c(
            Name                = 'TestCatalog'
            , REVVY__Id__c      = 'TestCatalog'
            , REVVY__Type__c    = 'Catalog'
            , REVVY__SubType__c = null
        );
        REVVY__MnCatalogNode__c category1 = new REVVY__MnCatalogNode__c(
            Name                = 'TestCategory1'
            , REVVY__Id__c      = 'TestCategory1'
            , REVVY__Type__c    = 'Category'
            , REVVY__SubType__c = null
        );
        REVVY__MnCatalogNode__c category2 = new REVVY__MnCatalogNode__c(
            Name                = 'TestCategory2'
            , REVVY__Id__c      = 'TestCategory2'
            , REVVY__Type__c    = 'Category'
            , REVVY__SubType__c = null
        );
        List<REVVY__MnCatalogNode__c> categories = new List<REVVY__MnCatalogNode__c> { catalog, category1, category2 };
        insert categories;

        REVVY__MnPriceList__c pricelist = createPriceList('Commercial', 'General');
		insert pricelist;

        // ============================================================================
        // Model
       REVVY__MnConfigEngineModel__c model = new REVVY__MnConfigEngineModel__c(
            REVVY__Id__c = 'INTLTestModel'
			, REVVY__Status__c = 'In Production'
        );
        insert model;

        REVVY__MnCatalogNode__c product1 = new REVVY__MnCatalogNode__c(
            Name                      = 'TestProduct1'
            , REVVY__Id__c            = 'TestProduct1'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = 'Product'
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
        );
        REVVY__MnCatalogNode__c product2 = new REVVY__MnCatalogNode__c(
            Name                      = 'TestProduct2'
            , REVVY__Id__c            = 'TestProduct2'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = 'Product'
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
        );
        REVVY__MnCatalogNode__c product3 = new REVVY__MnCatalogNode__c(
            Name                      = 'TestProduct3'
            , REVVY__Id__c            = 'TestProduct3'
            , REVVY__Status__c        = 'Active'
            , REVVY__Type__c          = 'Product'
            , REVVY__mainImage1__c    = 'MainImage1Path'
            , REVVY__image2__c        = 'Image2Path'
            , REVVY__image3__c        = 'Image3Path'
            , REVVY__image4__c        = 'Image4Path'
            , REVVY__Model__c         = model.Id
        );

        final List<REVVY__MnCatalogNode__c> products = new List<REVVY__MnCatalogNode__c> { product1, product2, product3 };
        insert products;

		// ============================================================================
		// update "Product IDs" field on model
		String modelProductIds = '[';
		for (REVVY__MnCatalogNode__c product : products) {
			modelProductIds += '"' + product.Name + '",';
		}
		modelProductIds = modelProductIds.removeEnd(',');
		modelProductIds += ']';

		model.REVVY__Product_IDs__c = modelProductIds;
		update model;

        // ============================================================================
        // Pricelist Line
        insert new List<REVVY__MnPriceListLine__c> {
            createPriceListLine(pricelist, product1, 10.00, 20.00)
            , createPriceListLine(pricelist, product2, 20.00, 40.00)
            , createPriceListLine(pricelist, product3, 30.00, 60.00)
        };

		List<REVVY__MnConfigEngineOptionGroup__c> optionGroups = new List<REVVY__MnConfigEngineOptionGroup__c> {
			new REVVY__MnConfigEngineOptionGroup__c(
				  Name         = 'OptionGroup1'
				, REVVY__Id__c = 'OptionGroup1'
			)
		};
		insert optionGroups;

		List<REVVY__MnConfigEngineOption__c> options = new List<REVVY__MnConfigEngineOption__c> {
			new REVVY__MnConfigEngineOption__c(
				  Name                   = 'Option1'
				, REVVY__Label__c        = 'Option1'
				, REVVY__Catalog_Node__c = product1.Id
				, REVVY__Option_Group__c = optionGroups[0].Id
				, REVVY__Option_Order__c = 1
			)
		};
		insert options;

		List<REVVY__MnConfigEngineModelOptionGroupJunction__c> optionJunctions = new List<REVVY__MnConfigEngineModelOptionGroupJunction__c> {
			new REVVY__MnConfigEngineModelOptionGroupJunction__c(
				  REVVY__OptionGroup_Id__c = optionGroups[0].Id
				, REVVY__Model_Id__c       = model.Id
			)
		};
		insert optionJunctions;
	}

    private static REVVY__MnPriceList__c createPriceList(String name, String segment) {
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
}