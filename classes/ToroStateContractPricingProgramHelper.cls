public class ToroStateContractPricingProgramHelper extends ToroPricingProgram  {
	public override List<Schema.FieldSetMember> getQuoteItemSublineFields() {
		return SObjectType.Revvy__MnQuoteItemSubline__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteItemFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}
	public override List<SelectOption> getPriceMethodOptions() { 
		return new List<SelectOption> {  new SelectOption('% off MSRP','% off MSRP')};
	}   
	public override boolean getQuoteLevelMSQPDNetEditable() { 
		return false;
	}
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		return ret;
	}
	public override boolean isEligible(Toro_PricingProgram__c pp, Revvy__MnQuote__c quote, List<Revvy__MnQuoteItem__c> qiList) {
		boolean ret = true;
		if(quote != null && quote.revvy__account__r != null){
			String qtAccountStateCode = quote.revvy__account__r.billingstatecode;
			ret = qtAccountStateCode.EqualsIgnoreCase(pp.stateprovince__c) ;		
		} 
		return ret;
	} 
	public override List<Revvy__MnQuoteItem__c> calculateRebateAndMargin(Id quoteId, String priceProgramExternalId, String priceMethod, List<QuoteItem> quoteItemWrapperList) {
		priceMethod = '% off MSRP';
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		if(quoteItemWrapperList != null && quoteItemWrapperList.size() != 0) {	
			CMnPriceProgramUtil.PriceProgramInfo info = CMnPriceProgramUtil.collectPriceProgram(priceProgramExternalId);
			Toro_PricingProgram__c rh = info.rebateMap.get(priceProgramExternalId); 
			if(rh != null) {
				for(QuoteItem qItem : quoteItemWrapperList) {
					Revvy__MnQuoteItem__c qi = qItem.qi;
					qi.Pricing_Program__c = priceProgramExternalId;
					qi.Select_a_Price_Method__c = priceMethod;
					system.debug(logginglevel.info,'----------------------- revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c);
					if(info.rebateApplicableProducts.get(priceProgramExternalId).contains('All') || 
						info.rebateApplicableProducts.get(priceProgramExternalId).contains(qi.revvy__Product_Id_F__c)) {
						//qi.REVVY__SuggestedPrice__c = qi.revvy__Price__c;
						decimal rebateValue = 0.0;
						decimal basePrice = qi.revvy__Price__c;
						decimal grossProfit = 0.0;
						qi.Distributor_Net__c = qi.revvy__Price__c;	
						
						for(Toro_PricingProgramLine__c line : rh.PricingProgramLines__r) {
							if('% of DNET'.equalsIgnoreCase(priceMethod)) {
								qi.Off_MSRP__c=0.0;
								basePrice = qi.REVVY__SuggestedPrice__c;
								system.debug(logginglevel.info,'qi.revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' line.ApplicableProducts__c=' + line.ApplicableProducts__c);
								if(String.isBlank(line.ApplicableProducts__c)){
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									qi.Award_Price__c = basePrice * qi.Award_of_DN__c/100;
									qi.Oroginal_of_DNet__c=qi.Award_of_DN__c;
									system.debug(logginglevel.info,'revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Award_of_DN__c=' + qi.Award_of_DN__c);
									continue;	
								}
								if(qi.revvy__Product_Id_F__c.equalsIgnoreCase(line.ApplicableProducts__c)) {
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									qi.Award_Price__c = basePrice * qi.Award_of_DN__c/100;
									qi.Oroginal_of_DNet__c=qi.Award_of_DN__c;
									system.debug(logginglevel.info,'matched revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Award_of_DN__c=' + qi.Award_of_DN__c);
									break; 
								} 
							} else if('% off MSRP'.equalsIgnoreCase(priceMethod) ) {
								system.debug('price method = % of MSRP ApplicableProducts__c =' + line.ApplicableProducts__c);
								//qi.Award_of_DN__c=0.0;
								basePrice = qi.REVVY__Price__c;
								system.debug(logginglevel.info,'qi.revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' line.ApplicableProducts__c=' + line.ApplicableProducts__c);
								if(String.isBlank(line.ApplicableProducts__c)){
									qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Original_off_MSRP__c = qi.Off_MSRP__c;
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Award_Price__c = basePrice * (100-qi.Off_MSRP__c)/100;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									system.debug(logginglevel.info,'matched revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Off_MSRP__c=' + qi.Off_MSRP__c);
									continue;
								}
								if(qi.revvy__Product_Id_F__c.equalsIgnoreCase(line.ApplicableProducts__c)) {
									qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Original_off_MSRP__c = qi.Off_MSRP__c;
									qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Award_Price__c = basePrice * (100-qi.Off_MSRP__c)/100;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									system.debug(logginglevel.info,'matched revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Off_MSRP__c=' + qi.Off_MSRP__c);
									break;
								} 
							}
						}
					}
					//if(excludedFromMSRP(qi)) {
					//	qi.Off_MSRP__c = 0;	
					//}
					updatedQuoteItems.add(qi);
				}
				
				for(QuoteItem qItem : quoteItemWrapperList) {
					Revvy__MnQuoteItem__c qi = qItem.qi;
					List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
					if(qiSub != null && qiSub.size() > 0) {
						for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
							qis.Percent_of_DNet__c = qi.Award_of_DN__c;
							qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;
							if('% of DNET'.equalsIgnoreCase(priceMethod)) {
								qis.award_price__c = qis.Revvy__SuggestedPrice__c * qis.Percent_of_DNet__c/100;	
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
								}
							} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
								qis.Award_Price__c = qis.Revvy__Price__c * (100-qis.Percent_Off_MSRP__c)/100;
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
								}
							}
							//if(excludedFromMSRP(qis)) {
							//	qis.Percent_Off_MSRP__c = 0;	
							//}
							updatedQuoteItemSublines.add(qis);
						}
					}
				}
				update updatedQuoteItemSublines;
				update updatedQuoteItems;		
			}	
		}
		return updatedQuoteItems;		
	} 
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram, 
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		//priceMethod = '% off MSRP';
		system.debug('inside state calculateRebateMarginImpl quoteItemList='+ quoteItemList);
		if(quoteItemList != null && quoteItemList.size() != 0) {
			//??	
			CMnPriceProgramUtil.PriceProgramInfo info = CMnPriceProgramUtil.collectPriceProgram(priceProgram);
			Toro_PricingProgram__c rh = info.rebateMap.get(priceProgram); 
			if(rh != null) {
				for(Toro_QuoteItem__c qi : quoteItemList) {
					qi.Pricing_Program__c = priceProgram;
					qi.Select_a_Price_Method__c = priceMethod;
					system.debug(logginglevel.info,'----------------------- Product_Id__c =' + qi.Product_Id__c);
					if(info.rebateApplicableProducts.get(priceProgram).contains('All') || 
						info.rebateApplicableProducts.get(priceProgram).contains(qi.Product_Id__c)) {
						//qi.REVVY__SuggestedPrice__c = qi.revvy__Price__c;
						decimal rebateValue = 0.0;
						decimal basePrice = qi.msrp_Price__c;
						decimal grossProfit = 0.0;
						qi.Distributor_Net__c = qi.msrp_Price__c;	
						for(Toro_PricingProgramLine__c line : rh.PricingProgramLines__r) {
							if('% off MSRP'.equalsIgnoreCase(priceMethod) ) {
								system.debug('price method = % of MSRP ApplicableProducts__c =' + line.ApplicableProducts__c);
								//qi.Award_of_DN__c=0.0;
								basePrice = qi.msrp_Price__c;
								system.debug(logginglevel.info,'qi.revvy__Product_Id_F__c =' + qi.Product_Id__c + ' line.ApplicableProducts__c=' + line.ApplicableProducts__c);
								if(String.isBlank(line.ApplicableProducts__c)){
									qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Original_off_MSRP__c = qi.Off_MSRP__c;
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									system.debug(logginglevel.info,'basePrice =' + basePrice + ' qi.Off_MSRP__c=' + qi.Off_MSRP__c);
									qi.Award_Price__c = basePrice * (100-qi.Off_MSRP__c)/100;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									//system.debug(logginglevel.info,'matched revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Off_MSRP__c=' + qi.Off_MSRP__c);
									continue;
								}
								if(qi.Product_Id__c.equalsIgnoreCase(line.ApplicableProducts__c)) {
									qi.Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Original_off_MSRP__c = qi.Off_MSRP__c;
									qi.Selected_Off_MSRP__c = line.Off_Mfg_Sugg_Ttl__c;
									qi.Award_of_DN__c = line.Award_Price_as_a_Percent_of_DN__c;
									qi.Award_Price__c = basePrice * (100-qi.Off_MSRP__c)/100;
									qi.Rebate_as_a_of_DN__c = line.Rebate_as_a_Percent_of_DN__c;
									//system.debug(logginglevel.info,'matched revvy__Product_Id_F__c =' + qi.revvy__Product_Id_F__c + ' Off_MSRP__c=' + qi.Off_MSRP__c);
									break;
								} 
							}
						}
					}
					
					if(excludedFromMSRP(qi)) {
						qi.Off_MSRP__c = 0;	
					}
					
					if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.Percent_of_DNet__c = qi.Award_of_DN__c;
							qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;
							if('% of DNET'.equalsIgnoreCase(priceMethod)) {
								qis.award_price__c = qis.Quote_Item_Sub_Line__r.Revvy__SuggestedPrice__c * qis.Percent_of_DNet__c/100;	
								if(!qis.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c.startsWith('TPP') && !qis.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
								}
							} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
								qis.Award_Price__c = qis.Quote_Item_Sub_Line__r.Revvy__Price__c * (100-qis.Percent_Off_MSRP__c)/100;
								if(!qis.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c.startsWith('TPP') && !qis.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
								}
							} 
							
							if(excludedFromMSRP(qis)) {
								qis.Percent_Off_MSRP__c = 0;	
							}	
								
						}
					}	
				}
			}	
		}														
		return quoteItemList;															
	}   
}