trigger PP_QuoteItemDelete on REVVY__MnQuoteItem__c (after delete) {
	List<REVVY__MnQuoteItem__c> quoteLines = (List<REVVY__MnQuoteItem__c>) trigger.old;  
	
	List<Id> quoteItemIds = new List<Id>();
	for(REVVY__MnQuoteItem__c qi : quoteLines) {
		quoteItemIds.add(qi.Id);		
	}
	List<REVVY__MnStrategy4__c> extensions = [select Id from REVVY__MnStrategy4__c where External_Id__c in :quoteItemIds];
	delete extensions;
	
}