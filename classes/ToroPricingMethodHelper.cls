public with sharing class ToroPricingMethodHelper {
	private static Map<String, Map<decimal, ToroPricingMethodData> >DNetPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >();     
	private static Map<String, Map<decimal, ToroPricingMethodData> >GPPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >(); 
	public List<Toro_QuoteItem__c> quoteItemList { get; set;}
	public String pricingProgramExternalId { get; set;}
	public ToroPricingMethodHelper() {		
	}
	public decimal setMSRPAwardPrice(Toro_QuoteItem_SubLine__c qis) {
		if(!qis.Unit_Award_Overridden__c) {
			system.debug('check point 1');
			if(qis.Product_Id__c.startsWith('TPP') || qis.Product_Id__c.startsWith('L0') || qis.Product_Id__c.startsWith('L1')) {
				system.debug('check point 2');
				qis.Award_Price__c = qis.MSRP_Price__c;
			} else {
				system.debug('check point 3');
				qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * (1-(qis.Percent_Off_MSRP__c/100));
			}
		}
		return qis.Award_Price__c;	
	}
	public decimal setDNetAwardPrice(Toro_QuoteItem_SubLine__c qis) {
		if(!qis.Unit_Award_Overridden__c) {
			system.debug('check point 1');
			if(qis.Product_Id__c.startsWith('TPP') || qis.Product_Id__c.startsWith('L0') || qis.Product_Id__c.startsWith('L1')) {
				system.debug('check point 2');
				qis.Award_Price__c = qis.MSRP_Price__c;
			} else {
				system.debug('check point 3');
				qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c)/100;
			}
		}
		return qis.Award_Price__c;	
	}
	
	public ToroPricingMethodHelper calculateBlendedDNetPercentFromMSRP() {
		Map<Id, decimal> retMap = new Map<Id, decimal>();
		
		for (Toro_QuoteItem__c qi : quoteItemList) {
			
			if(qi.Off_MSRP__c != null) {
				//qi.PricingMethodValue__c = string.valueOf(qi.Off_MSRP__c);
				decimal extDNet = 0;
				decimal extAward = 0;
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) *(1-CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100);
				} 
				extDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				extAward = qi.Award_Price__c * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				qi.Award_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) *(1-CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100)/qi.DNet_Price__c * 100;
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item ' + qi.Product_Name__c + ' -- ' + qi.Product_Name__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item --MSRP-- ' + qi.MSRP_Price__c + '--DNet--' + qi.DNet_Price__c + '--qty--' + qi.Quantity__c);
				
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qis.Toro_Extended_Qty__c = extQty;
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_Off_MSRP__c == null) {
								qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;
								//qis.PricingMethodValue__c = string.valueOf(qis.Percent_Off_MSRP__c);
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP --' + qis.Percent_Off_MSRP__c);
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) ) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) );
							extDNet += qis.Toro_DNet_Price__c * extQty;
							qis.Award_Price__c = setMSRPAwardPrice(qis);
							extAward += qis.Award_Price__c * extQty;
							qis.Percent_of_DNet__c = qis.Award_Price__c /qis.Toro_DNet_Price__c*100;
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- extDNet = ' + extDNet);			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- extAward = ' + extAward);							
						} else {
							qis.Award_Price__c = setMSRPAwardPrice(qis);	
						}	
					}	
					
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- total extDNet = ' + extDNet );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- total award = ' + extAward);				
				}
				if(extDNet != null && extDNet !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(extAward) / extDNet * 100;
					//qi.Award_of_DN__c = qi.Toro_Blend_Of_DN__c;
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP 123 -- quote item Toro_Blend_Of_DN__c = ' + qi.Toro_Blend_Of_DN__c + ' --Award_of_DN__c-- ' + qi.Award_of_DN__c );
					retrieveRebate(qi.Toro_Blend_Of_DN__c, qi);
				}
			}
		}
		
		
		return this;			
	}
	public ToroPricingMethodHelper calculateBlendedDNetPercentFromDNet() {
		Map<Id, decimal> retMap = new Map<Id, decimal>();
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.Award_of_DN__c != null) {
				//qi.PricingMethodValue__c = string.valueOf(qi.Award_of_DN__c);
				decimal extDNet = 0;
				decimal extAward = 0;
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100;										
				} 
				qi.Off_MSRP__c = (1 - qi.Award_Price__c/qi.MSRP_Price__c)*100;
				extDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item ' + qi.Product_Name__c + ' -- ' + qi.Product_Name__c + '% off msrp=' + qi.Off_MSRP__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item --DNet-- ' + qi.Award_of_DN__c + '--DNet--' + qi.DNet_Price__c + '--qty--' + qi.Quantity__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item product- ' + qi.Product_Name__c + ' award =' + qi.Award_Price__c);
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --DNet=' + qis.DNet_Price__c + ' MSRP=' + qis.MSRP_Price__c);
						qis.Toro_Extended_Qty__c = extQty;
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_of_DNet__c == null) {
								qis.Percent_of_DNet__c = qi.Award_of_DN__c;
								//qis.PricingMethodValue__c = string.valueOf(qis.Percent_of_DNet__c);
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --' + qis.Percent_of_DNet__c);
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c)) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c));
							qis.Award_Price__c = setDNetAwardPrice(qis);
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet -- qis.Award_Price__c' + (qis.Award_Price__c*extQty) + ' qis.MSRP_Price__c =' + qis.MSRP_Price__c +'-----'+qis.product_Id__c);
							qis.Percent_Off_MSRP__c = (1 - qis.Award_Price__c/qis.MSRP_Price__c)*100;
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --' + qis.Percent_of_DNet__c + ' % off msrp=' + qis.Percent_Off_MSRP__c);
							extDNet += qis.Toro_DNet_Price__c*extQty;
							extAward += qis.Award_Price__c*extQty;
							
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- qis.extDNet = ' + extDNet);			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- qis.extAward = ' + extAward );							
						} else {
							qis.Award_Price__c = setDNetAwardPrice(qis);	
						}	
					}	
					
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item extDNet = ' + extDNet );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item extAward = ' + extAward  );				
				}
				if(extDNet != null && extDNet !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(extAward) / extDNet * 100;
					retrieveRebate(qi.Toro_Blend_Of_DN__c, qi);
					//qi.PricingMethodValue__c = string.valueOf(qi.Award_of_DN__c);
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item Toro_Blend_Of_DN__c = ' + qi.Toro_Blend_Of_DN__c + ' --Award_of_DN__c-- ' + qi.Award_of_DN__c );
				}
			}
		}
		
		return this;			
	}
	public ToroPricingMethodHelper calculateGP() {
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.Award_of_DN__c != null) {
				//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
				decimal extDnet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				decimal extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_of_DNet__c == null) {
								qis.Percent_of_DNet__c = qi.Award_of_DN__c;
							}
							final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
							decimal subExtDNet = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty;
							decimal subExtAward = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100 * extQty;
							extDnet += subExtDNet;
							extAward += subExtAward;
							qis.Gross_Profit_Value__c = subExtAward - subExtDNet + (subExtDNet * qis.Rebate_as_of_DNet__c/100);	
							qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c/subExtAward*100;	
							//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;	
						}	
					}	
				}
				if(extDnet != null && extDnet !=0) {
					qi.Award_of_DN__c = extAward/extDnet*100;
				}
				qi.Toro_Gross_Profit_Value__c = extAward - extDnet + extDnet * qi.Rebate_as_a_of_DN__c/100;	
				if(extAward != null && extAward != 0) {
					qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/extAward*100;	
				}
			}
			
		}	
		
		return this;
	}
	
	public ToroPricingMethodHelper calculateExtensionFields() {
		/*
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
			//decimal extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			//award price has been calculated in calling function
			decimal extAward = qi.Award_price__c * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			decimal extMSRP = CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);			 
			qi.Toro_Rebate__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Rebate_as_a_of_DN__c/100;
			qi.Toro_Extended_DNet_Price__c = extDnet;
			decimal extRebate = qi.Toro_Rebate__c;
			qi.Toro_Gross_Profit_Value__c = extAward - extDnet + extDnet * qi.Rebate_as_a_of_DN__c/100;	
			if(extAward != null && extAward != 0) {
				qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/extAward*100;	
			}
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c)) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c));
						decimal subExtDNet = qis.Toro_DNet_Price__c* extQty;
						decimal subExtAward = qis.Award_Price__c * extQty;
						decimal subExtMSRP = qis.MSRP_Price__c * extQty;
						qis.Toro_Extended_DNET_Price__c = subExtDNet;
						qis.Toro_Extended_MSRP_Price__c = subExtMSRP;
						qis.Toro_Extended_Award_Price__c = subExtAward;
						extDnet += subExtDNet;
						extAward += subExtAward;
						extMSRP += subExtMSRP;
						qis.Gross_Profit_Value__c = subExtAward - subExtDNet + (subExtDNet * qis.Rebate_as_of_DNet__c/100);	
						qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c/subExtAward*100;	
						qis.Toro_Subline_Rebate__c = qis.Toro_DNet_Price__c * extQty *qis.Rebate_as_of_DNet__c/100;
						extRebate += qis.Toro_Subline_Rebate__c;
						qis.Toro_Extended_Award_Price__c = subExtAward;
						//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;	
					}	
				}	
			}
			
			qi.Toro_Total_Extended_Award_Price__c = extAward;
			qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			qi.Toro_Total_MSRP_Percentage__c = 100 - (extAward/extMSRP)*100;
			qi.Toro_Total_Rebate__c = extRebate;
			qi.Total_Gross_Profit_Value__c = extAward - extDnet + extRebate; 
			
			qi.Total_Gross_Profit_Percent__c = qi.Total_Gross_Profit_Value__c/extAward*100; 
			system.debug('PM helper calculateExtensionFields');
			quoteTotalAward 			+= qi.Toro_Total_Extended_Award_Price__c;
			quoteToroTotalAward       	+= qi.Toro_Total_Extended_Award_Price__c;
			quoteTotalDNet              += qi.Toro_Total_Extended_DNet_Price__c;
			quoteToroTotalDNet          += qi.Toro_Total_Extended_DNet_Price__c;
			quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			quoteTotalRebate       		+= qi.Toro_Total_Rebate__c;
			quoteTotalRebate            += qi.Toro_Total_Rebate__c;
			quoteTotalDnetWOTppAllied   += qi.Toro_Total_Extended_Award_Price__c;
			
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
		*/
		return this;
	}
	
	public ToroPricingMethodHelper retrieveRebate(decimal dnetPercent, Toro_QuoteItem__c qi) {
		if(!DNetPercentMap.containsKey(pricingProgramExternalId)) {
			Toro_PricingProgram__c pp = ToroCacheManager.getPricingProgram(pricingProgramExternalId);
			List<Toro_PricingProgramLine__c> pplList = pp.PricingProgramLines__r;
		    Map<decimal, ToroPricingMethodData> dnet2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Toro_PricingProgramLine__c  ppl : pplList) {
		    	ToroPricingMethodData pmd = new ToroPricingMethodData();
		    	
		    	dnet2PM.put((ppl.Award_Price_as_a_Percent_of_DN__c).setScale(5, roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, null));	
		    }
			DNetPercentMap.put(pricingProgramExternalId, dnet2PM);	
		}
		system.debug(logginglevel.info, 'retrievePricingInfoForDNet-- DNetPercentMap=' + DNetPercentMap);		
		dnetPercent = dnetPercent.setScale(5, roundingMode.HALF_UP);
		System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnetPercent = ' + dnetPercent  );
		System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent) = ' + (DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent))  );
		if(DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent)) {
			qi.Rebate_as_a_of_DN__c = DNetPercentMap.get(pricingProgramExternalId).get(dnetPercent).rebatePercent;
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- qi.Rebate_as_a_of_DN__c ='  + qi.Rebate_as_a_of_DN__c);
		} else if(DNetPercentMap.containsKey(pricingProgramExternalId)) {
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- no exact match'); 
			ToroPricingMethodData topRow = null;
			ToroPricingMethodData bottomRow = null;
			//conver dnetPercent to percent format
			Map<decimal, ToroPricingMethodData> dnet2PMMap = DNetPercentMap.get(pricingProgramExternalId);
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[0].percentOfDNet ='  + dnet2PMMap.values()[0].percentOfDNet);
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet ='  + dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet);
			if(dnetPercent >= dnet2PMMap.values()[0].percentOfDNet) {
				qi.Rebate_as_a_of_DN__c = dnet2PMMap.values()[0].rebatePercent;
				System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- cap at max ' + qi.Rebate_as_a_of_DN__c  ); 
			} else if(dnetPercent <= dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet){
				qi.Rebate_as_a_of_DN__c = dnet2PMMap.values()[dnet2PMMap.values().size()-1].rebatePercent;
				System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- cap at min ' + qi.Rebate_as_a_of_DN__c  );
			} else {
				for(integer i=0; i < dnet2PMMap.values().size()-1; i++) {
					//system.debug(logginglevel.info,'------------dnet2PMMap.values()[i]----------' + dnet2PMMap.values()[i]);
					system.debug(dnetPercent + '---' + dnet2PMMap.values()[i].percentOfDNet + '---' + dnet2PMMap.values()[i+1].percentOfDNet);
					if(dnetPercent < dnet2PMMap.values()[i].percentOfDNet && dnetPercent > dnet2PMMap.values()[i+1].percentOfDNet ) {
						topRow = dnet2PMMap.values()[i];
						bottomRow = dnet2PMMap.values()[i+1];
						break;
					}	
				}  
				if(topRow != null && bottomRow != null) {
					decimal x1=topRow.percentOfDNet/100;
					decimal x2=bottomRow.percentOfDNet/100;
					decimal y1=topRow.rebatePercent/100;
					decimal y2=bottomRow.rebatePercent/100;
					decimal x3 = dnetPercent/100;
					decimal rebatePercent  = y2 -(((x3-x2)*(y2-y1)) * 100);
					
					system.debug(logginglevel.info,'retrievePricingInfoForDNet---x1----' + x1 + '  x2= ' + x2 + ' y1=' + y1 + ' y2=' + y2 + 'x3=' + x3 + ' ' + rebatePercent);
					qi.Rebate_as_a_of_DN__c = rebatePercent*100;
				}   
				System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- calculated ' + qi.Rebate_as_a_of_DN__c  );       
			}
		}
		System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- Rebate_as_a_of_DN__c ' + qi.Rebate_as_a_of_DN__c  );  
		//set all sublines' rebate % as quote item's
		if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
			for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
				if(!qis.Exclude_from_Rebate__c) {
					qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;					
				}	
			}	
		}
				
		return this;
	} 
	
	private decimal lookupDNetPercentFromGPPercent(decimal gpPercent) {
		decimal dnetPercent = null;
		gpPercent = gpPercent.setScale(5, roundingMode.HALF_UP);
		system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent gpPercent = ' + gpPercent);
		system.debug('GPPercentMap.containsKey(pricingProgramExternalId)=' + GPPercentMap.containsKey(pricingProgramExternalId));
		system.debug('GPPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + GPPercentMap.get(pricingProgramExternalId).get(gpPercent));
		if(GPPercentMap.containsKey(pricingProgramExternalId) && GPPercentMap.get(pricingProgramExternalId).containsKey(gpPercent)) {
			dnetPercent = GPPercentMap.get(pricingProgramExternalId).get(gpPercent).percentOfDNet;	
			system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent match found dnetPercent= ' + dnetPercent);
		} else {
			system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent match not found dnetPercent= ' + dnetPercent);
			if(GPPercentMap.containsKey(pricingProgramExternalId)) {
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---');
				ToroPricingMethodData topRow = null;
				ToroPricingMethodData bottomRow = null;
				Map<decimal, ToroPricingMethodData> gp2Map = GPPercentMap.get(pricingProgramExternalId);
				ToroPricingMethodData upperBound = gp2Map.values()[0];
				ToroPricingMethodData lowerBound = gp2Map.values()[gp2Map.values().size()-1];
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---upperBound=' + upperBound);
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---lowerBound=' + lowerBound);
				if(gpPercent > upperBound.grossProfitPercent) {					
					dnetPercent = upperBound.percentOfDNet;
					system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---found upper bound=' + dnetPercent);
				} else if(gpPercent < lowerBound.grossProfitPercent) {
					dnetPercent = lowerBound.percentOfDNet;	
					system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---found lower bound=' + dnetPercent);
				} else {
					for(integer i=0; i < gp2Map.values().size()-1; i++) {
						if(gpPercent < gp2Map.values()[i].grossProfitPercent && gpPercent > gp2Map.values()[i+1].grossProfitPercent ) {
							topRow = gp2Map.values()[i];
							bottomRow = gp2Map.values()[i+1];
							break;
						}	
					}    
					
					system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent --- lower bound=' + topRow);
					system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent --- upper bound=' + bottomRow);
					if(topRow != null && bottomRow != null) {
						decimal x1 = topRow.grossProfitPercent/100;
						decimal x2 = bottomRow.grossProfitPercent/100;
						decimal x3 = gpPercent/100;
						system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---x1 = ' + x1 + ' - x2= ' + x2 + ' -x3= ' + x3);
						//Calculate  Percent Adjustment Amount (PAA)
						decimal paa = 1-((x1 - x2)-(x1 - x3))/(x1 - x2);
						system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---paa=' + paa);
						//gpPercentResult = gpPercentResult * 100;	 
						decimal gpDNetResult = topRow.percentOfDNet/100 - (topRow.percentOfDNet/100 - bottomRow.percentOfDNet/100) * paa;
						system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---gpDNetResult=' + gpDNetResult);
						dnetPercent = gpDNetResult*100;
					}   
				}            	
			}
		}
		return dnetPercent;	
	}
	public ToroPricingMethodHelper convertGPPercentToDNetPercent() {
		system.debug(logginglevel.info, 'convertGPPercentToDNetPercent--');
		if(!GPPercentMap.containsKey(pricingProgramExternalId)) {
			Toro_PricingProgram__c pp = ToroCacheManager.getPricingProgram(pricingProgramExternalId);
			List<Toro_PricingProgramLine__c> pplList = pp.PricingProgramLines__r;
		    Map<decimal, ToroPricingMethodData> gpp2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Toro_PricingProgramLine__c  ppl : pplList) {
		    	ToroPricingMethodData pmd = new ToroPricingMethodData();		    	
		    	gpp2PM.put((ppl.Distributor_Margin__c).setScale(5, roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, null));	
		    }
			GPPercentMap.put(pricingProgramExternalId, gpp2PM);	
		}
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.Toro_Gross_Profit_Percent__c != null) {
				system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi gp%=' + qi.Toro_Gross_Profit_Percent__c);
				qi.Award_of_DN__c = lookupDNetPercentFromGPPercent(qi.Toro_Gross_Profit_Percent__c);
				system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi Award_of_DN__c=' + qi.Award_of_DN__c);
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = qi.DNet_Price__c * qi.Award_of_DN__c/100;
				}
				qi.Off_MSRP__c = (1-qi.Award_Price__c/qi.MSRP_Price__c)*100 ;
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(!qis.Exclude_from_Rebate__c && qis.Gross_Profit_Percent__c != null) {
							qis.Percent_of_DNet__c = lookupDNetPercentFromGPPercent(qis.Gross_Profit_Percent__c);
							system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qis.Percent_of_DNet__c=' +qis.Percent_of_DNet__c);
							qis.Award_Price__c = setDNetAwardPrice(qis);
							qis.Percent_Off_MSRP__c = (1-qis.Award_Price__c/qi.MSRP_Price__c)*100 ;
							
						} else {
							qis.Award_Price__c = setDNetAwardPrice(qis);	
						}	
					}	
				}
			}
		}
		return this;
	}  
	
	public ToroPricingMethodHelper convertAwardPriceToDNetPercent() {
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
				qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c * 100;
			}
			qi.Toro_Extended_DNet_Price__c = qi.DNet_Price__c * qi.Quantity__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						if(qis.DNet_Price__c != null && qis.DNet_Price__c != 0) {
							qis.Percent_of_DNet__c = qis.Award_Price__c / qis.DNet_Price__c * 100;
						}
						final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						qis.Toro_Extended_Qty__c = extQty;
						qis.Toro_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty;
						//Toro_Extended_MSRP_Price__c
					}	
				}	
			}
		}
		return this;	
	} 
	
	public static List<Toro_QuoteItem__c> distributeTotalAwardDollors(List<Toro_QuoteItem__c> quoteItemList, decimal totalAwardDollors) {
		decimal totalToroDNetPrice = 0;
		for (Toro_QuoteItem__c qi : quoteItemList) {
			decimal qiExtDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
			system.debug(logginglevel.info, 'distributeTotalAwordDollors qi dnet  =' + qiExtDNet);
			qi.Toro_Extended_DNet_Price__c = qi.DNet_Price__c * qi.Quantity__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						qis.Toro_Extended_Qty__c = extQty;
						decimal qisExtDNet = (qis.TPP_Line_Item__c == true) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
						system.debug(logginglevel.info, 'distributeTotalAwordDollors qis dnet  =' + qisExtDNet);
						qis.Toro_DNet_Price__c = qisExtDNet;
						qiExtDNet += qis.Toro_DNet_Price__c;
						system.debug(logginglevel.info, 'distributeTotalAwordDollors qi qiExtDNet  =' + qiExtDNet);
						//qis.Toro_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty;
						//qi.Toro_Rollup_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_DNet_Price__c) + CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					}	
				}	
			}
			//qi.Toro_DNetWOTPPAllied__c = qi.Toro_Extended_DNet_Price__c + qi.Toro_Rollup_DNet_Price__c;
			qi.Toro_DNetWOTPPAllied__c = qiExtDNet;
			system.debug(logginglevel.info, 'distributeTotalAwordDollors Toro_DNetWOTPPAllied__c  =' + qi.Toro_DNetWOTPPAllied__c);
			//totalToroDNetPrice += qi.Toro_DNetWOTPPAllied__c;
			totalToroDNetPrice += qiExtDNet;
			system.debug(logginglevel.info, 'distributeTotalAwordDollors totalToroDNetPrice  =' + totalToroDNetPrice);
		}
		
		system.debug(logginglevel.info, 'distributeTotalAwordDollors totalToroDNetPrice  =' + totalToroDNetPrice);
		for (Toro_QuoteItem__c qi : quoteItemList) {
			qi.Award_Price__c = (totalAwardDollors * (qi.DNet_Price__c * qi.Quantity__c /totalToroDNetPrice)/qi.Quantity__c); //.setScale(2,roundingMode.HALF_UP);
			qi.PricingMethodValue__c = string.valueOf(qi.Award_Price__c.setScale(2, roundingMode.HALF_UP));
			system.debug(logginglevel.info, 'distributeTotalAwordDollors qi product   =' + qi.product_name__c + 'qi product id   =' + qi.product_id__c + ' qi.Award_Price__c=' + qi.Award_Price__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						
						final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						qis.Award_Price__c = totalAwardDollors * (qis.Toro_DNet_Price__c /totalToroDNetPrice)/extQty;
						//qis.Award_Price__c = qis.Award_Price__c.setScale(2,roundingMode.HALF_UP);
						system.debug(logginglevel.info, 'distributeTotalAwordDollors qis product   =' + qis.product_name__c + 'qis product id   =' + qis.product_id__c + ' qis award price =' + qis.Award_Price__c);
					} else {
						qis.Award_Price__c = 0;
					}	
					qis.PricingMethodValue__c = string.valueOf(qis.Award_Price__c.setScale(2, roundingMode.HALF_UP));
				}	
			}
		}
		
		return quoteItemList;	
	} 
	
}