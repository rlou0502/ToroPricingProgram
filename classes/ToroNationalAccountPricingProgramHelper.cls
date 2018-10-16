public class ToroNationalAccountPricingProgramHelper extends ToroPricingProgram {
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

	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgramExternalId,
		 				String priceMethod, List<Revvy__MnStrategy4__c> quoteItemWrapperList) {
		system.debug(logginglevel.info, '+++++++++++++++++ NAT = ' + quoteItemWrapperList);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceProgramExternalId);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT priceProgramExternalId = ' + priceMethod);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT performancePartFlag = ' + performancePartFlag);
		system.debug(logginglevel.info, '+++++++++++++++++ NAT setupFeePercentage = ' + setupFeePercentage);

		quote.Performance_Part__c=performancePartFlag;
		Map<String,Revvy__MnStrategy2__c> tierMap = retrieveNationalAccount( priceProgramExternalId);
		Map<String,String> tractionUnitMap = retrieveTractionUnit();
		system.debug(logginglevel.info, 'tierMap=' + tierMap);

		//get Pricing Program Header
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgramExternalId);	

		//decimal dSetupFeeHeader = ToroCacheManager.getSetupFee();
		decimal dSetupFeeHeader = setupFeePercentage;
		System.debug(logginglevel.info, '>>> Setup fee from cache=' + dSetupFeeHeader);

		//Exception
		
		Map<String,Revvy__MnStrategy2__c> ppMapExceptionMap = retrieveNationalAccountException(priceProgramExternalId);
		System.debug('\n\n@@ppMapExceptionMap: ' + ppMapExceptionMap + '\n\n');
		
		List<Revvy__MnStrategy4__c> updatedQuoteItems = new List<Revvy__MnStrategy4__c>();
		for(Revvy__MnStrategy4__c qi : quoteItemWrapperList) {
			if(qi.Exclude_from_Rebate_F__c && qi.Pricing_Program_Product_Type__c != 'Standard' &&  qi.Pricing_Program_Product_Type__c != 'TPP') {
                qi.Rebate_as_a_of_DN__c=0;
                qi.Fee_Percentage__c = 0;
                qi.Part_Percentage__c=0;	
                continue;
            }
            resetQIPercentage(qi);
			Decimal dsetupFeesQIS = 0;
			//Performance Part
			boolean bqiPP = ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(performancePartFlag, qi, performancePartMap, priceMethod);
			System.debug(logginglevel.info,'>>> NAT qi.REVVY__Product_ID_F__c ='+qi.Product_Id__c + ' performancePartFlag='+performancePartFlag + ' Tier=' + qi.Toro_Product_Tier__c);
			System.debug('>>> +++++++++++++++++ NAT 115 =');
			if(!bqiPP) {
				if(String.isEmpty(qi.Toro_Product_Tier__c) && !String.isEmpty(qi.Traction_Unit__c) && tractionUnitMap.containsKey(qi.Traction_Unit__c)) {
					String stier = tractionUnitMap.get(qi.Traction_Unit__c);
					System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 116 =  tierMap='+tierMap);
					System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 116 =  stier='+stier);
					Revvy__MnStrategy2__c rb = tierMap.get(stier);
					System.debug('>>> +++++++++++++++++ NAT 116 AAA =  rb='+rb);
					applyQIPercentage(qi,rb,dSetupFeeHeader);

				} else if(tierMap.containsKey(qi.Toro_Product_Tier__c)) {
					Revvy__MnStrategy2__c rb = tierMap.get(qi.Toro_Product_Tier__c);
					System.debug('>>> +++++++++++++++++ NAT 116 BBB =  rb='+rb);
					System.debug('>>> +++++++++++++++++ NAT 116 BBB =  rb='+rb + 'product=' + qi.product_Name__c + '--' + qi.product_Id__c);
					applyQIPercentage(qi,rb,dSetupFeeHeader);
					System.debug('>>> +++++++++++++++++ NAT 116 BBB =  rb='+rb + 'product=' + qi.product_Name__c + '--' + qi.Off_MSRP__c);
				}

				System.debug(logginglevel.info,'>>> NAT qi.Toro_Product_Type__c ='+qi.Product__r.Toro_Product_Type__c);
				//Parts
				if ('Semi-Finished Good'.equalsIgnoreCase(qi.Product__r.Toro_Product_Type__c)) {
					Revvy__MnStrategy2__c rb = tierMap.get('Parts');
					applyQIPercentage(qi,rb,dSetupFeeHeader);

				}

				//Run Exception
				if(ppMapExceptionMap.size() > 0 && ppMapExceptionMap.containsKey(qi.Product_Id__c)) {
					Revvy__MnStrategy2__c rb = ppMapExceptionMap.get(qi.Product_Id__c);
					System.debug('>>> +++++++++++++++++ NAT 118 =  rb='+rb);
					applyQIPercentage(qi,rb,dSetupFeeHeader);
				}

				if(excludedFromMSRP(qi)) {
					qi.Off_MSRP__c = 0;
				}
			}

			System.debug('>>> +++++++++++++++++ NAT 112 = qi  % off percent_off_msrp__c='+qi.Off_MSRP__c);
			if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					resetQISLPercentage(qis);
					
					//Performance Part
					ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap, priceMethod);
					System.debug('>>> +++++++++++++++++ NAT 000');
					if(!bqiPP) {

						if(tierMap.containsKey(qis.Toro_Product_Tier__c)) {
							Revvy__MnStrategy2__c rb = tierMap.get(qis.Toro_Product_Tier__c);
							System.debug('>>> +++++++++++++++++ NAT 111 =  rb='+rb);
							System.debug('>>> +++++++++++++++++ NAT 111 =  product ='+qis.product_Id__c + ' overridden =' + qis.Unit_Award_Overridden__c + ' award price=' + qis.award_price__c );
							applyQISLPercentage(qis,rb,dSetupFeeHeader);
							System.debug('>>> +++++++++++++++++ NAT 111 =  product ='+qis.product_Id__c + ' overridden =' + qis.Unit_Award_Overridden__c + ' award price=' + qis.award_price__c );
						} else {
							qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
							if(excludedFromMSRP(qis)) {
								System.debug('>>> +++++++++++++++++ NAT 222 =  product ='+qis.product_Id__c);
								qis.Percent_Off_MSRP__c = 0;
							} else{
								System.debug('>>> +++++++++++++++++ NAT 333 =  product ='+qis.product_Id__c);
								qis.percent_off_msrp__c =  qi.Off_MSRP__c;
							}
							qis.Part_Percentage__c = qi.Part_Percentage__c;
							qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * (1 - CMnQuoteUtil.defaultDecimal(qis.percent_off_msrp__c)/100);
							qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
						}

						//Parts
						if ('Semi-Finished Good'.equalsIgnoreCase(qis.Product__r.Toro_Product_Type__c)) {
							Revvy__MnStrategy2__c rb = tierMap.get('Parts');
							applyQISLPercentage(qis,rb,dSetupFeeHeader);

						}

						System.debug('>>> +++++++++++++++++ NAT 444 =  product ='+qis.product_Id__c + '---' + qis.percent_off_msrp__c);
						//Run Exception
						if(ppMapExceptionMap.size() > 0 && ppMapExceptionMap.containsKey(qis.Product_Id__c)) {
							Revvy__MnStrategy2__c rb = ppMapExceptionMap.get(qis.Product_Id__c);
							System.debug('\n\n@@qis: ' + qis + '\n\n');
							System.debug('>>> +++++++++++++++++ NAT 113 =  rb='+rb);

							if (qis.Product_Id__c.startsWithIgnoreCase('TPP')) {
								Set<String> applicableProductSet = new Set<String>();
								applicableProductSet.addAll(rb.ApplicableProducts__c.split(','));
								if (applicableProductSet.contains(qis.Product_Id__c)) {
									applyQISLPercentageTPP(qis,rb,dSetupFeeHeader);
								}

								else {
									applyQISLPercentage(qis,rb,dSetupFeeHeader);
								}
							}

							else {
								applyQISLPercentage(qis,rb,dSetupFeeHeader);
							}

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
			}

			//calculate total setup fees
			//
			//dtoroTotalSetupFees += (CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * qi.Quantity__c * (CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100)) +  dsetupFeesQIS;
			//System.debug('>>> +++++++++++++++++ NAT 120 qi.Award_Price__c=' + qi.Award_Price__c + ' Quantity__c='+qi.Quantity__c + ' Fee_Percentage__c='+qi.Fee_Percentage__c);
			//System.debug('>>> +++++++++++++++++ NAT 120 qi.Product_Id__c=' + qi.Product_Id__c + ' dtoroTotalSetupFees='+dtoroTotalSetupFees + ' dsetupFeesQIS='+dsetupFeesQIS);

		}

		System.debug(logginglevel.info, '>>> +++++++++++++++++ NAT 200=');

		//delete [Select Id From Revvy__MnStrategy4__c where Id in :deleteSetupFeeLineItemId];
		//delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];

		return quoteItemWrapperList;
	}

	
	public override List<Revvy__MnStrategy4__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
			System.debug('--- NationalAccount preSaveCalculateRebateMargin priceProgram='+ priceProgram);													
			List<Revvy__MnStrategy4__c> result = quoteItemList;													
			Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(priceProgram);
			System.debug('--- NationalAccount preSaveCalculateRebateMargin quote.Total_Award__c='+ quote.Total_Award__c);
			System.debug('--- NationalAccount preSaveCalculateRebateMargin pp_header.Setup_Threshold__c='+ pp_header.Setup_Threshold__c);
			if(pp_header.Setup_Threshold__c != null) {
				if(CMnQuoteUtil.defaultDecimal(quote.Toro_Award__c) > CMnQuoteUtil.defaultDecimal(pp_header.Setup_Threshold__c)) {
	
					for(Revvy__MnStrategy4__c qi : quoteItemList) {
						qi.Fee_Percentage__c = 0;
	
						if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
							for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
								qis.Fee_Percentage__c = 0;
							}
						}
					}
					result = calculateExtendedFields(quoteItemList);
					setupFeePercentage = 0;
					quote.Setup_Fee__c = 0;	
					ToroCacheManager.putQuote(quote);
				}	
			}
															
																
		return result;
	}


	public static Map<String,Revvy__MnStrategy2__c> retrieveNationalAccount(String pricingProgramExternalId) {
		Map<String,Revvy__MnStrategy2__c> ppMap = new Map<String,Revvy__MnStrategy2__c>();
		for(Revvy__MnStrategy2__c rl:[Select Id, ApplicableProducts__c, Pricing_1__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c, Tier__c
		                             ,Fee_Percentage__c , Part_Percentage__c, Award_Price_as_a_Percent_of_DN__c
		                          From Revvy__MnStrategy2__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		                                  ]) {
			if(!'Exception'.equalsIgnoreCase(rl.Tier__c)) {
				ppMap.put(rl.Tier__c, rl);
			}
		}
		return ppMap;
	}

	public static Map<String,Revvy__MnStrategy2__c> retrieveNationalAccountException(String pricingProgramExternalId) {
		Map<String,Revvy__MnStrategy2__c> ppMap = new Map<String,Revvy__MnStrategy2__c>();
		for(Revvy__MnStrategy2__c rl:[Select Id, ApplicableProducts__c, Pricing_1__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c, Tier__c
		                             ,Fee_Percentage__c , Part_Percentage__c, Award_Price_as_a_Percent_of_DN__c
		                          From Revvy__MnStrategy2__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId
		                                  ]) {

			if('Exception'.equalsIgnoreCase(rl.Tier__c)) {
				if(!String.isEmpty(rl.ApplicableProducts__c)) {
					for(String s:rl.ApplicableProducts__c.split(',')) {
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
		for(Toro_Traction_Unit_Tier__mdt tu:[Select MasterLabel,DeveloperName,Tier__c From Toro_Traction_Unit_Tier__mdt limit 5000]) {
			System.debug('>>> mdt masterLabel='+tu.Masterlabel + ' DeveloperName=' + tu.DeveloperName + ' Tier=' + tu.Tier__c);
			tractionUnitMap.put(tu.MasterLabel,tu.Tier__c);
		}
		return tractionUnitMap;

	}


	public void resetQIPercentage(Revvy__MnStrategy4__c qi) {

		qi.Off_MSRP__c = 0;
		qi.Award_of_DN__c =0;
		qi.Rebate_as_a_of_DN__c = 0;
		qi.Fee_Percentage__c = 0;
		qi.Part_Percentage__c = 0;
		qi.Award_Price__c = 0;
		qi.PricingMethodValue__c = '';

	}

	public void applyQIPercentage(Revvy__MnStrategy4__c qi, Revvy__MnStrategy2__c rb, decimal dsetupFeeHeader) {

		qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);
		qi.Award_of_DN__c =rb.Award_Price_as_a_Percent_of_DN__c;
		qi.Rebate_as_a_of_DN__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);
		qi.Fee_Percentage__c = getSetupFeePercentage(dsetupFeeHeader, CMnQuoteUtil.defaultDecimal(rb.Fee_Percentage__c));
		qi.Part_Percentage__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		if(rb.Part_Percentage__c !=null && rb.Part_Percentage__c >0) {
			qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(rb.Part_Percentage__c);
		}
		qi.Award_Price__c = qi.MSRP_Price__c * (1-qi.Off_MSRP__c/100);
		qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);

	}

	public void resetQISLPercentage(Revvy__MnStrategy5__c qis) {

		qis.Rebate_as_of_DNet__c = 0;
		qis.Percent_Off_MSRP__c = 0;
		qis.Part_Percentage__c = 0;
		qis.Fee_Percentage__c = 0;
		qis.Award_Price__c = 0;
		qis.PricingMethodValue__c = '';
		qis.Percent_of_DNet__c=0;

	}

	public void applyQISLPercentage(Revvy__MnStrategy5__c qis, Revvy__MnStrategy2__c rb, decimal dsetupFeeHeader) {

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
		if(!qis.Unit_Award_Overridden__c) {
			qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c)/100);
		}
		qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
		qis.Percent_of_DNet__c=rb.Award_Price_as_a_Percent_of_DN__c;

	}

	public void applyQISLPercentageTPP(Revvy__MnStrategy5__c qis, Revvy__MnStrategy2__c rb, decimal dsetupFeeHeader) {

		qis.Rebate_as_of_DNet__c = CMnQuoteUtil.defaultDecimal(rb.Rebate_as_a_Percent_of_DN__c);

		qis.percent_off_msrp__c =  CMnQuoteUtil.defaultDecimal(rb.Off_Mfg_Sugg_Ttl__c);

		if(!qis.Unit_Award_Overridden__c) {
			qis.Award_Price__c = qis.MSRP_Price__c * (1 - (qis.percent_off_msrp__c)/100);
		}
		qis.PricingMethodValue__c = String.valueOf(qis.percent_off_msrp__c);
		qis.Percent_of_DNet__c=rb.Award_Price_as_a_Percent_of_DN__c;

	}

	public static decimal getSetupFeePercentage(decimal dfeePercentageHeader, decimal rbFeePercentage) {
		decimal result = rbFeePercentage;
		if(dfeePercentageHeader !=null && dfeePercentageHeader > 0) {
			result = dfeePercentageHeader;
		}
		return result;
	}




}