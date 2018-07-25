public virtual class ToroStateContractPricingProgramHelper extends ToroPricingProgram  {
	public override boolean getQuoteLevelMSQPDNetEditable() { 
		return false;
	}
	
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		return ret;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return null;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.State_Contracts_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.State_Contract_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.State_Contract_Price_Program_Quote_SubLi.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.State_Contracts_Quote_Line_Summary_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryUpdatableFields() { 
		return null;
	}
	public virtual List<Revvy__MnStrategy4__c> preCalculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		
		return 	quoteItemList;
	}
	public override List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		system.debug('ToroStateContractPricingProgramHelper preCalculateRebateMargin');
		quoteItemList = loadMSRPPriceFromPricelist(priceProgram, quoteItemList);
		return preCalculateRebateMarginImpl(quoteId, priceProgram, priceMethod, quoteItemList);
	}
	public virtual List<Revvy__MnStrategy4__c> baseCalculateImplementation(Id quoteId, String priceProgram, 
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		//priceMethod = '% off MSRP';
		ToroPricingProgramData ppd1 = new ToroPricingProgramData(priceProgram);
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(String.isNotBlank(qi.pricing_program__c)) {
				system.debug('qi.pricing_program__c=' + qi.pricing_program__c);
				helper.addPricingProgramExtId(qi.pricing_program__c);	
			}
		}
		List<Revvy__MnStrategy4__c> primaryPricingProgramQuoteItems = new List<Revvy__MnStrategy4__c>();
		List<Revvy__MnStrategy4__c> secondaryPricingProgramQuoteItems = new List<Revvy__MnStrategy4__c>();
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			
			system.debug('baseCalculateImplementation qi.pricing_program__c=' + qi.pricing_program__c + ' priceProgram= ' + priceProgram);
			if(String.isNotBlank(qi.pricing_program__c)) {
				ToroPricingProgramData ppd2 = new ToroPricingProgramData(qi.pricing_program__c);
				if(ppd1.externalId.equalsIgnoreCase(ppd2.externalId)) {
					primaryPricingProgramQuoteItems.add(qi);	
					system.debug('primary--' + qi);	
				} else {
					secondaryPricingProgramQuoteItems.add(qi);
					system.debug('secondary--' + qi);
				}	
			}
		}
		if(secondaryPricingProgramQuoteItems.size()>0) {
			ToroPricingMethodHelper secondaryHelper = new ToroPricingMethodHelper();
			secondaryHelper.quoteItemList = secondaryPricingProgramQuoteItems;	
			secondaryHelper.quote=this.quote;	
			secondaryHelper.calculateBlendedDNetPercentFromMSRP().retrieveRebatePercent();
		} 
		system.debug('baseCalculateImplementation.inside state primaryPricingProgramQuoteItems.size=' + primaryPricingProgramQuoteItems.size());
		if(primaryPricingProgramQuoteItems.size() > 0) {
		system.debug('baseCalculateImplementation.inside state calculateRebateMarginImpl quoteItemList=');
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		boolean drivenByGP = false; 
		Map<String, Revvy__MnStrategy2__c> productPricingProgramLineMap = new Map<String, Revvy__MnStrategy2__c>();
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
		system.debug('-----------' + productPricingProgramLineMap);
		if(primaryPricingProgramQuoteItems != null && primaryPricingProgramQuoteItems.size() != 0) {
			for(Revvy__MnStrategy4__c qi : primaryPricingProgramQuoteItems) {
				Revvy__MnStrategy2__c line = productPricingProgramLineMap.get(qi.Product_Id__c);
				if(line == null) {
					line = productPricingProgramLineMap.get('All');	
				}
				system.debug('-----------line=' + line);
				if(line != null) {
					if(!qi.Off_MSRP_Overridden__c) {
						qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
					}
					qi.Original_off_MSRP__c = qi.Off_MSRP__c;
					//qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
					qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
					system.debug(logginglevel.info,'basePrice =' + qi.msrp_Price__c + ' qi.Off_MSRP__c=' + qi.Off_MSRP__c);
					if(!qi.Unit_Award_Overridden__c) {
						if(qi.Exclude_from_Rebate_F__c) {
							qi.Award_Price__c = qi.msrp_Price__c;
						} else {
							qi.Award_Price__c = qi.msrp_Price__c * (100-qi.Off_MSRP__c)/100;
						}
					} else {
						if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
							qi.Off_MSRP__c = (1-(qi.Award_Price__c/qi.MSRP_Price__c))*100;	
							//qi.Selected_Off_MSRP__c = qi.Off_MSRP__c;
						}
					}
					if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
						qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c*100;
					}
					qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					//qi.Original_Award_Price__c = qi.Award_Price__c ;
					qi.Original_Award_Price__c = qi.MSRP_Price__c*(1-qi.Selected_Off_MSRP__c/100);
					system.debug(logginglevel.info,'qi.Original_Award_Price__c =' + qi.Original_Award_Price__c );
					system.debug(logginglevel.info,'line.Rebate_as_a_Percent_of_DN__c =' + line.Rebate_as_a_Percent_of_DN__c );
					system.debug(logginglevel.info,'qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c );
					//qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;						
					//if((qi.Rebate_as_a_of_DN__c == null || qi.Rebate_as_a_of_DN__c==0) && line.Rebate_as_a_Percent_of_DN__c == null) {
					qi.DrivenByGP__c = drivenByGP;
					if(drivenByGP) {
						if(line.Distributor_Margin__c != null && qi.DNET_Price__c != null && qi.DNET_Price__c != 0) {
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
							
						}
					} else {
						qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
					}					
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
							if(qis.Exclude_from_Rebate_F__c) {
								qis.Award_Price__c = qis.msrp_Price__c;
							} else {	
								qis.Award_Price__c = qis.MSRP_Price__c * (100-qis.Percent_Off_MSRP__c)/100;
							}
						}
						if(qis.DNet_Price__c != null && qis.DNet_Price__c != 0){
							qis.Percent_of_DNet__c = qis.Award_Price__c/qis.DNet_Price__c*100;
						}
						if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
							if(qi.DrivenByGP__c) {
								qis.Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Percent__c;
								qis.Gross_Profit_Value__c = qis.award_price__c * qis.Gross_Profit_Percent__c/100;
								
								//decimal rebate = qi.award_price__c - qi.MSRP_Price__c + qi.Toro_Gross_Profit_Value__c;
								decimal rebate = qis.DNET_Price__c - qis.award_price__c + qis.Gross_Profit_Value__c;						
								if(qis.DNet_Price__c != null && qis.DNet_Price__c != 0)
									qis.Rebate_as_of_DNet__c = rebate / qis.DNET_Price__c * 100;
								qis.Gross_Profit_Value__c *= qi.adjusted_quantity__c;	
							} else {
								qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
							}
						}
						if(excludedFromMSRP(qis)) {
							qis.Percent_Off_MSRP__c = 0;	
						}	
						system.debug(logginglevel.info,'====% off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);							
					}
				}	
			}
			
		}	
		}												
		return quoteItemList;															
	}
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram, 
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		return baseCalculateImplementation(quoteId, priceProgram, priceMethod, quoteItemList);																
	}   
}