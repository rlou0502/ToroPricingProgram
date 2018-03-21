@isTest
private class ToroPricingProgramCacheTest {

    @testSetup static void setupTestData() {
        ToroTestData.loadTestData();

    }

    /**
     *
     * description
     *
     * @result the key result
     */
    @isTest static void test_do_load() {
         ToroPricingProgramCache cache = new ToroPricingProgramCache();
         final String pricingProgramExtId = 'STILargePackageProgram';
         cache.doLoad(pricingProgramExtId);
    }
}