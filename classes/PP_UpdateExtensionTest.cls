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
private class PP_UpdateExtensionTest {

    @testSetup static void setup() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void myUnitTest() {
    	Test.StartTest();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        List<REVVY__MnQuoteItemSubLine__c> qisUpdate = new List<REVVY__MnQuoteItemSubLine__c> ();
        List<REVVY__MnQuoteItem__c> quoteItems = [Select r.Id, (Select Id, Name From REVVY__QuoteItemSubLine__r) From REVVY__MnQuoteItem__c r where REVVY__Quote__c = :quote.Id];
    	for(REVVY__MnQuoteItem__c qi : quoteItems ) {
    		qi.REVVY__Quantity__c = 6;
    		for(REVVY__MnQuoteItemSubLine__c qis : qi.REVVY__QuoteItemSubLine__r) {
    			qis.REVVY__Quantity__c = 6;
    			qisUpdate.add(qis);
    		}
    	}
    	update quoteItems;
    	update qisUpdate;
    	Test.StopTest();
    }
    static testMethod void myUnitTest2() {
    	Test.StartTest();
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        List<REVVY__MnQuoteItemSubLine__c> qisUpdate = new List<REVVY__MnQuoteItemSubLine__c> ();
        List<REVVY__MnQuoteItem__c> quoteItems = [Select r.Id, (Select Id, Name From REVVY__QuoteItemSubLine__r) From REVVY__MnQuoteItem__c r where REVVY__Quote__c = :quote.Id];
    	for(REVVY__MnQuoteItem__c qi : quoteItems ) {
    		for(REVVY__MnQuoteItemSubLine__c qis : qi.REVVY__QuoteItemSubLine__r) {
    			qis.REVVY__Quantity__c = 6;
    			qisUpdate.add(qis);
    		}
    	}
    	update qisUpdate;
    	
		for(REVVY__MnQuoteItemSubLine__c qis : qisUpdate) {
			qis.REVVY__Quantity__c = 2;
		}
    	
    	update qisUpdate;
    	Test.StopTest();
    }
    static testMethod void myUnitTest3() {
    	ToroTriggerRunOnce.runQiExtensionRunOnce();
    	ToroTriggerRunOnce.runQiExtensionRunOnce();
    	ToroTriggerRunOnce.runQisExtensionRunOnce();
    	ToroTriggerRunOnce.runQisExtensionRunOnce();
    	ToroTriggerRunOnce.setInCloning(true);
    	system.assertEquals(true, ToroTriggerRunOnce.getInCloning());
    }
}