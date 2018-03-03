public class ToroNationalAccountPricingProgramHelper extends ToroPricingProgram {

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
	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.National_Account_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.National_Account_Quote_Line_Updtbl_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.National_Account_Quote_SubLine_Cols.getFields();
	}
	
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	
	public override boolean displaySetupFee() {
		return true;
	}      
	public override boolean displayPerformancePart() {
		return true;
	}
	
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgramExternalId,
		 				String priceMethod, List<Toro_QuoteItem__c> quoteItemWrapperList) {
		system.debug(logginglevel.info, '+++++++++++++++++ NAT = ' + quoteItemWrapperList);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceProgramExternalId);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceMethod);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT performancePartFlag = ' + performancePartFlag);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT setupFeePercentage = ' + setupFeePercentage);
		
		quote.Performance_Part__c=performancePartFlag;		
		Map<String,Toro_PricingProgramLine__c> tierMap = retrieveNationalAccount( priceProgramExternalId);
		Map<String,String> tractionUnitMap = retrieveTractionUnit();
		system.debug(logginglevel.info, 'tierMap=' + tierMap);

		//decimal dSetupFeeHeader = ToroCacheManager.getSetupFee();
		decimal dSetupFeeHeader = setupFeePercentage;
		System.debug(logginglevel.info, '>>> Setup fee from cache=' + dSetupFeeHeader);
		
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
		for(Toro_QuoteItem__c qi : quoteItemWrapperList) {
			if('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
				deleteSetupFeeLineItemId.add(qi.Id);
				deleteSetupFeeLineItemId.add(qi.QuoteItem__c);
			}
			Decimal dsetupFeesQIS = 0;
			
			//Performance Part			
			ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(performancePartFlag, qi, performancePartMap);
			System.debug(logginglevel.info,'>>> NAT qi.REVVY__Product_ID_F__c ='+qi.Product_Id__c);
			System.debug('>>> +++++++++++++++++ NAT 115 =');
			if(String.isEmpty(qi.Toro_Product_Tier__c) && !String.isEmpty(qi.Traction_Unit__c) && tractionUnitMap.containsKey(qi.Traction_Unit__c)) {
				String stier = tractionUnitMap.get(qi.Traction_Unit__c);
				System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 116 =  tierMap='+tierMap);
				System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 116 =  stier='+stier);
				Toro_PricingProgramLine__c rb = tierMap.get(stier);
				System.debug('>>> +++++++++++++++++ NAT 116 AAA =  rb='+rb);
				applyQIPercentage(qi,rb,dSetupFeeHeader);				
				
			} else if(tierMap.containsKey(qi.Toro_Product_Tier__c)) {
				Toro_PricingProgramLine__c rb = tierMap.get(qi.Toro_Product_Tier__c);
				System.debug('>>> +++++++++++++++++ NAT 116 BBB =  rb='+rb);
				applyQIPercentage(qi,rb,dSetupFeeHeader);				
			}
			
			//Run Exception
			if(exceptionSkuSet.size() > 0 && exceptionSkuSet.contains(qi.Product_Id__c)) {
				Toro_PricingProgramLine__c rb = tierMap.get(qi.Toro_Product_Tier__c);
				System.debug('>>> +++++++++++++++++ NAT 118 =  rb='+rb);
				applyQIPercentage(qi,rb,dSetupFeeHeader);	
			}
			
			if(excludedFromMSRP(qi)) {
				qi.Off_MSRP__c = 0;
			}

			System.debug('>>> +++++++++++++++++ NAT 112 = qi  % off percent_off_msrp__c='+qi.Off_MSRP__c);
			if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//Performance Part
					ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap);
					System.debug('>>> +++++++++++++++++ NAT 000');
					if(tierMap.containsKey(qis.Toro_Product_Tier__c)) {
						Toro_PricingProgramLine__c rb = tierMap.get(qis.Toro_Product_Tier__c);
						System.debug('>>> +++++++++++++++++ NAT 111 =  rb='+rb);
						applyQISLPercentage(qis,rb,dSetupFeeHeader);
						
					} else {
						qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
						if(excludedFromMSRP(qis)) {
							qis.Percent_Off_MSRP__c = 0;
						} else{
							qis.percent_off_msrp__c =  qi.Off_MSRP__c;
						}
						qis.Part_Percentage__c = qi.Part_Percentage__c;
						qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c)/100);
						qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
					}
					
					//Run Exception
					if(exceptionSkuSet.size() > 0 && exceptionSkuSet.contains(qi.Product_Id__c)) {
						Toro_PricingProgramLine__c rb = tierMap.get(qis.Toro_Product_Tier__c);
						System.debug('>>> +++++++++++++++++ NAT 113 =  rb='+rb);
						applyQISLPercentage(qis,rb,dSetupFeeHeader);
					}
					if(excludedFromMSRP(qis)) {
						qis.Fee_Percentage__c = 0;	
					} else {
						qis.Fee_Percentage__c = qi.Fee_Percentage__c;	
					}
					
					//Calculate extended award price 
					// Extended award price * setup fee perctange
					//dsetupFeesQIS += (CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)  * qi.Quantity__c * qis.Quantity__c) * (CMnQuoteUtil.defaultDecimal(qis.Fee_Percentage__c) /100);
					System.debug('>>> +++++++++++++++++ NAT 112 = qis  % off percent_off_msrp__c='+qis.percent_off_msrp__c);
					//System.debug('>>> +++++++++++++++++ NAT 112 = dsetupFeesQIS='+dsetupFeesQIS);
					
				}
			}			
			
			//calculate total setup fees
			//
			//dtoroTotalSetupFees += (CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * qi.Quantity__c * (CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100)) +  dsetupFeesQIS;
			//System.debug('>>> +++++++++++++++++ NAT 120 qi.Award_Price__c=' + qi.Award_Price__c + ' Quantity__c='+qi.Quantity__c + ' Fee_Percentage__c='+qi.Fee_Percentage__c);
			//System.debug('>>> +++++++++++++++++ NAT 120 qi.Product_Id__c=' + qi.Product_Id__c + ' dtoroTotalSetupFees='+dtoroTotalSetupFees + ' dsetupFeesQIS='+dsetupFeesQIS);
			
		}

		System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 200=');
		
		//delete [Select Id From Toro_QuoteItem__c where Id in :deleteSetupFeeLineItemId];
		//delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
		
		return quoteItemWrapperList;	
	}        
	
	public override List<Toro_QuoteItem__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){

		Decimal dtoroTotalSetupFees = 0;

		for(Toro_QuoteItem__c qi : quoteItemList) {
			Decimal dsetupFeesQIS = 0;
			if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					dsetupFeesQIS += CMnQuoteUtil.defaultDecimal(qis.Toro_Fee_Amount__c);
				}
			}
			dtoroTotalSetupFees += CMnQuoteUtil.defaultDecimal(qi.Toro_Fee_Amount__c);
		}

		REVVY__MnCatalogNode__c setupFeeCN = [Select Id From REVVY__MnCatalogNode__c where REVVY__Id__c = 'S00001'];
		if(dtoroTotalSetupFees > 0) {
			//Create Setup Fee Line Item
			System.debug('>>> +++++++++++++++++ NAT 201 =  dtoroTotalSetupFees='+dtoroTotalSetupFees);
			addSetupFeeFuture(quoteId, setupFeeCN.Id, dtoroTotalSetupFees, dtoroTotalSetupFees, 1);
			this.chainCall = true;
			map<String, Object> payload = new map<String, Object>{ 'quoteId'=>quoteId, 'productId'=>setupFeeCN.Id, 'price'=>dtoroTotalSetupFees,
				'unitPrice'=>dtoroTotalSetupFees, 'qty'=>1	
			};
			this.payloadOfChainCall = JSON.serialize(payload, false);
		}		

		return 	quoteItemList;
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
		                             ,Fee_Percentage__c , Part_Percentage__c, Award_Price_as_a_Percent_of_DN__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		                                  ]) {
			ppMap.put(rl.Tier__c, rl);                           	
		}
		return ppMap;
	}	
	
	public static Map<String,String> retrieveTractionUnit() {
		Map<String,String> tractionUnitMap = new Map<String,String>();
		for(Toro_Traction_Unit_Tier__mdt tu:[Select MasterLabel,DeveloperName,Tier__c From Toro_Traction_Unit_Tier__mdt limit 5000]) {
			System.debug('>>> mdt masterLabel='+tu.Masterlabel + ' DeveloperName=' + tu.DeveloperName + ' Tier=' + tu.Tier__c);
			tractionUnitMap.put(tu.MasterLabel,tu.Tier__c);
		}
		return tractionUnitMap;
				
	}
	
	public void applyQIPercentage(Toro_QuoteItem__c qi, Toro_PricingProgramLine__c rb, decimal dsetupFeeHeader) {

		qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);
		qi.Award_of_DN__c =0;
		qi.Rebate_as_a_of_DN__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);
		qi.Fee_Percentage__c = getSetupFeePercentage(dsetupFeeHeader, CMnQuoteUtil.defaultDecimal(rb.Fee_Percentage__c));
		qi.Part_Percentage__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
			qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		}
		qi.Award_Price__c = qi.MSRP_Price__c * (1-qi.Off_MSRP__c/100);
		qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);
		
	}

	public void applyQISLPercentage(Toro_QuoteItem_SubLine__c qis, Toro_PricingProgramLine__c rb, decimal dsetupFeeHeader) {

		qis.Rebate_as_of_DNet__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);
		if(excludedFromMSRP(qis)) {
			qis.Percent_Off_MSRP__c = 0;
		} else {
			qis.percent_off_msrp__c =  CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);
		}
		
		qis.Part_Percentage__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
			System.debug('>>> +++++++++++++++++ NAT 112 =  rb='+rb);
			if(excludedFromMSRP(qis)) {
				qis.Percent_Off_MSRP__c = 0;
				qis.Fee_Percentage__c = 0;
			} else {
				qis.percent_off_msrp__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
				qis.Fee_Percentage__c = getSetupFeePercentage(dsetupFeeHeader, CMnQuoteUtil.defaultDecimal(rb.Fee_Percentage__c));
			}
		}
		qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c)/100);
		qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
		qis.Percent_of_DNet__c=0;
		
	}
	
	public static decimal getSetupFeePercentage(decimal dfeePercentageHeader, decimal rbFeePercentage) {
		decimal result = rbFeePercentage;
		if(dfeePercentageHeader !=null && dfeePercentageHeader > 0) {
			result = dfeePercentageHeader;			
		}		
		return result;
	}
}