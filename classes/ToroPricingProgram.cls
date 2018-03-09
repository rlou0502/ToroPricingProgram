public abstract class ToroPricingProgram {
	public Revvy__MnQuote__c quote { get; set; }
	public List<Toro_QuoteItem__c> quoteItems { get; set; }
	public boolean performancePartFlag { get; set; }
	public decimal setupFeePercentage { get; set; }
	public String pricingMethod { get; set; }
	public boolean chainCall { get; set;}
	public string payloadOfChainCall { get; set; }
	public Map<String,Decimal> performancePartMap {get;set;}
	//public abstract List<Schema.FieldSetMember> getQuoteItemSublineFields();
	//public abstract List<Schema.FieldSetMember> getQuoteItemFields();
	public abstract List<Schema.FieldSetMember> getQuoteFields() ;
	public virtual List<Schema.FieldSetMember> getQuoteUpdatableFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.Quote_Header_Updatable_Fields.getFields();
	}
/* 	for quote item /subline extensions */

	public virtual List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}

	public virtual List<ToroSelectOption> retrieveDemoPricingProgramOptions() {
		return new List<ToroSelectOption>();
	}

	public virtual List<FieldSetMember> addUpdatableFieldSetMember(List<Schema.FieldSetMember> fieldSet, List<Schema.FieldSetMember> updatableFieldSet) {
		set<String> updatableFields = new set<String>();
		if(updatableFieldSet != null) {
	    	for(Schema.FieldSetMember s : updatableFieldSet) {
	    		updatableFields.add(s.fieldPath.toLowerCase());
	    	}
		}
		system.debug('updatableFields='+updatableFields);
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
        	FieldSetMember nfsm = new FieldSetMember(f);
        	nfsm.updatable=false;
        	system.debug('f.fieldPath='+f.fieldPath);
        	if(updatableFields.contains(f.fieldPath.toLowerCase())) {
        		nfsm.updatable=true;
        	}
            fset.add(nfsm);
        }
        return fset;
	}

	public virtual List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}


	public virtual boolean displayPerformancePart() {
		return false;
	}
	public virtual boolean displaySetupFee() {
		return false;
	}

	public virtual List<Toro_QuoteItem__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return 	quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return 	quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> postCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return 	quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> calculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList, boolean save ){
		Long perfStart = System.limits.getCpuTime();
		performancePartMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		
		//remove setup fees
		Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		for(Toro_QuoteItem__c qi : quoteItemList) {
			if('S00001'.equalsIgnoreCase(qi.Product_Id__c)) {
				deleteSetupFeeLineItemId.add(qi.Id);
				deleteSetupFeeLineItemId.add(qi.QuoteItem__c);
			}
		}				
		delete [Select Id From Toro_QuoteItem__c where Id in :deleteSetupFeeLineItemId];
		delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
		
		//call pre
		system.debug(logginglevel.info, 'calling precalculateRebateMarginImpl =' + priceProgram + ' -- ' + quoteItemList);
		List<Toro_QuoteItem__c> lQuoteItemList = preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);

		system.debug(logginglevel.info, 'calling calculateRebateMarginImpl =' + priceProgram + ' -- ' + quoteItemList);
		lQuoteItemList = calculateRebateMarginImpl(quoteId, priceProgram, priceMethod, lQuoteItemList);
		system.debug(logginglevel.info,'calling calculateRebateMarginImpl took ' + (System.limits.getCpuTime()-perfStart));

		lQuoteItemList = calculateExtendedFields(lQuoteItemList);
		system.debug(logginglevel.info,'calling calculateExtendedFields took ' + (System.limits.getCpuTime()-perfStart));

		lQuoteItemList = preSaveCalculateRebateMargin(quoteId, priceProgram, priceMethod, lQuoteItemList);
		system.debug(logginglevel.info,'calling preSaveCalculateRebateMargin');

		system.debug(logginglevel.info,'calling saveQuoteItemList');
		if(save) {
			lQuoteItemList = saveQuoteItemList(lQuoteItemList);
			lQuoteItemList = postCalculateRebateMargin(quoteId, priceProgram, priceMethod, lQuoteItemList);
		}


		system.debug(logginglevel.info,'calling saveQuoteItemList took ' + (System.limits.getCpuTime()-perfStart));
		return lQuoteItemList;
	}

	/*
	public virtual List<Toro_QuoteItem__c> updateQuote(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		List<Toro_QuoteItem__c> qiList = calculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		return saveQuoteItemList(qiList);
	}
	*/

	//Method calculateRebateMarginImpl is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		system.debug('inside base calculateRebateMarginImpl');
		return quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> calculateExtendedFields(List<Toro_QuoteItem__c> quoteItemList) {
		decimal quoteDnet = 0;
		decimal quoteAward = 0;
		decimal quoteTotalAward =0;
		decimal quoteToroTotalAward=0;
		decimal quoteTotalDNet =0;
		decimal quoteTotalSetupFee=0;
		decimal quoteToroTotalDNet=0;
		decimal quoteTotalGP=0;
		decimal quoteTotalRebate=0;
		decimal quoteTotalDnetWOTppAllied = 0;
		for (Toro_QuoteItem__c qi : quoteItemList) {
			//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
			decimal extDnet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			decimal extAward = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
			//decimal extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			decimal extMSRP = CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);			 
			qi.Toro_Rebate__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c)/100;
			decimal extRebate = qi.Toro_Rebate__c;
			decimal feeAmount = extAward * CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100;
			decimal totalAward = extAward;
			qi.Toro_Fee_Amount__c = feeAmount;
			if(extDnet != null && extDnet !=0) {
				qi.Award_of_DN__c = extAward/extDnet*100;
			}
			qi.Toro_Gross_Profit_Value__c = extAward - extDnet + extDnet * CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c)/100;	
			if(extAward != null && extAward != 0) {
				qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/extAward*100;	
			}
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
						decimal subExtDNet = qis.Toro_DNet_Price__c* extQty;
						decimal subExtAward = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)/100 * extQty;
						decimal subExtMSRP = qis.MSRP_Price__c * extQty;
						decimal subExtFitAmount = subExtAward * CMnQuoteUtil.defaultDecimal(qis.Fee_Percentage__c)/100;
						extDnet += subExtDNet;
						extAward += subExtAward;
						extMSRP += subExtMSRP;
						feeAmount += subExtFitAmount;
						totalAward += CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) *  CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c)/100 * extQty;
						qis.Toro_Fee_Amount__c = subExtFitAmount;
						qis.Gross_Profit_Value__c = subExtAward - subExtDNet + (subExtDNet * CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100);	
						if(subExtAward != 0) {
							qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c/subExtAward*100;	
						} else {
							system.debug('subExtAward is null or 0 --' + qis.product_name__c + ' dnet price =' + qis.Toro_DNet_Price__c + ' dnet %' + qis.Percent_of_DNet__c);
						}
						qis.Toro_Subline_Rebate__c = qis.Toro_DNet_Price__c * CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100;
						extRebate += qis.Toro_Subline_Rebate__c;
						qis.Toro_Extended_Award_Price__c      = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)  * extQty;
						//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;	
					}	
				}	
			}
			
			qi.Toro_Total_Extended_Award_Price__c = extAward;
			qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			if(extMSRP != 0) {
				qi.Toro_Total_MSRP_Percentage__c = 100 - (extAward/extMSRP)*100;
			}
			qi.Toro_Total_Rebate__c = extRebate;
			qi.Total_Gross_Profit_Value__c = extAward - extDnet + extRebate; 
			if(extAward != 0) {
				qi.Total_Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(qi.Total_Gross_Profit_Value__c)/extAward*100; 
			}
			if (qi.Toro_Fee_Amount__c != null) {
				qi.Toro_Total_Setup_Fees__c = feeAmount;
			}

			if (qi.Award_Price__c != null) {
				qi.Toro_Total_Unit_Award__c = extAward;
			}
			quoteTotalAward 			+= totalAward;
			quoteToroTotalAward       	+= extAward;
			quoteTotalDNet              += extDnet;
			quoteTotalSetupFee        	+= feeAmount;
			quoteToroTotalDNet          += extDnet;
			quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			quoteTotalRebate       		+= qi.Toro_Total_Rebate__c;
			quoteTotalRebate            += qi.Toro_Total_Rebate__c;
			quoteTotalDnetWOTppAllied   += extDnet;
		// quote.Toro_Rollup_Award_Price__c is quote award price
		// quote.Toro_Rollup_DNetWOTPPAllied__c is quote dnet without tpp and allied
		
		}	
		
		quote.Toro_Rollup_Award_Price__c       = quoteToroTotalAward;
		quote.Toro_Rollup_DNET__c              = quoteTotalDNet;
		quote.Toro_Rollup_Setup_Fees__c        = quoteTotalSetupFee;
		quote.Toro_Total_DNet__c               = quoteToroTotalDNet;
		quote.Toro_Total_Quote_Gross_Profit__c = quoteTotalGP;
		quote.Toro_Total_Quote_Rebate__c       = quoteTotalRebate;
		quote.Toro_Total_Rebate__c             = quoteTotalRebate;
		quote.Toro_Rollup_DNetWOTPPAllied__c   = quoteTotalDnetWOTppAllied;
		
		
		quote.Award_Price__c = quoteTotalAward;
		if(quote.Toro_Rollup_DNetWOTPPAllied__c != null && quote.Toro_Rollup_DNetWOTPPAllied__c != 0) {
			quote.Toro_Blended_Percent_of_DN__c            = CMnQuoteUtil.defaultDecimal(quote.Toro_Rollup_Award_Price__c) / quote.Toro_Rollup_DNetWOTPPAllied__c*100;
		}
		quote.Toro_Blended_Percent_of_DN__c=quote.Toro_Blended_Percent_of_DN__c.setScale(2);
		if(quote.Toro_Rollup_Award_Price__c != null && quote.Toro_Rollup_Award_Price__c != 0) {
			quote.Toro_Total_Quote_Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Quote_Gross_Profit__c) / quote.Toro_Rollup_Award_Price__c;
		}
		
		
		return quoteItemList;	
	}
	/*
	//Method calculateExtendedFields is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> calculateExtendedFields2(List<Toro_QuoteItem__c> quoteItemList) {
		system.debug(logginglevel.info,'inside base calculateExtendedFields =' + quoteItemList);
		initializeExtendedFieldsToZero(quoteItemList);

		// calculate subline values
		decimal quoteDnet = 0;
		decimal quoteAward = 0;
		for (Toro_QuoteItem__c qi : quoteItemList) {
			//qi.Award_Price__c = qi.Award_Price__c.setScale(2,roundingMode.HALF_UP);
			decimal qiExtDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			decimal qiExtAward = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			system.debug(logginglevel.info, 'calculateExtendedFields--  1 --' + qi.product_Name__c +  ' qiExtDNet=' + qiExtDNet + ' award= ' + qiExtAward );
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						qiExtDNet += CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qiExtAward += CMnQuoteUtil.defaultDecimal(qis.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					}
					
					//qis.Award_Price__c = qis.Award_Price__c.setScale(2,roundingMode.HALF_UP);
					//extended qty = qi qty * qis qty
					system.debug(logginglevel.info, 'calculateExtendedFields--' + qi.product_Name__c +  ' dnet=' + qis.DNet_Price__c + ' award= ' + qis.Award_Price__c + ' qis.qis.Percent_of_DNet__c ='+ qis.Percent_of_DNet__c + ' calculated award=' + qis.DNet_Price__c *qis.Percent_of_DNet__c/100);
					system.debug(logginglevel.info, 'calculateExtendedFields--' + qi.product_Name__c +  ' qiExtDNet=' + qiExtDNet + ' award= ' + qiExtAward );
					final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					// calculate values for the subline
					qis.Toro_Extended_Qty__c              = extQty;
					
					//qis.Toro_Extended_Award_DNet_Price__c can be deprecated
					qis.Toro_Extended_Award_DNet_Price__c = qis.DNet_Price__c * extQty * CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c)/100;
					
					//qis.Toro_Extended_Award_MSRP_Price__c can be deprecated
					qis.Toro_Extended_Award_MSRP_Price__c = qis.MSRP_Price__c * extQty * (1 - CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c)/100);
					system.debug(logginglevel.info,'------Percent_of_DNet__c  =' + qis.Percent_of_DNet__c);
					system.debug(logginglevel.info,'------Percent_Off_MSRP__c  =' + qis.Percent_Off_MSRP__c);

					//This is quote subline's award price - 
					system.debug(logginglevel.info,'------qis.Award_Price__c  =' + qis.Award_Price__c);
					
					//This is quote subline's award price -
					qis.Toro_Extended_Award_Price__c      = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)  * extQty;
					system.debug(logginglevel.info,'------qis.Toro_Extended_Award_Price__c  =' + qis.Toro_Extended_Award_Price__c);
					//do we need this//allied product will always dnet as 0
					qis.Toro_DNet_Price__c                = (qis.TPP_Line_Item__c == true) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
					//qis.Toro_Extended_Award_MSRP_Price__c can be deprecated
					qis.Toro_Extended_MSRP_Price__c       = (qis.Performance_Part__c == true) ? (qis.Quote_Item_Sub_Line__r.REVVY__Unit_Price__c * extQty) : (CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * extQty);

					System.debug('\n\n@@qis.Fee_Percentage__c: ' + qis.Fee_Percentage__c + '\n\n');
					if (qis.Fee_Percentage__c != null) {
						qis.Toro_Fee_Amount__c = qis.Toro_Extended_Award_Price__c * qis.Fee_Percentage__c/100;
					}

					qis.Toro_Subline_Rebate__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty* CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c)/100;

					// calculate rollups on the quote item
					//@deprecated
					qi.Toro_Rollup_Award_DNet_Price__c           += qis.Toro_Extended_Award_DNet_Price__c;
					//@deprecated
					qi.Toro_Rollup_Award_MSRP_Price__c           += qis.Toro_Extended_Award_MSRP_Price__c;
					//@deprecated
					qi.Toro_Rollup_Award_Price__c                += CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					//????????????
					if(qis.TPP_Line_Item__c) {
						qi.Toro_Rollup_DNet_for_TPP__c += CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					}
					//@deprecated
					qi.Toro_Rollup_DNet_Price__c                 += CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					qi.Toro_Rollup_Extended_Award_Price__c       += qis.Toro_Extended_Award_Price__c;
					//@deprecated
					qi.Toro_Rollup_MSRP_Price__c                 += qis.Toro_Extended_MSRP_Price__c;
					qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c += 1; // count of sublines

					if (qis.Toro_Fee_Amount__c != null) {
						qi.Toro_Rollup_Setup_Fees_Sub_Line__c += qis.Toro_Fee_Amount__c;
					}
					System.debug('\n\n@@qi.Toro_Rollup_Setup_Fees_Sub_Line__c: ' + qi.Toro_Rollup_Setup_Fees_Sub_Line__c + '\n\n');

					qi.Toro_Rollup_Subline_Rebate__c             += qis.Toro_Subline_Rebate__c;
					//??do we need this - need more input from nalee, nalee has a better way to do this
					//@deprecated
					qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c += CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c);
				}
			}
			quoteDnet += qiExtDNet;
			quoteAward += qiExtAward;
			system.debug(logginglevel.info, 'calculateExtendedFields--  quote --quoteDnet=' + quoteDnet +  ' quoteAward=' +quoteAward );
		}

		// calculate quote item values
		for (Toro_QuoteItem__c qi : quoteItemList) {
			System.debug('\n\n@@qi.Product_Name__c: ' + qi.Product_Name__c + '\n\n');
			final Decimal qty = qi.Quantity__c;
			qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			// calculate values for the quote item
			system.debug('qty=' + qty + 'MSRP_Price__c=' + qi.MSRP_Price__c + ' Award_of_DN__c =' + qi.Award_of_DN__c + 'qi.Toro_Rollup_Award_DNet_Price__c=' + qi.Toro_Rollup_Award_DNet_Price__c);
			if (qi.Award_of_DN__c != null) {
				qi.Toro_Extended_Award_DNet_Price__c = (CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qty * qi.Award_of_DN__c/100) + qi.Toro_Rollup_Award_DNet_Price__c;
			}


			if (qi.Off_MSRP__c != null) {
				system.debug(logginglevel.info,'------qi.Off_MSRP__c  =' +qi.Off_MSRP__c);
				qi.Toro_Extended_Award_MSRP_Price__c = (CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) * qty * (1 - qi.Off_MSRP__c/100)) + CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_Award_MSRP_Price__c);
			}
			//todo -- need calculate Toro_Rollup_Partner_Products__c and Toro_Rollup_TPP__c
			//might need Total_Award_Price__c, TPP should be included in calculation
			
			//qi.Toro_Total_Award_price__c = (qi.Select_a_Price_Method__c == '% of DNET')
			//								? qi.Toro_Extended_Award_DNet_Price__c
			//								: CMnQuoteUtil.defaultDecimal(qi.Toro_Extended_Award_MSRP_Price__c)
			//									- (CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_Partner_Products__c) * ((1 - CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)) / 100))
			//									- (CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_TPP__c) * ((1 - CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)) / 100));
			//
			 
			System.debug('\n\n@@qi.Select_a_Price_Method__c: ' + qi.Select_a_Price_Method__c + '\n\n');
			System.debug('\n\n@@qi.Toro_Extended_Award_DNet_Price__c: ' + qi.Toro_Extended_Award_DNet_Price__c + '\n\n');
			System.debug('\n\n@@qi.Toro_Extended_Award_MSRP_Price__c: ' + qi.Toro_Extended_Award_MSRP_Price__c + '\n\n');
			System.debug('\n\n@@qi.Toro_Total_Award_price__c: ' + qi.Toro_Total_Award_price__c + '\n\n');

			if (qi.Award_Price__c != null) {
				//@deprecated
				qi.Toro_Total_Extended_Award_Price__c = qi.Award_Price__c * qty;
			}
			system.debug(LoggingLevel.INFO,' id='+qi.Product_Id__c+' qty=' + qty + 'qi.DNet_Price__c ' + qi.DNet_Price__c );
			qi.Toro_Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qty);

			
			qi.Toro_Distributor_Responsibility__c = null; // @TODO
			//total extended dnet
			qi.Toro_Rollup_DNet_for_TPP__c =0;
			//need a total dnet price
			qi.Toro_DNet_Price__c      = (qi.DNet_Price__c * qty) + (qi.Toro_Rollup_DNet_Price__c - qi.Toro_Rollup_DNet_for_TPP__c);
			qi.Toro_DNetWOTPPAllied__c = (qi.DNet_Price__c * qty) + (qi.Toro_Rollup_DNet_Price__c - qi.Toro_Rollup_DNet_for_TPP__c);
//unit award price
			if (qi.Award_Price__c != null) {
				qi.Toro_Extended_Award_Price__c = qi.Award_Price__c * qty;
			}
			qi.Toro_Total_Award_price__c = qi.Toro_Extended_Award_Price__c + qi.Toro_Rollup_Extended_Award_Price__c;
			
			if (qi.Toro_DNetWOTPPAllied__c != 0) {
				//qi.Toro_Blend_Of_DN__c = qi.Toro_Total_Extended_Award_Price__c / qi.Toro_DNetWOTPPAllied__c * 100;
			}
			
			
			//?? remove?
			System.debug('+++++ Toro_Extended_MSRP_Price__c qi.MSRP_Price__c='+qi.MSRP_Price__c + ' qty='+qty );
			qi.Toro_Extended_MSRP_Price__c = (qi.Performance_Parts_Product__c == true)
												? qi.Award_Price__c * qty
												: qi.MSRP_Price__c * qty;

			if (qi.Fee_Percentage__c != null) {
				qi.Toro_Fee_Amount__c = (qi.Toro_Total_Extended_Award_Price__c * qi.Fee_Percentage__c/100) + qi.Toro_Rollup_Setup_Fees_Sub_Line__c;
			}

			if (qi.Rebate_as_a_of_DN__c != null) {
				system.debug(logginglevel.info, ' qi.Toro_Extended_DNet_Price__c =' + qi.Toro_Extended_DNet_Price__c + ' qi.Rebate_as_a_of_DN__c/100 ' + qi.Rebate_as_a_of_DN__c/100 + ' qi.Toro_Rollup_Subline_Rebate__c ' + qi.Toro_Rollup_Subline_Rebate__c);
				qi.Toro_Total_Rebate__c = (qi.Toro_Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100) + qi.Toro_Rollup_Subline_Rebate__c;
			}

			if (qi.Toro_Total_Rebate__c != null) {
				qi.Toro_Gross_Profit_Value__c = qi.Toro_Total_Award_price__c - qi.Toro_DNet_Price__c + qi.Toro_Total_Rebate__c;
			}

			if (qi.Toro_Total_Award_price__c != 0) {
				qi.Toro_Gross_Profit_Percent__c = (qi.Toro_Gross_Profit_Value__c / qi.Toro_Total_Award_price__c) * 100;
			}

			if (qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c != 0) {
				qi.Toro_QuoteItemSubline_Rebate_as_of_Dnet__c = (qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c / qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c)*100;
			}

			qi.Toro_Total_Extended_MSRP_Price__c = qi.Toro_Extended_MSRP_Price__c + qi.Toro_Rollup_MSRP_Price__c;

			if (qi.Toro_Fee_Amount__c != null) {
				qi.Toro_Total_Setup_Fees__c = qi.Toro_Fee_Amount__c + qi.Toro_Rollup_Setup_Fees_Sub_Line__c;
			}

			if (qi.Award_Price__c != null) {
				qi.Toro_Total_Unit_Award__c = qi.Award_Price__c + qi.Toro_Rollup_Award_Price__c;
			}
		}

		//debugCalculatedValues(quoteItemList);
		System.debug('\n\n@@quote: ' + quote + '\n\n');

		// initialize quote-level rollup fields
		quote.Toro_Rollup_Award_Price__c       = 0;
		quote.Toro_Rollup_DNET__c              = 0;
		quote.Toro_Rollup_Setup_Fees__c        = 0;
		quote.Toro_Total_DNet__c               = 0;
		quote.Toro_Total_Quote_Gross_Profit__c = 0;
		quote.Toro_Total_Quote_Rebate__c       = 0;
		quote.Toro_Total_Rebate__c             = 0;
		quote.Toro_Rollup_DNetWOTPPAllied__c   = 0;

		for (Toro_QuoteItem__c qi : quoteItemList) {
			quote.Toro_Rollup_Award_Price__c       += qi.Toro_Total_Extended_Award_Price__c;
			quote.Toro_Rollup_DNET__c              += qi.Toro_DNet_Price__c;
			quote.Toro_Rollup_Setup_Fees__c        += qi.Toro_Total_Setup_Fees__c;
			quote.Toro_Total_DNet__c               += qi.Toro_DNet_Price__c;
			quote.Toro_Total_Quote_Gross_Profit__c += qi.Toro_Gross_Profit_Value__c;
			quote.Toro_Total_Quote_Rebate__c       += qi.Toro_Total_Rebate__c;
			quote.Toro_Total_Rebate__c             += qi.Toro_Total_Rebate__c;
			quote.Toro_Rollup_DNetWOTPPAllied__c   += qi.Toro_DNetWOTPPAllied__c;
		}
		
			
		// quote.Toro_Rollup_Award_Price__c is quote award price
		// quote.Toro_Rollup_DNetWOTPPAllied__c is quote dnet without tpp and allied
		
		if(quote.Toro_Rollup_DNET__c != null && quote.Toro_Rollup_DNET__c != 0) {
			quote.Toro_Blended_Percent_of_DN__c            = quote.Toro_Rollup_Award_Price__c / quote.Toro_Rollup_DNetWOTPPAllied__c*100;
			quote.Toro_Blended_Percent_of_DN__c=quote.Toro_Blended_Percent_of_DN__c.setScale(2);
		}
		if(quote.Toro_Total_DNet__c != null && quote.Toro_Total_DNet__c != 0) {
			//quote.Toro_Total_Award_of_DNET__c              = quote.REVVY__OneTimeTotalAfterAdjustmentDisplay_F__c / quote.Toro_Total_DNet__c;
		}
		if(quote.Toro_Rollup_Award_Price__c != null && quote.Toro_Rollup_Award_Price__c != 0) {
			quote.Toro_Total_Quote_Gross_Profit_Percent__c = quote.Toro_Total_Quote_Gross_Profit__c / quote.Toro_Rollup_Award_Price__c;
		}
		quote.Award_Price__c = quoteAward;
		quote.Toro_Rollup_DNetWOTPPAllied__c = quoteDnet;
		// update quote;
		system.debug(logginglevel.info, 'calculateExtendedFields--  quote --quote.Toro_Rollup_DNetWOTPPAllied__c=' + quote.Toro_Rollup_DNetWOTPPAllied__c +  ' quote.Toro_Rollup_Award_Price__c=' +quote.Award_Price__c );
		return quoteItemList;
	}
*/
	// initializes the quote item and quote item subline calculated fields to 0
	private void initializeExtendedFieldsToZero(List<Toro_QuoteItem__c> quoteItemList) {
		system.debug('initializeExtendedFieldsToZero quoteItemList =' + quoteItemList);
		/*
		if(quoteItemList != null) {
			for (Toro_QuoteItem__c qi : quoteItemList) {
				//qi.Toro_Blend_Of_DN__c                        = 0;
				qi.Toro_Extended_DNet_Price__c                = 0;
				qi.Toro_Distributor_Responsibility__c         = 0;
				qi.Toro_DNet_Price__c                         = 0;
				qi.Toro_DNetWOTPPAllied__c                    = 0;
				qi.Toro_Extended_Award_Price__c               = 0;
				qi.Toro_Extended_Award_DNet_Price__c          = 0;
				qi.Toro_Extended_Award_MSRP_Price__c          = 0;
				qi.Toro_Extended_MSRP_Price__c                = 0;
				qi.Toro_Fee_Amount__c                         = 0;
				qi.Toro_Gross_Profit_Value__c                 = 0;
				qi.Toro_Gross_Profit_Percent__c               = 0;
				qi.Toro_QuoteItemSubline_Rebate_as_of_Dnet__c = 0;
				qi.Toro_Rollup_Award_DNet_Price__c            = 0;
				qi.Toro_Rollup_Award_MSRP_Price__c            = 0;
				qi.Toro_Rollup_Award_Price__c                 = 0;
				qi.Toro_Rollup_DNet_for_TPP__c                = 0;
				qi.Toro_Rollup_DNet_Price__c                  = 0;
				qi.Toro_Rollup_Extended_Award_Price__c        = 0;
				qi.Toro_Rollup_MSRP_Price__c                  = 0;
				qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c  = 0;
				qi.Toro_Rollup_Setup_Fees_Sub_Line__c         = 0;
				qi.Toro_Rollup_Subline_Rebate__c              = 0;
				qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c  = 0;
				qi.Toro_Total_Award_price__c                  = 0;
				qi.Toro_Total_Extended_Award_Price__c         = 0;
				qi.Toro_Total_Extended_MSRP_Price__c          = 0;
				qi.Toro_Total_Rebate__c                       = 0;
				qi.Toro_Total_Setup_Fees__c                   = 0;
				qi.Toro_Total_Unit_Award__c                   = 0;

				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.Toro_Extended_Qty__c                     = 0;
						qis.Toro_Extended_Award_DNet_Price__c        = 0;
						qis.Toro_Extended_Award_MSRP_Price__c        = 0;
						qis.Toro_Extended_Award_Price__c             = 0;
						qis.Toro_DNet_Price__c                       = 0;
						qis.Toro_Extended_MSRP_Price__c              = 0;
						qis.Toro_Fee_Amount__c                       = 0;
						qis.Toro_Subline_Rebate__c                   = 0;
						qi.Toro_Rollup_Award_DNet_Price__c           = 0;
						qi.Toro_Rollup_Award_MSRP_Price__c           = 0;
						qi.Toro_Rollup_Award_Price__c                = 0;
						qi.Toro_Rollup_DNet_for_TPP__c               = 0;
						qi.Toro_Rollup_DNet_Price__c                 = 0;
						qi.Toro_Rollup_Extended_Award_Price__c       = 0;
						qi.Toro_Rollup_MSRP_Price__c                 = 0;
						qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c = 0;
						qi.Toro_Rollup_Setup_Fees_Sub_Line__c        = 0;
						qi.Toro_Rollup_Subline_Rebate__c             = 0;
						qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c = 0;
					}
				}
			}
		}
		*/

	}
	
	//Method saveQuoteItemList is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> saveQuoteItemList(List<Toro_QuoteItem__c> quoteItemList ){

		system.debug(logginglevel.info,'inside base saveQuoteItemList');
		//saveToroQuoteItemList(quoteItemList);

		List<Toro_QuoteItem__c> updateQuoteItems = new List<Toro_QuoteItem__c>();
		List<Toro_QuoteItem_SubLine__c> updateQuoteItemSublines = new List<Toro_QuoteItem_SubLine__c>();

		for(Toro_QuoteItem__c qi : quoteItemList) {
			updateQuoteItems.add(qi);
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Toro_QuoteItem_SubLine__c qiSubline : qi.Toro_Quote_Item_Sub_Lines__r) {
					updateQuoteItemSublines.add(qiSubline);
				}
			}
		}

		if(updateQuoteItems.size() > 0) {
			database.update(updateQuoteItems, false);
		}
		if(updateQuoteItemSublines.size() > 0) {
			update updateQuoteItemSublines;
		}
		update quote;
		return quoteItemList;
	}

	public ToroPricingProgram() {
		quoteFieldMap = Schema.SObjectType.Revvy__MnQuote__c.fields.getMap();
		quoteItemFieldMap = Schema.SObjectType.Revvy__MnQuoteItem__c.fields.getMap();
		quoteItemSublineFieldMap = Schema.SObjectType.Revvy__MnQuoteItemSubline__c.fields.getMap();
	}

	public virtual void initializeQuoteHeader(Id quoteId) {
		//system.debug(logginglevel.info, 'initializeQuoteHeader -- quoteId-------'+quoteId);
		//quote = ToroCacheManager.getQuote(quoteId);
		//system.debug(logginglevel.info, 'initializeQuoteHeader quoteId-------'+quoteId);
		//system.debug(logginglevel.info, 'initializeQuoteHeader quote-------'+quote);
		String quoteQuery = 'select ' + getQuoteFieldAPINameQuery('Setup_Fee__c, Toro_Support_Plus_Allowance__c, Blended_Percent_of_DN__c, Support_Plus_Rebate__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c,Blended_Percent_of_DN__c') + ' from Revvy__MnQuote__c where id=:quoteId';
		quote = Database.query(quoteQuery);

	}
	public virtual void initialize(Id quoteId) {
		initializeQuoteHeader(quoteId);

		String quoteLineQuery = 'Select ' + getToroQuoteItemFieldAPINamesQuery('FreezeLine__c, Product__r.Toro_Product_Type__c,Traction_Unit__c, Off_MSRP__c,Award_Price__c,Rebate_as_a_of_DN__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, MSRP_Price__c, Original_off_MSRP__c, Oroginal_of_DNet__c,Unit_Award_Overridden__c, QuoteItem__r.REVVY__Catalog_Node__r.revvy__id__c, QuoteItem__r.REVVY__Catalog_Node__r.name,Select_Price_Program_Type__c,QuoteItem__r.REVVY__SuggestedPrice__c,Misc_Style__c , DNet_Price__c,QuoteItem__r.REVVY__Price__c,Off_MSRP__c, Selected_Off_MSRP__c, Pricing_Program__c, Select_a_Price_Method__c, Award_of_DN__c, Standard_Price__c');
		quoteLineQuery += ', (Select ' + getToroQuoteItemSublineFieldAPINamesQuery('FreezeLine__c, Award_Price__c, Rebate_as_of_DNet__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, Exclude_from_Rebate__c,Unit_Award_Overridden__c, Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c,DNet_Price_2__c ,Misc_Style__c, DNet_Price__c ,Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name, Standard_Price__c, Quote_Item_Sub_Line__r.REVVY__Price__c, Quote_Item_Sub_Line__r.REVVY__SuggestedPrice__c, Toro_Quote_Item__r.Select_a_Price_Method__c, Percent_Off_MSRP__c, Percent_of_DNet__c,Quantity__c');
		quoteLineQuery += ' from Toro_Quote_Item_Sub_Lines__r order by Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name) from  Toro_QuoteItem__c where Mn_Quote__c = :quoteId';
		System.debug('88888888888888888888=' + quoteLineQuery);
		quoteItems = Database.query(quoteLineQuery);
		system.debug('quote items =' + quoteItems);
		//Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		//for(REVVY__MnQuoteItem__c qi : quoteItems) {
		//	system.debug('**************' + qi.Off_MSRP__c + '&&&&&&' + qi.Award_of_DN__c);
			//if('S00001'.equalsIgnoreCase(qi.REVVY__Product_ID_F__c)) {
			//	deleteSetupFeeLineItemId.add(qi.Id);
			//}
			//Reset Values
			//qi.Off_MSRP__c = 0;
			//qi.Rebate_as_a_of_DN__c = 0;
			//qi.Fee_Percentage__c = 0;
			//qi.Part_Percentage__c = 0;
			//qi.Award_Price__c = 0; //qi.REVVY__SuggestedPrice__c * qi.Award_of_DN__c/100;

			//List<REVVY__MnQuoteItemSubLine__c> qiSub = qi.REVVY__QuoteItemSubLine__r;
			//if(qiSub!=null) {
			//	for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
			//		qis.percent_off_msrp__c =  0;
			//		qis.Fee_Percentage__c = 0;
			//		qis.Part_Percentage__c = 0;
			//		qis.Award_Price__c =0;
			//	}
			//}
		//}
		//delete setup fee line
		//delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
	}
	public virtual Revvy__MnQuoteItem__c calculateRebateAndMarginForQuoteItem(String pricingProgram, String priceMethod, Revvy__MnQuoteItem__c quoteItem ) {
		return null;
	}
	public virtual List<SelectOption> getPriceMethodOptions() {
		return new List<SelectOption> {new SelectOption('% off MSRP','% off MSRP'),  new SelectOption('% of DNET','% of DNET') };
	}
	public virtual boolean getQuoteLevelMSQPDNetEditable() {
		return true;
	}

	public virtual List<Schema.FieldSetMember> getQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	public virtual boolean excludedFromMSRP(Toro_QuoteItem__c qi) {
		boolean ret = false;

		if(qi.Performance_Parts_Product__c) {
			ret=true;
		}

		return ret;
	}

	public virtual boolean excludedFromMSRP(Toro_QuoteItem_SubLine__c qi) {
		boolean ret = false;
		String productId = string.isNotBlank(qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c) ? qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c : qi.Quote_Item_Sub_Line__r.Product_ID_F__c;
		if(productId.startsWith('TPP')  || productId.startsWith('L0') || productId.startsWith('L1') || qi.Performance_Part__c) {
			ret = true;
		}
		return ret;
	}

	private String CombineSelectClauses(List<String> fieldListFromFS, String extraFields ) {
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldListFromFS);
		return String.join(new List<String>(nameSet), ',');
	}

	protected virtual List<String> getQuoteFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}

	protected virtual String getQuoteFieldAPINameQuery(String extraFields) {
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}

	protected virtual String getToroQuoteFieldAPINameQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}

	protected virtual String getToroQuoteItemFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		return CombineSelectClauses(fieldNames, extraFields);
	}

	protected virtual String getToroQuoteItemSublineFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemSublineFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		return CombineSelectClauses(fieldNames, extraFields);
	}


	protected Map<String, Schema.SObjectField> quoteFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemSublineFieldMap { get; set; }
}