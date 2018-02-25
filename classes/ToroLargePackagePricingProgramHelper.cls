public class ToroLargePackagePricingProgramHelper extends ToroPricingProgram {
	public override List<Schema.FieldSetMember> getQuoteItemSublineFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteItemSublineFields');
		return SObjectType.Revvy__MnQuoteItemSubline__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteItemFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteItemFields');
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Large_Package_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteItemUpdatableFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteItemSublineUpdatableFields() {
		return SObjectType.Revvy__MnQuoteItemSubline__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
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
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}

	public override boolean isEligible(Toro_PricingProgram__c pp, Revvy__MnQuote__c quote, List<Revvy__MnQuoteItem__c> qiList) {
		//pp.Minimum_Threshold__c
		//quote.Rollup_DNetWOTPPAllied__c
		boolean ret = true;
		if(quote != null && quote.revvy__account__r != null){
			String qtAccountStateCode = quote.revvy__account__r.billingstatecode;
			ret = qtAccountStateCode.EqualsIgnoreCase(pp.stateprovince__c) ;
			ret = ret && (quote.Rollup_DNetWOTPPAllied__c > pp.MinimumThreshold__c);
		}
		return ret;

		//return true;
	}

	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}

	public override List<ToroSelectOption> retrievePricingProgramOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();

		List<Toro_PricingProgram__c> pricingPrograms = [select name, PricingProgramType__c, MinimumThreshold__c,
					stateprovince__c from Toro_PricingProgram__c order by name asc ];
		for(Toro_PricingProgram__c pp : pricingPrograms) {
        	//if(isEligible(pp, quote, quoteItems)) {
	        	ret.add(new ToroSelectOption(pp.name, pp.name));
	        //}
        }
		return ret;
	}

	public override boolean displayPerformancePart() {
		return true;
	}


	public decimal lookupRebateAsPercentOfDNet(decimal percentOfDNet, List<Toro_PricingProgramLine__c> dNetLineList ) {
		decimal result = 0;
		decimal x3 = percentOfDNet;

		//system.debug('lookupRebateAsPercentOfDNet---x3='+ x3);
		for(integer i =dNetLineList.size()-1; i > 0  ; i--) {
			Toro_PricingProgramLine__c l = dNetLineList[i];
			//system.debug('lookupRebateAsPercentOfDNet---high='+ dNetLineList[i].Award_Price_as_a_Percent_of_DN__c + ' low=' +
			//	dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c);
			if(x3 < dNetLineList[i].Award_Price_as_a_Percent_of_DN__c && x3 > dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c){
				decimal x1=(dNetLineList[i].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal x2=(dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal y1=(dNetLineList[i].Rebate_as_a_Percent_of_DN__c)/100;
				decimal y2=(dNetLineList[i-1].Rebate_as_a_Percent_of_DN__c)/100;
				x3 = x3/100;
				result = y2 -(((x3-x2)*(y2-y1)));
				break;
			}
		}
		return result;
	}
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		//todo
		//Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		system.debug(logginglevel.info, 'checkpoint 1 pp='+ priceProgram + ' pm=' + priceMethod);
		if('Total Award $'.equalsIgnoreCase(priceMethod)) {
			return ToroPricingMethodUtil.applyTotalAwordDollors(priceProgram, quoteItemList, null);	
		} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
			return ToroPricingMethodUtil.applyGPPercent(priceProgram, quoteItemList, null);	
		}
		system.debug(logginglevel.info, 'priceProgram =' + priceProgram + ' priceMethod=' + priceMethod);
		List<Toro_PricingProgram__c> rebates = [Select r.Name, r.ExternalId__c, r.ApplicableProducts__c,
				(Select Off_Mfg_Sugg_Ttl__c, Award_Price_as_a_Percent_of_DN__c, Rebate_as_a_Percent_of_DN__c,
				Distributor_Margin__c, ApplicableProducts__c From PricingProgramLines__r) From Toro_PricingProgram__c r where ExternalId__c = :priceProgram];
		map<string, Toro_PricingProgram__c> rebateMap = new map<string, Toro_PricingProgram__c>();
		map<string, set<String>> rebateApplicableProducts = new map<string, set<String>>();
		map<decimal, Toro_PricingProgramLine__c> msrpLineMap = new map<decimal, Toro_PricingProgramLine__c>();
		map<decimal, Toro_PricingProgramLine__c> dnetLineMap = new map<decimal, Toro_PricingProgramLine__c>();
		decimal msrpMin = 999;
		decimal msrpMax = 0;
		decimal dnetMin = 999;
		decimal dnetMax = 0;
		system.debug(logginglevel.info,'header size = ' + rebates.size());
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
				msrpLineMap.put(l.Off_Mfg_Sugg_Ttl__c, l);
				dnetLineMap.put(l.Award_Price_as_a_Percent_of_DN__c, l);
				msrpMin = Math.min(msrpMin, l.Off_Mfg_Sugg_Ttl__c);
				msrpMax = Math.max(msrpMax, l.Off_Mfg_Sugg_Ttl__c);
				dnetMin = Math.min(dnetMin, l.Award_Price_as_a_Percent_of_DN__c);
				dnetMax = Math.max(dnetMax, l.Award_Price_as_a_Percent_of_DN__c);
			}
		}
		system.debug(logginglevel.info,'checkpoint 2');
		List<Toro_PricingProgramLine__c> dNetLineList = new List<Toro_PricingProgramLine__c>();
		for(decimal key : dnetLineMap.keyset()){
			dNetLineList.add(dnetLineMap.get(key));
		}
		system.debug(logginglevel.info,'checkpoint 3 list size =' + quoteItemList.size());
		for(Toro_QuoteItem__c qi : quoteItemList) {
			Toro_PricingProgram__c rh = rebateMap.get(priceProgram);

			//Performance Part
			//todo
			//ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(quote.Performance_Part__c, qi, ppMap);
		system.debug(logginglevel.info,'checkpoint 4');
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
					qi.Distributor_Net__c = qi.MSRP_Price__c;
					if('% of DNET'.equalsIgnoreCase(priceMethod) && !qi.Performance_Parts_Product__c) {
						if(qi.Unit_Award_Overridden__c) {
							qi.Award_of_DN__c = qi.Award_Price__c * 100/qi.DNet_Price__c;
						}
						qi.Award_of_DN__c = Math.min(qi.Award_of_DN__c, dnetMax);
						qi.Award_of_DN__c = Math.max(qi.Award_of_DN__c, dnetMin);
						Toro_PricingProgramLine__c l = dnetLineMap.get(qi.Award_of_DN__c);
						if(l != null) {
							
							qi.Award_of_DN__c = l.Award_Price_as_a_Percent_of_DN__c;
							qi.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
							system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.DNet_Price__c * qi.Award_of_DN__c/100;
							}
							qi.Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
						} else if(qi.Award_of_DN__c <= dnetMax &&  qi.Award_of_DN__c >= dnetMin) {
							qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
							system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.DNet_Price__c * qi.Award_of_DN__c/100;
							}
							qi.Off_MSRP__c = (qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c;
						}
					} else if('% off MSRP'.equalsIgnoreCase(priceMethod) && !qi.Performance_Parts_Product__c)  {
						if(qi.Unit_Award_Overridden__c) {
							qi.Off_MSRP__c = 100 - (qi.Award_Price__c/qi.MSRP_Price__c)*100.0;
						}
						qi.Off_MSRP__c = Math.min(qi.Off_MSRP__c, msrpMax);
						qi.Off_MSRP__c = Math.max(qi.Off_MSRP__c, msrpMin);
						Toro_PricingProgramLine__c l = msrpLineMap.get(qi.Off_MSRP__c);
						if(l != null) {
						system.debug('Unit_Award_Overridden__c=' + qi.Unit_Award_Overridden__c );
							qi.Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
							qi.Award_of_DN__c = l.Award_Price_as_a_Percent_of_DN__c;
							qi.Selected_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.MSRP_Price__c * (100-qi.Off_MSRP__c)/100;
								system.debug('111111111Award_Price__c=' + qi.Award_Price__c );
							}
							qi.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
							system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
						} else if(qi.Off_MSRP__c <= msrpMax &&  qi.Off_MSRP__c >= msrpMin) {
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.MSRP_Price__c * (1-(qi.Off_MSRP__c/100));
								system.debug('2222222222 Award_Price__c=' + qi.Award_Price__c );
							}
							system.debug('lookupRebateAsPercentOfDNet--- qi.Award_Price__c' + qi.Award_Price__c);
							qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c * 100;
							system.debug('lookupRebateAsPercentOfDNet--- qi.DNet_Price__c' + qi.DNet_Price__c);
							system.debug('lookupRebateAsPercentOfDNet--- qi.Award_of_DN__c' + qi.Award_of_DN__c);
							qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
							system.debug(logginglevel.info,'inside rebate-------------------qi.Rebate_as_a_of_DN__c =' + qi.Rebate_as_a_of_DN__c);
						}
					}
				}
				//if(excludedFromMSRP(qi)) {
				//	qi.Off_MSRP__c = 0;
				//}
				//updatedQuoteItems.add(qi);
				}

				if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
				//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
				for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {

					//Performance Part
					system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 333');
					system.debug('-------------++++++++qis' + qis);


					//ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(quote.Performance_Part__c, qis, ppMap);


					system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 444');
					if(qis.Product_ID__c.startsWith('TPP') || qis.Product_ID__c.startsWith('L')) {
						qis.Award_Price__c = qis.MSRP_Price__c;
					}
					if(!qis.Performance_Part__c && !qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
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
							qis.Percent_of_DNet__c = Math.min(qis.Percent_of_DNet__c, dnetMax);
							qis.Percent_of_DNet__c = Math.max(qis.Percent_of_DNet__c, dnetMin);
							Toro_PricingProgramLine__c l = dnetLineMap.get(qis.Percent_of_DNet__c);
							if(l != null) {
								qis.Percent_of_DNet__c = l.Award_Price_as_a_Percent_of_DN__c;
								qis.Percent_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = l.Rebate_as_a_Percent_of_DN__c;
								}
								system.debug(logginglevel.info,'inside rebate-------------------qis.Rebate_as_a_of_DN__c =' + qis.Rebate_as_of_DNet__c);
								//qis.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.DNet_Price__c * qis.Percent_of_DNet__c/100;
									system.debug('111111111 qis Award_Price__c=' + qis.Award_Price__c );
								}
							} else if(qis.Percent_of_DNet__c <= dnetMax &&  qis.Percent_of_DNet__c >= dnetMin) {
								if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c=lookupRebateAsPercentOfDNet(qis.Percent_of_DNet__c,dNetLineList);
									system.debug(logginglevel.info,'inside rebate-------------------qis.Rebate_as_a_of_DN__c =' + qis.Rebate_as_of_DNet__c);
								}
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.DNet_Price__c * qis.Percent_of_DNet__c/100;
									system.debug('2222222 qis Award_Price__c=' + qis.Award_Price__c );
								}
								qis.Percent_Off_MSRP__c = ((qi.MSRP_Price__c-qi.Award_Price__c)/qi.MSRP_Price__c)*100;
							}
						} else if('% off MSRP'.equalsIgnoreCase(priceMethod) && !qis.Performance_Part__c)  {
							system.debug('qis Unit_Award_Overridden__c=' + qis.Unit_Award_Overridden__c );
							if(qis.Unit_Award_Overridden__c) {
								qis.Percent_Off_MSRP__c = 100 - (qis.Award_Price__c/qis.MSRP_Price__c)*100.0;
							}
							system.debug('1-----qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
							qis.Percent_Off_MSRP__c = Math.min(qis.Percent_Off_MSRP__c, msrpMax);
							qis.Percent_Off_MSRP__c = Math.max(qis.Percent_Off_MSRP__c, msrpMin);
							system.debug('2------qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
							Toro_PricingProgramLine__c l = msrpLineMap.get(qis.Percent_Off_MSRP__c);
							System.debug('>>> inside rebate MSRP --- l='+l + ' - qis.Percent_Off_MSRP__c='+qis.Percent_Off_MSRP__c);
							if(l != null) {
								qis.Percent_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								system.debug('3------qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
								qis.Percent_of_DNet__c = l.Award_Price_as_a_Percent_of_DN__c;
								if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = l.Rebate_as_a_Percent_of_DN__c;
								}
								//qis.Selected_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.MSRP_Price__c * (1-(qis.Percent_Off_MSRP__c/100));
								}
								System.debug('>>> inside rebate MSRP --- l qis.Award_Price__c='+qis.Award_Price__c + ' - Id ='+ qis.Product_Id__c);
								//qis.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
							} else if(qis.Percent_Off_MSRP__c <= msrpMax &&  qis.Percent_Off_MSRP__c >= msrpMin) {
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.MSRP_Price__c * (1-(qis.Percent_Off_MSRP__c/100));
								}
								if(qis.DNet_Price__c != 0){
									qis.Percent_of_DNet__c = qis.Award_Price__c/qis.DNet_Price__c*100;
								} else {
									system.debug('DNet price is zero ---' + qis.Product_Name__c + '---' + qis.Product_Id__c);
								}
								//qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
								if(!qis.Product_Id__c.startsWith('TPP') && !qis.Product_Id__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
								}
							}
						}
					}
					//if(excludedFromMSRP(qis)) {
					//	qis.Percent_Off_MSRP__c = 0;
					//}
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
		return quoteItemList;
	}

	//system.debug(logginglevel.info, '%%%%%%%%%%%%%%%%%%%%' + qis.Unit_Award_Overridden__c);
	public override List<Revvy__MnQuoteItem__c> calculateRebateAndMargin(Id quoteId, String priceProgramExternalId, String priceMethod, List<QuoteItem> quoteItemWrapperList) {
		Map<String,Decimal> ppMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();

		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		List<Toro_PricingProgram__c> rebates = [Select r.Name, r.ExternalId__c, r.ApplicableProducts__c,
				(Select Off_Mfg_Sugg_Ttl__c, Award_Price_as_a_Percent_of_DN__c, Rebate_as_a_Percent_of_DN__c,
				Distributor_Margin__c, ApplicableProducts__c From PricingProgramLines__r) From Toro_PricingProgram__c r where ExternalId__c = :priceProgramExternalId];
		map<string, Toro_PricingProgram__c> rebateMap = new map<string, Toro_PricingProgram__c>();
		map<string, set<String>> rebateApplicableProducts = new map<string, set<String>>();
		map<decimal, Toro_PricingProgramLine__c> msrpLineMap = new map<decimal, Toro_PricingProgramLine__c>();
		map<decimal, Toro_PricingProgramLine__c> dnetLineMap = new map<decimal, Toro_PricingProgramLine__c>();
		decimal msrpMin = 999;
		decimal msrpMax = 0;
		decimal dnetMin = 999;
		decimal dnetMax = 0;
		//system.debug('header size = ' , rebates.size());
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
				msrpLineMap.put(l.Off_Mfg_Sugg_Ttl__c, l);
				dnetLineMap.put(l.Award_Price_as_a_Percent_of_DN__c, l);
				msrpMin = Math.min(msrpMin, l.Off_Mfg_Sugg_Ttl__c);
				msrpMax = Math.max(msrpMax, l.Off_Mfg_Sugg_Ttl__c);
				dnetMin = Math.min(dnetMin, l.Award_Price_as_a_Percent_of_DN__c);
				dnetMax = Math.max(dnetMax, l.Award_Price_as_a_Percent_of_DN__c);
			}
		}

		List<Toro_PricingProgramLine__c> dNetLineList = new List<Toro_PricingProgramLine__c>();
		for(decimal key : dnetLineMap.keyset()){
			dNetLineList.add(dnetLineMap.get(key));
		}
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.msrpMin ' + msrpMin);
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.msrpMax ' + msrpMax);
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.dnetMin ' + dnetMin);
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.dnetMax ' + dnetMax);
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.msrpLineMap ' + msrpLineMap);
		system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper.dnetLineMap ' + dnetLineMap);

		for(QuoteItem qItem : quoteItemWrapperList) {
			REVVY__MnQuoteItem__c qi = qItem.qi;
			Toro_PricingProgram__c rh = rebateMap.get(qi.Pricing_Program__c);

			//Performance Part
			ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItem(quote.Performance_Part__c, qi, ppMap);
			system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part  QuoteItem 222');
			if(rh != null) {
				if(qi.REVVY__Product_ID_F__c.startsWith('TPP') || qi.REVVY__Product_ID_F__c.startsWith('L')) {
					qi.Award_Price__c = qi.DNet_Price__c;
				}
				if(!qi.REVVY__Product_ID_F__c.startsWith('TPP') && !qi.REVVY__Product_ID_F__c.startsWith('L')) {
				if(rebateApplicableProducts.get(qi.Pricing_Program__c).contains('All') ||
						rebateApplicableProducts.get(qi.Pricing_Program__c).contains(qi.revvy__Product_Id_F__c)) {
					system.debug('inside rebate-------------------qi.Off_MSRP__c =' + qi.Off_MSRP__c);
					decimal rebateValue = 0.0;
					decimal basePrice = qi.revvy__Price__c;
					decimal grossProfit = 0.0;
					qi.Distributor_Net__c = qi.revvy__Price__c;
					if('% of DNET'.equalsIgnoreCase(qi.Select_a_Price_Method__c) && !qi.Performance_Parts_Product__c) {
						if(qi.Unit_Award_Overridden__c) {
							qi.Award_of_DN__c = qi.Award_Price__c * 100/qi.REVVY__SuggestedPrice__c;
						}
						qi.Award_of_DN__c = Math.min(qi.Award_of_DN__c, dnetMax);
						qi.Award_of_DN__c = Math.max(qi.Award_of_DN__c, dnetMin);
						Toro_PricingProgramLine__c l = dnetLineMap.get(qi.Award_of_DN__c);
						if(l != null) {
							qi.Award_of_DN__c = l.Award_Price_as_a_Percent_of_DN__c;
							qi.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.REVVY__SuggestedPrice__c * qi.Award_of_DN__c/100;
							}
							qi.Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
						} else if(qi.Award_of_DN__c <= dnetMax &&  qi.Award_of_DN__c >= dnetMin) {
							qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.REVVY__SuggestedPrice__c * qi.Award_of_DN__c/100;
							}
							qi.Off_MSRP__c = (qi.REVVY__Price__c-qi.Award_Price__c)/qi.REVVY__Price__c;
						}
					} else if('% off MSRP'.equalsIgnoreCase(qi.Select_a_Price_Method__c) && !qi.Performance_Parts_Product__c)  {
						if(qi.Unit_Award_Overridden__c) {
							qi.Off_MSRP__c = 100 - (qi.Award_Price__c/qi.Revvy__Price__c)*100.0;
						}
						qi.Off_MSRP__c = Math.min(qi.Off_MSRP__c, msrpMax);
						qi.Off_MSRP__c = Math.max(qi.Off_MSRP__c, msrpMin);
						Toro_PricingProgramLine__c l = msrpLineMap.get(qi.Off_MSRP__c);
						if(l != null) {
							qi.Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
							qi.Award_of_DN__c = l.Award_Price_as_a_Percent_of_DN__c;
							qi.Selected_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.Revvy__Price__c * (100-qi.Off_MSRP__c)/100;
							}
							qi.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
						} else if(qi.Off_MSRP__c <= msrpMax &&  qi.Off_MSRP__c >= msrpMin) {
							system.debug('lookupRebateAsPercentOfDNet--- qi.Revvy__Price__c' + qi.Revvy__Price__c);
							system.debug('lookupRebateAsPercentOfDNet--- qi.Off_MSRP__c' + qi.Off_MSRP__c);
							if(!qi.Unit_Award_Overridden__c) {
								qi.Award_Price__c = qi.Revvy__Price__c * (1-(qi.Off_MSRP__c/100));
							}
							system.debug('lookupRebateAsPercentOfDNet--- qi.Award_Price__c' + qi.Award_Price__c);
							qi.Award_of_DN__c = qi.Award_Price__c/qi.REVVY__SuggestedPrice__c * 100;
							system.debug('lookupRebateAsPercentOfDNet--- qi.REVVY__SuggestedPrice__c' + qi.REVVY__SuggestedPrice__c);
							system.debug('lookupRebateAsPercentOfDNet--- qi.Award_of_DN__c' + qi.Award_of_DN__c);
							qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
						}
					}
				}
				//if(excludedFromMSRP(qi)) {
				//	qi.Off_MSRP__c = 0;
				//}
				updatedQuoteItems.add(qi);
				}
				List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
				system.debug('----------------------' + qi);
				if(qiSub!=null && qiSub.size()>0) {
				//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
				for(REVVY__MnQuoteItemSubline__c qis : qiSub) {

					//Performance Part
					system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 333');
					system.debug('-------------++++++++qis' + qis);
					ToroPerformancePartPricingProgramHelper.applyPerformancePartForQuoteItemSubLine(quote.Performance_Part__c, qis, ppMap);
					system.debug('+++++++++++++++++ToroLargePackagePricingProgramHelper Performance Part QuoteItemSubLine 444');
					if(qis.Product_ID2__c.startsWith('TPP') || qis.Product_ID2__c.startsWith('L')) {
						qis.Award_Price__c = qis.Revvy__Price__c;
					}
					if(!qis.Performance_Part__c && !qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
					if(rebateApplicableProducts.get(qi.Pricing_Program__c).contains('All') ||
						rebateApplicableProducts.get(qi.Pricing_Program__c).contains(qis.Product_ID2__c)) {
						system.debug('inside rebate-------------------' );
						decimal rebateValue = 0.0;
						decimal basePrice = qis.revvy__Price__c;
						decimal grossProfit = 0.0;
						//qis.Distributor_Net__c = qis.revvy__Price__c;
							System.debug('>>> inside rebate MSRP --- qis.Performance_Part__c='+qis.Performance_Part__c);
						if('% of DNET'.equalsIgnoreCase(qi.Select_a_Price_Method__c) && !qis.Performance_Part__c) {
							if(qis.Unit_Award_Overridden__c) {
								qis.Percent_of_DNet__c = qis.Award_Price__c * 100/qis.REVVY__SuggestedPrice__c;
							}
							qis.Percent_of_DNet__c = Math.min(qis.Percent_of_DNet__c, dnetMax);
							qis.Percent_of_DNet__c = Math.max(qis.Percent_of_DNet__c, dnetMin);
							Toro_PricingProgramLine__c l = dnetLineMap.get(qis.Percent_of_DNet__c);
							if(l != null) {
								qis.Percent_of_DNet__c = l.Award_Price_as_a_Percent_of_DN__c;
								qis.Percent_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = l.Rebate_as_a_Percent_of_DN__c;
								}
								//qis.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.Revvy__SuggestedPrice__c * qis.Percent_of_DNet__c/100;
								}
							} else if(qis.Percent_of_DNet__c <= dnetMax &&  qis.Percent_of_DNet__c >= dnetMin) {
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c=lookupRebateAsPercentOfDNet(qis.Percent_of_DNet__c,dNetLineList);
								}
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.REVVY__SuggestedPrice__c * qis.Percent_of_DNet__c/100;
								}
								qis.Percent_Off_MSRP__c = ((qi.REVVY__Price__c-qi.Award_Price__c)/qi.REVVY__Price__c)*100;
							}
						} else if('% off MSRP'.equalsIgnoreCase(qi.Select_a_Price_Method__c) && !qis.Performance_Part__c)  {
							if(qis.Unit_Award_Overridden__c) {
								qis.Percent_Off_MSRP__c = 100 - (qis.Award_Price__c/qis.Revvy__Price__c)*100.0;
							}
							system.debug('1-----qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
							qis.Percent_Off_MSRP__c = Math.min(qis.Percent_Off_MSRP__c, msrpMax);
							qis.Percent_Off_MSRP__c = Math.max(qis.Percent_Off_MSRP__c, msrpMin);
							system.debug('2------qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
							Toro_PricingProgramLine__c l = msrpLineMap.get(qis.Percent_Off_MSRP__c);
							System.debug('>>> inside rebate MSRP --- l='+l + ' - qis.Percent_Off_MSRP__c='+qis.Percent_Off_MSRP__c);
							if(l != null) {
								qis.Percent_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								system.debug('3------qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
								qis.Percent_of_DNet__c = l.Award_Price_as_a_Percent_of_DN__c;
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = l.Rebate_as_a_Percent_of_DN__c;
								}
								//qis.Selected_Off_MSRP__c = l.Off_Mfg_Sugg_Ttl__c;
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.Revvy__Price__c * (1-(qis.Percent_Off_MSRP__c/100));
								}
								System.debug('>>> inside rebate MSRP --- l qis.Award_Price__c='+qis.Award_Price__c + ' - Id ='+ qis.Product_ID2__c);
								//qis.Rebate_as_a_of_DN__c = l.Rebate_as_a_Percent_of_DN__c;
							} else if(qis.Percent_Off_MSRP__c <= msrpMax &&  qis.Percent_Off_MSRP__c >= msrpMin) {
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_Price__c = qis.Revvy__Price__c * (1-(qis.Percent_Off_MSRP__c/100));
								}
								qis.Percent_of_DNet__c = qis.Award_Price__c/qis.REVVY__SuggestedPrice__c*100;
								//qi.Rebate_as_a_of_DN__c=lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
								if(!qis.Product_ID2__c.startsWith('TPP') && !qis.Product_ID2__c.startsWith('L')) {
									qis.Rebate_as_of_DNet__c = lookupRebateAsPercentOfDNet(qi.Award_of_DN__c,dNetLineList);
								}
							}
						}
					}
					//if(excludedFromMSRP(qis)) {
					//	qis.Percent_Off_MSRP__c = 0;
					//}
					}
					if(!qis.Exclude_from_Rebate__c) {
						qis.Extended_Rebate__c = qis.Rebate_as_of_DNet__c * qis.REVVY__SuggestedPrice__c* qis.revvy__quantity__c*qi.revvy__quantity__c;
					}
					updatedQuoteItemSublines.add(qis);
				}
				}

				//system.debug('--++--++--++='  + qis.percent_off_msrp__c + ' off DN=' + qis.percent_of_dnet__c);
			}
		}

		Long perfStart = System.limits.getCpuTime();
		update updatedQuoteItems;
		update updatedQuoteItemSublines;
        update quote; // ??? why update quote here ??
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
		delete [Select Id From REVVY__MnQuoteItem__c where REVVY__Product_ID_F__c = 'S00001' and REVVY__Quote__c = :quoteId];

		return null;
	}
	//Apply_Support_Plus__c
	//Support_Plus_Quantity__c
	public override Map<String, boolean> getQuoteItemSublineFieldsUpdatable(String pricingMethod) {
		system.debug('++++++ToroLargePackagePricingProgramHelper =' + pricingMethod);
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemSublineFieldAPINames()) {
			fs.add(s.toLowerCase());
			system.debug('++++++ToroLargePackagePricingProgramHelper s.toLowerCase() =' + s.toLowerCase() + ' pricingMethod='+pricingMethod);
			if('percent_off_msrp__c'.equalsIgnoreCase(s.toLowerCase()) && '% off MSRP'.equalsIgnoreCase(pricingMethod)) {
				system.debug('-----------' + s.toLowerCase() + ' is updatable ');
				ret.put(s.toLowerCase(), true);
			} else if('percent_of_dnet__c'.equalsIgnoreCase(s.toLowerCase()) && '% of DNET'.equalsIgnoreCase(pricingMethod)) {
				system.debug('-----------' + s.toLowerCase() + ' is updatable ');
				ret.put(s.toLowerCase(), true);
			} else if('revvy__freezepricing__c'.equalsIgnoreCase(s.toLowerCase())) {
				ret.put(s.toLowerCase(), true);
			} else if('performance_part__c'.equalsIgnoreCase(s.toLowerCase())) {
				ret.put(s.toLowerCase(), true);
			} else if('award_price__c'.equalsIgnoreCase(s.toLowerCase())) {
				ret.put(s.toLowerCase(), true);
			} else {
				ret.put(s.toLowerCase(), false);
			}
		}
		return ret;
	}
	public override Map<String, boolean> getQuoteItemFieldsUpdatable() {
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemFieldAPINames()) {
			if('revvy__product_id_f__cc'.equalsIgnoreCase(s.toLowerCase())) {
				continue;
			}
			fs.add(s.toLowerCase());
			if('revvy__freezepricing__c'.equalsIgnoreCase(s.toLowerCase())) {
				ret.put(s.toLowerCase(), true);
			} else if('award_price__c'.equalsIgnoreCase(s.toLowerCase())) {
				ret.put(s.toLowerCase(), true);
			} else {
				ret.put(s.toLowerCase(), false);
			}
		}
		return ret;
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
		final Toro_PricingProgram__c pricingProgram = [SELECT
															OutCrossThreshold__c
															, MinimumThreshold__c
															, MinimumTractionUnits__c
														FROM
															Toro_PricingProgram__c
														WHERE
															Name = :priceProgram LIMIT 1];

		Revvy__MnQuote__c quote = [SELECT
										Toro_ApprovalReason__c
										, Toro_ApprovalRequired__c
										, Total_Extended_DNet__c
									FROM
										Revvy__MnQuote__c
									WHERE
										Id = :quoteId LIMIT 1];

		Boolean containsOutCross = checkForOutCrossProducts(quoteItemList);
		Integer numberOfTractionUnits = getNumberOfTractionUnits(quoteItemList);

		// quotes that contain outcross items have a separate threshold
		if (containsOutCross && quote.Total_Extended_DNet__c < pricingProgram.OutCrossThreshold__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = '<below outcross threshold - placeholder - use custom label>';
		}

		else if (!containsOutcross && quote.Total_Extended_DNet__c < pricingProgram.MinimumThreshold__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = '<below minimum threshold - placeholder - use custom label>';
		}

		else if (numberOfTractionUnits < pricingProgram.MinimumTractionUnits__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = '<below minimum traction units - placeholder - use custom label>';
		}

		if (quote.Toro_ApprovalRequired__c) update quote;

		return 	quoteItemList;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public Integer getNumberOfTractionUnits(List<Toro_QuoteItem__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		final List<Id> quoteItemIds = new List<Id>();
		for (Toro_QuoteItem__c quoteItem : quoteItemList) {

		}

		return 0;
	}

	public Boolean checkForOutCrossProducts(List<Toro_QuoteItem__c> quoteItemList) {
		return false;
	}
}