public class ToroLargePackagePricingProgramHelper extends ToroPricingProgram {

	public override List<Schema.FieldSetMember> getQuoteFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}

	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		List<Schema.FieldSetMember> fsl = SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
		return fsl;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Summary_Cols.getFields();
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

	public override List<ToroSelectOption> retrieveDemoPricingProgramOptions() {
		List<ToroSelectOption> sels = new List<ToroSelectOption>();
		for(Toro_PricingProgram__c pp : [SELECT Name, PricingProgramStyle__c, ExternalId__c FROM Toro_PricingProgram__c
									where PricingProgramStyle__c = 'Demo' AND Exclude__c = false order by externalID__c asc]){
			sels.add(new ToroSelectOption(pp.ExternalId__c+ ';' + pp.PricingProgramStyle__c, pp.name));
		}
		return sels;
	}
	public override boolean displayPerformancePart() {
		return true;
	}

	public override List<Toro_QuoteItem__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){

		if(this.performancePartFlag) {
			//Performance Part
			for(Toro_QuoteItem__c qi : quoteItemList) {
				system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part Toro_QuoteItem__c 222 performancePartFlag='+performancePartFlag  );
				ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(performancePartFlag, qi, performancePartMap);
					if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
						for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							//Performance Part
							system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 333');
							system.debug('-------------++++++++qis' + qis);
							ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap);
						}
					}
			}
		}

		return 	quoteItemList;
	}



	public decimal lookupRebateAsPercentOfDNet(decimal percentOfDNet, List<Toro_PricingProgramLine__c> dNetLineList ) {
		decimal result = 0;
		decimal x3 = percentOfDNet;

		system.debug('lookupRebateAsPercentOfDNet---x3='+ x3);
		for(integer i =dNetLineList.size()-1; i > 0  ; i--) {
			Toro_PricingProgramLine__c l = dNetLineList[i];
			//system.debug('lookupRebateAsPercentOfDNet---high='+ dNetLineList[i].Award_Price_as_a_Percent_of_DN__c + ' low=' +
			//	dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c);
			system.debug('lookupRebateAsPercentOfDNet---x3='+ x3 + ' i ' + dNetLineList[i].Award_Price_as_a_Percent_of_DN__c + ' i-1 ' +  dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c);
			if(x3 >= dNetLineList[i].Award_Price_as_a_Percent_of_DN__c && x3 <= dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c){
				decimal x1=(dNetLineList[i].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal x2=(dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal y1=(dNetLineList[i].Rebate_as_a_Percent_of_DN__c)/100;
				decimal y2=(dNetLineList[i-1].Rebate_as_a_Percent_of_DN__c)/100;
				x3 = x3/100;
				system.debug('x1=' + x1 + ' x2=' + x2 + ' y1 =' + y1 + ' y2 = ' + y2 + 'x3='+ x3);
				result = y2 -(((x3-x2)*(y2-y1)));
				system.debug(' result =' + result);
				break;
			}
		}
		return result*100;
	}
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		ToroPricingMethodHelper helper = new ToroPricingMethodHelper();
		helper.pricingProgramExternalId = priceProgram;
		helper.quoteItemList = quoteItemList;
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {

			helper.convertAwardPriceToDNetPercent().calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
			quoteItemList = helper.quoteItemList;
			for (Toro_QuoteItem__c qi : quoteItemList) {
				qi.Off_MSRP__c = ((qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c)*100;
				if(qi.Award_of_DN__c != null) {
					if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							decimal dnet = (qis.TPP_Line_Item__c == true) ? CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) : CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
							qis.Percent_Off_MSRP__c = ((qis.MSRP_Price__c-qis.Award_Price__c)/qis.MSRP_Price__c)*100;
						}
					}
				}
			}

		} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
			helper.convertGPPercentToDNetPercent().calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
		} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
			helper.calculateBlendedDNetPercentFromMSRP().calculateExtensionFields();
		} else if('% of DNET'.equalsIgnoreCase(priceMethod)) {
			helper.calculateBlendedDNetPercentFromDNet().calculateExtensionFields();
		}
		quoteItemList = helper.quoteItemList;
		return quoteItemList;
		system.debug(logginglevel.info, 'priceProgram =' + priceProgram + ' priceMethod=' + priceMethod);
		List<Toro_PricingProgram__c> rebates = new List<Toro_PricingProgram__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		map<string, Toro_PricingProgram__c> rebateMap = new map<string, Toro_PricingProgram__c>();
		map<string, set<String>> rebateApplicableProducts = new map<string, set<String>>();
		map<decimal, Toro_PricingProgramLine__c> dnetLineMap = new map<decimal, Toro_PricingProgramLine__c>();
		decimal msrpMin = 999;
		decimal msrpMax = 0;
		decimal dnetMin = 999;
		decimal dnetMax = 0;
		system.debug(logginglevel.info,'header size = ' + rebates.size());
		system.debug(logginglevel.info,'rebates = ' + rebates);
		for(Toro_PricingProgram__c rh : rebates) {
			rebateMap.put(rh.ExternalId__c, rh);
			if(!rebateApplicableProducts.containsKey(rh.ExternalId__c)) {
				rebateApplicableProducts.put(rh.ExternalId__c, new set<String>());
			}
			if(string.isNotBlank(rh.ApplicableProducts__c)) {
				String[] parts = rh.ApplicableProducts__c.split(',');
				rebateApplicableProducts.get(rh.ExternalId__c).addAll(parts);
			}
			for(Toro_PricingProgramLine__c l : rh.PricingProgramLines__r) {
				dnetLineMap.put(l.Award_Price_as_a_Percent_of_DN__c, l);
				msrpMin = Math.min(msrpMin, l.Off_Mfg_Sugg_Ttl__c);
				msrpMax = Math.max(msrpMax, l.Off_Mfg_Sugg_Ttl__c);
				dnetMin = Math.min(dnetMin, l.Award_Price_as_a_Percent_of_DN__c);
				dnetMax = Math.max(dnetMax, l.Award_Price_as_a_Percent_of_DN__c);
			}
		}
		system.debug(logginglevel.info,'checkpoint 2 =' + rebateMap);
		List<Toro_PricingProgramLine__c> dNetLineList = new List<Toro_PricingProgramLine__c>();
		for(decimal key : dnetLineMap.keyset()){
			dNetLineList.add(dnetLineMap.get(key));
		}
		system.debug(logginglevel.info,'checkpoint 3 list size =' + dNetLineList);
		for(Toro_QuoteItem__c qi : quoteItemList) {
			Toro_PricingProgram__c rh = rebateMap.get(priceProgram);
			qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			//Performance Part
			ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(quote.Performance_Part__c, qi, performancePartMap);

			system.debug(logginglevel.info,'checkpoint 4 qi.Award_of_DN__c =' + qi.Award_of_DN__c + ' sku =' + qi.Product_Name__c);
			if(rh != null) {
				if(qi.Product_Id__c.startsWith('TPP') || qi.Product_Id__c.startsWith('L')) {
					qi.Award_Price__c = qi.MSRP_Price__c;
				}
				if(!qi.Product_Id__c.startsWith('TPP') && !qi.Product_Id__c.startsWith('L')) {
					system.debug(logginglevel.info,'rebateApplicableProducts.get(priceProgram)=' + rebateApplicableProducts.get(priceProgram));
					if(rebateApplicableProducts.get(priceProgram).contains('All') ||
						rebateApplicableProducts.get(priceProgram).contains(qi.Product_Id__c)) {
						system.debug(logginglevel.info,'inside rebate-------------------qi.Off_MSRP__c =' + qi.Off_MSRP__c);
						system.debug(logginglevel.info,'inside rebate-------------------priceMethod =' + priceMethod);
						decimal rebateValue = 0.0;
						decimal basePrice = qi.MSRP_Price__c;
						decimal grossProfit = 0.0;
						//qi.Distributor_Net__c = qi.MSRP_Price__c;
						if('% of DNET'.equalsIgnoreCase(priceMethod) && !qi.Performance_Parts_Product__c) {
							if(qi.Unit_Award_Overridden__c) {
								qi.Award_of_DN__c = qi.Award_Price__c * 100/qi.DNet_Price__c;
							}
							if(qi.Award_of_DN__c == null) {
								system.debug(logginglevel.info,'continue---');
								continue;
								//qi.Award_of_DN__c = dnetMin;
							}
							if(qi.Award_of_DN__c != null) {
								qi.Award_of_DN__c = Math.min(qi.Award_of_DN__c, dnetMax);
								qi.Award_of_DN__c = Math.max(qi.Award_of_DN__c, dnetMin);
							}

							if(qi.Award_of_DN__c != null) {
								qi.Award_of_DN__c = Math.min(qi.Award_of_DN__c, dnetMax);
								qi.Award_of_DN__c = Math.max(qi.Award_of_DN__c, dnetMin);
							}

							qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
							system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c + ' dnet='+ qi.DNet_Price__c + ' % of DN=' + qi.Award_of_DN__c);
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
							}
							if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
								qi.Off_MSRP__c = (qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c;
							}
							decimal rebateDollar = qi.DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;
							qi.Toro_Gross_Profit_Value__c = qi.Award_Price__c - qi.DNet_Price__c + rebateDollar;
							if(qi.Award_Price__c != null && qi.Award_Price__c != 0) {
								qi.Toro_Gross_Profit_Percent__c = (1-(qi.DNet_Price__c-rebateDollar)/qi.Award_Price__c)*100;
							}
							qi.PricingMethodValue__c = string.valueOf(qi.Award_of_DN__c);
						} else if('% off MSRP'.equalsIgnoreCase(priceMethod) && !qi.Performance_Parts_Product__c)  {
							if(qi.Unit_Award_Overridden__c) {
								qi.Off_MSRP__c = 100 - (qi.Award_Price__c/qi.MSRP_Price__c)*100.0;
							}
							if(qi.Off_MSRP__c == null) {
								continue;
								//qi.Off_MSRP__c = msrpMin;
							}
							if(qi.Off_MSRP__c != null) {
								qi.Off_MSRP__c = Math.min(qi.Off_MSRP__c, msrpMax);
								qi.Off_MSRP__c = Math.max(qi.Off_MSRP__c, msrpMin);
							}

							if(excludedFromMSRP(qi)) {
								qi.Off_MSRP__c = 0;
							}
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.MSRP_Price__c * (1-(qi.Off_MSRP__c/100));
								system.debug('2222222222 Award_Price__c=' + qi.Award_Price__c );
							}
							system.debug('lookupRebateAsPercentOfDNet--- qi.Award_Price__c' + qi.Award_Price__c + ' qi.DNet_Price__c= ' + qi.DNet_Price__c);
							if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0 ) {
								qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c * 100;
								system.debug('lookupRebateAsPercentOfDNet--- qi.DNet_Price__c' + qi.DNet_Price__c);
								system.debug('lookupRebateAsPercentOfDNet--- qi.Award_of_DN__c' + qi.Award_of_DN__c);
								qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
								system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
								decimal rebateDollar = qi.DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;
								qi.Toro_Gross_Profit_Value__c = qi.Award_Price__c - qi.DNet_Price__c + rebateDollar;
								qi.Toro_Gross_Profit_Percent__c = (1-(qi.DNet_Price__c-rebateDollar)/qi.Award_Price__c)*100;
								qi.PricingMethodValue__c = string.valueOf(qi.Off_MSRP__c);
							} else {
								system.debug('lookupRebateAsPercentOfDNet--- qi.product id' + qi.Product_Id__c);
							}
						}
					}
				}

				if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
					for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {

						//Performance Part
						system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 333');
						system.debug('-------------++++++++qis' + qis);
						ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(performancePartFlag, qis, performancePartMap);

						system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 444');
						if(excludedFromMSRP(qis)) {
							qis.Award_Price__c = qis.MSRP_Price__c;
						}
						if(!excludedFromMSRP(qis)) {
							if(rebateApplicableProducts.get(priceProgram).contains('All') ||
								rebateApplicableProducts.get(priceProgram).contains(qis.Product_Id__c)) {
								system.debug('inside rebate-------------------' );
								decimal rebateValue = 0.0;
								decimal basePrice = qis.MSRP_Price__c;
								decimal grossProfit = 0.0;
								//qis.Distributor_Net__c = qis.MSRP_Price__c;
								System.debug('>>> inside rebate MSRP --- qis.Performance_Part__c='+qis.Performance_Part__c);
								if('% of DNET'.equalsIgnoreCase(priceMethod) && !qis.Performance_Part__c) {
									if(qis.Unit_Award_Overridden__c) {
										qis.Percent_of_DNet__c = qis.Award_Price__c * 100/qis.DNet_Price__c;
									}
									if(qis.Percent_of_DNet__c == null) {
										qis.Percent_of_DNet__c = dnetMin;
									}
									qis.Percent_of_DNet__c = Math.min(qis.Percent_of_DNet__c, dnetMax);
									qis.Percent_of_DNet__c = Math.max(qis.Percent_of_DNet__c, dnetMin);

									if(!excludedFromMSRP(qis)) {
										qis.Rebate_as_of_DNet__c=lookupRebateAsPercentOfDNet(qis.Percent_of_DNet__c,dNetLineList);
										system.debug(logginglevel.info,'inside rebate-------------------qis.Rebate_as_a_of_DN__c =' + qis.Rebate_as_of_DNet__c);
									}
									if(!qis.Unit_Award_Overridden__c) {
										qis.Award_Price__c = qis.DNet_Price__c * qis.Percent_of_DNet__c/100;
										system.debug('2222222 qis Award_Price__c=' + qis.Award_Price__c );
									}
									qis.Percent_Off_MSRP__c = ((qis.MSRP_Price__c-qis.Award_Price__c)/qis.MSRP_Price__c)*100;
									decimal rebateDollar = qis.DNet_Price__c * qis.Rebate_as_of_DNet__c/100;
									qis.Gross_Profit_Value__c = qis.Award_Price__c - qis.DNet_Price__c + rebateDollar;
									qis.Gross_Profit_Percent__c = (qis.Gross_Profit_Value__c/qis.Award_Price__c)*100;
									qis.PricingMethodValue__c = string.valueOf(qis.Percent_of_DNet__c);
								} else if('% off MSRP'.equalsIgnoreCase(priceMethod) && !qis.Performance_Part__c)  {
									system.debug('qis Unit_Award_Overridden__c=' + qis.Unit_Award_Overridden__c );
									if(qis.Unit_Award_Overridden__c) {
										qis.Percent_Off_MSRP__c = 100 - (qis.Award_Price__c/qis.MSRP_Price__c)*100.0;
									}
									if(qis.Percent_Off_MSRP__c == null) {
										qis.Percent_Off_MSRP__c = msrpMin;
									}

									system.debug('1-----qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
									qis.Percent_Off_MSRP__c = Math.min(qis.Percent_Off_MSRP__c, msrpMax);
									qis.Percent_Off_MSRP__c = Math.max(qis.Percent_Off_MSRP__c, msrpMin);
									system.debug('2------qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);

									if(excludedFromMSRP(qis)) {
										qis.Percent_Off_MSRP__c = 0;
									}
									if(!qis.Unit_Award_Overridden__c) {
										qis.Award_Price__c = qis.MSRP_Price__c * (1-(qis.Percent_Off_MSRP__c/100));
									}
									if(qis.DNet_Price__c != 0){
										qis.Percent_of_DNet__c = qis.Award_Price__c/qis.DNet_Price__c*100;
									} else {
										system.debug('DNet price is zero ---' + qis.Product_Name__c + '---' + qis.Product_Id__c);
									}
									//qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
									if(!excludedFromMSRP(qis)) {
										qis.Rebate_as_of_DNet__c = lookupRebateAsPercentOfDNet(qis.Percent_of_DNet__c,dNetLineList);
									}
									decimal rebateDollar = qis.DNet_Price__c * qis.Rebate_as_of_DNet__c/100;
									qis.Gross_Profit_Value__c = qis.Award_Price__c - qis.DNet_Price__c + rebateDollar;
									qis.Gross_Profit_Percent__c = (qis.Gross_Profit_Value__c/qis.Award_Price__c) * 100;
									qis.PricingMethodValue__c = string.valueOf(qis.Percent_Off_MSRP__c);
								}
							}

						}
						if(!qis.Exclude_from_Rebate__c) {
							//qis.Extended_Rebate__c = qis.Rebate_as_of_DNet__c * qis.DNet_Price__c* qis.quantity__c*qi.quantity__c;
						}
						//updatedQuoteItemSublines.add(qis);
						if(qis.Award_price__c != null && qis.Award_price__c != 0) {
							//should TPP & L be excluded here?
							qis.Gross_Profit_Percent__c = ((qis.Award_price__c - qis.DNet_Price__c + (qis.DNet_Price__c * CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100))/qis.Award_price__c)*100;
						}
					}
				}

				//system.debug('--++--++--++='  + qis.percent_off_msrp__c + ' off DN=' + qis.percent_of_dnet__c);
			}
		}

		Long perfStart = System.limits.getCpuTime();
		//update updatedQuoteItems;
		//update updatedQuoteItemSublines;
       // update quote; // ??? why update quote here ??
       /*
		system.debug('perf------updateQuote quote items------------ = ' + (System.limits.getCpuTime() - perfStart));

        Revvy__MnQuote__c tmpQ = [select Rollup_DNetWOTPPAllied__c from Revvy__MnQuote__c where id = :quoteId];
        List<Support_Plus_Plan__c> plans = [select Total_DNet_Low__c, Total_DNet_High__c, Maximum_Support__c from Support_Plus_Plan__c order by Total_DNet_Low__c];
        for(Support_Plus_Plan__c sp : plans) {
        	if((tmpQ.Rollup_DNetWOTPPAllied__c >= sp.Total_DNet_Low__c) && (tmpQ.Rollup_DNetWOTPPAllied__c < sp.Total_DNet_High__c)) {
        		tmpQ.Toro_Support_Plus_Allowance__c = sp.Maximum_Support__c;
        		break;
        	}
        }
        //update quote;
        update tmpQ;

		//delete setup fees
		//delete [Select Id From REVVY__MnQuoteItem__c where REVVY__Product_ID_F__c = 'S00001' and REVVY__Quote__c = :quoteId];
       */
       system.debug(quoteItemList);
		return quoteItemList;
	}



	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public override List<Toro_QuoteItem__c> postCalculateRebateMargin(Id quoteId
																		, String priceProgram
																		, String priceMethod
																		, List<Toro_QuoteItem__c> quoteItemList
	) {
		Toro_PricingProgram__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgram);

		Revvy__MnQuote__c quote = [SELECT
										Toro_ApprovalReason__c
										, REVVY__NeedsApproval__c
										, Total_Extended_DNet__c
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
	public Integer getNumberOfTractionUnits(List<Toro_QuoteItem__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Toro_QuoteItem__c quoteItem : quoteItemList) {
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
	public Boolean checkForOutCrossProducts(List<Toro_QuoteItem__c> quoteItemList) {
		System.debug('\n\n@@checkForOutCrossProducts quoteItemList: ' + quoteItemList + '\n\n');
		for (Toro_QuoteItem__c quoteItem : quoteItemList) {
			if (quoteItem.Product_Name__c.startsWithIgnorecase('OUTCROSS')) {
				System.debug('\n\n@@contains outcross\n\n');
				return true;
			}
		}

		return false;
	}
}