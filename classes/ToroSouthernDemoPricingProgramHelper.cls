public with sharing class ToroSouthernDemoPricingProgramHelper  extends ToroPricingProgram {
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
		pricingProgramSet.add(ppd.externalId);
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
		system.debug('primary pp =' + ppd.externalId);
		Revvy__MnStrategy1__c southernDemo = ToroCacheManager.getPricingProgram(ppd.externalId);
		if(String.isNotBlank(southernDemo.ApplicableProductsLong__c)) {
			system.debug('primary ApplicableProductsLong__c =' + southernDemo.ApplicableProductsLong__c);
			String[] parts = southernDemo.ApplicableProductsLong__c.split(',');
			for(String p : parts) {
				modelIdPricingProgramMap.put(p, southernDemo.ExternalID__c);	
			}
		}
		return modelIdPricingProgramMap;	
	}
	public override List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){		
		//Performance Part
		quoteItemList=super.preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		Map<String, String> model2pp = loadModelIdChartABPricingProgramMap(priceProgram);
		
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(!qi.Pricing_Program_Overridden__c || qi.Pricing_Program__c.contains(priceProgram)) {
				qi.Pricing_Program__c = model2pp.get(qi.Product_Id__c);	
			}
			system.debug('qi.Pricing_Program__c=' + qi.Pricing_Program__c + ' model id=' + qi.Product_Id__c);
			if(qi.Pricing_Program__c== null) {
				system.debug('map=' + model2pp);	
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
		
		helper.quoteItemList = quoteItemList;	
		helper.quote=this.quote;	
		for(String ppId : pricingProgramSet) {
			helper.addPricingProgramExtId(ppId);	
		}
		
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {
		 	helper.convertAwardPriceToDNetPercent().calculateBlendedDNetPercentFromDNet().retrieveRebatePercent();
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
		quoteItemList = CMnQuoteUtil.checkIfApprovalNeeded(this.quote, priceProgram, priceMethod, quoteItemList );
		return quoteItemList;
	}
	
	public override List<Revvy__MnStrategy4__c> postSaveQuoteItemList(Id quoteId 
																		, String priceProgram
																		, String priceMethod
																		, List<Revvy__MnStrategy4__c> quoteItemList
	) {
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgram);
		
		quoteItemList = CMnQuoteUtil.checkIfApprovalNeeded(this.quote, priceProgram, priceMethod, quoteItemList );
		System.debug('\n\n@@scottcheck\n\n');
		System.debug('\n\n@@pricingProgram: ' + pricingProgram + '\n\n');
		System.debug('\n\n@@quote: ' + quote + '\n\n');
		update quote;

		return	quoteItemList;

	}
}