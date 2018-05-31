@isTest
private class ToroPricingProgramDataTest {

	@isTest static void test_constructor() {
		String selectedPricingProgram = 'externalid;subtype';
		ToroPricingProgramData data = new ToroPricingProgramData(selectedPricingProgram);
		System.assertEquals('externalid', data.externalId);
		System.assertEquals('subtype', data.subType);
	}

	@isTest static void test_constructor2() {
		String selectedPricingProgram = 'externalid';
		ToroPricingProgramData data = new ToroPricingProgramData(selectedPricingProgram);
		System.assertEquals('externalid', data.externalId);
	}
}