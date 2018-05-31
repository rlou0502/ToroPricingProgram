trigger PP_QuoteItemSublineDelete on REVVY__MnQuoteItemSubLine__c (after delete) {
	List<REVVY__MnQuoteItemSubLine__c> quoteLines = (List<REVVY__MnQuoteItemSubLine__c>) trigger.old;  
	
	List<Id> quoteItemIds = new List<Id>();
	for(REVVY__MnQuoteItemSubLine__c qi : quoteLines) {
		quoteItemIds.add(qi.Id);		
	}
	List<REVVY__MnStrategy5__c> extensions = [select Id from REVVY__MnStrategy5__c where External_Id__c in :quoteItemIds];
	delete extensions;    
}