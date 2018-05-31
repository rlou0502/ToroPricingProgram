trigger PP_PricingProgramDelete on REVVY__MnStrategy1__c (after delete) {
	List<REVVY__MnStrategy1__c> quoteLines = (List<REVVY__MnStrategy1__c>) trigger.old;  
	
	List<Id> parentIds = new List<Id>();
	for(REVVY__MnStrategy1__c qi : quoteLines) {
		parentIds.add(qi.Id);		
	}
	List<REVVY__MnStrategy2__c> extensions = [select Id from REVVY__MnStrategy2__c where PricingProgram__c in :parentIds];
	delete extensions;       
}