trigger PP_CreateQIExtension on REVVY__MnQuoteItem__c (after insert) {
	List<REVVY__MnQuoteItem__c> qis = (List<REVVY__MnQuoteItem__c>) trigger.new;   
	List<Toro_QuoteItem__c>  tQIs = new List<Toro_QuoteItem__c>();
	for(REVVY__MnQuoteItem__c qi : qis) {
		tQIs.add(new Toro_QuoteItem__c(External_Id__c = qi.Id, Product__c = qi.REVVY__Catalog_Node__c, Toro_Quantity__c = qi.REVVY__Quantity__c,
			QuoteItem__c=qi.Id, MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c, 	Mn_Quote__c=qi.Revvy__Quote__c));		
	}
	insert tQIs;
}