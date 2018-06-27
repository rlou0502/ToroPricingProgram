trigger PP_QuoteCloningDone on REVVY__MnQuote__c (after update) {
	//Cloning in progress...
	List<REVVY__MnQuote__c> qis = (List<REVVY__MnQuote__c>) trigger.new;   
    
    List<Id> quoteIds = new List<Id>();
    for(REVVY__MnQuote__c qi : qis) {
        System.debug('old subphase' + Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c);
        System.debug('new subphase' + qi.REVVY__SubPhase__c);
    	if(Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c == 'Cloning in progress...' && qi.REVVY__SubPhase__c == 'Draft') {
        	ToroTriggerRunOnce.setInCloning(true);	    
        } else if(Trigger.oldMap.get(qi.Id).REVVY__SubPhase__c == 'Draft' && qi.REVVY__SubPhase__c == 'Draft'){
            if(ToroTriggerRunOnce.getInCloning()) {
            	quoteIds.add(qi.Id);    
            }
        }
        
        //tQIs.add(new Revvy__MnStrategy4__c(External_Id__c = qi.Id, 
        //    MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c));        
    }
    system.debug('quote Id=' + quoteIds);
    List<REVVY__MnQuoteItem__c> qItemsUpdate = new List<REVVY__MnQuoteItem__c>();
    List<REVVY__MnQuoteItemSubline__c> qItemSublinesUpdate = new List<REVVY__MnQuoteItemSubline__c>();
    if(quoteIds.size() > 0) {
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
}