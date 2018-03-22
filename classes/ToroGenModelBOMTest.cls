@isTest
private class ToroGenModelBOMTest {

	@TestSetup static void setupTestData() {
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
	}

	@isTest static void test_gen_bom() {
		ToroGenModelBOM.genBOM();
	}

	@isTest static void test_get_stock_order() {
		ToroGenModelBOM.getStockOrder();
	}

	@isTest static void test_inner_classes() {
		ToroGenModelBOM.ProductModelView pmv1 = new ToroGenModelBOM.ProductModelView();
		System.assert(pmv1 != null);

		ToroGenModelBOM.ProductModelView pmv2 = new ToroGenModelBOM.ProductModelView(
			'modelname'
			, 'productab'
			, 'description'
			, 9.99
			, 9.99
			, 100
			, 999
		);
		System.assert(pmv2 != null);
	}

}