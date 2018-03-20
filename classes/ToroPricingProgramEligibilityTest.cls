/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ToroPricingProgramEligibilityTest {

   @testSetup static void setupTestData() {
	   	/*
		List<sObject> disti = Test.loadData(Account.sObjectType, 'TestData_PP_Distributor');
		Id RecordTypeIdDisti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
		List<User_Distributor__c> userDistributors = new List<User_Distributor__c>();
		for(sObject s : disti) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdDisti;
			userDistributors.add(new User_Distributor__c(User_Name__c=userInfo.getUserId(), Distributor__c=s.Id));
		}
		update disti;
		insert userDistributors;

		List<sObject> corporateAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CorporateAccount');
		Id RecordTypeIdCorporate = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
		for(sObject s : corporateAccount) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdCorporate;
		}
		update corporateAccount;
		List<sObject> customerAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CustomerAccount');
		for(sObject s : customerAccount) {
			Account a = (Account) s;
			a.recordtypeid = RecordTypeIdCorporate;
		}
		update customerAccount;
		List<sObject> pricingProgram = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_PricingProgram');
		List<sObject> eligilibility = Test.loadData(Revvy__MnStrategy3__c.sObjectType, 'TestData_PP_Eligibility');
		*/
		ToroTestData.loadTestData();

	}

    static testmethod void myUnitTest2() {
    	account customer = [select id from account where name='Barefoot Bay Golf Course' limit 1];
    	customer.Account_Manager__c = UserInfo.getUserId();
    	system.debug(logginglevel.info, 'customer =' + customer);
    	List<Revvy__MnStrategy1__c> pps = ToroPricingProgramEligibility.retrievePricingProgramsForCustomerAccountWithId(customer.Id);

    	for(Revvy__MnStrategy1__c pp : pps) {
    		system.debug(logginglevel.info, '------pricing program =' + pp);
    	}

    	customer.First_Tee__c = true;
    	update customer;
    	system.debug(logginglevel.info, 'customer =' + customer);
    	pps = ToroPricingProgramEligibility.retrievePricingProgramsForCustomerAccountWithId(customer.Id);

    	for(Revvy__MnStrategy1__c pp : pps) {
    		system.debug(logginglevel.info, '------pricing program =' + pp);
    	}

    	REVVY__MnPriceList__c pricelist = new REVVY__MnPriceList__c(Name='Test', REVVY__Segment__c='General', REVVY__Currency__c='USD', Revvy__Id__c='General', Revvy__Status__c='Active' );
    	insert pricelist;
    	Revvy__MnQuote__c q = new Revvy__MnQuote__c(Revvy__Account__c = customer.Id, REVVY__Segment__c='General',  currency2__c='USD_USD');
    	insert q;
    	pps = ToroPricingProgramEligibility.retrievePricingProgramsForQuote(q.Id);
    	for(Revvy__MnStrategy1__c pp : pps) {
    		system.debug(logginglevel.info, '111------pricing program =' + pp);
    	}
    	List<ToroSelectOption> options = ToroPricingProgramEligibility.retrievePricingProgramOptions(q.Id);
    	system.debug(logginglevel.info,options);
    	customer.Tax_Supported__c = true;
    	update customer;
    	options =ToroPricingProgramEligibility.retrievePricingProgramOptions(q.Id);
    	system.debug(logginglevel.info,options);
    	customer.Commercial_Distributor__c=null;
    	update customer;
    	options = ToroPricingProgramEligibility.retrievePricingProgramOptions(q.Id);
    	system.debug(logginglevel.info,options);
    }
}