public with sharing class ToroContractPriceListPPHelper extends ToroStateContractPricingProgramHelper { 
	public override List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)}; 
		system.debug('ToroContractPriceListPPHelper--' +  rebates);
		system.debug('ToroContractPriceListPPHelper--' +  rebates);
		system.debug('ToroContractPriceListPPHelper--' +  rebates);
		for(Revvy__MnStrategy1__c pp : rebates) {
			system.debug('ToroContractPriceListPPHelper--'+pp);
			String priceListId = pp.OverriddenPriceList__c; 
			
			system.debug('ToroContractPriceListPPHelper--priceListId='+priceListId);
			Map<String, revvy__MnPriceListLine__c> prodPriceListLineMap = new Map<String, revvy__MnPriceListLine__c>();
			List<revvy__MnPriceListLine__c> plis = [SELECT Id, revvy__ListedPrice__c,revvy__SuggestedPrice__c,revvy__product__c,
				revvy__product__r.revvy__Id__c 
				FROM revvy__MnPriceListLine__c  WHERE revvy__PriceList__c = :priceListId];
			system.debug('ToroContractPriceListPPHelper--plis='+plis);
			for(revvy__MnPriceListLine__c ppl : plis) {
				prodPriceListLineMap.put(ppl.revvy__product__r.revvy__Id__c, ppl);		
			}
			system.debug('ToroContractPriceListPPHelper--prodPriceListLineMap='+prodPriceListLineMap);
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				if(prodPriceListLineMap.containsKey(qi.Product_Id__c)) {
					revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qi.Product_Id__c);
					qi.MSRP_Price__c = ppl.revvy__ListedPrice__c;
					qi.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
					system.debug('ToroContractPriceListPPHelper--' + qi.MSRP_Price__c + '---' + qi.DNet_Price__c);
				} else {
					system.debug('ToroContractPriceListPPHelper-- qi not in price list--' + qi.Product_Id__c);
				}
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(prodPriceListLineMap.containsKey(qis.Product_Id__c)) {
							revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qis.Product_Id__c);
							qis.MSRP_Price__c = ppl.revvy__ListedPrice__c;
							qis.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
							system.debug('ToroContractPriceListPPHelper-- qis ' + qis.MSRP_Price__c + '---' + qis.DNet_Price__c);
						} else {
							system.debug('ToroContractPriceListPPHelper-- qis not in price list--' + qis.Product_Id__c);
						}			
					}
				}	
			}
		}
		return 	quoteItemList;
	}     
}