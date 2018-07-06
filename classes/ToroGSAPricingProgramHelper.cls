public virtual class ToroGSAPricingProgramHelper extends ToroPricingProgram {
	public override boolean displaySetupFee() {
		return false;
	}      
	public override boolean displayPerformancePart() {
		return false;
	}   
	
	public virtual decimal retrieveAwardPrice(REVVY__MnPriceListLine__c ppl) {
		return null;	
	} 
	public override List<Revvy__MnStrategy4__c> loadPricesFromPricelist(String priceProgram, List<Revvy__MnStrategy4__c> quoteItemList ){
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('ToroContractPriceListPPHelper--' +  rebates);
		for(Revvy__MnStrategy1__c pp : rebates) {
			system.debug('ToroContractPriceListPPHelper--'+pp);
			String priceListId = pp.OverriddenPriceList__c;
			system.debug('ToroContractPriceListPPHelper--priceListId='+priceListId);
			Map<String, revvy__MnPriceListLine__c> prodPriceListLineMap = new Map<String, revvy__MnPriceListLine__c>();
			List<revvy__MnPriceListLine__c> plis = [SELECT Id, revvy__ListedPrice__c,revvy__SuggestedPrice__c,revvy__product__c,
				revvy__product__r.revvy__Id__c, revvy__PriceField1__c, revvy__PriceField2__c, revvy__PriceField3__c
				FROM revvy__MnPriceListLine__c  WHERE revvy__PriceList__c = :priceListId AND (REVVY__Start_Date__c <= TODAY AND REVVY__End_Date__c > TODAY)];
			system.debug('ToroContractPriceListPPHelper--plis='+plis);
			for(revvy__MnPriceListLine__c ppl : plis) {
				prodPriceListLineMap.put(ppl.revvy__product__r.revvy__Id__c, ppl);		
			}
			system.debug('ToroContractPriceListPPHelper--prodPriceListLineMap='+prodPriceListLineMap);
			for(Revvy__MnStrategy4__c qi : quoteItemList) {
				if(prodPriceListLineMap.containsKey(qi.Product_Id__c)) {
					revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qi.Product_Id__c);
					//qi.MSRP_Price__c = ppl.revvy__ListedPrice__c;
					//qi.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
					if(retrieveAwardPrice(ppl) != null) {
						qi.Award_price__c = retrieveAwardPrice(ppl);//ppl.revvy__PriceField1__c;
						qi.OnlyExistedInCPL__c= false;	
					} else {
						if(!qi.Unit_Award_Overridden__c) {
							qi.Award_price__c = 0;
						}
						qi.OnlyExistedInCPL__c= true;
						qi.Rebate_as_a_of_DN__c=0;
					}
					system.debug('ToroContractPriceListPPHelper test-- qi product = ' + qi.Product_Id__c + '  --- ' +qi.Award_price__c );
					
				} else {
					if(!qi.Unit_Award_Overridden__c) {
						qi.Award_price__c = 0;
					}
					qi.OnlyExistedInCPL__c= true;
					system.debug('ToroContractPriceListPPHelper-- qi not in price list--' + qi.Product_Id__c);
				}
				system.debug('ToroContractPriceListPPHelper--product = ' + qi.Product_Name__c + '  -OnlyExistedInCPL__c-- ' + qi.OnlyExistedInCPL__c);
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(prodPriceListLineMap.containsKey(qis.Product_Id__c)) {
							revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qis.Product_Id__c);
							//qis.MSRP_Price__c = ppl.revvy__ListedPrice__c;
							//qis.DNet_Price__c = ppl.revvy__SuggestedPrice__c;	
							decimal awardPrice = retrieveAwardPrice(ppl);
							if(awardPrice != null) {
								system.debug('model id = ' + qis.Product_Id__c + ' award price =' + awardPrice);
								qis.Award_price__c = awardPrice;
								qis.OnlyExistedInCPL__c= false;	
							} else {
								if(!qis.Unit_Award_Overridden__c) {
									qis.Award_price__c = 0;
								}
								qis.OnlyExistedInCPL__c= true;
								qis.Rebate_as_of_DNet__c=0;
							}
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- ' +awardPrice + '--OnlyExistedInCPL__c=' + qis.OnlyExistedInCPL__c );
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- award price ' +qis.Award_price__c + ' overridden flag='+ qis.Unit_Award_Overridden__c );
						} else {
							qis.OnlyExistedInCPL__c= true;
							if(!qis.Unit_Award_Overridden__c) {
								qis.Award_price__c = 0;
							}
							system.debug('ToroContractPriceListPPHelper test-- qis product = ' + qis.Product_Name__c + '  --- award price ' +qis.Award_price__c );
						}
						system.debug('ToroContractPriceListPPHelper--product = ' + qis.Product_Name__c + '  -OnlyExistedInCPL__c-- ' + qis.OnlyExistedInCPL__c);			
					}
				}	
			}
		}
		return 	quoteItemList;															
	}     
								
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgramExternalId,
		 				String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList) {
		quoteItems = loadPricesFromPricelist(priceProgramExternalId, quoteItemList);
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgramExternalId)};
		decimal gpPercent = 0;
		for(Revvy__MnStrategy1__c rh : rebates) {
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					gpPercent = l.Distributor_Margin__c;		
				}
			}
		} 	 
		
		system.debug('Distributor_Margin__c = ' + gpPercent);
		for(Revvy__MnStrategy4__c qi : quoteItems) {
			qi.Toro_Com_Dollar__c = 0;
			qi.award_price__c = CMnQuoteUtil.defaultDecimal(qi.award_price__c);
			if(!qi.OnlyExistedInCPL__c) {
				qi.Toro_Gross_Profit_Percent__c = gpPercent;
				qi.Toro_Gross_Profit_Value__c = qi.award_price__c * qi.Toro_Gross_Profit_Percent__c/100;
				qi.Commission__c = qi.Toro_Gross_Profit_Percent__c;
				qi.Commission_Dollar__c = qi.Toro_Gross_Profit_Value__c;
				system.debug('qi.Toro_Gross_Profit_Percent__c =' + qi.Toro_Gross_Profit_Percent__c);	
			} else {
				qi.Toro_Gross_Profit_Value__c =(qi.award_price__c-qi.dnet_price__c)*CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				if(qi.award_price__c != null && qi.award_price__c != 0 && qi.Adjusted_Quantity__c != null && qi.Adjusted_Quantity__c != 0) {
					qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/(qi.award_price__c*CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c)) * 100;	
				}
				qi.Commission__c = 0;
				qi.Commission_Dollar__c = 0;
			}
			
			qi.Toro_Com_Dollar__c += qi.Commission_Dollar__c;
			decimal rebate = qi.DNet_Price__c - qi.award_price__c + qi.Toro_Gross_Profit_Value__c;
			system.debug('qi.rebate =' + rebate);
			if(!qi.OnlyExistedInCPL__c) {
				qi.Toro_Rebate__c = rebate * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
			} else {
				qi.Toro_Rebate__c = 0;
			}
			system.debug('qi =' + qi);
			qi.PricingMethodValue__c='';
			if(qi.award_price__c != 0 && qi.dnet_price__c != null && qi.dnet_price__c != 0) {
				qi.Rebate_as_a_of_DN__c = rebate/qi.dnet_price__c * 100;
				system.debug('rebate %=' + qi.Rebate_as_a_of_DN__c);
			} else {
				system.debug('ToroContractPriceListPPHelper---------qi.product_name__c=' + qi.product_name__c);
			}
			if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
				qi.Award_of_DN__c = qi.award_price__c/qi.DNet_Price__c*100;
			}
			if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
				qi.Off_MSRP__c = (1-qi.award_price__c/qi.MSRP_Price__c)*100;
			}
			system.debug('Distributor_Margin__c = ' + qi.Toro_Gross_Profit_Percent__c);
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);	
					qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					if(!qis.OnlyExistedInCPL__c) {
						qis.Gross_Profit_Percent__c = gpPercent;	
						qis.Gross_Profit_Value__c = (qis.Award_Price__c *CMnQuoteUtil.defaultDecimal(qis.Gross_Profit_Percent__c)/100) * extQty;
						qis.Commission__c = qis.Gross_Profit_Percent__c;
						qis.Commission_Dollar__c = qis.Gross_Profit_Value__c;
					} else {
						qis.Gross_Profit_Value__c = (qis.Award_Price__c - qis.DNet_Price__c)*extQty;
						try {
							qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c / (qis.Award_Price__c*extQty) * 100 ;
						}catch (Exception e) {
							system.debug(logginglevel.warn, e.getMessage() + e.getStackTraceString());
						}
						qis.Commission__c = 0;
						qis.Commission_Dollar__c = 0;					
					}
					qi.Toro_Com_Dollar__c += qis.Commission_Dollar__c;
					qis.PricingMethodValue__c='';
					system.debug('-------qis.Award_Price__c=' + qis.Award_Price__c + ' -- qis.Gross_Profit_Percent__c=' + qis.Gross_Profit_Percent__c);
						
					if(!qis.OnlyExistedInCPL__c) {
						decimal qisRebate = qis.DNet_Price__c * extQty - qis.award_price__c *extQty  + qis.Gross_Profit_Value__c;	
						qis.Toro_Subline_Rebate__c = qisRebate;	
						try{
							qis.Rebate_as_of_DNet__c = qisRebate/(qis.dnet_price__c*extQty) *100;	
						} catch (Exception e) {
							system.debug(logginglevel.warn, e.getMessage() + e.getStackTraceString());
							system.debug('ToroContractPriceListPPHelper---------qis.product_name__c=' + qis.product_name__c + ' product id=' + qis.product_Id__c);
						}
					} else {
						qis.Toro_Subline_Rebate__c=0;
						qis.Rebate_as_of_DNet__c = 0;
					}
					
					if(qis.DNet_Price__c != null && qis.DNet_Price__c!=0){
						qis.Percent_of_DNet__c = qis.award_price__c/qis.DNet_Price__c*100;	
					}
					if(qis.MSRP_Price__c !=null && qis.MSRP_Price__c !=0) {
						qis.Percent_Off_MSRP__c = (1-qis.award_price__c/qis.MSRP_Price__c)*100;
					}
					system.debug('Distributor_Margin__c = ' + qis.Gross_Profit_Percent__c);
				}
			}
		}	
		return quoteItems;		
	}
	
	public override List<Revvy__MnStrategy4__c> calculateExtendedFields(List<Revvy__MnStrategy4__c> quoteItemList) {
		decimal quoteMSRP=0;
		decimal quoteTotalAward =0;
		decimal quoteTotalToroAward=0;
		decimal quoteTotalDNet =0;
		decimal quoteTotalSetupFee=0;
		decimal quoteToroTotalDNet=0;
		decimal quoteTotalGP=0;
		decimal quoteTotalRebate=0;
		decimal quoteTotalDnetWOTppAllied = 0;
		decimal quoteTPPAppliedDNet = 0;
		decimal quoteToroDNet = 0;
		decimal quoteTPPAppliedMSRP = 0;
		decimal quoteToroMSRP = 0;
        decimal quoteTPPAppliedAward = 0;
		decimal quoteToroAward = 0;
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
			qi.Toro_Total_Setup_Fees__c = 0;
			decimal qiTotalDNet=0;
			decimal qiTotalMSRP=0;
			decimal qiTotalAward=0;
			decimal qiTPPAppliedDNet = 0;
			decimal qiToroDNet = 0;
			decimal qiTPPAppliedMSRP = 0;
			decimal qiToroMSRP = 0;
        	decimal qiTPPAppliedAward = 0;
			decimal qiToroAward = 0;
			qi.Total_Award__c =0;
			qi.Total_Toro_Award__c=0;
			qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			qi.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c);
			qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
			qi.Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_DNet_Price__c);
			qi.Extended_MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_MSRP_Price__c);
			qi.Rebate_as_a_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c);
			qi.Total_Toro_Award__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_Award__c);
			qi.Total_Toro_MSRP__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_MSRP__c);
			qi.Total_DNET__c = CMnQuoteUtil.defaultDecimal(qi.Total_DNET__c);
			qi.Total_Toro_Award__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_Award__c);
			qi.Total_Toro_DNET__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_DNET__c);
			qi.Toro_Total_Rebate__c=CMnQuoteUtil.defaultDecimal(qi.Toro_Total_Rebate__c);
				
			system.debug('check total award for each qi -- 1 qi.award price= ' + qi.award_price__c );
			
			if(!qi.Exclude_from_Rebate_F__c) {
				qiToroDNet = qi.DNet_Price__c * qi.Adjusted_Quantity__c;	
				qiToroMSRP = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiToroAward = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiToroAward;
				qi.Extended_DNet_Price__c = qiToroDNet;
				qi.Extended_MSRP_Price__c = qiToroMSRP;
			} else {
				qiTPPAppliedDNet = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedMSRP = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedAward = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiTPPAppliedAward;
				qi.Extended_DNet_Price__c = qiToroDNet;
				qi.Extended_MSRP_Price__c = qiToroMSRP;
			}
			qiTotalDNet = qiToroDNet + qiTPPAppliedDNet;
			qiTotalMSRP = qiToroMSRP + qiTPPAppliedMSRP;
			qiTotalAward = qiToroAward + qiTPPAppliedAward; 		
			qi.Total_Award__c = qiTotalAward;
			decimal extRebate = CMnQuoteUtil.defaultDecimal(qi.Toro_Rebate__c);
			
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
					if(!qis.Exclude_from_Rebate_F__c) {
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
					if(!qis.Exclude_from_Rebate_F__c) {
						extRebate = extRebate + CMnQuoteUtil.defaultDecimal(qis.Toro_Subline_Rebate__c);
					} 
					System.debug('Product =' + qis.product_Name__c + ' rebate = ' + qis.Toro_Subline_Rebate__c + ' exc=' + qis.Exclude_from_Rebate_F__c + ' rebate total =' + extRebate);
					qi.Total_Award__c = qiTotalAward + qisRollupToroAward+ qisRollupTPPAppliedAward;
					system.debug('check total award for each qi -- 1 qi.Total_Award__c= ' + qi.Total_Award__c + ' qiTotalAward='+qiTotalAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);
					qi.Total_Toro_Award__c = qi.Total_Award__c - qisRollupTPPAppliedAward - qiTPPAppliedAward; 
					system.debug('check total award for each qi -- 1 qi.Total_Toro_Award__c= ' + qi.Total_Toro_Award__c + ' qiTPPAppliedAward='+qiTPPAppliedAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);
					qi.Total_MSRP__c = qiTotalMSRP + qisRollupToroMSRP+ qisRollupTPPAppliedMSRP;
					qi.Total_Toro_MSRP__c = qi.Total_MSRP__c - qisRollupTPPAppliedMSRP - qiTPPAppliedMSRP; 
					qi.Total_DNET__c = qiTotalDNET + qisRollupToroDNET+ qisRollupTPPAppliedDNET;
					qi.Total_Toro_DNET__c = qi.Total_DNET__c - qisRollupTPPAppliedDNET - qiTPPAppliedDNET; 
				}
			}
			
			
			
			qi.Toro_Total_Rebate__c = extRebate;
			//qi.Toro_Total_Extended_Award_Price__c = extAward;
			//qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			//qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			if(qi.Total_Toro_MSRP__c != 0) {
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
		quote.Commission_Dollar__c = quote.Toro_Total_Quote_Gross_Profit__c;
		quote.Commission__c = quote.Toro_Total_Quote_Gross_Profit_Percent__c;
		System.debug('\n\n@@quote: ' + quote + '\n\n');
		return quoteItemList;
	}    
}