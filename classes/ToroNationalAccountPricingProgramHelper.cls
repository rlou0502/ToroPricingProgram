public class ToroNationalAccountPricingProgramHelper extends ToroPricingProgram {
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
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		return ret;
	}
	public override List<Revvy__MnQuoteItem__c> calculateRebateAndMargin(Id quoteId, String priceProgramExternalId, String priceMethod, List<QuoteItem> quoteItemWrapperList) {
		system.debug('+++++++++++++++++ NAT = ' + quoteItemWrapperList);
		/*
		system.debug(logginglevel.info, '+++++++++++++++++ priceProgramExternalId = ' + priceProgramExternalId);
		quote.Performance_Part__c=false;		
		Map<String,Toro_PricingProgramLine__c> skuMap = retrieveNationalAccount( priceProgramExternalId);
		Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		for(QuoteItem qItem : quoteItemWrapperList) {
			REVVY__MnQuoteItem__c qi = qItem.qi;
			if('S00001'.equalsIgnoreCase(qi.REVVY__Product_ID_F__c)) {
				deleteSetupFeeLineItemId.add(qi.Id);
			}
			ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(quote.Performance_Part__c, qi, null);
			System.debug('>>> NAT qi.REVVY__Product_ID_F__c ='+qi.REVVY__Product_ID_F__c);
			if(skuMap.containsKey(qi.REVVY__Product_ID_F__c)) {
				Toro_PricingProgramLine__c rb = skuMap.get(qi.REVVY__Product_ID_F__c);
				qi.Off_MSRP__c = rb.Off_Mfg_Sugg_Ttl__c;
				qi.Rebate_as_a_of_DN__c = rb.Rebate_as_a_Percent_of_DN__c;
				qi.Fee_Percentage__c = rb.Fee_Percentage__c;
				qi.Part_Percentage__c = rb.Part_Percentage__c;
				if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
					qi.Off_MSRP__c = rb.Part_Percentage__c;
				}
				qi.Award_Price__c = qi.REVVY__Price__c * (1-qi.Off_MSRP__c/100);
			}
			
			updatedQuoteItems.add(qItem.qi);
			List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
			system.debug('----------------------' + qi);
			//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
			if(qiSub!=null) {
				for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
					ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(quote.Performance_Part__c, qis, null);
					if(skuMap.containsKey(qis.Product_ID2__c)) {
						Toro_PricingProgramLine__c rb = skuMap.get(qis.Product_ID2__c);
						qis.Rebate_as_of_DNet__c = rb.Rebate_as_a_Percent_of_DN__c;
						qis.percent_off_msrp__c =  rb.Off_Mfg_Sugg_Ttl__c;
						qis.Fee_Percentage__c = rb.Fee_Percentage__c;
						qis.Part_Percentage__c = rb.Part_Percentage__c;
						if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
							qis.percent_off_msrp__c = rb.Part_Percentage__c;
						}
						qis.Award_Price__c = qis.REVVY__Price__c * (1 - (qis.percent_off_msrp__c/100));
					}
					//percent_of_dnet__c
					//Percent_Off_MSRP__c
					updatedQuoteItemSublines.add(qis);
					system.debug('--++--++--++='  + qis.percent_off_msrp__c + ' off DN=' + qis.percent_of_dnet__c);	
				}	
			}


		}
		update updatedQuoteItems;
		update updatedQuoteItemSublines;
		update quote;
		
		Revvy__MnQuote__c mnq = [Select Id, Rollup_Setup_Fees__c From Revvy__MnQuote__c Where Id = :quoteId];
		REVVY__MnCatalogNode__c setupFeeCN = [Select Id From REVVY__MnCatalogNode__c where REVVY__Id__c = 'S00001'];
		delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
		if(mnq.Rollup_Setup_Fees__c > 0) {
			//Create Setup Fee Line Item
			addSetupFeeFuture(quoteId, setupFeeCN.Id, mnq.Rollup_Setup_Fees__c, mnq.Rollup_Setup_Fees__c, 1);
			
		}		
		*/
		
		
		return null;	
	}        
	
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgramExternalId,
		 				String priceMethod, List<Toro_QuoteItem__c> quoteItemWrapperList) {
		system.debug(logginglevel.info, '+++++++++++++++++ NAT = ' + quoteItemWrapperList);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceProgramExternalId);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceMethod);
		quote.Performance_Part__c=false;		
		Map<String,Toro_PricingProgramLine__c> tierMap = retrieveNationalAccount( priceProgramExternalId);
		system.debug(logginglevel.info, 'tierMap=' + tierMap);
		
		//Exception
		Set<String> exceptionSkuSet = new Set<String>();
		if(tierMap.containsKey('Exception')) {
			Toro_PricingProgramLine__c ppl = tierMap.get('Exception');
			if(ppl!=null && !String.isEmpty(ppl.ApplicableProducts__c)) {
				for(String sku:ppl.ApplicableProducts__c.split(',')) {
					exceptionSkuSet.add(sku);
				}				
			}			
		}
				
		Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		List<Toro_QuoteItem__c> updatedQuoteItems = new List<Toro_QuoteItem__c>();
		Decimal dtoroTotalSetupFees = 0;
		for(Toro_QuoteItem__c qi : quoteItemWrapperList) {
			if('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
				deleteSetupFeeLineItemId.add(qi.Id);
				deleteSetupFeeLineItemId.add(qi.QuoteItem__c);
			}
			Decimal dextendedAwardPrice = 0;
			if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//todo
					//ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(quote.Performance_Part__c, qis, null);
					if(tierMap.containsKey(qis.Toro_Product_Tier__c)) {
						Toro_PricingProgramLine__c rb = tierMap.get(qis.Toro_Product_Tier__c);
						qis.Rebate_as_of_DNet__c = rb.Rebate_as_a_Percent_of_DN__c;
						qis.percent_off_msrp__c =  rb.Off_Mfg_Sugg_Ttl__c;
						qis.Fee_Percentage__c = rb.Fee_Percentage__c;
						qis.Part_Percentage__c = rb.Part_Percentage__c;
						if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
							qis.percent_off_msrp__c = rb.Part_Percentage__c;
						}
						qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c/100));
						
						
					}
					
					//Run Exception
					if(exceptionSkuSet.size() > 0 && exceptionSkuSet.contains(qi.Product_Id__c)) {
						Toro_PricingProgramLine__c rb = tierMap.get(qis.Toro_Product_Tier__c);
						qis.Rebate_as_of_DNet__c = rb.Rebate_as_a_Percent_of_DN__c;
						qis.percent_off_msrp__c =  rb.Off_Mfg_Sugg_Ttl__c;
						qis.Part_Percentage__c = rb.Part_Percentage__c;
						if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
							qis.percent_off_msrp__c = rb.Part_Percentage__c;
						}
						qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c/100));						
					}

					//Calculate extended award price 
					dextendedAwardPrice += CMnQuoteUtil.defaultDecimal(qis.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);

				}
			}			
			
			
			//ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(quote.Performance_Part__c, qi, null);
			System.debug(logginglevel.info,'>>> NAT qi.REVVY__Product_ID_F__c ='+qi.Product_Id__c);
			if(tierMap.containsKey(qi.Toro_Product_Tier__c)) {
				Toro_PricingProgramLine__c rb = tierMap.get(qi.Toro_Product_Tier__c);
				qi.Off_MSRP__c = rb.Off_Mfg_Sugg_Ttl__c;
				qi.Rebate_as_a_of_DN__c = rb.Rebate_as_a_Percent_of_DN__c;
				qi.Fee_Percentage__c = rb.Fee_Percentage__c;
				qi.Part_Percentage__c = rb.Part_Percentage__c;
				if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
					qi.Off_MSRP__c = rb.Part_Percentage__c;
				}
				qi.Award_Price__c = qi.MSRP_Price__c * (1-qi.Off_MSRP__c/100);
			}
			

			
			//Run Exception
			if(exceptionSkuSet.size() > 0 && exceptionSkuSet.contains(qi.Product_Id__c)) {
				Toro_PricingProgramLine__c rb = tierMap.get(qi.Toro_Product_Tier__c);
				qi.Off_MSRP__c = rb.Off_Mfg_Sugg_Ttl__c;
				qi.Rebate_as_a_of_DN__c = rb.Rebate_as_a_Percent_of_DN__c;
				qi.Part_Percentage__c = rb.Part_Percentage__c;
				if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
					qi.Off_MSRP__c = rb.Part_Percentage__c;
				}
				qi.Award_Price__c = qi.MSRP_Price__c * (1-qi.Off_MSRP__c/100);
				
			}
			
			//calculate total setup fees
			dtoroTotalSetupFees += CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c) * CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * 
								CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(dextendedAwardPrice);


		}
		
		
		delete [Select Id From Toro_QuoteItem__c where Id in :deleteSetupFeeLineItemId];
		delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
		REVVY__MnCatalogNode__c setupFeeCN = [Select Id From REVVY__MnCatalogNode__c where REVVY__Id__c = 'S00001'];
		if(dtoroTotalSetupFees > 0) {
			//Create Setup Fee Line Item
			addSetupFeeFuture(quoteId, setupFeeCN.Id, dtoroTotalSetupFees, dtoroTotalSetupFees, 1);
		}		
		
		return quoteItemWrapperList;	
	}        
	
	//@future
    public static void addSetupFeeFuture(String quoteId, String productId, decimal price, decimal unitPrice, decimal qty) {
    	REVVY__MnQuoteItem__c mnqi = new REVVY__MnQuoteItem__c();
		mnqi.REVVY__Quote__c=quoteId;
		mnqi.REVVY__Catalog_Node__c = productId;
		mnqi.Revvy__Price__c = price;
		mnqi.REVVY__Unit_Price__c = unitPrice;		
		mnqi.REVVY__Quantity__c = qty;
		mnqi.Dirty__c = true;
		Revvy__MnSequenceGen__c sequence = [SELECT Id,  REVVY__CurrentValue__c FROM Revvy__MnSequenceGen__c WHERE Revvy__ObjectName__c='MnQuoteItem__c' limit 1];
		mnqi.REVVY__Id__c = ++sequence.REVVY__CurrentValue__c;
		insert mnqi;
		++sequence.REVVY__CurrentValue__c;
		update sequence;    
    }    
    
	public static Map<String,Toro_PricingProgramLine__c> retrieveNationalAccount(String pricingProgramExternalId) {
		Map<String,Toro_PricingProgramLine__c> ppMap = new Map<String,Toro_PricingProgramLine__c>();
		for(Toro_PricingProgramLine__c rl:[Select Id, ApplicableProducts__c, Pricing_1__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c, Tier__c
		                             ,Fee_Percentage__c , Part_Percentage__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		                                  ]) {
			ppMap.put(rl.Tier__c, rl);                           	
		}
		return ppMap;
	}	
}