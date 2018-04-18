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
private class ToroPricingMethodUtilTest {
	@testSetup static void methodName() {
		Revvy__MnStrategy1__c pp = new Revvy__MnStrategy1__c(NAME='Market Support Chart Large Package',APPLICABLEPRODUCTS__C='112-6769,131-6828,03921,30511,T0000-3423',EXTERNALID__C='Market Support Chart Large Package',MINIMUMTHRESHOLD__C=130000,PRICINGPROGRAMTYPE__C='Support Chart',PRICINGPROGRAMSTYLE__C='Large Package');
		insert pp;
		List<Revvy__MnStrategy2__c> ppls = new List<Revvy__MnStrategy2__c> {
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=101,DISTRIBUTOR_MARGIN__C=14.7,OFF_MFG_SUGG_TTL__C=29.3,REBATE_AS_A_PERCENT_OF_DN__C=13.8),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=100,DISTRIBUTOR_MARGIN__C=14.4,OFF_MFG_SUGG_TTL__C=30,REBATE_AS_A_PERCENT_OF_DN__C=14),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=120,DISTRIBUTOR_MARGIN__C=20.9,OFF_MFG_SUGG_TTL__C=16,REBATE_AS_A_PERCENT_OF_DN__C=5.1),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=119,DISTRIBUTOR_MARGIN__C=20.8,OFF_MFG_SUGG_TTL__C=16.7,REBATE_AS_A_PERCENT_OF_DN__C=5.7),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=118,DISTRIBUTOR_MARGIN__C=20.6,OFF_MFG_SUGG_TTL__C=17.4,REBATE_AS_A_PERCENT_OF_DN__C=6.3),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=117,DISTRIBUTOR_MARGIN__C=20.4,OFF_MFG_SUGG_TTL__C=18.1,REBATE_AS_A_PERCENT_OF_DN__C=6.9),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=116,DISTRIBUTOR_MARGIN__C=20.3,OFF_MFG_SUGG_TTL__C=18.8,REBATE_AS_A_PERCENT_OF_DN__C=7.5),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=115,DISTRIBUTOR_MARGIN__C=20.2,OFF_MFG_SUGG_TTL__C=19.5,REBATE_AS_A_PERCENT_OF_DN__C=8.2),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=114,DISTRIBUTOR_MARGIN__C=20,OFF_MFG_SUGG_TTL__C=20.2,REBATE_AS_A_PERCENT_OF_DN__C=8.8),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=113,DISTRIBUTOR_MARGIN__C=19.8,OFF_MFG_SUGG_TTL__C=20.9,REBATE_AS_A_PERCENT_OF_DN__C=9.4),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=112,DISTRIBUTOR_MARGIN__C=19.6,OFF_MFG_SUGG_TTL__C=21.6,REBATE_AS_A_PERCENT_OF_DN__C=10),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=111,DISTRIBUTOR_MARGIN__C=19.4,OFF_MFG_SUGG_TTL__C=22.3,REBATE_AS_A_PERCENT_OF_DN__C=10.5),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=110,DISTRIBUTOR_MARGIN__C=19.1,OFF_MFG_SUGG_TTL__C=23,REBATE_AS_A_PERCENT_OF_DN__C=11),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=109,DISTRIBUTOR_MARGIN__C=18.8,OFF_MFG_SUGG_TTL__C=23.7,REBATE_AS_A_PERCENT_OF_DN__C=11.5),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=108,DISTRIBUTOR_MARGIN__C=18.5,OFF_MFG_SUGG_TTL__C=24.4,REBATE_AS_A_PERCENT_OF_DN__C=12),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=107,DISTRIBUTOR_MARGIN__C=18.1,OFF_MFG_SUGG_TTL__C=25.1,REBATE_AS_A_PERCENT_OF_DN__C=12.4),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=106,DISTRIBUTOR_MARGIN__C=17.7,OFF_MFG_SUGG_TTL__C=25.8,REBATE_AS_A_PERCENT_OF_DN__C=12.8),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=105,DISTRIBUTOR_MARGIN__C=17.1,OFF_MFG_SUGG_TTL__C=26.5,REBATE_AS_A_PERCENT_OF_DN__C=13),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=104,DISTRIBUTOR_MARGIN__C=16.5,OFF_MFG_SUGG_TTL__C=27.2,REBATE_AS_A_PERCENT_OF_DN__C=13.2),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=103,DISTRIBUTOR_MARGIN__C=15.9,OFF_MFG_SUGG_TTL__C=27.9,REBATE_AS_A_PERCENT_OF_DN__C=13.4),
			new Revvy__MnStrategy2__c(PricingProgram__c=pp.id,AWARD_PRICE_AS_A_PERCENT_OF_DN__C=102,DISTRIBUTOR_MARGIN__C=15.3,OFF_MFG_SUGG_TTL__C=28.6,REBATE_AS_A_PERCENT_OF_DN__C=13.6)};
		insert ppls;
		//List<sObject> qiList = Test.loadData(Revvy__MnStrategy4__c.sObjectType, 'TestData_PP_ToroQuoteItem_1');
		//List<sObject> qisList = Test.loadData(Revvy__MnStrategy5__c.sObjectType, 'TestData_PP_ToroQuoteSubline_1');
		//system.debug(logginglevel.info);
	}
    static  void testAwardPrice() {
    	decimal dnetPrice = 1000;
    	decimal awardPrice = 1145;
    	decimal msrpPrice = 1145/(1-0.181);
    	ToroPricingMethodData result = ToroPricingMethodUtil.retrieveDataForAwardPrice('Market Support Chart Large Package', msrpPrice, dnetPrice, awardPrice);
    	system.debug(result);
    	System.assertEquals(result.grossProfitPercent.setScale(2,roundingMode.HALF_UP), 0.20);
    	System.assertEquals(result.percentOfDNet.setScale(2,roundingMode.HALF_UP), 1.15);
    	System.assertEquals(result.percentOfMSRP.setScale(2,roundingMode.HALF_UP), 0.18);
    }
    static  void testDNetPercent() {
    	decimal dnetPrice = 1000;
    	decimal percentOfDnet = 1.14; //117%
    	ToroPricingMethodData result = ToroPricingMethodUtil.retrieveDataForDNetPercent('Market Support Chart Large Package', null, dnetPrice, percentOfDnet);
    	system.debug(result);
    	percentOfDnet = 1.145; //117%
    	decimal msrpPrice = 1145/(1-0.181);
    	result = ToroPricingMethodUtil.retrieveDataForDNetPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfDnet);
    	system.debug(result);
    	
    	//System.assertEquals(result.grossProfitPercent.setScale(4,roundingMode.HALF_UP), 0.0020);
    	//System.assertEquals(result.percentOfDNet.setScale(4,roundingMode.HALF_UP), 0.0115);
    	//System.assertEquals(result.percentOfMSRP.setScale(4,roundingMode.HALF_UP), 0.0018);
    }
    static  void testMSRPPercent() {
    	decimal dnetPrice = 1000;
    	decimal percentOfMSRP = 0.216; //117%
    	decimal msrpPrice = 1070/(1-percentOfMSRP);
    	system.debug('calling retrieveDataForMSRPPercent');
    	ToroPricingMethodData result = ToroPricingMethodUtil.retrieveDataForMSRPPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfMSRP);
    	system.debug(result);
    	percentOfMSRP = 0.25;
    	msrpPrice = 1070/(1-percentOfMSRP);
    	result = ToroPricingMethodUtil.retrieveDataForMSRPPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfMSRP);
    	system.debug(result);
    	//System.assertEquals(result.grossProfitPercent.setScale(4,roundingMode.HALF_UP), 0.0020);
    	//System.assertEquals(result.percentOfDNet.setScale(4,roundingMode.HALF_UP), 0.0115);
    	//System.assertEquals(result.percentOfMSRP.setScale(4,roundingMode.HALF_UP), 0.0018);
    }
    static  void testGPPercent() {
    	decimal dnetPrice = 1000;
    	decimal percentOfGP = 0.2; //117%
    	decimal msrpPrice = 1140/(1-0.202);
    	system.debug('calling retrieveDataForMSRPPercent');
    	ToroPricingMethodData result = ToroPricingMethodUtil.retrieveDataForGrossProfitPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfGP);
    	System.assertEquals(result.percentOfMSRP, 0.202);
    	system.debug(result);
    	percentOfGP = 0.20275;
    	result = ToroPricingMethodUtil.retrieveDataForGrossProfitPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfGP);
    	system.debug(result);
    	System.assertEquals(result.percentOfDNet, 1.1575);
    	
    	percentOfGP = 0.21;
    	result = ToroPricingMethodUtil.retrieveDataForGrossProfitPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfGP);
    	System.assertEquals(result.grossProfitPercent.setScale(5,roundingMode.HALF_UP), 0.20900);
    	percentOfGP = 0.14;
    	result = ToroPricingMethodUtil.retrieveDataForGrossProfitPercent('Market Support Chart Large Package', msrpPrice, dnetPrice, percentOfGP);
    	
    	System.assertEquals(result.grossProfitPercent.setScale(5,roundingMode.HALF_UP), 0.14400);
    	
    }
    
    
}