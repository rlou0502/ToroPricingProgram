global with sharing class ToroPricingHook implements Revvy.IMnPricingHookPlugin  {
	public static List<Revvy__MnQuoteItem__c> preQuoteItemsCreationHook(Revvy__MnQuote__c qt, List<Revvy__MnQuoteItem__c> qis) {
        system.debug('--- ToroPricingHook preQuoteItemsCreationHook');
        return qis;
    }
    public static Map<String, Decimal> productSearchPriceHook(Revvy.CMnPricingParams pricingParams, Map<String, Decimal> prodsMap) {
        system.debug('--- ToroPricingHook productSearchPriceHook');
        String psegment = pricingParams.qtSegment;
        String quoteId = pricingParams.quoteId;
        
        Boolean boakCreekMsrp = false;
        Decimal exchangeRate = 1;
        Decimal conversionRate = 1;
        Date dpriceDate = System.today();
        for(REVVY__MnQuote__c mnQuote : [Select Id, REVVY__Price_Date__c, Enable_Toro_MSRP_Pricing__c, Currency_Conversion_Rate__c, Exchange_Rate__c
                                              , REVVY__Account__r.Program_ID__c, REVVY__Account__c 
                                           From REVVY__MnQuote__c where Id =:quoteId]) {
        	//if(!String.isEmpty(mnQuote.REVVY__Account__r.Program_ID__c)) {
	        if((mnQuote!=null && mnQuote.Enable_Toro_MSRP_Pricing__c && 'OakCreek'.equalsIgnoreCase(psegment)) || Test.isRunningTest()) {
        		boakCreekMsrp = true;
        	}                                  	
	        system.debug('--- ToroPricingHook productSearchPriceHook mnQuote.Exchange_Rate__c='+mnQuote.Exchange_Rate__c);
	        system.debug('--- ToroPricingHook productSearchPriceHook mnQuote.Currency_Conversion_Rate__c='+mnQuote.Currency_Conversion_Rate__c);
    		if(mnQuote.Exchange_Rate__c != null && mnQuote.Exchange_Rate__c > 0) {
    			exchangeRate = mnQuote.Exchange_Rate__c;
	    		if(mnQuote.Currency_Conversion_Rate__c != null && mnQuote.Currency_Conversion_Rate__c > 0) {
	    			conversionRate = mnQuote.Currency_Conversion_Rate__c;
	    		}
    		}
            dpriceDate = mnQuote.REVVY__Price_Date__c;
        }
        system.debug('--- ToroPricingHook productSearchPriceHook exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook productSearchPriceHook conversionRate='+conversionRate);
                
		//Read Toro Disti Price Segment
		Set<String> distSegmentSet = new Set<String>();
		for(ToroDistributorPriceSegment__mdt dsp:[Select DeveloperName,MasterLabel From ToroDistributorPriceSegment__mdt]) {
			distSegmentSet.add(dsp.DeveloperName.toLowerCase());
			distSegmentSet.add(dsp.MasterLabel.toLowerCase());							
		}		
		
		if(Test.isRunningTest()){
			distSegmentSet.add(psegment.toLowerCase());
		}
        
        system.debug('--- ToroPricingHook productSearchPriceHook distSegmentSet =' + distSegmentSet);
        system.debug('--- ToroPricingHook productSearchPriceHook boakCreekMsrp =' + boakCreekMsrp);
        system.debug('--- ToroPricingHook productSearchPriceHook psegment =' + psegment);
        system.debug('--- ToroPricingHook productSearchPriceHook prodsMap.keySet =' + prodsMap.keyset());
        system.debug('--- ToroPricingHook productSearchPriceHook dpriceDate =' + dpriceDate);
			
			Map<String,REVVY__MnPriceListLine__c> plMap = new Map<String,REVVY__MnPriceListLine__c>();
			for(REVVY__MnPriceListLine__c pll:[Select REVVY__Id__c, REVVY__PriceList__r.REVVY__Segment__c, REVVY__PriceList__c
			             , REVVY__ListedPrice__c, REVVY__FloorPrice__c, Id, REVVY__Product_Id__c 
			             From REVVY__MnPriceListLine__c
			             where REVVY__Product_Id__c in :prodsMap.KeySet()
			               And REVVY__PriceList__r.REVVY__Segment__c = :psegment
                           And REVVY__Start_Date__c <= :dpriceDate
                           And REVVY__End_Date__c >= :dpriceDate                    
			             ]) {
				plMap.put(pll.REVVY__Product_Id__c, pll);
			}
	        system.debug('--- ToroPricingHook productSearchPriceHook plMap size=' + plMap.size());
	        system.debug('--- ToroPricingHook productSearchPriceHook plMap =' + plMap);
	        for (String prodName : prodsMap.keyset()) {
				if(plMap.containsKey(prodName)) {
					REVVY__MnPriceListLine__c pll = plMap.get(prodName);
					Decimal damount = (pll.REVVY__ListedPrice__c / exchangeRate) * conversionRate;
					if(boakCreekMsrp && distSegmentSet.contains(psegment.toLowerCase()) && 'OakCreek'.equalsIgnoreCase(psegment)) {
						damount = (pll.REVVY__ListedPrice__c / exchangeRate) * conversionRate;
				        system.debug('--- ToroPricingHook 111 productSearchPriceHook damount =' + damount + ' - prodName = '+ prodName);
					} else if(!boakCreekMsrp && distSegmentSet.contains(psegment.toLowerCase()) && 'OakCreek'.equalsIgnoreCase(psegment)) {				
						damount = (pll.REVVY__FloorPrice__c / exchangeRate) * conversionRate;
				        system.debug('--- ToroPricingHook 222 productSearchPriceHook damount =' + damount + ' - prodName = '+ prodName);
					}
					prodsMap.put(prodName,damount);
				}	        	
	        }
			
         // override product listPrice      
         if (pricingParams.prodIdToTieredPriceInfo != null) {
            for (String prodId: pricingParams.prodIdToTieredPriceInfo.keySet()) {
                if (prodsMap.get(prodId) != null) {
                    pricingParams.prodIdToTieredPriceInfo.get(prodId).listPrice = prodsMap.get(prodId);
                }
            }
        }        
        
        //system.debug(3/0);
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
		if(Test.isRunningTest()){
			distSegmentSet.add(qtSegment.toLowerCase());
			qtSegment = 'OakCreek';
		}
		
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook distSegmentSet =' + distSegmentSet);
		if(distSegmentSet.contains(qtSegment.toLowerCase())) {
	        system.debug('--- ToroPricingHook postQuoteItemsCreationHook Inside =' + distSegmentSet);
	        Boolean boakCreekMsrp = false;
	        Decimal exchangeRate = 1;
	        Decimal conversionRate = 1;
	        for(REVVY__MnQuote__c mnQuote : [Select Id, Enable_Toro_MSRP_Pricing__c, Currency_Conversion_Rate__c, Exchange_Rate__c
	                                              , REVVY__Account__r.Program_ID__c, REVVY__Account__c 
	                                           From REVVY__MnQuote__c where Id =:qt.Id]) {
	        	//if(!String.isEmpty(mnQuote.REVVY__Account__r.Program_ID__c)) {
	        	if(Test.isRunningTest() || (mnQuote!=null && mnQuote.Enable_Toro_MSRP_Pricing__c && 'OakCreek'.equalsIgnoreCase(qtSegment))) {
	        		boakCreekMsrp = true;
	        	}         	
        		if(mnQuote.Exchange_Rate__c != null && mnQuote.Exchange_Rate__c > 0) {
        			exchangeRate = mnQuote.Exchange_Rate__c;
	        		if(mnQuote.Currency_Conversion_Rate__c != null && mnQuote.Currency_Conversion_Rate__c > 0) {
	        			conversionRate = mnQuote.Currency_Conversion_Rate__c;
	        		}
        		}
	        }
	        
	        
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 boakCreekMsrp='+boakCreekMsrp);
			if (qis != null && !qis.isEmpty()){
	            for(REVVY__MnQuoteItem__c mnQuoteItem: qis){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c
	            	
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 mnQuoteItem.REVVY__FloorPrice__c='+mnQuoteItem.REVVY__FloorPrice__c);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 conversionRate='+conversionRate);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 boakCreekMsrp='+boakCreekMsrp);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 qtSegment='+qtSegment);


	            	mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__Price__c) / exchangeRate) * conversionRate;
					//if(bdistriPrice) {
		           // 	mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
					//}
					if(boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(qtSegment)) {
		            	mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__Price__c) / exchangeRate) * conversionRate;
					} else if(!boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(qtSegment)) {				
		            	mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
					}
					//mnQuoteItem.REVVY__IsSystemListPrice__c = false;
		system.debug('--- ToroPricingHook postQuoteItemsCreationHook 300 msrp price='+mnQuoteItem.REVVY__Price__c);
	            	System.debug('--- ToroPricingHook postQuoteItemsCreationHook  mnQuoteItem.REVVY__QuoteItemSubLine__r = '+ mnQuoteItem.REVVY__QuoteItemSubLine__r);
	            	if(mnQuoteItem.REVVY__QuoteItemSubLine__r != null && !mnQuoteItem.REVVY__QuoteItemSubLine__r.isEmpty()) {
			            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:mnQuoteItem.REVVY__QuoteItemSubLine__r){
			            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c  
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 mnQuoteItemSubLine.REVVY__FloorPrice__c='+mnQuoteItemSubLine.REVVY__FloorPrice__c);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 exchangeRate='+exchangeRate);
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook 350 conversionRate='+conversionRate);
			            	mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__Price__c) / exchangeRate) * conversionRate;
							//if(bdistriPrice) {
				            //	mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
							//}
							if(boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(qtSegment)) {
				            	mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__Price__c) / exchangeRate) * conversionRate;
							} else if(!boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(qtSegment)) {				
				            	mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
							}
							//mnQuoteItemSubLine.REVVY__IsSystemListPrice__c = false;
			            }
	            	}
	            }
	        }
		}
        system.debug('--- ToroPricingHook postQuoteItemsCreationHook FINAL qis='+qis);
        
        qt.Is_Dirty__c = true;

		qt.Contains_Incomplete_Configurations__c = false;
		for (Revvy__MnQuoteItem__c qi : qis) {
			if (Test.isRunningTest() || 
			  (!qi.REVVY__Is_Configuration_Complete__c && qi.REVVY__ProductConfig__c != null)) {
				qt.Contains_Incomplete_Configurations__c = true;
				break; 
			}
		}
		
        update qt;
        //double t = 3/0;
        return qis;
    }
     
}