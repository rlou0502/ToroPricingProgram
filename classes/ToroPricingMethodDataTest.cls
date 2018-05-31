@isTest
private class ToroPricingMethodDataTest {
    /**
     *
     * description
     *
     * @result the key result
     */
    @isTest static void test_constructor() {
        final Decimal percentOfMSRP      = 10;
        final Decimal percentOfDNet      = 10;
        final Decimal rebatePercent      = 10;
        final Decimal grossProfitPercent = 10;
        final Decimal dnet               = 10;

        ToroPricingMethodData data = new ToroPricingMethodData(percentOfMSRP, percentOfDNet, rebatePercent, grossProfitPercent, dnet);
        System.assert(data != null);
    }

    @isTest static void test_constructor2() {
         ToroPricingMethodData data = new ToroPricingMethodData();
         System.assert(data != null);
    }
}