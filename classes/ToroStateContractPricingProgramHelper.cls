public virtual class ToroStateContractPricingProgramHelper extends ToroPricingProgram  {
	public override List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}
	   
	public override boolean getQuoteLevelMSQPDNetEditable() { 
		return false;
	}
	
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		return ret;
	}
/*	
	public override List<Toro_QuoteItem__c> calculateExtendedFields(List<Toro_QuoteItem__c> quoteItemList) {
		decimal quoteDnet = 0;
		decimal quoteAward = 0;
		decimal quoteTotalAward =0;
		decimal quoteToroTotalAward=0;
		decimal quoteTotalDNet =0;
		decimal quoteTotalSetupFee=0;
		decimal quoteToroTotalDNet=0;
		decimal quoteTotalGP=0;
		decimal quoteTotalRebate=0;
		decimal quoteTotalDnetWOTppAllied = 0;
		for (Toro_QuoteItem__c qi : quoteItemList) {
			//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
			decimal extDnet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			//decimal extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			//award price has been calculated in calling function
			decimal extAward = CMnQuoteUtil.defaultDecimal(qi.Award_price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			decimal extMSRP = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);			 
			qi.Toro_Rebate__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c)/100;
			qi.Toro_Extended_DNet_Price__c = extDnet;
			qi.Toro_Extended_MSRP_Price__c = extMSRP;
			decimal extRebate = qi.Toro_Rebate__c;
			qi.Toro_Gross_Profit_Value__c = extAward - extDnet + extDnet * CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c)/100;	
			if(extAward != null && extAward != 0) {
				qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/extAward*100;	
			}
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c)) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c));
						decimal subExtDNet = CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c)* extQty;
						decimal subExtAward = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c) * extQty;
						decimal subExtMSRP = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * extQty;
						qis.Toro_Extended_DNET_Price__c = subExtDNet;
						qis.Toro_Extended_MSRP_Price__c = subExtMSRP;
						qis.Toro_Extended_Award_Price__c = subExtAward;
						extDnet += subExtDNet;
						extAward += subExtAward;
						extMSRP += subExtMSRP;
						system.debug('checking MSRP ext qi.extMSRP=' + extMSRP);
						qis.Gross_Profit_Value__c = subExtAward - subExtDNet + (subExtDNet * CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100);	
						if(subExtAward != 0) {
							qis.Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(qis.Gross_Profit_Value__c)/subExtAward*100;	
						}
						qis.Toro_Subline_Rebate__c = qis.Toro_DNet_Price__c * extQty *CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100;
						extRebate += qis.Toro_Subline_Rebate__c;
						qis.Toro_Extended_Award_Price__c = subExtAward;
						//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;	
					}	
				}	
			}
			
			qi.Toro_Total_Extended_Award_Price__c = extAward;
			qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			if(extMSRP != 0) {
				qi.Toro_Total_MSRP_Percentage__c = 100 - (extAward/extMSRP)*100;
			}
			qi.Toro_Total_Rebate__c = extRebate;
			qi.Total_Gross_Profit_Value__c = extAward - extDnet + extRebate; 
			if(extAward != 0) {
				qi.Total_Gross_Profit_Percent__c = qi.Total_Gross_Profit_Value__c/extAward*100; 
			}
			system.debug('checking MSRP ext qi.Toro_Total_Extended_MSRP_Price__c=' + qi.Toro_Total_Extended_MSRP_Price__c);
			quoteTotalAward 			+= qi.Toro_Total_Extended_Award_Price__c;
			quoteToroTotalAward       	+= qi.Toro_Total_Extended_Award_Price__c;
			quoteTotalDNet              += qi.Toro_Total_Extended_DNet_Price__c;
			quoteToroTotalDNet          += qi.Toro_Total_Extended_DNet_Price__c;
			quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			quoteTotalRebate       		+= qi.Toro_Total_Rebate__c;
			quoteTotalDnetWOTppAllied   += qi.Toro_Total_Extended_Award_Price__c;
			
		}	
		quote.Toro_Rollup_Award_Price__c       = quoteTotalAward;
		quote.Toro_Rollup_DNET__c              = quoteTotalDNet;
		quote.Toro_Rollup_Setup_Fees__c        = quoteTotalSetupFee;
		quote.Toro_Total_DNet__c               = quoteToroTotalDNet;
		quote.Toro_Total_Quote_Gross_Profit__c = quoteTotalGP;
		quote.Toro_Total_Quote_Rebate__c       = quoteTotalRebate;
		quote.Toro_Total_Rebate__c             = quoteTotalRebate;
		quote.Toro_Rollup_DNetWOTPPAllied__c   = quoteTotalDnetWOTppAllied;
		
		
		quote.Award_Price__c = quoteTotalAward;
		if(quote.Toro_Rollup_DNET__c != null && quote.Toro_Rollup_DNET__c != 0) {
			quote.Toro_Blended_Percent_of_DN__c            = CMnQuoteUtil.defaultDecimal(quote.Toro_Rollup_Award_Price__c) / quote.Toro_Rollup_DNET__c*100;
		}
		
		quote.Toro_Blended_Percent_of_DN__c=CMnQuoteUtil.defaultDecimal(quote.Toro_Blended_Percent_of_DN__c).setScale(2);
		if(quote.Toro_Rollup_Award_Price__c != null && quote.Toro_Rollup_Award_Price__c != 0) {
			quote.Toro_Total_Quote_Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Quote_Gross_Profit__c) / quote.Toro_Rollup_Award_Price__c *100;
		}
		return quoteItemList;
	}
*/
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram, 
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		//priceMethod = '% off MSRP';
		system.debug('inside state calculateRebateMarginImpl quoteItemList='+ quoteItemList);
		List<Toro_PricingProgram__c> rebates = new List<Toro_PricingProgram__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		Map<String, Toro_PricingProgramLine__c> productPricingProgramLineMap = new Map<String, Toro_PricingProgramLine__c>();
		for(Toro_PricingProgram__c rh : rebates) {
			if(rh.PricingProgramLines__r != null) {
				for(Toro_PricingProgramLine__c l : rh.PricingProgramLines__r) {
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
		system.debug('-----------' + productPricingProgramLineMap);
		if(quoteItemList != null && quoteItemList.size() != 0) {
			for(Toro_QuoteItem__c qi : quoteItemList) {
				Toro_PricingProgramLine__c line = productPricingProgramLineMap.get(qi.Product_Id__c);
				if(line == null) {
					line = productPricingProgramLineMap.get('All');	
				}
				system.debug('-----------line=' + line);
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
					for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.Percent_of_DNet__c = qi.Award_of_DN__c;
						qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;	
						qi.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);
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
		
		}														
		return quoteItemList;															
	}   
}