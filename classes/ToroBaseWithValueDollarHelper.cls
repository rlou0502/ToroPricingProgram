public virtual class ToroBaseWithValueDollarHelper extends ToroPricingProgram  { 
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
	
	public virtual List<Revvy__MnStrategy4__c> baseCalculateImplementation(Id quoteId, String priceProgram, 
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		//priceMethod = '% off MSRP';
		system.debug('inside state calculateRebateMarginImpl quoteItemList='+ quoteItemList);
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('inside state calculateRebateMarginImpl--rebate =' + rebates);
		Map<String, Revvy__MnStrategy2__c> productPricingProgramLineMap = new Map<String, Revvy__MnStrategy2__c>();
		for(Revvy__MnStrategy1__c rh : rebates) {
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
		if(quoteItemList != null && quoteItemList.size() != 0) {
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
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
					qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
					qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
					system.debug(logginglevel.info,'basePrice =' + qi.msrp_Price__c + ' qi.Off_MSRP__c=' + qi.Off_MSRP__c);
					if(!qi.Unit_Award_Overridden__c) {
						qi.Award_Price__c = qi.msrp_Price__c * (100-qi.Off_MSRP__c)/100;
					} else {
						if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
							qi.Off_MSRP__c = (1-(qi.Award_Price__c/qi.MSRP_Price__c))*100;	
							//qi.Selected_Off_MSRP__c = qi.Off_MSRP__c;
						}
					}
					qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					//qi.Original_Award_Price__c = qi.Award_Price__c ;
					qi.Original_Award_Price__c = qi.MSRP_Price__c*(1-qi.Selected_Off_MSRP__c/100);
					system.debug(logginglevel.info,'qi.Original_Award_Price__c =' + qi.Original_Award_Price__c );
					system.debug(logginglevel.info,'line.Rebate_as_a_Percent_of_DN__c =' + line.Rebate_as_a_Percent_of_DN__c );
					system.debug(logginglevel.info,'qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c );
					//qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;	
					if((qi.Rebate_as_a_of_DN__c == null || qi.Rebate_as_a_of_DN__c==0) && line.Rebate_as_a_Percent_of_DN__c == null) {
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
							qi.DrivenByGP__c = true;
						}
					} else if(qi.Rebate_as_a_of_DN__c == null && line.Rebate_as_a_Percent_of_DN__c != null) {
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
							qis.Award_Price__c = qis.MSRP_Price__c * (100-qis.Percent_Off_MSRP__c)/100;
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
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram, 
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		return baseCalculateImplementation(quoteId, priceProgram, priceMethod, quoteItemList);																
	}
}