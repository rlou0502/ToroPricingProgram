public with sharing class ToroChartABPricingProgramHelper extends ToroPricingProgram {
	public override List<Schema.FieldSetMember> getQuoteFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}

	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		List<Schema.FieldSetMember> fsl = SObjectType.Revvy__MnStrategy5__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
		return fsl;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_Quote_Line_Summary_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryUpdatableFields() { 
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_QI_Summary_Updatable_Cols.getFields();
	}
//Large_Package_Quote_Line_Cols
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		}
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}
	public override boolean displayPerformancePart() {
		return true;
	}
	private Set<String> pricingProgramSet = new Set<String>();
	public Map<String, String> loadModelIdChartABPricingProgramMap(String pricingProgram) {
		system.debug('getAllowSupportPlus pricingProgram=' + pricingProgram);
		Map<String, String> modelIdPricingProgramMap = new Map<String, String>();
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		List<Revvy__MnStrategy1__c> childrenPricingProgram = [Select Id, ExternalID__c, ApplicableProductsLong__c from Revvy__MnStrategy1__c where Parent_program__r.externalID__c = :ppd.externalId];
		for(Revvy__MnStrategy1__c pp : childrenPricingProgram) {
			pricingProgramSet.add(pp.ExternalID__c);
			if(String.isNotBlank(pp.ApplicableProductsLong__c)) {
				String[] parts = pp.ApplicableProductsLong__c.split(',');
				for(String p : parts) {
					modelIdPricingProgramMap.put(p, pp.ExternalID__c);	
				}
			}
		}
		return modelIdPricingProgramMap;	
	}
	public override List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){		
		//Performance Part
		Map<String, String> model2pp = loadModelIdChartABPricingProgramMap(priceProgram);
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(!qi.Pricing_Program_Overridden__c) {
				qi.Pricing_Program__c = model2pp.get(qi.Product_Id__c);
			} 
			system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part Revvy__MnStrategy4__c 222 performancePartFlag='+performancePartFlag  );
			ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(performancePartFlag, qi, performancePartMap, priceMethod);
				if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						//Performance Part
						system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 333');
						system.debug('-------------++++++++qis' + qis);
						ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap, priceMethod);
					}
				}
		}
		return 	quoteItemList;
	}
	
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
																
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		
		Map<String, decimal> pp2RebateMap = new Map<String, decimal>();
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.primaryPricingProgramExtId = priceProgram;
		helper.quoteItemList = quoteItemList;	
		helper.quote=this.quote;	
		for(String ppId : pricingProgramSet) {
			helper.addPricingProgramExtId(ppId);	
		}
		
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {
		 	helper.distributeQuoteItemTotalAwardDollors().convertAwardPriceToDNetPercent().calculateBlendedDNetPercentFromDNet().retrieveRebatePercent();
			quoteItemList = helper.quoteItemList;			
			for (Revvy__MnStrategy4__c qi : quoteItemList) {
				if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0 ) {
					qi.Off_MSRP__c = ((qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c)*100;
				}
				if(qi.Award_of_DN__c != null) {
					if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							decimal dnet = (qis.TPP_Line_Item__c == true) ? CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) : CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
							if(qis.MSRP_Price__c != null && qis.MSRP_Price__c != 0) {
								qis.Percent_Off_MSRP__c = ((qis.MSRP_Price__c-qis.Award_Price__c)/qis.MSRP_Price__c)*100;
							}
						}
					}
				}
			}

		} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
			helper.convertGPPercentToDNetPercent().calculateBlendedDNetPercentFromDNet().retrieveRebatePercent();
		} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {			
			helper.calculateBlendedDNetPercentFromMSRP().retrieveRebatePercent();
			
		} else if('% of DNET'.equalsIgnoreCase(priceMethod)) {
			helper.calculateBlendedDNetPercentFromDNet().retrieveRebatePercent();
		}
		quote.Toro_Blended_Percent_of_DN__c = helper.quote.Toro_Blended_Percent_of_DN__c;
		quoteItemList = helper.quoteItemList;
		
		return quoteItemList;
	} 
	 
	public override List<Revvy__MnStrategy4__c> postSaveQuoteItemList(Id quoteId
																		, String priceProgram
																		, String priceMethod
																		, List<Revvy__MnStrategy4__c> quoteItemList
	) {
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgram);

		Revvy__MnQuote__c quote = [SELECT
										Toro_ApprovalReason__c
										, REVVY__NeedsApproval__c
										, Toro_Total_DNet__c
										, Toro_Blended_Percent_of_DN__c
									FROM
										Revvy__MnQuote__c
									WHERE
										Id = :quoteId LIMIT 1];

		System.debug('\n\n@@approval flag - quote: ' + quote + '\n\n');
		Boolean containsOutCross = checkForOutCrossProducts(quoteItemList);
		Integer numberOfTractionUnits = getNumberOfTractionUnits(quoteItemList);

		// quotes that contain outcross items have a separate threshold

		Boolean needsApproval = false;
		String approvalMessage = '';

		if (containsOutCross && quote.Toro_Total_DNet__c < pricingProgram.OutCrossThreshold__c) {
			needsApproval = true;
			approvalMessage = 'Total Extended DNet must exceed ' + pricingProgram.OutCrossThreshold__c + '.' + ' (It is ' + quote.Toro_Total_DNet__c + ').';
		}

		else if (!containsOutcross && quote.Toro_Total_DNet__c < pricingProgram.MinimumThreshold__c) {
			needsApproval = true;
			approvalMessage = 'Total Extended DNet must exceed ' + pricingProgram.MinimumThreshold__c + '.' + ' (It is ' + quote.Toro_Total_DNet__c + ').';
		}

		if (quote.Toro_Blended_Percent_of_DN__c < pricingProgram.Blended_DNet_Threshold__c) {
			needsApproval = true;
			approvalMessage = ' Blended Percent of DNet must exceed ' + pricingProgram.Blended_DNet_Threshold__c + '%.';
		}

		if (numberOfTractionUnits < pricingProgram.MinimumTractionUnits__c) {
			needsApproval = true;
			approvalMessage += ' Quote must contain at least ' + pricingProgram.MinimumTractionUnits__c + ' traction unit(s).';
		}

		if (needsApproval) {
			quote.REVVY__NeedsApproval__c = true;
			quote.Toro_ApprovalReason__c = approvalMessage;
		}

		else {
			quote.REVVY__NeedsApproval__c = false;
			quote.Toro_ApprovalReason__c = '';
		}

		update quote;

		return	quoteItemList;
	}

	/**
	 *
	 * returns the number of Traction Units in a quote
	 *
	 * @param  quoteItemList    the list of Toro Quote Items
	 * @return count of traction units
	 */
	public Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good') {
				count++;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}

	/**
	 *
	 * check if the quote items contain an Out-Cross unit
	 *
	 * @param  quoteItemList    the list of Toro Quote Items
	 * @return true/false
	 */
	public Boolean checkForOutCrossProducts(List<Revvy__MnStrategy4__c> quoteItemList) {
		System.debug('\n\n@@checkForOutCrossProducts quoteItemList: ' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product_Name__c.startsWithIgnorecase('OUTCROSS')) {
				System.debug('\n\n@@contains outcross\n\n');
				return true;
			}
		}

		return false;
	}    
}