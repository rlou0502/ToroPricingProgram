trigger PP_CanadianCurrencyChange on REVVY__MnQuote__c (after update) {
	List<REVVY__MnQuote__c> quotes = (List<REVVY__MnQuote__c>) trigger.new;   
	List<Id> quoteIds = new List<Id>();
	Map<Id, decimal> canadianExchangeRatios = new Map<Id, decimal>();
    for(REVVY__MnQuote__c q : quotes) {
    	if(Trigger.oldMap.get(q.Id).Currency_Conversion_Rate__c != q.Currency_Conversion_Rate__c 
    				&& Trigger.oldMap.get(q.Id).Currency_Conversion_Rate__c != null
    				&& Trigger.oldMap.get(q.Id).Currency_Conversion_Rate__c != 0 
    				&& q.Currency2__c.startsWith('CAD')) {
        	canadianExchangeRatios.put(q.Id, q.Currency_Conversion_Rate__c/Trigger.oldMap.get(q.Id).Currency_Conversion_Rate__c);  
        	quoteIds.add(q.Id);  
    	}       
    }
    system.debug('PP_CanadianCurrencyChange -- quoteIds =' + quoteIds);
    system.debug('PP_CanadianCurrencyChange -- canadianExchangeRatios =' + canadianExchangeRatios);
    List<REVVY__MnStrategy4__c> quoteItems = [Select MSRP_Price__c, Id, External_Id__c, DNet_Price__c, Award_Price__c, Mn_Quote__c,
    												(Select Id, Award_Price__c, DNet_Price__c, External_Id__c, 
    													MSRP_Price__c From Toro_Quote_Item_Sub_Lines__r) 
    										 From REVVY__MnStrategy4__c where Mn_Quote__c in :quoteIds];
    system.debug('PP_CanadianCurrencyChange -- quoteItems =' + quoteItems);
    List<REVVY__MnStrategy4__c> updateToroQuoteItems = new List<REVVY__MnStrategy4__c>();
    List<REVVY__MnStrategy5__c> updateToroSublines = new List<REVVY__MnStrategy5__c>();
    List<REVVY__MnQuoteItem__c> updateQuoteItems = new List<REVVY__MnQuoteItem__c>();
    List<REVVY__MnQuoteItemSubline__c> updateSublines = new List<REVVY__MnQuoteItemSubline__c>();
    for(REVVY__MnStrategy4__c qi : quoteItems) {
    	qi.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c);
    	qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
    	qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
    	system.debug('PP_CanadianCurrencyChange -- qi before =' + qi);
    	decimal exchangeRatio = canadianExchangeRatios.get(qi.Mn_Quote__c);
    	updateToroQuoteItems.add(new REVVY__MnStrategy4__c(Id=qi.Id, MSRP_Price__c=qi.MSRP_Price__c*exchangeRatio, DNet_Price__c=qi.DNet_Price__c*exchangeRatio, Award_Price__c=qi.Award_Price__c*exchangeRatio));
    	updateQuoteItems.add(new REVVY__MnQuoteItem__c(Id=qi.External_Id__c, REVVY__Price__c=qi.MSRP_Price__c*exchangeRatio, REVVY__SuggestedPrice__c=qi.DNet_Price__c*exchangeRatio));
    	if(qi.Toro_Quote_Item_Sub_Lines__r != null) {
    		for(REVVY__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
    			qis.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c);
    			qis.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
    			qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
    	
    			updateToroSublines.add(new REVVY__MnStrategy5__c(Id=qis.Id, MSRP_Price__c=qis.MSRP_Price__c*exchangeRatio, DNet_Price__c=qis.DNet_Price__c*exchangeRatio, Award_Price__c=qis.Award_Price__c*exchangeRatio));	
    			updateSublines.add(new REVVY__MnQuoteItemSubline__c(Id=qis.External_Id__c, REVVY__Price__c=qis.MSRP_Price__c*exchangeRatio, REVVY__SuggestedPrice__c=qis.DNet_Price__c*exchangeRatio));
    		}
    	}
    }
    system.debug(updateToroQuoteItems);
    system.debug(updateToroSublines);
    
    if(updateToroQuoteItems.size() > 0) {
    	update updateToroQuoteItems;	
    }
    if(updateToroSublines.size() > 0) {
    	update updateToroSublines;	
    }
    if(updateToroQuoteItems.size() > 0) {
    	update updateToroQuoteItems;	
    }
    if(updateQuoteItems.size() > 0) {
    	update updateQuoteItems;	
    }
    if(updateSublines.size() > 0) {
    	update updateSublines;	
    }
    
}