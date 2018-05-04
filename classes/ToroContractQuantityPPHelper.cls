public with sharing class ToroContractQuantityPPHelper extends ToroStateContractPricingProgramHelper  {
	public class InnerClass implements Comparable {
		public InnerClass(decimal min, decimal max, Revvy__MnStrategy2__c ppl) {
			this.maxQty = max;
			this.minQty = min;
			this.ppl = ppl;	
		}
		public decimal maxQty { get; set;}
		public decimal minQty { get; set; }
		public Revvy__MnStrategy2__c ppl { get; set;}
		public Integer compareTo(Object compareTo) {
	        InnerClass compareToEmp = (InnerClass)compareTo;
	        if (compareToEmp.minQty < this.minQty) {
	        	 return 1; 
	        } else if(compareToEmp.minQty > this.minQty ){
	        	return -1;
	        } else {
	        	return 0;
	        }    
	    }
	}
	
	public override List<Revvy__MnStrategy4__c> baseCalculateImplementation(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		Integer numOfTractionUnits = CMnQuoteUtil.getNumberOfTractionUnits(quoteItemList);
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		List<ToroContractQuantityPPHelper.InnerClass> qtyTiers = new List<ToroContractQuantityPPHelper.InnerClass>();
		for(Revvy__MnStrategy1__c rh : rebates) {
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					qtyTiers.add(new ToroContractQuantityPPHelper.InnerClass(l.min_qty__c, l.max_qty__c, l));		
				}
			}
		}
		qtyTiers.sort();
		decimal minQty = qtyTiers[0].minQty;
		decimal maxQty = qtyTiers[qtyTiers.size()-1].maxQty;
		system.debug('tier : ' + qtyTiers + ' minQty:' + minQty + ' maxQty:' + maxQty);
		Revvy__MnStrategy2__c line = null;
		if(numOfTractionUnits <= minQty)  {
			line = qtyTiers[0].ppl;	
		} else if(numOfTractionUnits >= maxQty) {
			line = qtyTiers[qtyTiers.size()-1].ppl;
		} else {
			for(ToroContractQuantityPPHelper.InnerClass qtyTier : qtyTiers) {
				if(numOfTractionUnits >= qtyTier.minQty && numOfTractionUnits <= qtyTier.maxQty) {
					line = qtyTier.ppl;	
				}		
			}
		}
		
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(line != null) {
				qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
				qi.Original_off_MSRP__c = qi.Off_MSRP__c;
				qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
				qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
				qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);
				system.debug(logginglevel.info,'basePrice =' + qi.msrp_Price__c + ' qi.Off_MSRP__c=' + qi.Off_MSRP__c);
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = qi.msrp_Price__c * (100-qi.Off_MSRP__c)/100;
				}
				qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;	
			}
			if(excludedFromMSRP(qi)) {
				qi.Off_MSRP__c = 0;	
			}				
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Percent_of_DNet__c = qi.Award_of_DN__c;
					qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;	
					qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);
					if(!qis.Unit_Award_Overridden__c) {			
						qis.Award_Price__c = qis.MSRP_Price__c * (100-qis.Percent_Off_MSRP__c)/100;
					}
					if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
						qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
					}
					if(excludedFromMSRP(qis)) {
						qis.Percent_Off_MSRP__c = 0;	
					}								
				}
			}	
		}
		return quoteItemList; 															
	}    
}