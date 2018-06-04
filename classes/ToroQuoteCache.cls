public with sharing class ToroQuoteCache   {
	public static Revvy__MnQuote__c getQuote(Id quoteId) {
		Revvy__MnQuote__c q = (Revvy__MnQuote__c) Cache.Session.getPartition(ToroCacheManager.constPartitionName).get(quoteId);
		if(q == null) {
			String quoteQuery = 'select ' + CMnQuoteUtil.getQuoteQuery('Previous_Price_List__c,Toro_Rollup_DNetWOTPPAllied__c,Toro_Rollup_DNET__c,Setup_Fee__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c, Gross_Profit_Percent__c, Total_Award_Dollars__c') + ' from Revvy__MnQuote__c where id=:quoteId';
        	//String quoteQuery = 'select ' + CMnQuoteUtil.getQuoteQuery('Toro_Rollup_DNetWOTPPAllied__c,Total_Extended_DNet__c,Toro_Rollup_DNET__c,Setup_Fee__c, Toro_Support_Plus_Allowance__c,  SP_Toro_Responsibility__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c') + ' from Revvy__MnQuote__c where id=:quoteId';
        	q = (Revvy__MnQuote__c) Database.query(quoteQuery);
		}
		return q;
	}
	public static void putQuote(Revvy__MnQuote__c quote) {
		Cache.Session.getPartition(ToroCacheManager.constPartitionName).put(quote.Id, quote);
	}
}