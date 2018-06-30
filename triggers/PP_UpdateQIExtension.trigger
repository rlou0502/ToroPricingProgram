trigger PP_UpdateQIExtension on REVVY__MnQuoteItem__c (after update) {
	if(ToroTriggerRunOnce.runQuoteItemRunOnce()) {
	    List<REVVY__MnQuoteItem__c> qis = (List<REVVY__MnQuoteItem__c>) trigger.new;   
	    List<Revvy__MnStrategy4__c>  tQIs = new List<Revvy__MnStrategy4__c>();
	    List<Id> quoteItemIds = new List<Id>();
	    for(REVVY__MnQuoteItem__c qi : qis) {
	    	if(Trigger.oldMap.get(qi.Id).REVVY__Quantity__c != qi.REVVY__Quantity__c) {
	            tQIs.add(new Revvy__MnStrategy4__c(External_Id__c = qi.Id, 
	            	Adjusted_Quantity__c = qi.REVVY__Quantity__c,
	            	Off_MSRP_Overridden__c=false)); 
	            quoteItemIds.add(qi.Id);
	    	}
	        //tQIs.add(new Revvy__MnStrategy4__c(External_Id__c = qi.Id, 
	        //    MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c));        
	    }
	    if(tQIs.size() > 0) {
	    	upsert tQIs External_Id__c;  
	    }  
	    List<Revvy__MnStrategy5__c> sublines = [select Id, Quote_Item_Sub_Line__r.REVVY__Quantity__c, Quote_Item_Sub_Line__r.REVVY__QuoteItem__r.REVVY__Quantity__c from Revvy__MnStrategy5__c where Quote_Item_Sub_Line__r.REVVY__QuoteItem__c in :quoteItemIds ];
	    for(Revvy__MnStrategy5__c sl : sublines) {
	    	sl.Adjusted_Quantity__c = sl.Quote_Item_Sub_Line__r.REVVY__Quantity__c * sl.Quote_Item_Sub_Line__r.REVVY__QuoteItem__r.REVVY__Quantity__c;	
	    }
	    if(sublines.size() > 0) {
	    	update sublines;
	    }
	}
}