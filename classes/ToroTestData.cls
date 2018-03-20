/**
 * ToroTestData
 *
 * helper class for creating test data
 *
 * @author Roy Lou
 */
public with sharing class ToroTestData {

    private static final Id RECTYPE_ACCOUNT_CHANNEL_PARTNER = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
    private static final Id RECTYPE_ACCOUNT_END_USER        = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();

    /**
     *
     * load base test data
     *
     */
    public static void loadTestData() {
        if (!Test.isRunningTest()) return;

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

		List<sObject> pricingProgram = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_PricingProgram');
		List<sObject> eligilibility  = Test.loadData(Revvy__MnStrategy3__c.sObjectType, 'TestData_PP_Eligibility');
    }
}