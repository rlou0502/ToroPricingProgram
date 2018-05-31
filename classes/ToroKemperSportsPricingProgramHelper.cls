public with sharing class ToroKemperSportsPricingProgramHelper extends ToroPricingProgram {

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
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.National_Account_Quote_Line_Updtbl_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.National_Account_Quote_SubLine_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.National_Account_Quote_Line_Cols.getFields();
	}
	public override boolean displaySetupFee() {
		return true;
	}
	public override boolean displayPerformancePart() {
		return true;
	}

	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(
																	Id quoteId
																	, String priceProgramExternalId
																	, String priceMethod
																	, List<Revvy__MnStrategy4__c> quoteItemWrapperList
	) {
		System.debug('\n\n@@quoteItemWrapperList: ' + quoteItemWrapperList + '\n\n');
		System.debug('\n\n@@priceProgramExternalId: ' + priceProgramExternalId + '\n\n');
		System.debug('\n\n@@priceMethod: ' + priceMethod + '\n\n');
		System.debug('\n\n@@performancePartFlag: ' + performancePartFlag + '\n\n');
		System.debug('\n\n@@setupFeePercentage: ' + setupFeePercentage + '\n\n');

		quote.Performance_Part__c = performancePartFlag;

		Map<String,Revvy__MnStrategy2__c> tierMap = retrieveNationalAccount(priceProgramExternalId);
		System.debug('\n\n@@tierMap: ' + tierMap + '\n\n');

		Map<String,String> tractionUnitMap = retrieveTractionUnit();

		//decimal dSetupFeeHeader = ToroCacheManager.getSetupFee();
		decimal dSetupFeeHeader = setupFeePercentage;
		System.debug(logginglevel.info, '>>> Setup fee from cache=' + dSetupFeeHeader);

		// Exception
		Map<String,Revvy__MnStrategy2__c> ppMapExceptionMap = retrieveNationalAccountException(priceProgramExternalId);
		Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		List<Revvy__MnStrategy4__c> updatedQuoteItems = new List<Revvy__MnStrategy4__c>();
		for (Revvy__MnStrategy4__c qi : quoteItemWrapperList) {
			resetQIPercentage(qi);

			if ('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
				//deleteSetupFeeLineItemId.add(qi.Id);
				deleteSetupFeeLineItemId.add(qi.QuoteItem__c);
			}

			Decimal dsetupFeesQIS = 0;

			// Performance Part
			boolean bqiPP = ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(performancePartFlag, qi, performancePartMap, priceMethod);
			if (!bqiPP) {
				if (String.isEmpty(qi.Toro_Product_Tier__c) && !String.isEmpty(qi.Traction_Unit__c) && tractionUnitMap.containsKey(qi.Traction_Unit__c)) {
					String stier = tractionUnitMap.get(qi.Traction_Unit__c);
					Revvy__MnStrategy2__c rb = tierMap.get(stier);
					applyQIPercentage(qi,rb,dSetupFeeHeader);
				}

				else if (tierMap.containsKey(qi.Toro_Product_Tier__c)) {
					Revvy__MnStrategy2__c rb = tierMap.get(qi.Toro_Product_Tier__c);
					applyQIPercentage(qi,rb,dSetupFeeHeader);
				}

				// Parts
				if ('Semi-Finished Good'.equalsIgnoreCase(qi.Product__r.Toro_Product_Type__c)) {
					Revvy__MnStrategy2__c rb = tierMap.get('Parts');
					applyQIPercentage(qi,rb,dSetupFeeHeader);
				}

				// Run Exception
				if (ppMapExceptionMap.size() > 0 && ppMapExceptionMap.containsKey(qi.Product_Id__c)) {
					Revvy__MnStrategy2__c rb = ppMapExceptionMap.get(qi.Product_Id__c);
					applyQIPercentage(qi,rb,dSetupFeeHeader);
				}
			}

			if (qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					resetQISLPercentage(qis);

					// Performance Part
					ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap, priceMethod);
					if (!bqiPP) {
						if (tierMap.containsKey(qis.Toro_Product_Tier__c)) {
							Revvy__MnStrategy2__c rb = tierMap.get(qis.Toro_Product_Tier__c);
							applyQISLPercentage(qis,rb,dSetupFeeHeader);
						}

						else {
							qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
							//if (excludedFromMSRP(qis)) {
							//	qis.Percent_Off_MSRP__c = 0;
							//} else{
								qis.percent_off_msrp__c =  qi.Off_MSRP__c;
							//}
							qis.Part_Percentage__c = qi.Part_Percentage__c;
							qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * (1 - CMnQuoteUtil.defaultDecimal(qis.percent_off_msrp__c)/100);
							qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
						}

						// Parts
						if ('Semi-Finished Good'.equalsIgnoreCase(qis.Product__r.Toro_Product_Type__c)) {
							Revvy__MnStrategy2__c rb = tierMap.get('Parts');
							applyQISLPercentage(qis,rb,dSetupFeeHeader);
						}

						// Run Exception
						if (ppMapExceptionMap.size() > 0 && ppMapExceptionMap.containsKey(qis.Product_Id__c)) {
							Revvy__MnStrategy2__c rb = ppMapExceptionMap.get(qis.Product_Id__c);
							applyQISLPercentage(qis,rb,dSetupFeeHeader);
						}

						if (excludedFromMSRP(qis)) {
							qis.Fee_Percentage__c = 0;
						}

						else {
							qis.Fee_Percentage__c = qi.Fee_Percentage__c;
						}

						// Calculate extended award price
						// Extended award price * setup fee perctange
						//dsetupFeesQIS += (CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)  * qi.Quantity__c * qis.Quantity__c) * (CMnQuoteUtil.defaultDecimal(qis.Fee_Percentage__c) /100);
					}
				}
			}

			// Calculate total setup fees
			//dtoroTotalSetupFees += (CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * qi.Quantity__c * (CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100)) +  dsetupFeesQIS;
		}

		//delete [Select Id From Revvy__MnStrategy4__c where Id in :deleteSetupFeeLineItemId];
		//delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
		return quoteItemWrapperList;
	}

	public Revvy__MnStrategy4__c retrieveSetupFeeQuoteItem(Id quoteId) {
		String quoteLineQuery = 'Select ' + getToroQuoteItemFieldAPINamesQuery('OnlyExistedInCPL__c,Original_Award_Price__c,Off_MSRP_Overridden__c, Product__r.Toro_Product_Type__c,Traction_Unit__c, Off_MSRP__c,Award_Price__c,Rebate_as_a_of_DN__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, MSRP_Price__c, Original_off_MSRP__c, Oroginal_of_DNet__c,Unit_Award_Overridden__c, QuoteItem__r.REVVY__Catalog_Node__r.revvy__id__c, QuoteItem__r.REVVY__Catalog_Node__r.name, Product__r.Hierarchy_Code__c,QuoteItem__r.REVVY__SuggestedPrice__c,Misc_Style__c , DNet_Price__c,QuoteItem__r.REVVY__Price__c,Off_MSRP__c, Selected_Off_MSRP__c, Pricing_Program__c, Select_a_Price_Method__c, Award_of_DN__c, Standard_Price__c');
		quoteLineQuery += ' from Revvy__MnStrategy4__c where Mn_Quote__c = :quoteId and Product_Id__c = \'S00001\'';
		List<Revvy__MnStrategy4__c> quoteItems = Database.query(quoteLineQuery);
		if (quoteItems.size() > 0) {
			return quoteItems[0];
		}

		else {
			return null;
		}
	}

	public override List<Revvy__MnStrategy4__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){

			Decimal dtoroTotalSetupFees = 0;
			/*
			for (Revvy__MnStrategy4__c qi : quoteItemList) {
				Decimal dsetupFeesQIS = 0;
				if (qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						dsetupFeesQIS += CMnQuoteUtil.defaultDecimal(qis.Toro_Fee_Amount__c);
					}
				}
				System.debug('>>> +++++++++++++++++ NAT 201 =  Toro_Fee_Amount__c='+qi.Toro_Fee_Amount__c);
				dtoroTotalSetupFees += CMnQuoteUtil.defaultDecimal(qi.Toro_Fee_Amount__c);
			}
			*/
			REVVY__MnCatalogNode__c setupFeeCN = [Select Id From REVVY__MnCatalogNode__c where REVVY__Id__c = 'S00001'];
			//if (dtoroTotalSetupFees > 0) {
				//Create Setup Fee Line Item
		    	dtoroTotalSetupFees = 0;
		    	if (setupFeePercentage!= null && setupFeePercentage >0) {
		    		dtoroTotalSetupFees = (CMnQuoteUtil.defaultDecimal(quote.Toro_Rollup_Award_Price__c) * setupFeePercentage) / 100;

		    		addSetupFeeFuture(quoteId, setupFeeCN.Id, dtoroTotalSetupFees, dtoroTotalSetupFees, 1);
		    		system.debug('exiting addSetupFeeFuture 1');

		    		//this.initialize(this.quote.Id);

					quoteItemList = this.quoteItems;

		    		Revvy__MnStrategy4__c setupQi = retrieveSetupFeeQuoteItem(this.quote.Id);
		    		system.debug('exiting addSetupFeeFuture 2');

					// Read extended quote item
					boolean foundSetupFeeQuoteItem = false;
					for (Revvy__MnStrategy4__c qi : quoteItemList) {
						if ('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
							qi.Award_Price__c          = setupQi.Award_Price__c;
							qi.Total_Award__c          = setupQi.Total_Award__c;
							qi.Total_Toro_Award__c     = setupQi.Total_Toro_Award__c;
							qi.Extended_Award_Price__c = setupQi.Extended_Award_Price__c;
							//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(dtoroTotalSetupFees).setScale(2);
							foundSetupFeeQuoteItem = true;
							break;
						}
					}
					if (!foundSetupFeeQuoteItem) {
			    		System.debug('>>> +++++++++++++++++ SETUP FEE 222 not found');
			    		if (setupQi != null) {
			    			//setupQi.Award_Price__c = CMnQuoteUtil.defaultDecimal(dtoroTotalSetupFees).setScale(2);
			    			quoteItemList.add(setupQi);
			    			System.debug('>>> +++++++++++++++++ SETUP FEE 222 not found = ' + quoteItemList);
			    		}
					}
		    	}

			//this.chainCall = true;
			//map<String, Object> payload = new map<String, Object>{ 'quoteId'=>quoteId, 'productId'=>setupFeeCN.Id, 'price'=>dtoroTotalSetupFees,
				//'unitPrice'=>dtoroTotalSetupFees, 'qty'=>1
			//};
			//this.payloadOfChainCall = JSON.serialize(payload, false);
		//}

		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			if ('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
				System.debug('>>> +++++++++++++++++ SETUP FEE 333 found qi=' + qi);
			}
		}

		return quoteItemList;
	}

	//@future
    public static void addSetupFeeFuture(String quoteId, String productId, decimal price, decimal unitPrice, decimal qty) {
    	System.debug('>>> +++++++++++++++++ Setup FEE unitPrice='+ unitPrice + ' - Price='+ price);
    	List<Revvy__MnQuoteItem__c> setupFees = [select Id from Revvy__MnQuoteItem__c where Revvy__Product_Id_F__c = 'S00001' and revvy__Quote__c = :quoteId];
    	system.debug('----size =' + setupFees.size());
    	if (setupFees.size() == 0) {

			REVVY__MnQuoteItem__c mnqi  = new REVVY__MnQuoteItem__c();
			mnqi.REVVY__Quote__c        = quoteId;
			mnqi.REVVY__Catalog_Node__c = productId;
			mnqi.Revvy__Price__c        = price;
			mnqi.REVVY__Unit_Price__c   = unitPrice;
			mnqi.REVVY__Quantity__c     = qty;
			mnqi.Dirty__c               = true;

			Revvy__MnSequenceGen__c sequence = [SELECT Id,  REVVY__CurrentValue__c FROM Revvy__MnSequenceGen__c WHERE Revvy__ObjectName__c='MnQuoteItem__c' limit 1];
			mnqi.REVVY__Id__c = ++sequence.REVVY__CurrentValue__c;
			insert mnqi;

			++sequence.REVVY__CurrentValue__c;
			update sequence;

			Revvy__MnStrategy4__c tqi = new Revvy__MnStrategy4__c(External_Id__c = mnqi.Id, award_price__c=mnqi.Revvy__Price__c,
				extended_award_price__c= mnqi.Revvy__Price__c * qty, Total_Toro_Award__c = mnqi.Revvy__Price__c * qty, Total_Award__c=mnqi.Revvy__Price__c * qty);
	    	upsert tqi External_Id__c;
	    	System.debug('>>> +++++++++++++++++ Setup FEE unitPrice='+ unitPrice + ' - Price='+ price + ' id='+ mnqi.Id);
    	}

		else {
    		List<Revvy__MnStrategy4__c> updateQuoteItems = new List<Revvy__MnStrategy4__c>();
    		system.debug('check point 1');
    		for (Revvy__MnQuoteItem__c qi : setupFees) {
    			qi.Revvy__Price__c = price;
    			qi.REVVY__Unit_Price__c = unitPrice;

    			updateQuoteItems.add(new Revvy__MnStrategy4__c(
					External_Id__c = qi.Id
					, award_price__c=qi.Revvy__Price__c
					, extended_award_price__c= qi.Revvy__Price__c * qty
					, Total_Toro_Award__c = qi.Revvy__Price__c * qty
					, Total_Award__c=qi.Revvy__Price__c * qty
				));
    		}

    		try {
    			upsert updateQuoteItems External_Id__c;
    		}

			catch (Exception e) {
    			system.debug('-----' + e);
    		}

    	}
    	system.debug('exiting addSetupFeeFuture');
    }

	public static Map<String,Revvy__MnStrategy2__c> retrieveNationalAccount(String pricingProgramExternalId) {
		Map<String,Revvy__MnStrategy2__c> ppMap = new Map<String,Revvy__MnStrategy2__c>();
		for (Revvy__MnStrategy2__c rl : [
						Select
							Id, ApplicableProducts__c, Pricing_1__c
							, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c
							, Tier__c,Fee_Percentage__c , Part_Percentage__c
							, Award_Price_as_a_Percent_of_DN__c
		                From
							Revvy__MnStrategy2__c
		                Where
							PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		]) {
			if (!'Exception'.equalsIgnoreCase(rl.Tier__c)) {
				ppMap.put(rl.Tier__c, rl);
			}
		}
		return ppMap;
	}

	public static Map<String,Revvy__MnStrategy2__c> retrieveNationalAccountException(String pricingProgramExternalId) {
		Map<String,Revvy__MnStrategy2__c> ppMap = new Map<String,Revvy__MnStrategy2__c>();
		for (Revvy__MnStrategy2__c rl:[Select Id, ApplicableProducts__c, Pricing_1__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c, Tier__c
		                             ,Fee_Percentage__c , Part_Percentage__c, Award_Price_as_a_Percent_of_DN__c
		                          From Revvy__MnStrategy2__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		                                  ]) {

			if ('Exception'.equalsIgnoreCase(rl.Tier__c)) {
				if (!String.isEmpty(rl.ApplicableProducts__c)) {
					for (String s:rl.ApplicableProducts__c.split(',')) {
						String ssku = s.replaceAll(' ','');
						ppMap.put(ssku, rl);
					}
				}
			}
		}

		return ppMap;
	}

	public static Map<String,String> retrieveTractionUnit() {
		Map<String,String> tractionUnitMap = new Map<String,String>();
		for (Toro_Traction_Unit_Tier__mdt tu:[Select MasterLabel,DeveloperName,Tier__c From Toro_Traction_Unit_Tier__mdt limit 5000]) {
			System.debug('>>> mdt masterLabel='+tu.Masterlabel + ' DeveloperName=' + tu.DeveloperName + ' Tier=' + tu.Tier__c);
			tractionUnitMap.put(tu.MasterLabel,tu.Tier__c);
		}
		return tractionUnitMap;

	}

	public void resetQIPercentage(Revvy__MnStrategy4__c qi) {
		qi.Off_MSRP__c           = 0;
		qi.Award_of_DN__c        = 0;
		qi.Rebate_as_a_of_DN__c  = 0;
		qi.Fee_Percentage__c     = 0;
		qi.Part_Percentage__c    = 0;
		qi.Award_Price__c        = 0;
		qi.PricingMethodValue__c = '';
	}

	public void applyQIPercentage(Revvy__MnStrategy4__c qi, Revvy__MnStrategy2__c rb, decimal dsetupFeeHeader) {
		qi.Off_MSRP__c          = CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);
		qi.Award_of_DN__c       = rb.Award_Price_as_a_Percent_of_DN__c;
		qi.Rebate_as_a_of_DN__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);
		qi.Fee_Percentage__c    = getSetupFeePercentage(dsetupFeeHeader, CMnQuoteUtil.defaultDecimal(rb.Fee_Percentage__c));
		qi.Part_Percentage__c   = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);

		if (rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
			qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		}

		qi.Award_Price__c        = qi.MSRP_Price__c * (1-qi.Off_MSRP__c/100);
		qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);
	}

	public void resetQISLPercentage(Revvy__MnStrategy5__c qis) {
		qis.Rebate_as_of_DNet__c  = 0;
		qis.Percent_Off_MSRP__c   = 0;
		qis.Part_Percentage__c    = 0;
		qis.Fee_Percentage__c     = 0;
		qis.Award_Price__c        = 0;
		qis.PricingMethodValue__c = '';
		qis.Percent_of_DNet__c    = 0;
	}

	public void applyQISLPercentage(Revvy__MnStrategy5__c qis, Revvy__MnStrategy2__c rb, decimal dsetupFeeHeader) {
		qis.Rebate_as_of_DNet__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);
		//if (excludedFromMSRP(qis)) {
		//	qis.Percent_Off_MSRP__c = 0;
		//} else {
			qis.percent_off_msrp__c =  CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);
		//}

		qis.Part_Percentage__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);

		if (rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
			if (excludedFromMSRP(qis)) {
				//qis.Percent_Off_MSRP__c = 0;
				qis.Fee_Percentage__c = 0;
			}

			else {
				//qis.percent_off_msrp__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
				qis.Fee_Percentage__c = getSetupFeePercentage(dsetupFeeHeader, CMnQuoteUtil.defaultDecimal(rb.Fee_Percentage__c));
			}

			qis.percent_off_msrp__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		}

		if (!qis.Unit_Award_Overridden__c) {
			qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c)/100);
		}

		qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
		qis.Percent_of_DNet__c=rb.Award_Price_as_a_Percent_of_DN__c;

	}

	public static decimal getSetupFeePercentage(decimal dfeePercentageHeader, decimal rbFeePercentage) {
		decimal result = rbFeePercentage;
		if (dfeePercentageHeader !=null && dfeePercentageHeader > 0) {
			result = dfeePercentageHeader;
		}

		return result;
	}

	/*
	public override List<Revvy__MnStrategy4__c> calculateExtendedFields(List<Revvy__MnStrategy4__c> quoteItemList) {
		decimal quoteMSRP                 = 0;
		decimal quoteTotalAward           = 0;
		decimal quoteTotalToroAward       = 0;
		decimal quoteTotalDNet            = 0;
		decimal quoteTotalSetupFee        = 0;
		decimal quoteToroTotalDNet        = 0;
		decimal quoteTotalGP              = 0;
		decimal quoteTotalRebate          = 0;
		decimal quoteTotalDnetWOTppAllied = 0;
		decimal quoteTPPAppliedDNet       = 0;
		decimal quoteToroDNet             = 0;
		decimal quoteTPPAppliedMSRP       = 0;
		decimal quoteToroMSRP             = 0;
		decimal quoteTPPAppliedAward      = 0;
		decimal quoteToroAward            = 0;


		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			decimal qiTotalDNet       = 0;
			decimal qiTotalMSRP       = 0;
			decimal qiTotalAward      = 0;
			decimal qiTPPAppliedDNet  = 0;
			decimal qiToroDNet        = 0;
			decimal qiTPPAppliedMSRP  = 0;
			decimal qiToroMSRP        = 0;
			decimal qiTPPAppliedAward = 0;
			decimal qiToroAward       = 0;

			//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
			qi.Toro_Total_Setup_Fees__c = 0;
			qi.Total_Award__c           = 0;
			qi.Total_Toro_Award__c      = 0;
			qi.DNet_Price__c            = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			qi.MSRP_Price__c            = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c);
			qi.Award_Price__c           = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
			qi.Extended_DNet_Price__c   = CMnQuoteUtil.defaultDecimal(qi.Extended_DNet_Price__c);
			qi.Extended_MSRP_Price__c   = CMnQuoteUtil.defaultDecimal(qi.Extended_MSRP_Price__c);
			qi.Rebate_as_a_of_DN__c     = CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c);
			qi.Total_Toro_MSRP__c       = CMnQuoteUtil.defaultDecimal(qi.Total_Toro_MSRP__c);
			qi.Total_Toro_DNET__c       = CMnQuoteUtil.defaultDecimal(qi.Total_Toro_DNET__c);
			qi.Total_DNET__c            = CMnQuoteUtil.defaultDecimal(qi.Total_DNET__c);
			system.debug('check total award for each qi -- 1 qi.award price= ' + qi.award_price__c );

			if(!excludeTPPAllied(qi)) {
				qiToroDNet                 = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
				qiToroMSRP                 = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiToroAward                = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiToroAward;
				qi.Extended_DNet_Price__c  = qiToroDNet;
				qi.Extended_MSRP_Price__c  = qiToroMSRP;
			}

			else {
				qiTPPAppliedDNet           = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedMSRP           = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedAward          = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiTPPAppliedAward;
				qi.Extended_DNet_Price__c  = qiToroDNet;
				qi.Extended_MSRP_Price__c  = qiToroMSRP;
			}

			qiTotalDNet       = qiToroDNet + qiTPPAppliedDNet;
			qiTotalMSRP       = qiToroMSRP + qiTPPAppliedMSRP;
			qiTotalAward      = qiToroAward + qiTPPAppliedAward;
			qi.Total_Award__c = qiTotalAward;
			qi.Toro_Fee_Amount__c = CMnQuoteUtil.defaultDecimal(qi.Extended_Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100;
			decimal extFeeAmount = qi.Toro_Fee_Amount__c;
			qi.Toro_Rebate__c = qi.Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;

			decimal extRebate = qi.Toro_Rebate__c;
			if(!qi.DrivenByGP__c) {
				qi.Toro_Gross_Profit_Value__c = qi.Extended_Award_Price__c - qi.Extended_DNet_Price__c + qi.Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;
				if(qi.Extended_Award_Price__c != null && qi.Extended_Award_Price__c != 0) {
					qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/qi.Extended_Award_Price__c*100;
				}
			}

			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				decimal qisRollupTPPAppliedDNet = 0;
				decimal qisRollupToroDNet = 0;
				decimal qisRollupTPPAppliedMSRP = 0;
				decimal qisRollupToroMSRP = 0;
	        	decimal qisRollupTPPAppliedAward = 0;
				decimal qisRollupToroAward = 0;
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
					qis.Toro_Extended_Qty__c = extQty;
					qis.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
					qis.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c);
					qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					qis.TPP_DNet__c = CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c);
					qis.Rebate_as_of_DNet__c = CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c);
					if(!qis.Exclude_from_Rebate__c) {
						qisRollupToroDNet += qis.DNet_Price__c * extQty;
						qisRollupToroMSRP += qis.MSRP_Price__c * extQty;
						qisRollupToroAward += qis.Award_Price__c * extQty;
						qis.Extended_MSRP_Price__c = qis.MSRP_Price__c * extQty;
						qis.Extended_DNet_Price__c = qis.DNet_Price__c * extQty;
						qis.Extended_Award_Price__c = qis.Award_Price__c * extQty;
					} else {
						//use TPP_DNet here
						qisRollupTPPAppliedDNet += qis.TPP_DNet__c * extQty;
						qisRollupTPPAppliedMSRP += qis.MSRP_Price__c * extQty;
						qisRollupTPPAppliedAward += qis.Award_Price__c * extQty;
						qis.Extended_MSRP_Price__c = qis.MSRP_Price__c * extQty;
						qis.Extended_Award_Price__c = qis.Award_Price__c * extQty;
						qis.Extended_DNet_Price__c = qis.TPP_DNet__c * extQty;
					}

					if(!qis.Exclude_from_Rebate__c) {
						if(!qi.DrivenByGP__c) {
							qis.Gross_Profit_Value__c = qis.Extended_Award_Price__c - qis.Extended_DNet_Price__c + (qis.Extended_DNet_Price__c * qis.Rebate_as_of_DNet__c/100);
							if(qis.Extended_Award_Price__c != 0) {
								qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c/qis.Extended_Award_Price__c*100;
							}
						} else {
							qis.Gross_Profit_Value__c = qis.Gross_Profit_Percent__c/100*qis.Extended_Award_Price__c;
						}
						qis.Toro_Subline_Rebate__c = qis.Extended_DNet_Price__c * qis.Rebate_as_of_DNet__c/100;
						extRebate += qis.Toro_Subline_Rebate__c;
						//qis.Toro_Extended_Award_Price__c = subExtAward;
						qis.Toro_Fee_Amount__c = qis.Extended_Award_Price__c * CMnQuoteUtil.defaultDecimal(qis.Fee_Percentage__c)/100;
						extFeeAmount += qis.Toro_Fee_Amount__c;
						system.debug(logginglevel.info,'====% off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);
						//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;
					}

					qi.Total_Award__c = qiTotalAward + qisRollupToroAward+ qisRollupTPPAppliedAward;
					system.debug('check total award for each qi -- 1 qi.Total_Award__c= ' + qi.Total_Award__c + ' qiTotalAward='+qiTotalAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);
					qi.Total_Toro_Award__c = qi.Total_Award__c - qisRollupTPPAppliedAward - qiTPPAppliedAward;
					system.debug('check total award for each qi -- 1 qi.Total_Toro_Award__c= ' + qi.Total_Toro_Award__c + ' qiTPPAppliedAward='+qiTPPAppliedAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);

					qi.Total_MSRP__c      = qiTotalMSRP + qisRollupToroMSRP+ qisRollupTPPAppliedMSRP;

					// qi.Total_Toro_MSRP__c = qi.Total_MSRP__c - qisRollupTPPAppliedMSRP - qiTPPAppliedMSRP;
					qi.Total_Toro_MSRP__c = qi.Total_MSRP__c - qiTPPAppliedMSRP;

					qi.Total_DNET__c      = qiTotalDNET + qisRollupToroDNET+ qisRollupTPPAppliedDNET;
					qi.Total_Toro_DNET__c = qi.Total_DNET__c - qisRollupTPPAppliedDNET - qiTPPAppliedDNET;

					System.debug('\n\n@@qi: ' + qi + '\n\n');
					System.debug('@@qi.Product_Name__c: ' + qi.Product_Name__c);
					System.debug('@@qis.Product_Name__c: ' + qis.Product_Name__c);
					System.debug('@@qisRollupToroMSRP: ' + qisRollupToroMSRP);
					System.debug('@@qisRollupTPPAppliedMSRP: ' + qisRollupTPPAppliedMSRP);
					System.debug('@@qiTPPAppliedMSRP: ' + qiTPPAppliedMSRP);
					System.debug('@@qi.Total_MSRP__c: ' + qi.Total_MSRP__c);
					System.debug('@@qi.Total_Toro_MSRP__c: ' + qi.Total_Toro_MSRP__c);
					System.debug('@@qi.Total_DNET__c: ' + qi.Total_DNET__c);
					System.debug('@@qi.Total_Toro_DNET__c: ' + qi.Total_Toro_DNET__c + '\n\n');
				}
			}


			qi.Toro_Total_Setup_Fees__c = extFeeAmount;
			qi.Toro_Total_Rebate__c = extRebate;
			//qi.Toro_Total_Extended_Award_Price__c = extAward;
			//qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			//qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			if( qi.Total_Toro_MSRP__c != 0) {
				system.debug('check total award for each qi -- 2 qi.Total_Toro_Award__c= ' + qi.Total_Toro_Award__c + ' qi.Total_Toro_MSRP__c='+qi.Total_Toro_MSRP__c);
				qi.Blended_MSRP__c = 100 - (qi.Total_Toro_Award__c/qi.Total_Toro_MSRP__c)*100;
			}
			if(qi.Total_Toro_DNET__c != 0) {
				qi.Toro_Blend_Of_DN__c = qi.Total_Toro_Award__c/qi.Total_Toro_DNET__c*100;
				qi.Blended_Rebate__c = qi.Toro_Total_Rebate__c/qi.Total_Toro_DNET__c*100;
			}

			qi.Total_Gross_Profit_Value__c = qi.Total_Toro_Award__c - qi.Total_Toro_DNET__c + qi.Toro_Total_Rebate__c;
			if(qi.Total_Toro_Award__c != 0) {
				qi.Blended_GP__c = qi.Total_Gross_Profit_Value__c/qi.Total_Toro_Award__c*100;
			}

			//system.debug('checking MSRP ext qi.Toro_Total_Extended_MSRP_Price__c=' + qi.Toro_Total_Extended_MSRP_Price__c);
			system.debug('check total award for each qi -- 1 quoteTotalAward= ' + quoteTotalAward + ' quoteTotalToroAward='+quoteTotalToroAward);
			quoteTotalAward       		+= qi.Total_Award__c;
			quoteTotalToroAward       	+= qi.Total_Toro_Award__c;
			quoteTotalDNet              += qi.Total_DNET__c;
			quoteToroTotalDNet          += qi.Total_Toro_DNET__c;
			quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			quoteTotalRebate       		+= qi.Toro_Total_Rebate__c;
			quoteTotalDnetWOTppAllied   += qi.Total_Toro_Award__c;
			quoteTotalSetupFee          += qi.Toro_Total_Setup_Fees__c;
			quoteMSRP					+= qi.Total_Toro_MSRP__c;
			system.debug('check total award for each qi --qi.Total_Award__c= ' + qi.Total_Award__c + ' qi.Total_Toro_Award__c='+qi.Total_Toro_Award__c);
			system.debug('check total award for each qi --quoteTotalAward= ' + quoteTotalAward + ' quoteTotalToroAward='+quoteTotalToroAward);
		}
		quote.Ext_MSRP__c                      = quoteMSRP;
		quote.Toro_Rollup_Award_Price__c       = quoteTotalToroAward;
		quote.Toro_Rollup_DNET__c              = quoteTotalDNet;
		quote.Toro_Rollup_Setup_Fees__c        = quoteTotalSetupFee;
		quote.Toro_Total_DNet__c               = quoteToroTotalDNet;
		quote.Toro_Total_Quote_Gross_Profit__c = quoteTotalGP;
		quote.Toro_Total_Quote_Rebate__c       = quoteTotalRebate;
		quote.Toro_Total_Rebate__c             = quoteTotalRebate;
		quote.Toro_Rollup_DNetWOTPPAllied__c   = quoteTotalDnetWOTppAllied;
		quote.Toro_Award__c = quoteTotalToroAward;
        quote.Total_Award__c = quoteTotalAward;
		if(quote.Toro_Rollup_DNET__c != null && quote.Toro_Rollup_DNET__c != 0) {
			quote.Toro_Blended_Percent_of_DN__c            = CMnQuoteUtil.defaultDecimal(quote.Toro_Rollup_Award_Price__c) / quote.Toro_Rollup_DNET__c*100;
		}

		quote.Toro_Blended_Percent_of_DN__c=CMnQuoteUtil.defaultDecimal(quote.Toro_Blended_Percent_of_DN__c).setScale(2);
		if(quote.Toro_Rollup_Award_Price__c != null && quote.Toro_Rollup_Award_Price__c != 0) {
			quote.Toro_Total_Quote_Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Quote_Gross_Profit__c) / quote.Toro_Rollup_Award_Price__c *100;
		}

		System.debug('\n\n@@quote: ' + quote + '\n\n');
		return quoteItemList;
	}
	*/
}