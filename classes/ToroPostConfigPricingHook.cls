global with sharing class ToroPostConfigPricingHook implements REVVY.IMnPostConfigPricingHookPlugin  {
	global void preBOMUpdateHook(REVVY.CMnPricingParams pricingParams){
		List<REVVY__MnQuoteItem__c> qiList = pricingParams.qiList;
        List<REVVY__MnQuoteItemSubLine__c> qislList = pricingParams.qiSubLineList;
        Map<String,List<REVVY.UserEnteredAttr>> attrMap = pricingParams.lineAndSublineAttrMap;
        system.debug('qiList =' + qiList);
        system.debug('qislList =' + qislList);
        system.debug('attrMap =' + attrMap);
        
		String qtCurrency = pricingParams.qtCurrency;
		String qtSegment = pricingParams.qtSegment;
		//
		if(qtCurrency == 'CAD' && qtSegment == 'Commercial') {
			 if ( qiList != null && qiList.size() != 0){
	            for(REVVY__MnQuoteItem__c mnQuoteItem: qiList){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c
	            }
	        }
	        if ( qislList != null && qislList.size() != 0){
	            for(REVVY__MnQuoteItemSubLine__c mnQuoteItemSubLine:qislList){
	            	//mnQuoteItem.REVVY__PriceListLine__r.REVVY__FloorPrice__c  
	            }
	        }		
		}
        //integer r = 12/0;
       
	}   
}