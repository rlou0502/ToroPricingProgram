public with sharing class ToroBaseAwardAccessoryHelper  extends ToroStateContractPricingProgramHelper  {
	
	public override List<Revvy__MnStrategy4__c> baseCalculateImplementation(Id quoteId, String priceProgram, 
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		//priceMethod = '% off MSRP';
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(String.isNotBlank(qi.pricing_program__c)) {
				system.debug('qi.pricing_program__c=' + qi.pricing_program__c);
				helper.addPricingProgramExtId(qi.pricing_program__c);	
			}
		}
		system.debug('inside state calculateRebateMarginImpl quoteItemList=');
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		boolean drivenByGP = false; 
		Map<String, Revvy__MnStrategy2__c> productPricingProgramLineMap = new Map<String, Revvy__MnStrategy2__c>();
		Revvy__MnStrategy2__c accesseryLine = null;
		for(Revvy__MnStrategy1__c rh : rebates) {
			drivenByGP = rh.DrivenByGP__c;
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					system.debug('inside state calculateRebateMarginImpl--' + l);
					if(String.isNotBlank(l.ApplicableProducts__c)) {
						String[] parts = l.ApplicableProducts__c.split(',');
						for(String p : parts) {
							productPricingProgramLineMap.put(p, l);	
							system.debug('inside state calculateRebateMarginImpl--' + p + '--' + l);
						}
					} else {
						productPricingProgramLineMap.put('All', l);
					}
					
				}
			}
		}
		system.debug('inside state calculateRebateMarginImpl drivenByGP=' + drivenByGP);
		accesseryLine = productPricingProgramLineMap.get('All');
		
		if(quoteItemList != null && quoteItemList.size() != 0) {
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				Revvy__MnStrategy2__c line = productPricingProgramLineMap.get(qi.Product_Id__c);
				
				system.debug('-----------line=' + line);
				if(line != null) {
					qi.DrivenByGP__c = drivenByGP;
					
					if(!CMnQuoteUtil.isNonToroProduct(qi)) {
						qi.Award_Price__c = line.Award_Price__c;	
					} 
					if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
						qi.Off_MSRP__c = (1-(qi.Award_Price__c/qi.MSRP_Price__c))*100;
					}
					if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
						qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c*100;
					}
					//qi.Toro_Gross_Profit_Percent__c = line.Distributor_Margin__c;
					//qi.Rebate_as_a_of_DN__c = 0;
					if(drivenByGP) {
						//if(line.Distributor_Margin__c != null && qi.DNET_Price__c != null && qi.DNET_Price__c != 0) {
							qi.Toro_Gross_Profit_Percent__c = line.Distributor_Margin__c;
							qi.Toro_Gross_Profit_Value__c = qi.award_price__c * qi.Toro_Gross_Profit_Percent__c/100;
							system.debug('qi.Toro_Gross_Profit_Percent__c =' + qi.Toro_Gross_Profit_Percent__c);
							
							
							//decimal rebate = qi.award_price__c - qi.MSRP_Price__c + qi.Toro_Gross_Profit_Value__c;
							decimal rebate = qi.DNET_Price__c - qi.award_price__c + qi.Toro_Gross_Profit_Value__c;
							system.debug('qi.award price =' + qi.award_price__c + ' msrp =' + qi.msrp_price__c + ' qi.Toro_Gross_Profit_Value__c =' + qi.Toro_Gross_Profit_Value__c + ' rebate='+ rebate );
							if(qi.DNET_Price__c != null && qi.DNET_Price__c != 0) {
								qi.Rebate_as_a_of_DN__c = rebate / qi.DNET_Price__c * 100;
							}
							qi.Toro_Gross_Profit_Value__c *= qi.adjusted_quantity__c;
							system.debug('qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
							
						//}
					} 	
					
					//qi.Toro_Gross_Profit_Value__c = qi.award_price__c * qi.Toro_Gross_Profit_Percent__c/100;
					qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.adjusted_quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					
				}
				
				system.debug('-----------qi.DrivenByGP__c=' + qi.DrivenByGP__c);
								
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.Percent_Off_MSRP__c=0;
						qis.Rebate_as_of_DNet__c=0;
						qis.Gross_Profit_Percent__c=0;
						if(accesseryLine != null) {
							qis.Percent_Off_MSRP__c = accesseryLine.Off_Mfg_Sugg_Ttl__c;							
						}
						qis.Award_Price__c = qis.MSRP_Price__c * (100-qis.Percent_Off_MSRP__c)/100;
						if(qis.Exclude_from_Rebate_F__c && qis.Pricing_Program_Product_Type__c != 'Standard' &&  qis.Pricing_Program_Product_Type__c != 'TPP') {
							qis.Award_Price__c = qis.MSRP_Price__c;	
						}
						if(qis.Award_Price__c != null && qis.Award_Price__c != 0){
							qis.Percent_of_DNet__c = qis.DNet_Price__c/qis.Award_Price__c*100;
						}
						qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);										
						system.debug(logginglevel.info,'====% off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);							
					}
				}		
			}	
		}													
		return quoteItemList;															
	}
	  
}