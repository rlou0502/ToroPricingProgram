public virtual class ToroSecondaryPricingProgram {
	private static Map<String, Map<decimal, ToroPricingMethodData> >DNetPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >();    
	public virtual decimal retrieveRebatePercentBasedOnBlendedDNet(Revvy__MnStrategy4__c qi, decimal dnetPercent, String ppExtId, String primaryExtId) {
		return retrieveRebatePercent(dnetPercent, ppExtId);
	}
	public decimal retrieveRebatePercent(decimal dnetPercent, String ppExtId) {
		if(dnetPercent == null) {
			return 0;	
		}
		decimal rebatePercent = 0;
		system.debug(logginglevel.info, 'retrieveRebatePercentBasedOnBlendedDNet-- ppExtId=' + ppExtId);
		if(!DNetPercentMap.containsKey(ppExtId)) {
			Revvy__MnStrategy1__c pp = ToroCacheManager.getPricingProgram(ppExtId);
			//Equipment Partnership
			List<Revvy__MnStrategy2__c> pplList = pp.PricingProgramLines__r;
			if(pplList != null && pplList.size() == 1) {
				Revvy__MnStrategy2__c ppl = pp.PricingProgramLines__r[0];
				if(ppl.Award_Price_as_a_Percent_of_DN__c == null && ppl.Rebate_as_a_Percent_of_DN__c != null) {
					return ppl.Rebate_as_a_Percent_of_DN__c;	
				}		
			}
		    Map<decimal, ToroPricingMethodData> dnet2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Revvy__MnStrategy2__c  ppl : pplList) {
		    	ToroPricingMethodData pmd = new ToroPricingMethodData();
		    	
				ppl.Award_Price_as_a_Percent_of_DN__c = CMnQuoteUtil.defaultDecimal(ppl.Award_Price_as_a_Percent_of_DN__c);

		    	dnet2PM.put((ppl.Award_Price_as_a_Percent_of_DN__c).setScale(5, roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, null));	
		    }
			DNetPercentMap.put(ppExtId, dnet2PM);	
		}
		system.debug(logginglevel.info, 'retrieveRebatePercentBasedOnBlendedDNet-- dnetPercent=' + dnetPercent);	
		system.debug(logginglevel.info, 'retrievePricingInfoForDNet-- DNetPercentMap=' + DNetPercentMap);	
		dnetPercent = dnetPercent.setScale(5, roundingMode.HALF_UP);
		//System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnetPercent = ' + dnetPercent  );
		//System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent) = ' + (DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent))  );
		//System.debug(logginglevel.info, 'DNetPercentMap.containsKey(ppExtId)=' + DNetPercentMap.containsKey(ppExtId));
		//System.debug(logginglevel.info, 'DNetPercentMap.get(ppExtId).containsKey(dnetPercent) =' + DNetPercentMap.get(ppExtId).containsKey(dnetPercent));
		if(DNetPercentMap.containsKey(ppExtId) && DNetPercentMap.get(ppExtId).containsKey(dnetPercent)) {
			rebatePercent = DNetPercentMap.get(ppExtId).get(dnetPercent).rebatePercent;
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- rebatePercent ='  + rebatePercent);
		} else if(DNetPercentMap.containsKey(ppExtId)) {
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- no exact match'); 
			ToroPricingMethodData topRow = null;
			ToroPricingMethodData bottomRow = null;
			//conver dnetPercent to percent format
			Map<decimal, ToroPricingMethodData> dnet2PMMap = DNetPercentMap.get(ppExtId);
			//System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[0].percentOfDNet ='  + dnet2PMMap.values()[0].percentOfDNet);
			//System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet ='  + dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet);
			if(dnet2PMMap != null && dnet2PMMap.size() > 0) {
				if(dnetPercent >= dnet2PMMap.values()[0].percentOfDNet) {
					rebatePercent = dnet2PMMap.values()[0].rebatePercent;
					System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- cap at max ' + rebatePercent  ); 
				} else if(dnetPercent <= dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet){
					rebatePercent = dnet2PMMap.values()[dnet2PMMap.values().size()-1].rebatePercent;
					System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- cap at min ' + rebatePercent  );
				} else {
					for(integer i=0; i < dnet2PMMap.values().size()-1; i++) {
						//system.debug(logginglevel.info,'------------dnet2PMMap.values()[i]----------' + dnet2PMMap.values()[i]);
						system.debug(dnetPercent + '---' + dnet2PMMap.values()[i].percentOfDNet + '---' + dnet2PMMap.values()[i+1].percentOfDNet);
						if(dnetPercent < dnet2PMMap.values()[i].percentOfDNet && dnetPercent > dnet2PMMap.values()[i+1].percentOfDNet ) {
							topRow = dnet2PMMap.values()[i];
							bottomRow = dnet2PMMap.values()[i+1];
							break;
						}	
					}  
					if(topRow != null && bottomRow != null) {
						decimal x1=topRow.percentOfDNet/100;
						decimal x2=bottomRow.percentOfDNet/100;
						decimal y1=topRow.rebatePercent/100;
						decimal y2=bottomRow.rebatePercent/100;
						decimal x3 = dnetPercent/100;
						rebatePercent  = y2 -(((x3-x2)*(y2-y1)) * 100);
						
						system.debug(logginglevel.info,'retrievePricingInfoForDNet---x1----' + x1 + '  x2= ' + x2 + ' y1=' + y1 + ' y2=' + y2 + 'x3=' + x3 + ' ' + rebatePercent);
						rebatePercent = rebatePercent*100;
					}   
					System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- calculated ' + rebatePercent  );       
				}
			}
		}
		return rebatePercent;
	} 
}