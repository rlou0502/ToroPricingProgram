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
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return null;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.State_Contracts_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.State_Contract_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.State_Contracts_Quote_Line_Summary_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryUpdatableFields() { 
		return null;
	}
	
	public virtual List<Toro_QuoteItem__c> baseCalculateImplementation(Id quoteId, String priceProgram, 
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
					qi.Toro_Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
					qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c.setScale(4));
					//qi.Original_Award_Price__c = qi.Award_Price__c ;
					qi.Original_Award_Price__c = qi.MSRP_Price__c*(1-qi.Selected_Off_MSRP__c/100);
					system.debug(logginglevel.info,'qi.Original_Award_Price__c =' + qi.Original_Award_Price__c );
					qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;	
				}
				if(excludedFromMSRP(qi)) {
					qi.Off_MSRP__c = 0;	
				}
				
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
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
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram, 
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return baseCalculateImplementation(quoteId, priceProgram, priceMethod, quoteItemList);																
	}   
}