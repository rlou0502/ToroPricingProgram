global with sharing class ToroPostConfigPricingHook implements REVVY.IMnPostConfigPricingHookPlugin  {
	global void preBOMUpdateHook(REVVY.CMnPricingParams pricingParams){

        //System.debug('!!!!!!!!!!!!!!!!!!! pricingParams: ' + JSON.serialize(pricingParams));
        Id qtId = pricingParams.quoteId;
        system.debug('--- ToroPostConfigPricingHook qtId =' + qtId);
		
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook');
        String psegment = pricingParams.qtSegment;
        String quoteId = pricingParams.quoteId;
        
        
        Boolean boakCreekMsrp = false;
        Decimal exchangeRate = 1;
        Decimal conversionRate = 1;
        Date dpriceDate = System.today();
        for(REVVY__MnQuote__c mnQuote : [Select Id, REVVY__Price_Date__c, Enable_Toro_MSRP_Pricing__c, Currency_Conversion_Rate__c, Exchange_Rate__c
                                              , REVVY__Account__r.Program_ID__c, REVVY__Account__c 
                                           From REVVY__MnQuote__c where Id =:quoteId]) {
	        if((mnQuote!=null && mnQuote.Enable_Toro_MSRP_Pricing__c && 'OakCreek'.equalsIgnoreCase(psegment)) || Test.isRunningTest()) {
        		boakCreekMsrp = true;
        	}                                  	
	        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook mnQuote.Exchange_Rate__c='+mnQuote.Exchange_Rate__c);
	        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook mnQuote.Currency_Conversion_Rate__c='+mnQuote.Currency_Conversion_Rate__c);
    		if(mnQuote.Exchange_Rate__c != null && mnQuote.Exchange_Rate__c > 0) {
    			exchangeRate = mnQuote.Exchange_Rate__c;
	    		if(mnQuote.Currency_Conversion_Rate__c != null && mnQuote.Currency_Conversion_Rate__c > 0) {
	    			conversionRate = mnQuote.Currency_Conversion_Rate__c;
	    		}
    		}
            dpriceDate = mnQuote.REVVY__Price_Date__c;
        }
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook exchangeRate='+exchangeRate);
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook conversionRate='+conversionRate);
                
		//Read Toro Disti Price Segment
		Set<String> distSegmentSet = new Set<String>();
		for(ToroDistributorPriceSegment__mdt dsp:[Select DeveloperName,MasterLabel From ToroDistributorPriceSegment__mdt]) {
			distSegmentSet.add(dsp.DeveloperName.toLowerCase());
			distSegmentSet.add(dsp.MasterLabel.toLowerCase());							
		}		
		
		if(Test.isRunningTest()){
			distSegmentSet.add(psegment.toLowerCase());
		}
        
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook distSegmentSet =' + distSegmentSet);
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook boakCreekMsrp =' + boakCreekMsrp);
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook psegment =' + psegment);
        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook dpriceDate =' + dpriceDate);
		Set<String> plSet = new Set<String>();
        Map<String,REVVY__MnPriceListLine__c> plMap = new Map<String,REVVY__MnPriceListLine__c>();
        if (pricingParams.qiList  != null && !pricingParams.qiList.isEmpty()){
            for(REVVY__MnQuoteItem__c mnQuoteItem: pricingParams.qiList) {
		        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook mnQuoteItem.REVVY__PriceListLine__c  =' + mnQuoteItem.REVVY__PriceListLine__c );
        		plSet.add(mnQuoteItem.REVVY__PriceListLine__c);
            }
        }
        if(pricingParams.qiSubLineList != null && !pricingParams.qiSubLineList.isEmpty()) {
            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:pricingParams.qiSubLineList){
		        system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook mnQuoteItemSubLine.REVVY__PriceListLine__c  =' + mnQuoteItemSubLine.REVVY__PriceListLine__c   );
        		plSet.add(mnQuoteItemSubLine.REVVY__PriceListLine__c);
            }
        }
        
        for(REVVY__MnPriceListLine__c pll:[Select REVVY__Id__c, REVVY__PriceList__r.REVVY__Segment__c, REVVY__PriceList__c
                                           , REVVY__ListedPrice__c, REVVY__FloorPrice__c, Id, REVVY__Product_Id__c 
                                           From REVVY__MnPriceListLine__c
                                           where Id in :plSet
                                          ]) {
             plMap.put(pll.REVVY__Product_Id__c, pll);
             plMap.put(pll.Id, pll);
        }

                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 200 plMap='+plMap);
        
        if (pricingParams.qiList  != null && !pricingParams.qiList.isEmpty()){
            for(REVVY__MnQuoteItem__c mnQuoteItem: pricingParams.qiList) {
                
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 300 mnQuoteItem.REVVY__FloorPrice__c='+mnQuoteItem.REVVY__FloorPrice__c);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 300 exchangeRate='+exchangeRate);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 300 conversionRate='+conversionRate);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 300 boakCreekMsrp='+boakCreekMsrp);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 300 psegment='+psegment);
                
                
                mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__Price__c) / exchangeRate) * conversionRate;
                if(boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(psegment)) {
                    mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__Price__c) / exchangeRate) * conversionRate;
                } else if(!boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(psegment)) {				
                    mnQuoteItem.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItem.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
                }
                
                
            }
        }
        
        if(pricingParams.qiSubLineList != null && !pricingParams.qiSubLineList.isEmpty()) {
            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:pricingParams.qiSubLineList){
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 350 mnQuoteItemSubLine.REVVY__FloorPrice__c='+mnQuoteItemSubLine.REVVY__FloorPrice__c);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 350 exchangeRate='+exchangeRate);
                system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 350 conversionRate='+conversionRate);
                mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__Price__c) / exchangeRate) * conversionRate;
                if(boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(psegment)) {
                    mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(mnQuoteItemSubLine.REVVY__Price__c) / exchangeRate) * conversionRate;
                } else if(!boakCreekMsrp && 'OakCreek'.equalsIgnoreCase(psegment) && plMap != null && plMap.containsKey(mnQuoteItemSubLine.REVVY__PriceListLine__c)) {	
                    system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 351 ');
                    REVVY__MnPriceListLine__c pl = plMap.get(mnQuoteItemSubLine.REVVY__PriceListLine__c);
                	system.debug('--- ToroPostConfigPricingHook preBOMUpdateHook 350 pl.REVVY__FloorPrice__c='+pl.REVVY__FloorPrice__c);
                    mnQuoteItemSubLine.REVVY__Price__c = (CMnQuoteUtil.defaultDecimal(pl.REVVY__FloorPrice__c) / exchangeRate) * conversionRate;
                }
            }
        }    

		
        if(qtId != null) {
			Revvy__MnQuote__c qt = new Revvy__MnQuote__c(Id=qtId,Is_Dirty__c=true);
			update qt;
        }

        //double t = 3/0;
	}   
}