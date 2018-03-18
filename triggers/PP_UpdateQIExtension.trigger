trigger PP_UpdateQIExtension on REVVY__MnQuoteItem__c (after update) {
	List<REVVY__MnQuoteItem__c> qis = (List<REVVY__MnQuoteItem__c>) trigger.new;   
	List<REVVY__MnStrategy4__c>  tQIs = new List<REVVY__MnStrategy4__c>();
	for(REVVY__MnQuoteItem__c qi : qis) {
		tQIs.add(new REVVY__MnStrategy4__c(External_Id__c = qi.Id, Toro_Quantity__c = qi.REVVY__Quantity__c,
			MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c));		
	}
	upsert tQIs External_Id__c;    
}