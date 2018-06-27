trigger PP_Stratgy5Update on REVVY__MnStrategy5__c (after update) {
	if(ToroTriggerRunOnce.runQisExtensionRunOnce()) {
		List<Revvy__MnStrategy5__c>  tQIs = (List<Revvy__MnStrategy5__c>)  trigger.new;
		List<REVVY__MnQuoteItemSubline__c> qis = new List<REVVY__MnQuoteItemSubline__c>();   

	    for(Revvy__MnStrategy5__c qi : tQIs) {
	    	REVVY__MnQuoteItemSubline__c quoteItemSubline = new REVVY__MnQuoteItemSubline__c(id = qi.External_Id__c);
	    	if(Trigger.oldMap.get(qi.Id).MSRP_Price__c != qi.MSRP_Price__c) {
	    		quoteItemSubline.REVVY__Price__c = qi.MSRP_Price__c;
	    	}  
	    	if(Trigger.oldMap.get(qi.Id).DNet_Price__c != qi.DNet_Price__c) {
	    		quoteItemSubline.REVVY__SuggestedPrice__c = qi.DNet_Price__c;
	    	}
	    	qis.add(quoteItemSubline);
	    }	
	    if(qis.size() > 0) {
	    	update qis;
	    }	
	}    
}