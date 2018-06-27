trigger PP_Stratgy4Update on REVVY__MnStrategy4__c (after update) {
	if(ToroTriggerRunOnce.runQiExtensionRunOnce()) {
		List<Revvy__MnStrategy4__c>  tQIs = (List<Revvy__MnStrategy4__c>)  trigger.new;
		List<REVVY__MnQuoteItem__c> qis = new List<REVVY__MnQuoteItem__c>();   

	    for(Revvy__MnStrategy4__c qi : tQIs) {
	    	REVVY__MnQuoteItem__c quoteItem = new REVVY__MnQuoteItem__c(id = qi.External_Id__c);
	    	if(Trigger.oldMap.get(qi.Id).MSRP_Price__c != qi.MSRP_Price__c) {
	    		quoteItem.REVVY__Price__c = qi.MSRP_Price__c;
	    	}  
	    	if(Trigger.oldMap.get(qi.Id).DNet_Price__c != qi.DNet_Price__c) {
	    		quoteItem.REVVY__SuggestedPrice__c = qi.DNet_Price__c;
	    	}
	    	qis.add(quoteItem);
	    }	
	    if(qis.size() > 0) {
	    	update qis;
	    }
	}    
}