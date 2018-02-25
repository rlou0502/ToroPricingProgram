trigger Populate_DNet_Price on REVVY__MnQuoteItemSubLine__c (before insert, before update) {
    List<REVVY__MnQuoteItemSubLine__c> sublines = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new; 
    List<Id> productIds = new List<Id>();
    List<Id> qiSublineIds = new List<Id>();
    for(REVVY__MnQuoteItemSubLine__c sl : sublines) {
        if(sl.Standard_Price__c == null) {
            sl.Standard_Price__c = sl.Revvy__Price__c;
        }
        productIds.add(sl.revvy__Catalog_Node__c);  
        qiSublineIds.add(sl.Id);    
    } 
    Id accountId = null;
    Date priceDate = null;
    String qtChannel = null;
    String qtCountry = null;
    String qtSegment = null;
    String qtCurrency = null;
         
    for(REVVY__MnQuoteItemSubLine__c  qisubLine : [select revvy__quoteItem__r.revvy__quote__r.REVVY__Account__c,
                                                            revvy__quoteItem__r.revvy__quote__r.REVVY__Price_Date__c,
                                                            revvy__quoteItem__r.revvy__quote__r.REVVY__Channel__c,
                                                            revvy__quoteItem__r.revvy__quote__r.REVVY__PriceCountry__c,
                                                            revvy__quoteItem__r.revvy__quote__r.REVVY__Segment__c,
                                                            revvy__quoteItem__r.revvy__quote__r.REVVY__Currency__c,
                                                            revvy__Catalog_Node__c, revvy__SuggestedPrice__c
                                                             from  REVVY__MnQuoteItemSubLine__c where id in :qiSublineIds])
    {
        accountId = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__Account__c;
        priceDate = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__Price_Date__c; 
        qtChannel = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__Channel__c;
        qtCountry = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__PriceCountry__c;
        qtSegment = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__Segment__c;
        qtCurrency = qisubLine.revvy__quoteItem__r.revvy__quote__r.REVVY__Currency__c;
        break;
    }
    Map<Id, decimal> product2SuggestedPrice = new Map<Id, decimal>();
    
    List<revvy__MnPriceListLine__c> plis = [SELECT Id, revvy__ListedPrice__c,revvy__PricingTier__c ,revvy__CostPrice__c,
                            revvy__FloorPrice__c,revvy__SuggestedPrice__c,revvy__PriceList__r.revvy__Priority__c, revvy__product__c,
                            revvy__PriceList__r.revvy__Account__c, revvy__PriceList__r.revvy__Contract__c FROM revvy__MnPriceListLine__c  
                            WHERE revvy__product__r.revvy__type__c IN ('Product', 'Bundle') AND 
                            revvy__product__r.revvy__effective_start_date__c <= TODAY AND 
                            revvy__product__r.revvy__effective_end_date__c >= TODAY AND 
                            revvy__product__r.revvy__status__c = 'Active'  AND  revvy__product__c = :productIds  AND
                            revvy__start_date__c <= :priceDate AND revvy__end_date__c >= :priceDate AND
                            revvy__PriceList__c IN (SELECT Id FROM revvy__MnPriceList__c WHERE  
                            revvy__Status__c='Active' AND  revvy__start_date__c <= :priceDate AND 
                            revvy__end_date__c >= :priceDate AND (revvy__Account__c= :accountId OR  
                            (revvy__PriceType__c='Price List' AND revvy__Channel__c = :qtChannel AND 
                            revvy__Country__c = :qtCountry )) AND revvy__segment__c = :qtSegment  AND revvy__currency__c = :qtCurrency )];
        system.debug(logginglevel.info, 'plis=' + plis);
    for(revvy__MnPriceListLine__c pli : plis) {
        product2SuggestedPrice.put(pli.revvy__product__c, pli.revvy__SuggestedPrice__c);    
    }   
    for(REVVY__MnQuoteItemSubLine__c sl : sublines) {
        if (Schema.sObjectType.REVVY__MnQuoteItemSubLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
            sl.DNet_Price_2__c = sl.REVVY__SuggestedPrice__c;
        } else {
            sl.DNet_Price_2__c = product2SuggestedPrice.get(sl.revvy__catalog_Node__c);
        }
    } 
    
}