public with sharing class ToroPricingProgramUtil {
	public static List<Revvy__MnStrategy4__c> loadPricesFromPricelist(String priceProgram, List<Revvy__MnStrategy4__c> quoteItemList ){
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
				revvy__product__r.revvy__Id__c, revvy__PriceField1__c
				FROM revvy__MnPriceListLine__c  WHERE revvy__PriceList__c = :priceListId];
			system.debug('ToroContractPriceListPPHelper--plis='+plis);
			for(revvy__MnPriceListLine__c ppl : plis) {
				prodPriceListLineMap.put(ppl.revvy__product__r.revvy__Id__c, ppl);		
			}
			system.debug('ToroContractPriceListPPHelper--prodPriceListLineMap='+prodPriceListLineMap);
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				if(prodPriceListLineMap.containsKey(qi.Product_Id__c)) {
					revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qi.Product_Id__c);
					//qi.MSRP_Price__c = ppl.revvy__ListedPrice__c;
					//qi.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
					if(ppl.revvy__PriceField1__c != null) {
						qi.Award_price__c = ppl.revvy__PriceField1__c;
						qi.OnlyExistedInCPL__c= false;	
					} else {
						if(!qi.Unit_Award_Overridden__c) {
							qi.Award_price__c = 0;
						}
						qi.OnlyExistedInCPL__c= true;
					}
					system.debug('ToroContractPriceListPPHelper test-- qi product = ' + qi.Product_Name__c + '  --- ' +ppl.revvy__PriceField1__c );
					
				} else {
					if(!qi.Unit_Award_Overridden__c) {
						qi.Award_price__c = 0;
					}
					qi.OnlyExistedInCPL__c= true;
					system.debug('ToroContractPriceListPPHelper-- qi not in price list--' + qi.Product_Id__c);
				}
				system.debug('ToroContractPriceListPPHelper--product = ' + qi.Product_Name__c + '  -OnlyExistedInCPL__c-- ' + qi.OnlyExistedInCPL__c);
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(prodPriceListLineMap.containsKey(qis.Product_Id__c)) {
							revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qis.Product_Id__c);
							//qis.MSRP_Price__c = ppl.revvy__ListedPrice__c;
							//qis.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
							if(ppl.revvy__PriceField1__c != null) {
								qis.Award_price__c = ppl.revvy__PriceField1__c;
								qis.OnlyExistedInCPL__c= false;	
							} else {
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_price__c = 0;
								}
								qis.OnlyExistedInCPL__c= true;
							}
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- ' +ppl.revvy__PriceField1__c + '--OnlyExistedInCPL__c=' + qis.OnlyExistedInCPL__c );
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- award price ' +qis.Award_price__c + ' overridden flag='+ qis.Unit_Award_Overridden__c );
						} else {
							qis.OnlyExistedInCPL__c= true;
							if(!qis.Unit_Award_Overridden__c) {
								qis.Award_price__c = 0;
							}
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- award price ' +qis.Award_price__c );
						}
						system.debug('ToroContractPriceListPPHelper--product = ' + qis.Product_Name__c + '  -OnlyExistedInCPL__c-- ' + qis.OnlyExistedInCPL__c);			
					}
				}	
			}
		}
		return 	quoteItemList;															
	}    
}