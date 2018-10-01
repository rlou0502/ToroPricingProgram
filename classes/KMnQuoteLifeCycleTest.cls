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
private class KMnQuoteLifeCycleTest {
	@TestSetup static void setupTestData() {
		ToroTestData.loadTestData();
		ToroTestData.loadQuoteTestData();
	}
    static testMethod void myUnitTest() {
        Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        REVVY__MnProperty__c prop = new REVVY__MnProperty__c(Name='ToroCPQHostName', REVVY__Value__c='test');
        insert prop;
        KMnQuoteLifeCycleSelectPriceProgram p = new KMnQuoteLifeCycleSelectPriceProgram();
        Map<String,String> values = new Map<String,String>{'objectId'=>quote.Id};
        p.doAction(values);
        KMnQuoteLifeCycleReadOnlyPriceProgram p2 = new KMnQuoteLifeCycleReadOnlyPriceProgram();
        p2.doAction(values);
        
        KMnQuoteLifeCycleAbandoned  p3 = new KMnQuoteLifeCycleAbandoned ();
		p3.doAction(values);
        
        KMnQuoteLifeCycleClosedLost  p4 = new KMnQuoteLifeCycleClosedLost();
        p4.doAction(values);
    }
}