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
//@deprecate
@isTest(SeeAllData=true)
private class ToroPricingMethodTest2 {
    static testMethod void testApplyTotalAwardDollars() {
    	ToroPricingProgram pp = new ToroLargePackagePricingProgramHelper();	
    	pp.initialize('a482F0000008zjx');
    	List<Revvy__MnStrategy4__c> quoteItemList = ToroPricingMethodUtil.applyTotalAwordDollors('Market Support Chart Large Package', pp.quoteItems, 200000);
    	decimal awardprice = 0;
    	for (Revvy__MnStrategy4__c qi : quoteItemList) {
			system.debug(logginglevel.info, '% off msrp=' + qi.Off_MSRP__c + ' % off dnet=' + qi.Award_of_DN__c + ' rebate %=' + qi.Rebate_as_a_of_DN__c + ' gp%=' + qi.Toro_Gross_Profit_Percent__c + ' award price=' + qi.award_price__c);
			awardprice += qi.award_price__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					system.debug(logginglevel.info, ' qis % off msrp=' + qis.Percent_Off_MSRP__c + ' % off dnet=' + qis.Percent_of_DNet__c + ' rebate %=' + qis.Rebate_as_of_DNet__c + ' gp%=' + qis.Gross_Profit_Percent__c + ' award price=' + qis.award_price__c);
					awardprice += qis.award_price__c;
				}	
			}
		}
    	system.debug(logginglevel.info, 'total award price =' + awardprice);
    }
    static testMethod void testApplyGPPercent() {
    	ToroPricingProgram pp = new ToroLargePackagePricingProgramHelper();	
    	pp.initialize('a482F0000008zjx');
    	List<Revvy__MnStrategy4__c> quoteItemList = ToroPricingMethodUtil.applyGPPercent('Market Support Chart Large Package', pp.quoteItems, 0.2);
    	decimal awardprice = 0;
    	for (Revvy__MnStrategy4__c qi : quoteItemList) {
			system.debug(logginglevel.info, '% off msrp=' + qi.Off_MSRP__c + ' % off dnet=' + qi.Award_of_DN__c + ' rebate %=' + qi.Rebate_as_a_of_DN__c + ' gp%=' + qi.Toro_Gross_Profit_Percent__c + ' award price=' + qi.award_price__c);
			awardprice += qi.award_price__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					system.debug(logginglevel.info, ' qis % off msrp=' + qis.Percent_Off_MSRP__c + ' % off dnet=' + qis.Percent_of_DNet__c + ' rebate %=' + qis.Rebate_as_of_DNet__c + ' gp%=' + qis.Gross_Profit_Percent__c + ' award price=' + qis.award_price__c);
					awardprice += qis.award_price__c;
				}	
			}
		}
    	system.debug(logginglevel.info, 'total award price =' + awardprice);
    }
}