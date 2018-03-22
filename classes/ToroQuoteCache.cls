public with sharing class ToroQuoteCache implements Cache.CacheBuilder  {
	public Object doLoad(Id quoteId) {
		system.debug(logginglevel.info, 'initializeQuoteHeader -- ToroQuoteCache-------'+quoteId);
		String quoteQuery = 'select ' + CMnQuoteUtil.getQuoteQuery('Total_Extended_DNet__c, Setup_Fee__c, Toro_Support_Plus_Allowance__c,  Support_Plus_Rebate__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c') + ' from Revvy__MnQuote__c where id=:quoteId';
        Revvy__MnQuote__c q = (Revvy__MnQuote__c) Database.query(quoteQuery);
        return q;
    }        
}