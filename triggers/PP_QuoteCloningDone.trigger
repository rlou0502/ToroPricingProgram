trigger PP_QuoteCloningDone on REVVY__MnQuote__c (after update) {
	//Cloning in progress...
	List<REVVY__MnQuote__c> qis = (List<REVVY__MnQuote__c>) trigger.new;   
    
    List<Id> quoteIds = new List<Id>();
    List<Id> originalQuoteIds = new List<Id>();
	List<REVVY__MnQuote__c> clonedQuotes = new List<REVVY__MnQuote__c>();
    for(REVVY__MnQuote__c qi : qis) {
        System.debug('old subphase= ' + Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c + ' new subphase= ' + qi.REVVY__SubPhase__c + ' InCloning =' + ToroTriggerRunOnce.getInCloning());
        if(Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c == 'Revision in progress...' && qi.REVVY__SubPhase__c == 'Draft') {
        	ToroTriggerRunOnce.setInCloning(true);  	    
        } else if(Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c == 'Copying Items Within Quote' && qi.REVVY__SubPhase__c == 'Draft') {
        	ToroTriggerRunOnce.setInCloning(true);
        } else if(Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c == 'Draft' && qi.REVVY__SubPhase__c == 'Draft'){
            if(ToroTriggerRunOnce.getInCloning()) {
            	quoteIds.add(qi.Id);    
            	originalQuoteIds.add(qi.REVVY__OriginalQuote__c);
            }
        }
        
        //tQIs.add(new Revvy__MnStrategy4__c(External_Id__c = qi.Id, 
        //    MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c));        
    }
    system.debug('quote Id=' + quoteIds);
    List<REVVY__MnQuoteItem__c> qItemsUpdate = new List<REVVY__MnQuoteItem__c>();
    List<REVVY__MnQuoteItemSubline__c> qItemSublinesUpdate = new List<REVVY__MnQuoteItemSubline__c>();
    String PricingMethod = '';
    if(quoteIds.size() > 0) {
    	for(REVVY__MnQuote__c qi : [select id, REVVY__Segment__c, revvy__currency__c, REVVY__Price_Date__c,  REVVY__OriginalQuote__r.Revvy__Segment__c, Price_Method__c,
    								REVVY__OriginalQuote__r.revvy__currency__c, REVVY__OriginalQuote__r.REVVY__Price_Date__c from REVVY__MnQuote__c where id in :quoteIds]) {
    		PricingMethod = qi.Price_Method__c;
    		system.debug('cloning --- segment =' + qi.Revvy__Segment__c);
    		system.debug('cloning --- currency =' + qi.revvy__currency__c);
    		system.debug('cloning --- prce date =' + qi.REVVY__Price_Date__c);
    		if(qi.Revvy__Segment__c != qi.REVVY__OriginalQuote__r.Revvy__Segment__c) {
	    		qi.Revvy__Segment__c = qi.REVVY__OriginalQuote__r.Revvy__Segment__c;
	    		clonedQuotes.add(qi);
    		}	
    	}
    	try {
    		if(clonedQuotes.size() > 0) {
    			update clonedQuotes;
    		}
    	} catch (Exception e) {
    		//ignore this exception
    		system.debug('cloning --- exception =' + e);
    	}
    	List<REVVY__MnStrategy4__c> qItems = [Select Id, external_Id__c, (Select Id, external_Id__c From Toro_Quote_Item_Sub_Lines__r) From REVVY__MnStrategy4__c where Mn_Quote__c in :quoteIds];
        for(REVVY__MnStrategy4__c qi : qItems) {
            qItemsUpdate.add(new REVVY__MnQuoteItem__c(Id =qi.External_Id__c, Quote_Item_Extension__c = qi.Id));		
            for(REVVY__MnStrategy5__c sub : qi.Toro_Quote_Item_Sub_Lines__r) { 
                qItemSublinesUpdate.add(new REVVY__MnQuoteItemSubLine__c(Id =sub.External_Id__c, Quote_Item_Subline_Extension__c = sub.Id));
            }    
        } 
        system.debug('quote Id= is batch' + system.isBatch());
        
        if(qItemsUpdate.size() > 0) {
            update qItemsUpdate;
        }
        if(qItemSublinesUpdate.size() > 0) {
            update qItemSublinesUpdate;
        }
       
    }
    //only clone one quote a time
    if(quoteIds.size() == 1) {
    	List<REVVY__MnQuoteItem__c> clonedQuoteItems = new List<REVVY__MnQuoteItem__c>();
    	List<REVVY__MnStrategy4__c> clonedQuoteItemExts = new List<REVVY__MnStrategy4__c>();
    	Map<String, REVVY__MnQuoteItem__c> quoteItemMap = new Map<String, REVVY__MnQuoteItem__c>();
    	Map<String, REVVY__MnQuoteItemSubline__c> quoteItemSublineMap = new Map<String, REVVY__MnQuoteItemSubline__c>();
        for(REVVY__MnQuoteItem__c qi : [select REVVY__Price__c, REVVY__SuggestedPrice__c, revvy__product_id_f__c, 
        			pricing_Program__c, pricing_method_value__c,
        			Award_Price__c, Description__c, REVVY__Quote__c, (Select Id, REVVY__Price__c, REVVY__SuggestedPrice__c,
        			Award_Price__c,REVVY__Catalog_Node__r.REVVY__Id__c, pricing_method_value__c  From REVVY__QuoteItemSubLine__r) 
        			from REVVY__MnQuoteItem__c where REVVY__Quote__c in :originalQuoteIds]) {
        	quoteItemMap.put(qi.revvy__product_id_f__c+'_'+qi.Description__c, qi);	 
        	if(qi.REVVY__QuoteItemSubLine__r != null && !qi.REVVY__QuoteItemSubLine__r.isEmpty()) {
	            for(REVVY__MnQuoteItemSubLine__c sub : qi.REVVY__QuoteItemSubLine__r){
	            	quoteItemSublineMap.put(sub.REVVY__Catalog_Node__r.REVVY__Id__c, sub);		
	            }
			}    	
        }
        System.debug('quoteItemMap= ' + quoteItemMap);
        Map<Id, REVVY__MnQuoteItem__c> clonedQuoteItemMap = new Map<Id, REVVY__MnQuoteItem__c>();
        for(REVVY__MnQuoteItem__c qi : [select REVVY__Price__c, REVVY__SuggestedPrice__c, revvy__product_id_f__c, Award_Price__c, Description__c, REVVY__Quote__c from REVVY__MnQuoteItem__c where REVVY__Quote__c in :quoteIds]) {
        	if(quoteItemMap.containsKey(qi.revvy__product_id_f__c+'_'+qi.Description__c)){
        		REVVY__MnQuoteItem__c originalQI = quoteItemMap.get(qi.revvy__product_id_f__c+'_'+qi.Description__c);
        		qi.REVVY__Price__c = originalQI.REVVY__Price__c;
        		qi.REVVY__SuggestedPrice__c = originalQI.REVVY__SuggestedPrice__c; 	
        		qi.Award_price__c = originalQI.Award_price__c;
        		clonedQuoteItems.add(qi);	
        		clonedQuoteItemMap.put(qi.Id, qi);
        	}	
        }
        for(REVVY__MnStrategy4__c qi : [select id, External_Id__c, QuoteItem__r.pricing_program__c, QuoteItem__r.pricing_method_value__c from REVVY__MnStrategy4__c where External_Id__c in :clonedQuoteItemMap.keyset()]) {
        	REVVY__MnQuoteItem__c originalQI = clonedQuoteItemMap.get(qi.External_Id__c);
        	qi.MSRP_Price__c = originalQI.REVVY__Price__c;
        	qi.DNet_Price__c = originalQI.REVVY__SuggestedPrice__c;
        	qi.Award_Price__c = originalQI.Award_Price__c;
        	qi.Original_MSRP_Price__c = originalQI.REVVY__Price__c;
        	qi.pricing_program__c = qi.QuoteItem__r.pricing_program__c;
        	if ('Total Award $'.equalsIgnoreCase(PricingMethod)){
        		qi.Total_Toro_Award__c = qi.QuoteItem__r.pricing_method_value__c;			
			} else if ('Gross Profit %'.equalsIgnoreCase(PricingMethod)) {
				qi.Toro_Gross_Profit_Percent__c = qi.QuoteItem__r.pricing_method_value__c;
			} else if('% of DNET'.equalsIgnoreCase(PricingMethod)) {
				qi.Award_of_DN__c = qi.QuoteItem__r.pricing_method_value__c;
			} else  {
				qi.Off_MSRP__c = qi.QuoteItem__r.pricing_method_value__c;
			}
        	clonedQuoteItemExts.add(qi);	
        }
        	
        										
        System.debug('clonedQuoteItems= ' + clonedQuoteItems);	
        System.debug('clonedQuoteItemExts= ' + clonedQuoteItemExts);	
        if(clonedQuoteItems.size() > 0) {
        	update clonedQuoteItems;	
        }
        if(clonedQuoteItemExts.size() > 0) {
        	update clonedQuoteItemExts;	
        }
        
        List<REVVY__MnQuoteItemSubLine__c> clonedSublineUpdate = new List<REVVY__MnQuoteItemSubLine__c>();
        for(REVVY__MnQuoteItemSubLine__c qiSub : [select id, REVVY__Catalog_Node__r.REVVY__Id__c from REVVY__MnQuoteItemSubLine__c where REVVY__QuoteItem__r.Revvy__Quote__c in :quoteIds]) {
        	REVVY__MnQuoteItemSubLine__c originalSub = quoteItemSublineMap.get(qiSub.REVVY__Catalog_Node__r.REVVY__Id__c);	
        	if(originalSub != null) {
        		qiSub.REVVY__Price__c = originalSub.REVVY__Price__c;
        		qiSub.REVVY__SuggestedPrice__c = originalSub.REVVY__SuggestedPrice__c;
        		qiSub.Award_Price__c = 	originalSub.Award_Price__c;
        		clonedSublineUpdate.add(qiSub);
        	}	
        }
        if(clonedSublineUpdate.size() > 0) {
        	update clonedSublineUpdate;	
        }
        List<REVVY__MnStrategy5__c> clonedSublineExtUpdate = new List<REVVY__MnStrategy5__c>();
        
        for(REVVY__MnStrategy5__c qiSub : [select id, Product_Id__c, Quote_Item_Sub_Line__r.pricing_method_value__c from REVVY__MnStrategy5__c where Toro_Quote_Item_2__r.Mn_Quote__c in :quoteIds]) {
        	REVVY__MnQuoteItemSubLine__c originalSub = quoteItemSublineMap.get(qiSub.Product_Id__c);	
        	if(originalSub != null) {
        		qiSub.MSRP_Price__c = originalSub.REVVY__Price__c;
        		qiSub.DNet_Price__c = originalSub.REVVY__SuggestedPrice__c;
        		qiSub.Award_Price__c = 	originalSub.Award_Price__c;
        		if ('Total Award $'.equalsIgnoreCase(PricingMethod)){
	        		qiSub.Award_Price__c = qiSub.Quote_Item_Sub_Line__r.pricing_method_value__c;			
				} else if ('Gross Profit %'.equalsIgnoreCase(PricingMethod)) {
					qiSub.Gross_Profit_Percent__c = qiSub.Quote_Item_Sub_Line__r.pricing_method_value__c;
				} else if('% of DNET'.equalsIgnoreCase(PricingMethod)) {
					qiSub.Percent_of_DNet__c = qiSub.Quote_Item_Sub_Line__r.pricing_method_value__c;
				} else  {
					qiSub.Percent_Off_MSRP__c = qiSub.Quote_Item_Sub_Line__r.pricing_method_value__c;
				}
			
        		clonedSublineExtUpdate.add(qiSub);
        	}	
        }
        
        if(clonedSublineExtUpdate.size() > 0) {
        	update clonedSublineExtUpdate;	
        }
    }
}