global with sharing class ToroPricingHook implements Revvy.IMnPricingHookPlugin  {
	public static List<Revvy__MnQuoteItem__c> preQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis) {
        system.debug('--- ToroPricingHook preQuoteItemsCreationHook');
        return qis;
    }
    public static Map<String, Decimal> productSearchPriceHook(Revvy.CMnPricingParams pricingParams, Map<String, Decimal> prodsMap) {
        system.debug('--- ToroPricingHook productSearchPriceHook');
        String psegment = pricingParams.qtSegment;
        String quoteId = pricingParams.quoteId;
        
        Boolean bcorpAccount = false;
        Decimal exchangeRate = 1;
        Decimal conversionRate = 1;
        for(REVVY__MnQuote__c mnQuote : [Select Id, Currency_Conversion_Rate__c, Exchange_Rate__c
                                              , REVVY__Account__r.Program_ID__c, REVVY__Account__c 
                                           From REVVY__MnQuote__c where Id =:quoteId]) {
        	if(!String.isEmpty(mnQuote.REVVY__Account__r.Program_ID__c)) {
        		bcorpAccount = true;
        	}                                  	
	        system.debug('--- ToroPricingHook productSearchPriceHook mnQuote.Exchange_Rate__c='+mnQuote.Exchange_Rate__c);
	        system.debug('--- ToroPricingHook productSearchPriceHook mnQuote.Currency_Conversion_Rate__c='+mnQuote.Currency_Conversion_Rate__c);
    		if(mnQuote.Exchange_Rate__c != null && mnQuote.Exchange_Rate__c > 0) {
    			exchangeRate = mnQuote.Exchange_Rate__c;
	    		if(mnQuote.Currency_Conversion_Rate__c != null && mnQuote.Currency_Conversion_Rate__c > 0) {
	    			conversionRate = mnQuote.Currency_Conversion_Rate__c;
	    		}
    		}
        }
        system.debug('--- ToroPricingHook productSearchPriceHook exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook productSearchPriceHook conversionRate='+conversionRate);
                
		//Read Toro Disti Price Segment
		Set<String> distSegmentSet = new Set<String>();
		for(ToroDistributorPriceSegment__mdt dsp:[Select DeveloperName,MasterLabel From ToroDistributorPriceSegment__mdt]) {
			distSegmentSet.add(dsp.DeveloperName.toLowerCase());
			distSegmentSet.add(dsp.MasterLabel.toLowerCase());							
		}		
        
        system.debug('--- ToroPricingHook productSearchPriceHook psegment =' + psegment);
        system.debug('--- ToroPricingHook productSearchPriceHook prodsMap.keySet =' + prodsMap.keyset());
		if(!bcorpAccount && distSegmentSet.contains(psegment.toLowerCase())) {
			
			Map<String,REVVY__MnPriceListLine__c> plMap = new Map<String,REVVY__MnPriceListLine__c>();
			for(REVVY__MnPriceListLine__c pll:[Select REVVY__Id__c, REVVY__PriceList__r.REVVY__Segment__c, REVVY__PriceList__c
			             , REVVY__ListedPrice__c, REVVY__FloorPrice__c, Id, REVVY__Product_Id__c 
			             From REVVY__MnPriceListLine__c
			             where REVVY__Product_Id__c in :prodsMap.KeySet()
			               And REVVY__PriceList__r.REVVY__Segment__c = :psegment
			             ]) {
				plMap.put(pll.REVVY__Product_Id__c, pll);
			}
	        system.debug('--- ToroPricingHook productSearchPriceHook plMap size=' + plMap.size());
	        system.debug('--- ToroPricingHook productSearchPriceHook plMap =' + plMap);
	        for (String prodName : prodsMap.keyset()) {
				if(plMap.containsKey(prodName)) {
					REVVY__MnPriceListLine__c pll = plMap.get(prodName);
					Decimal damount = (pll.REVVY__FloorPrice__c / exchangeRate) * conversionRate;
			        system.debug('--- ToroPricingHook productSearchPriceHook damount =' + damount);
					prodsMap.put(prodName,damount);
				}	        	
	        }
			
		}
        
        
        return prodsMap;
    }
    public static Decimal productDetailPriceHook(Revvy.CMnPricingParams pricingParams, String productId, Decimal currPrice) {
        system.debug('--- ToroPricingHook productDetailPriceHook');
        return currPrice;
    }
    public static List<Revvy__MnQuoteItem__c> postQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis) {
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook');
		String qtSegment = qt.REVVY__Segment__c;
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook qtSegment='+qtSegment);
        
		//Read Toro Disti Price Segment
		Set<String> distSegmentSet = new Set<String>();
		for(ToroDistributorPriceSegment__mdt dsp:[Select DeveloperName,MasterLabel From ToroDistributorPriceSegment__mdt]) {
			distSegmentSet.add(dsp.DeveloperName.toLowerCase());
			distSegmentSet.add(dsp.MasterLabel.toLowerCase());							
		}		
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook distSegmentSet =' + distSegmentSet);
		if(distSegmentSet.contains(qtSegment.toLowerCase())) {
	        system.debug('--- ToroPricingHook postQuoteItemsCreationHook Inside =' + distSegmentSet);
	        Boolean bcorpAccount = false;
	        Decimal exchangeRate = 1;
	        Decimal conversionRate = 1;
	        for(REVVY__MnQuote__c mnQuote : [Select Id, Currency_Conversion_Rate__c, Exchange_Rate__c
	                                              , REVVY__Account__r.Program_ID__c, REVVY__Account__c 
	                                           From REVVY__MnQuote__c where Id =:qt.Id]) {
	        	if(!String.isEmpty(mnQuote.REVVY__Account__r.Program_ID__c)) {
	        		bcorpAccount = true;
	        	}         	
        		if(mnQuote.Exchange_Rate__c != null && mnQuote.Exchange_Rate__c > 0) {
        			exchangeRate = mnQuote.Exchange_Rate__c;
	        		if(mnQuote.Currency_Conversion_Rate__c != null && mnQuote.Currency_Conversion_Rate__c > 0) {
	        			conversionRate = mnQuote.Currency_Conversion_Rate__c;
	        		}
        		}
	        }
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 bcorpAccount='+bcorpAccount);
			if (!bcorpAccount && qis != null && !qis.isEmpty()){
	            for(REVVY__MnQuoteItem__c mnQuoteItem: qis){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c
	            	
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 mnQuoteItem.REVVY__FloorPrice__c='+mnQuoteItem.REVVY__FloorPrice__c);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 conversionRate='+conversionRate);
	            	mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
	            	System.debug('--- ToroPricingHook postQuoteItemsCreationHook  mnQuoteItem.REVVY__QuoteItemSubLine__r = '+ mnQuoteItem.REVVY__QuoteItemSubLine__r);
	            	if(mnQuoteItem.REVVY__QuoteItemSubLine__r != null && !mnQuoteItem.REVVY__QuoteItemSubLine__r.isEmpty()) {
			            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:mnQuoteItem.REVVY__QuoteItemSubLine__r){
			            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c  
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 mnQuoteItemSubLine.REVVY__FloorPrice__c='+mnQuoteItemSubLine.REVVY__FloorPrice__c);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 conversionRate='+conversionRate);
			            	mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
			            }
	            	}
	            }
	        }
		}
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook FINAL qis='+qis);
        return qis;
    }
     
}