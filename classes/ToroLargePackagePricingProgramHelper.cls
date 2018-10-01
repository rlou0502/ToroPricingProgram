public virtual class ToroLargePackagePricingProgramHelper extends ToroPricingProgram {
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
	public virtual override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		}
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}

	public override List<ToroSelectOption> retrieveDemoPricingProgramOptions() {
		List<ToroSelectOption> sels = new List<ToroSelectOption>();
		for(Revvy__MnStrategy1__c pp : [SELECT Name, PricingProgramStyle__c, ExternalId__c FROM Revvy__MnStrategy1__c
									where PricingProgramStyle__c = 'Demo' AND Exclude__c = false order by externalID__c asc]){
			sels.add(new ToroSelectOption(pp.ExternalId__c+ ';' + pp.PricingProgramStyle__c, pp.name));
		}
		return sels;
	}
	public override boolean displayPerformancePart() {
		return true;
	}

	public virtual override List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
			//Performance Part
		quoteItemList=super.preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper pricing program ='+qi.pricing_program__c  );
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
		quoteItemList = loadPricesFromPricelist(priceProgram, quoteItemList);
		return 	quoteItemList;
	}

	public virtual override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.pricingProgramExternalId = priceProgram;
		helper.primaryPricingProgramExtId = priceProgram;
		system.debug(logginglevel.info, 'helper.pricingProgramExternalId='+ helper.pricingProgramExternalId );
		
		helper.quoteItemList = quoteItemList;
		helper.quote=this.quote;
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(String.isNotBlank(qi.pricing_program__c)) {
				helper.addPricingProgramExtId(qi.pricing_program__c);	
			}
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
							decimal dnet =  CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
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
		//TCPQ-2528 Support Plus within Program change to Approvals required
		//Move following line to preSaveCalculateRebateMargin
		//quoteItemList = CMnQuoteUtil.checkIfApprovalNeeded(this.quote, priceProgram, priceMethod, quoteItemList );
		return quoteItemList;
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public override List<Revvy__MnStrategy4__c> postSaveQuoteItemList(Id quoteId 
																		, String priceProgram
																		, String priceMethod
																		, List<Revvy__MnStrategy4__c> quoteItemList
	) {
		System.debug('\n\n@@postSaveQuoteItemList called\n\n');
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgram);

		quoteItemList = CMnQuoteUtil.checkIfApprovalNeeded(this.quote, priceProgram, priceMethod, quoteItemList );
		System.debug('\n\n@@scottcheck\n\n');
		System.debug('\n\n@@pricingProgram: ' + pricingProgram + '\n\n');
		System.debug('\n\n@@quote: ' + quote + '\n\n');
		update quote;

		return	quoteItemList;
	}
	
	//TCPQ-2528 Support Plus within Program change to Approvals required
	public override List<Revvy__MnStrategy4__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
																
		quoteItemList = super.preSaveCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		quoteItemList = CMnQuoteUtil.checkIfApprovalNeeded(this.quote, priceProgram, priceMethod, quoteItemList );
		return quoteItemList;
	}
}