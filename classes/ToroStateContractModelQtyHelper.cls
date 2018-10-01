public virtual class ToroStateContractModelQtyHelper extends ToroStateContractPricingProgramHelper  {
	protected Map<String, Revvy__MnStrategy2__c> productPricingProgramLineMap = new Map<String, Revvy__MnStrategy2__c>();
	protected Revvy__MnStrategy2__c qtyTierLine = null;
	public virtual Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList, Set<String> inclusiveExclusiveModels) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good' && !inclusiveExclusiveModels.contains(quoteItem.Product_Id__c)) {
				count += (Integer) quoteItem.Quantity__c;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}
	public virtual REVVY__MnStrategy2__c getPricingProgramLine( REVVY__MnStrategy4__c qi) {
		Revvy__MnStrategy2__c line = productPricingProgramLineMap.get(qi.Product_Id__c);
		if(line == null) {
			line = qtyTierLine;	
		}
		return line;
	}
	
	public override List<Revvy__MnStrategy4__c> baseCalculateImplementation(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		boolean drivenByGP = false;
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		
		List<ToroContractQuantityPPHelper.InnerClass> qtyTiers = new List<ToroContractQuantityPPHelper.InnerClass>();
		for(Revvy__MnStrategy1__c rh : rebates) {
			drivenByGP = rh.DrivenByGP__c;
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					if(String.IsNotBlank(l.ApplicableProducts__c)) {
						String[] parts = l.ApplicableProducts__c.split(',');
						for(String p : parts) {
							productPricingProgramLineMap.put(p, l);	
							system.debug('inside state calculateRebateMarginImpl--' + p + '--' + l);
						}	
					} else {
						productPricingProgramLineMap.put('All', l);
					}
					if(l.min_qty__c != null){
						qtyTiers.add(new ToroContractQuantityPPHelper.InnerClass(l.min_qty__c, l.max_qty__c, l));	
					}	
				}			
			}
		}
		qtyTiers.sort();
		decimal minQty = qtyTiers[0].minQty;
		decimal maxQty = qtyTiers[qtyTiers.size()-1].maxQty;
		system.debug('tier : ' + qtyTiers + ' minQty:' + minQty + ' maxQty:' + maxQty);
		
		Integer numOfTractionUnits = getNumberOfTractionUnits(quoteItemList, productPricingProgramLineMap.keyset());
		system.debug('numOfTractionUnits : ' + numOfTractionUnits );
		
		if(numOfTractionUnits <= minQty)  {
			qtyTierLine = qtyTiers[0].ppl;	
		} else if(numOfTractionUnits >= maxQty) {
			qtyTierLine = qtyTiers[qtyTiers.size()-1].ppl;
		} else {
			for(ToroContractQuantityPPHelper.InnerClass qtyTier : qtyTiers) {
				if(numOfTractionUnits >= qtyTier.minQty && numOfTractionUnits <= qtyTier.maxQty) {
					qtyTierLine = qtyTier.ppl;	
				}		
			}
		}
		
		if(quoteItemList != null && quoteItemList.size() != 0) {
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				Revvy__MnStrategy2__c line = getPricingProgramLine(qi);
				
				system.debug('-----------line=' + line);
				if(line != null) {
					if(!qi.Off_MSRP_Overridden__c) {
						qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
					}
					qi.Original_off_MSRP__c = qi.Off_MSRP__c;
					qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
					qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
					system.debug(logginglevel.info,'basePrice =' + qi.msrp_Price__c + ' qi.Off_MSRP__c=' + qi.Off_MSRP__c);
					if(!qi.Unit_Award_Overridden__c) {
						qi.Award_Price__c = qi.msrp_Price__c * (100-qi.Off_MSRP__c)/100;
						//qi.Original_Award_Price__c = qi.MSRP_Price__c*(1-qi.Selected_Off_MSRP__c/100);
						if(qi.Exclude_from_Rebate_F__c && qi.Pricing_Program_Product_Type__c != 'Standard' &&  qi.Pricing_Program_Product_Type__c != 'TPP') {
							qi.Award_Price__c = qi.MSRP_Price__c;	
						}
					} else {
						qi.Award_Price__c = calcDistributedTractionUnitAwardPrice(qi);
						if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
							qi.Off_MSRP__c = (1-(qi.Award_Price__c/qi.MSRP_Price__c))*100;	
							//qi.Selected_Off_MSRP__c = qi.Off_MSRP__c;
						}
					}
					qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					//qi.Original_Award_Price__c = qi.Award_Price__c ;
					
					system.debug(logginglevel.info,'qi.Original_Award_Price__c =' + qi.Original_Award_Price__c );
					system.debug(logginglevel.info,'line.Rebate_as_a_Percent_of_DN__c =' + line.Rebate_as_a_Percent_of_DN__c );
					system.debug(logginglevel.info,'qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c );
					//qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;	
					//if((qi.Rebate_as_a_of_DN__c == null || qi.Rebate_as_a_of_DN__c==0) && line.Rebate_as_a_Percent_of_DN__c == null) {
					qi.DrivenByGP__c = drivenByGP;
					if(drivenByGP) {
						//if(line.Distributor_Margin__c != null && qi.DNET_Price__c != null && qi.DNET_Price__c != 0) {
							qi.Toro_Gross_Profit_Percent__c = line.Distributor_Margin__c;
							qi.Toro_Gross_Profit_Value__c = qi.award_price__c * qi.Toro_Gross_Profit_Percent__c/100;
							system.debug('qi.Toro_Gross_Profit_Percent__c =' + qi.Toro_Gross_Profit_Percent__c);
							
							
							//decimal rebate = qi.award_price__c - qi.MSRP_Price__c + qi.Toro_Gross_Profit_Value__c;
							decimal rebate = qi.DNET_Price__c - qi.award_price__c + qi.Toro_Gross_Profit_Value__c;
							system.debug('qi.award price =' + qi.award_price__c + ' msrp =' + qi.msrp_price__c + ' qi.Toro_Gross_Profit_Value__c =' + qi.Toro_Gross_Profit_Value__c + ' rebate='+ rebate );
							if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0)
								qi.Rebate_as_a_of_DN__c = rebate / qi.DNET_Price__c * 100;
							qi.Toro_Gross_Profit_Value__c *= qi.adjusted_quantity__c;
							system.debug('qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
							//qi.DrivenByGP__c = true;
						//}
					} else {
						qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
					}
				}
				if(excludedFromMSRP(qi)) {
					qi.Off_MSRP__c = 0;	
				}
				
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.MSRP_Price__c=CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c);
						
						qis.Percent_of_DNet__c = qi.Award_of_DN__c;
						qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;	
						qis.Percent_Off_MSRP__c=CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c);
						qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);
						if(!qis.Unit_Award_Overridden__c) {			
							qis.Award_Price__c = qis.MSRP_Price__c * (100-qis.Percent_Off_MSRP__c)/100;
							if(qis.Exclude_from_Rebate_F__c && qis.Pricing_Program_Product_Type__c != 'Standard' &&  qis.Pricing_Program_Product_Type__c != 'TPP') {
								qis.Award_Price__c = qis.MSRP_Price__c;	
							}
						}
						if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
							qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
						}
						if(excludedFromMSRP(qis)) {
							qis.Percent_Off_MSRP__c = 0;	
						}	
						system.debug(logginglevel.info,'====% off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);							
					}
				}	
			}
		
		}			
		return quoteItemList; 															
	}    
}