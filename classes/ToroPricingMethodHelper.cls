public with sharing class ToroPricingMethodHelper {
	private static Map<String, Map<decimal, ToroPricingMethodData> >DNetPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >();     
	private static Map<String, Map<decimal, ToroPricingMethodData> >GPPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >(); 
	public List<Toro_QuoteItem__c> quoteItemList { get; set;}
	public String pricingProgramExternalId { get; set;}
	public ToroPricingMethodHelper() {		
	}
	
	public ToroPricingMethodHelper calculateBlendedDNetPercentFromMSRP() {
		Map<Id, decimal> retMap = new Map<Id, decimal>();
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.Off_MSRP__c != null) {
				//qi.PricingMethodValue__c = string.valueOf(qi.Off_MSRP__c);
				qi.Toro_Rollup_Award_MSRP_Price__c =0;
				qi.Toro_Rollup_DNet_Price__c =0;
				qi.Toro_Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				qi.Toro_Extended_Award_MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) *(1-CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
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
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
							qi.Toro_Rollup_DNet_Price__c += qis.Toro_DNet_Price__c;
							qis.Toro_Extended_MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * (1-(qis.Percent_Off_MSRP__c)/100) * extQty;
							qi.Toro_Rollup_Award_MSRP_Price__c += qis.Toro_Extended_MSRP_Price__c;
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- qis.Toro_DNet_Price__c = ' + qis.Toro_DNet_Price__c + ' --qis.Toro_Extended_MSRP_Price__c-- ' + qis.Toro_Extended_MSRP_Price__c );			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- qi.Toro_Rollup_Award_MSRP_Price__c = ' + qi.Toro_Rollup_Award_MSRP_Price__c );							
						}	
					}	
					qi.Toro_Extended_Award_MSRP_Price__c += qi.Toro_Rollup_Award_MSRP_Price__c;
					qi.Toro_Extended_DNet_Price__c += qi.Toro_Rollup_DNet_Price__c;
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Rollup_Award_MSRP_Price__c = ' + qi.Toro_Rollup_Award_MSRP_Price__c + ' --Toro_Rollup_DNet_Price__c-- ' + qi.Toro_Rollup_DNet_Price__c );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Extended_Award_MSRP_Price__c = ' + qi.Toro_Extended_Award_MSRP_Price__c + ' --Toro_Rollup_DNet_Price__c-- ' + qi.Toro_Rollup_DNet_Price__c );				
				}
				if(qi.Toro_Extended_DNet_Price__c != null && qi.Toro_Extended_DNet_Price__c !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Toro_Extended_Award_MSRP_Price__c) / qi.Toro_Extended_DNet_Price__c * 100;
					qi.Award_of_DN__c = qi.Toro_Blend_Of_DN__c;
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Blend_Of_DN__c = ' + qi.Toro_Blend_Of_DN__c + ' --Award_of_DN__c-- ' + qi.Award_of_DN__c );
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
				qi.Toro_Rollup_Award_Dnet_Price__c =0;
				qi.Toro_Rollup_DNet_Price__c =0;
				qi.Toro_Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				qi.Toro_Extended_Award_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Quantity__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item ' + qi.Product_Name__c + ' -- ' + qi.Product_Name__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item --DNet-- ' + qi.Award_of_DN__c + '--DNet--' + qi.DNet_Price__c + '--qty--' + qi.Quantity__c);
				
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						qis.Toro_Extended_Qty__c = extQty;
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_of_DNet__c == null) {
								qis.Percent_of_DNet__c = qi.Award_of_DN__c;
								//qis.PricingMethodValue__c = string.valueOf(qis.Percent_of_DNet__c);
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP --' + qis.Percent_of_DNet__c);
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
							qi.Toro_Rollup_DNet_Price__c += qis.Toro_DNet_Price__c;
							qis.Toro_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100 * extQty;
							qi.Toro_Rollup_Award_DNet_Price__c += qis.Toro_DNet_Price__c;
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- qis.Toro_DNet_Price__c = ' + qis.Toro_DNet_Price__c + ' --qis.Toro_Extended_MSRP_Price__c-- ' + qis.Toro_DNet_Price__c );			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- qi.Toro_Rollup_Award_MSRP_Price__c = ' + qi.Toro_Rollup_Award_DNet_Price__c );							
						}	
					}	
					qi.Toro_Extended_Award_DNet_Price__c += qi.Toro_Rollup_Award_DNet_Price__c;
					qi.Toro_Extended_DNet_Price__c += qi.Toro_Rollup_DNet_Price__c;
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Rollup_Award_DNet_Price__c = ' + qi.Toro_Rollup_Award_DNet_Price__c + ' --Toro_Rollup_DNet_Price__c-- ' + qi.Toro_Rollup_DNet_Price__c );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Extended_Award_DNet_Price__c = ' + qi.Toro_Extended_Award_DNet_Price__c + ' --Toro_Rollup_DNet_Price__c-- ' + qi.Toro_Rollup_DNet_Price__c );				
				}
				if(qi.Toro_Extended_DNet_Price__c != null && qi.Toro_Extended_DNet_Price__c !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Toro_Extended_Award_DNet_Price__c) / qi.Toro_Extended_DNet_Price__c * 100;
					qi.Award_of_DN__c = qi.Toro_Blend_Of_DN__c;
					qi.PricingMethodValue__c = string.valueOf(qi.Award_of_DN__c);
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item Toro_Blend_Of_DN__c = ' + qi.Toro_Blend_Of_DN__c + ' --Award_of_DN__c-- ' + qi.Award_of_DN__c );
				}
			}
		}
		
		return this;			
	}
	public ToroPricingMethodHelper calculateGP() {
		for (Toro_QuoteItem__c qi : quoteItemList) {
			if(qi.Award_of_DN__c != null) {
				qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
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
							qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qis.Percent_of_DNet__c/100;	
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
	
	public ToroPricingMethodHelper retrievePricingInfoForDNet() {
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
		
		for(Toro_QuoteItem__c qi : quoteItemList) {
			decimal dnetPercent = qi.Award_of_DN__c.setScale(5, roundingMode.HALF_UP);
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
				dnetPercent = dnetPercent;
				Map<decimal, ToroPricingMethodData> dnet2PMMap = DNetPercentMap.get(pricingProgramExternalId);
				System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[0].percentOfDNet ='  + dnet2PMMap.values()[0].percentOfDNet);
				System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet ='  + dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet);
				if(dnetPercent > dnet2PMMap.values()[0].percentOfDNet) {
					qi.Rebate_as_a_of_DN__c = dnet2PMMap.values()[0].rebatePercent;
					System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- cap at max ' + qi.Rebate_as_a_of_DN__c  ); 
				} else if(dnetPercent < dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet){
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
						decimal rebatePercent  = y2 -(((x3-x2)*(y2-y1)));
						
						system.debug(logginglevel.info,'retrievePricingInfoForDNet---x1----' + x1 + '  x2= ' + x2 + ' y1=' + y1 + ' y2=' + y2 + 'x3=' + x3 + ' ' + rebatePercent);
						qi.Rebate_as_a_of_DN__c = rebatePercent*100;
					}   
					System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- calculated ' + qi.Rebate_as_a_of_DN__c  );       
				}
			}
			qi.Rebate_as_a_of_DN__c = qi.Rebate_as_a_of_DN__c;
			System.debug(logginglevel.info, 'retrievePricingInfoForDNet-- Rebate_as_a_of_DN__c ' + qi.Rebate_as_a_of_DN__c  );  
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;					
					}	
				}	
			}
				
		}
		
		return this;
	} 
	
	private decimal lookupDNetPercentFromGPPercent(decimal gpPercent) {
		decimal dnetPercent = null;
		gpPercent = gpPercent.setScale(5, roundingMode.HALF_UP);
		system.debug('GPPercentMap.containsKey(pricingProgramExternalId)=' + GPPercentMap.containsKey(pricingProgramExternalId));
		system.debug('GPPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + GPPercentMap.get(pricingProgramExternalId).get(gpPercent));
		if(GPPercentMap.containsKey(pricingProgramExternalId) && GPPercentMap.get(pricingProgramExternalId).containsKey(gpPercent)) {
			dnetPercent = GPPercentMap.get(pricingProgramExternalId).get(gpPercent).percentOfDNet;	
		} else {
			if(GPPercentMap.containsKey(pricingProgramExternalId)) {
				ToroPricingMethodData topRow = null;
				ToroPricingMethodData bottomRow = null;
				Map<decimal, ToroPricingMethodData> gp2Map = GPPercentMap.get(pricingProgramExternalId);
				ToroPricingMethodData upperBound = gp2Map.values()[0];
				ToroPricingMethodData lowerBound = gp2Map.values()[gp2Map.values().size()-1];
				if(gpPercent > upperBound.grossProfitPercent) {
					dnetPercent = upperBound.percentOfDNet;
				} else if(gpPercent < lowerBound.grossProfitPercent) {
					dnetPercent = lowerBound.percentOfDNet;	
				} else {
					for(integer i=0; i < gp2Map.values().size()-1; i++) {
						if(gpPercent < gp2Map.values()[i].grossProfitPercent && gpPercent > gp2Map.values()[i+1].grossProfitPercent ) {
							topRow = gp2Map.values()[i];
							bottomRow = gp2Map.values()[i+1];
							break;
						}	
					}    
					
					if(topRow != null && bottomRow != null) {
						decimal x1 = topRow.grossProfitPercent/100;
						decimal x2 = bottomRow.grossProfitPercent/100;
						decimal x3 = gpPercent/100;
						system.debug(x1 + ' - ' + x2 + ' - ' + x3);
						//Calculate  Percent Adjustment Amount (PAA)
						decimal paa = 1-((x1 - x2)-(x1 - x3))/(x1 - x2);
						system.debug('gpPercentResult=' + paa);
						//gpPercentResult = gpPercentResult * 100;	 
						decimal gpDNetResult = topRow.percentOfDNet/100 - (topRow.percentOfDNet/100 - bottomRow.percentOfDNet/100) * paa;
						system.debug('gpDNetResult=' + gpDNetResult);
						dnetPercent = gpDNetResult*100;
					}   
				}            	
			}
		}
		return dnetPercent;	
	}
	public ToroPricingMethodHelper convertGPPercentToDNetPercent() {
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
				qi.Award_of_DN__c = lookupDNetPercentFromGPPercent(qi.Toro_Gross_Profit_Percent__c);
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(!qis.Exclude_from_Rebate__c && qis.Gross_Profit_Percent__c != null) {
							qis.Percent_of_DNet__c = lookupDNetPercentFromGPPercent(qis.Gross_Profit_Percent__c);
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
					}	
				}	
			}
		}
		return this;	
	} 
	
	public static List<Toro_QuoteItem__c> distributeTotalAwordDollors(List<Toro_QuoteItem__c> quoteItemList, decimal totalAwardDollors) {
		decimal totalToroDNetPrice = 0;
		for (Toro_QuoteItem__c qi : quoteItemList) {
			qi.Toro_Extended_DNet_Price__c = qi.DNet_Price__c * qi.Quantity__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						qis.Toro_Extended_Qty__c = extQty;
						qis.Toro_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty;
						qi.Toro_Rollup_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_DNet_Price__c) + CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					}	
				}	
			}
			qi.Toro_DNetWOTPPAllied__c = qi.Toro_Extended_DNet_Price__c + qi.Toro_Rollup_DNet_Price__c;
			totalToroDNetPrice += qi.Toro_DNetWOTPPAllied__c;
		}
		
		system.debug(logginglevel.info, 'totalToroDNetPrice  =' + totalToroDNetPrice);
		for (Toro_QuoteItem__c qi : quoteItemList) {
			qi.Award_Price__c = (totalAwardDollors * (qi.DNet_Price__c * qi.Quantity__c /totalToroDNetPrice)).setScale(2,roundingMode.HALF_UP);
			system.debug(logginglevel.info, 'qi product   =' + qi.product_name__c + 'qi product id   =' + qi.product_id__c + ' qi.Award_Price__c=' + qi.Award_Price__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						
						final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						qis.Award_Price__c = totalAwardDollors * (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty /totalToroDNetPrice);
						qis.Award_Price__c = qis.Award_Price__c.setScale(2,roundingMode.HALF_UP);
						system.debug(logginglevel.info, 'qis product   =' + qis.product_name__c + 'qis product id   =' + qis.product_id__c + ' qis award price =' + qis.Award_Price__c);
					} else {
						qis.Award_Price__c = 0;
					}	
				}	
			}
		}
		
		return quoteItemList;	
	} 
	
}