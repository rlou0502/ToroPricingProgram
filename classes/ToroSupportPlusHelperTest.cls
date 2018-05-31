@isTest
private class ToroSupportPlusHelperTest {

	@isTest static void test_sequence_gen() {
		System.assert(ToroSupportPlusHelper.generateQiExtId() != null);

		Decimal extId = ToroSupportPlusHelper.generateQiExtId();
		System.assert(extid != null);

		ToroSupportPlusHelper.saveSequenceGen();
		System.assertEQUALS(extId, [SELECT
									REVVY__CurrentValue__c
								FROM
									REVVY__MnSequenceGen__c
								WHERE
									REVVY__ObjectName__c = 'MnQuoteItem__c'
								LIMIT 1].REVVY__CurrentValue__c);

	}

	@isTest static void test_method_two() {
		// Implement test code
	}

}