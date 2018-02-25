global with sharing class CMnPricingHook implements Revvy.IMnPricingHookPlugin  {
	public static List<Revvy__MnQuoteItem__c> preQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis) {
		system.debug(Logginglevel.info, 'preQuoteItemsCreationHook');
        /*
        if (qis == null || qis.size() == 0) return qis;
        system.debug(Logginglevel.info, 'qis.size() =' + qis.size());
        List<Id> productIds = new List<Id>();
        for(Revvy__MnQuoteItem__c qi : qis) {
            productIds.add(qi.REVVY__Catalog_Node__c);    
        }
        Id accountId = qt.REVVY__Account__c;
        Date priceDate = qt.REVVY__Price_Date__c;
        String qtChannel = qt.REVVY__Channel__c;
        String qtCountry = qt.REVVY__PriceCountry__c;
        String qtSegment = qt.REVVY__Segment__c;
        String qtCurrency = qt.REVVY__Currency__c;

        List<revvy__MnPriceListLine__c> plis = [SELECT Id, revvy__ListedPrice__c,revvy__PricingTier__c ,revvy__CostPrice__c,
                            revvy__FloorPrice__c,revvy__SuggestedPrice__c,revvy__PriceList__r.revvy__Priority__c, 
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
		
        if (qis == null || qis.size() == 0) return qis;
        MnQuoteItem__c newQuoteItem = qis[0];
        qis[0].price__c = 500;
        System.debug('price is set to 500' + qis[0]);
        fakeCallout();
        */
        return qis;
    }
    public static Map<String, Decimal> productSearchPriceHook(Revvy.CMnPricingParams pricingParams, Map<String, Decimal> prodsMap) {
        system.debug(Logginglevel.info, 'productSearchPriceHook');
        system.debug(Logginglevel.info, pricingParams);
        system.debug(Logginglevel.info, prodsMap);
        //integer w = 3/0;
        /*
        if (prodsMap == null || prodsMap.size() == 0) return prodsMap;
        prodsMap.values()[0] = 222;
        String junkstr = '';
        for (String prodName : prodsMap.keyset()) {
            junkstr = junkstr + ' ' + prodsMap.get(prodName);
            prodsMap.put(prodName, 222);
        }
        System.debug('price is set to 222' + prodsMap.values()[0] + ' and key is ' + prodsMap.keyset());
        System.debug('junk str is ' + junkstr);
        fakeCallout();
        */
        return prodsMap;
    }
    public static Decimal productDetailPriceHook(Revvy.CMnPricingParams pricingParams, String productId, Decimal currPrice) {
        system.debug(Logginglevel.info, 'productDetailPriceHook');
        /*
        if (String.isBlank(productId)) return 0;
        Decimal retval = 111;
        System.debug('price is set to 111' + retval + ' old price ' + currPrice);
        fakeCallout();
        */
        return currPrice;
    }
    public static List<Revvy__MnQuoteItem__c> postQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis) {
        system.debug(Logginglevel.info, 'postQuoteItemsCreationHook');
        //return CMnPriceProgramUtil.calcRebateAndMargin(qt, qis);
        return qis;
    }
     
}