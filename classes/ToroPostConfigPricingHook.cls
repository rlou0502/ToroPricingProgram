global with sharing class ToroPostConfigPricingHook implements REVVY.IMnPostConfigPricingHookPlugin  {
	global void preBOMUpdateHook(REVVY.CMnPricingParams pricingParams){
		List<REVVY__MnQuoteItem__c> qiList = pricingParams.qiList;
        List<REVVY__MnQuoteItemSubLine__c> qislList = pricingParams.qiSubLineList;
        Map<String,List<REVVY.UserEnteredAttr>> attrMap = pricingParams.lineAndSublineAttrMap;
        system.debug('--- ToroPostConfigPricingHook qiList =' + qiList);
        system.debug('--- ToroPostConfigPricingHook qislList =' + qislList);
        system.debug('--- ToroPostConfigPricingHook attrMap =' + attrMap);
        
		String qtCurrency = pricingParams.qtCurrency;
		String qtSegment = pricingParams.qtSegment;
        system.debug('--- ToroPostConfigPricingHook qtSegment =' + qtSegment);
		//
		//Read Toro Disti Price Segment
		Set<String> distSegmentSet = new Set<String>();
		for(ToroDistributorPriceSegment__mdt dsp:[Select DeveloperName,MasterLabel From ToroDistributorPriceSegment__mdt]) {
			distSegmentSet.add(dsp.DeveloperName.toLowerCase());
			distSegmentSet.add(dsp.MasterLabel.toLowerCase());							
		}		
        system.debug('--- ToroPostConfigPricingHook distSegmentSet =' + distSegmentSet);
		if(distSegmentSet.contains(qtSegment.toLowerCase())) {
	        system.debug('--- ToroPostConfigPricingHook Inside =' + distSegmentSet);
			 if ( qiList != null && qiList.size() != 0){
	            for(REVVY__MnQuoteItem__c mnQuoteItem: qiList){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c
	            	mnQuoteItem.REVVY__Price__c = mnQuoteItem.REVVY__FloorPrice__c;
	            	
	            }
	        }
	        if ( qislList != null && qislList.size() != 0){
	            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:qislList){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c  
	            	mnQuoteItemSubLine.REVVY__Price__c = mnQuoteItemSubLine.REVVY__FloorPrice__c;
	            }
	        }		
		}
        //integer r = 12/0;
       
	}   
}