@isTest
private class ToroQIBaseTest {

	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
		Revvy__MnSequenceGen__c sequence = new Revvy__MnSequenceGen__c(Revvy__ObjectName__c='MnQuoteItem__c', REVVY__CurrentValue__c=1);
		insert sequence;


	}

	@isTest static void test_method_one() {
		// Implement test code
	}

	@isTest static void test_method_two() {
		// Implement test code
	}

}