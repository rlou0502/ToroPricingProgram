public with sharing class ToroPricingMethodUtil {
	private static Map<String, Map<decimal, ToroPricingMethodData> >GPPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >(); 
	private static Map<String, Map<decimal, ToroPricingMethodData> >DNetPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >(); 
	private static Map<String, Map<decimal, ToroPricingMethodData> >MSRPPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >();
	static map<Id, List<Toro_PricingProgramLine__c>> pricingProgramLinesMap = new map<Id, List<Toro_PricingProgramLine__c>>();
	public static ToroPricingMethodData retrieveDataForGrossProfitPercent(String pricingProgramExternalId, decimal MSRPPrice, decimal dnetPrice,  decimal gpPercent) {
		ToroPricingMethodData returnData = null;
		if(!GPPercentMap.containsKey(pricingProgramExternalId)) {
			List<Toro_PricingProgramLine__c> pplList = [Select Id, Award_Price_as_a_Percent_of_DN__c, Distributor_Margin__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId order by Distributor_Margin__c desc];
		    Map<decimal, ToroPricingMethodData> gp2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Toro_PricingProgramLine__c  ppl : pplList) {
		    	gp2PM.put((ppl.Distributor_Margin__c/100).setScale(5,roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, dnetPrice));	
		    }
			GPPercentMap.put(pricingProgramExternalId, gp2PM);		
		}
		
		
		gpPercent = gpPercent.setScale(5, roundingMode.HALF_UP);
		system.debug('GPPercentMap.containsKey(pricingProgramExternalId)=' + GPPercentMap.containsKey(pricingProgramExternalId));
		system.debug('GPPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + GPPercentMap.get(pricingProgramExternalId).get(gpPercent));
		if(GPPercentMap.containsKey(pricingProgramExternalId) && GPPercentMap.get(pricingProgramExternalId).containsKey(gpPercent)) {
			return GPPercentMap.get(pricingProgramExternalId).get(gpPercent);	
		}
		if(GPPercentMap.containsKey(pricingProgramExternalId)) {
			ToroPricingMethodData topRow = null;
			ToroPricingMethodData bottomRow = null;
			Map<decimal, ToroPricingMethodData> gp2Map = GPPercentMap.get(pricingProgramExternalId);
			ToroPricingMethodData upperBound = gp2Map.values()[0];
			ToroPricingMethodData lowerBound = gp2Map.values()[gp2Map.values().size()-1];
			if(gpPercent > upperBound.grossProfitPercent) {
				return upperBound;
			}
			if(gpPercent < lowerBound.grossProfitPercent) {
				return lowerBound;	
			}
			for(integer i=0; i < gp2Map.values().size()-1; i++) {
				if(gpPercent < gp2Map.values()[i].grossProfitPercent && gpPercent > gp2Map.values()[i+1].grossProfitPercent ) {
					topRow = gp2Map.values()[i];
					bottomRow = gp2Map.values()[i+1];
					break;
				}	
			}    
			
			if(topRow != null && bottomRow != null) {
				decimal x1 = topRow.grossProfitPercent;
				decimal x2 = bottomRow.grossProfitPercent;
				decimal x3 = gpPercent;
				system.debug(x1 + ' - ' + x2 + ' - ' + x3);
				decimal gpPercentResult = 1-((x1 - x2)-(x1 - x3))/(x1 - x2);
				system.debug('gpPercentResult=' + gpPercentResult);
				//gpPercentResult = gpPercentResult * 100;	 
				decimal gpDNetResult = topRow.percentOfDNet - (topRow.percentOfDNet - bottomRow.percentOfDNet) * gpPercentResult;
				system.debug('gpDNetResult=' + gpDNetResult);
				gpDNetResult = gpDNetResult.setScale(5, roundingMode.HALF_UP);
				returnData = retrieveDataForDNetPercent(pricingProgramExternalId, MSRPPrice, dnetPrice, gpDNetResult);
			}               	
		}
		 
		return returnData;
	}  
	public static ToroPricingMethodData retrieveDataForMSRPPercent(String pricingProgramExternalId, decimal MSRPPrice, decimal dnetPrice,  decimal msrpPercent) {
		system.debug('msrpPercent percent=' + msrpPercent);
		ToroPricingMethodData returnData = null;
		if(!MSRPPercentMap.containsKey(pricingProgramExternalId)) {
			List<Toro_PricingProgramLine__c> pplList = [Select Id, Award_Price_as_a_Percent_of_DN__c, Distributor_Margin__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId order by Off_Mfg_Sugg_Ttl__c asc];
		    Map<decimal, ToroPricingMethodData> msrp2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Toro_PricingProgramLine__c  ppl : pplList) {
		    	msrp2PM.put((ppl.Off_Mfg_Sugg_Ttl__c/100).setScale(5,roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, dnetPrice));	
		    }
			MSRPPercentMap.put(pricingProgramExternalId, msrp2PM);	
			system.debug(MSRPPercentMap);	
		}
		msrpPercent = msrpPercent.setScale(5,roundingMode.HALF_UP);
		system.debug('MSRPPercentMap.containsKey(pricingProgramExternalId)=' + MSRPPercentMap.containsKey(pricingProgramExternalId));
		system.debug('MSRPPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + MSRPPercentMap.get(pricingProgramExternalId).get(msrpPercent));
		if(MSRPPercentMap.containsKey(pricingProgramExternalId) && MSRPPercentMap.get(pricingProgramExternalId).containsKey(msrpPercent)) {
			system.debug('return-----' + MSRPPercentMap.get(pricingProgramExternalId).get(msrpPercent));
			return MSRPPercentMap.get(pricingProgramExternalId).get(msrpPercent);	
		}
		decimal awardPrice = MSRPPrice*(1-msrpPercent);
		decimal dnetPercent = awardPrice/dnetPrice;
		dnetPercent = dnetPercent.setScale(5, roundingMode.HALF_UP);
		returnData = retrieveDataForDNetPercent(pricingProgramExternalId, MSRPPrice, dnetPrice, dnetPercent);               	
		 
		return returnData;
	} 
	
	public static List<Toro_QuoteItem__c> distributeTotalAwordDollors(String pricingProgramExternalId, List<Toro_QuoteItem__c> quoteItemList, decimal totalAwardDollors) {
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
	 
	public static List<Toro_QuoteItem__c> applyTotalAwordDollors(String pricingProgramExternalId, List<Toro_QuoteItem__c> quoteItemList, decimal totalAwardDollors) {
		/*
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
		*/
		//system.debug(logginglevel.info, 'totalToroDNetPrice  =' + totalToroDNetPrice);
		for (Toro_QuoteItem__c qi : quoteItemList) {
			//qi.Award_Price__c = totalAwardDollors * (qi.DNet_Price__c * qi.Quantity__c /totalToroDNetPrice);
			//system.debug(logginglevel.info, 'qi.Award_Price__c  =' + qi.Award_Price__c);
			system.debug(logginglevel.info, 'qi product   =' + qi.product_name__c);
			qi.Unit_Award_Overridden__c=true;
			ToroPricingMethodData qiPMData = retrieveDataForAwardPrice(pricingProgramExternalId, qi.MSRP_Price__c, qi.DNet_Price__c, qi.Award_Price__c);
			qi.Award_of_DN__c=qiPMData.percentOfDNet;
			qi.Rebate_as_a_of_DN__c=qiPMData.rebatePercent;
			qi.Off_MSRP__c=qiPMData.percentOfMSRP;
			qi.Toro_Gross_Profit_Percent__c=qiPMData.grossProfitPercent;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						system.debug(logginglevel.info, 'qis product   =' + qis.product_name__c + 'qis product id   =' + qis.product_id__c);
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						//qis.Award_Price__c = totalAwardDollors * (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty /totalToroDNetPrice);
						qis.Unit_Award_Overridden__c=true;
						ToroPricingMethodData qisPMData = retrieveDataForAwardPrice(pricingProgramExternalId, qis.MSRP_Price__c, qis.DNet_Price__c, qis.Award_Price__c);
						qis.Percent_of_DNet__c=qiPMData.percentOfDNet;
						qis.Rebate_as_of_DNet__c=qiPMData.rebatePercent;
						qis.Percent_Off_MSRP__c=qiPMData.percentOfMSRP;
						qis.Gross_Profit_Percent__c=qiPMData.grossProfitPercent;
					}	
				}	
			}
		}
		
		return quoteItemList;	
	} 
	public static List<Toro_QuoteItem__c> applyGPPercent(String pricingProgramExternalId, List<Toro_QuoteItem__c> quoteItemList, decimal gpPercent) {
		for (Toro_QuoteItem__c qi : quoteItemList) {
			ToroPricingMethodData qiPMData = retrieveDataForGrossProfitPercent(pricingProgramExternalId, qi.MSRP_Price__c, qi.DNet_Price__c, qi.Toro_Gross_Profit_Percent__c);
			qi.Award_of_DN__c=qiPMData.percentOfDNet;
			qi.Rebate_as_a_of_DN__c=qiPMData.rebatePercent;
			qi.Off_MSRP__c=qiPMData.percentOfMSRP;
			qi.Toro_Gross_Profit_Percent__c=qiPMData.grossProfitPercent;
			qi.Award_Price__c = qiPMData.awardPrice;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {					
						ToroPricingMethodData qisPMData = retrieveDataForGrossProfitPercent(pricingProgramExternalId, qis.MSRP_Price__c, qis.DNet_Price__c, qis.Gross_Profit_Percent__c);
						qis.Percent_of_DNet__c=qiPMData.percentOfDNet;
						qis.Rebate_as_of_DNet__c=qiPMData.rebatePercent;
						qis.Percent_Off_MSRP__c=qiPMData.percentOfMSRP;
						qis.Gross_Profit_Percent__c=qiPMData.grossProfitPercent;
						qis.Award_Price__c = qiPMData.awardPrice;
					}	
				}	
			}
		}		
		return quoteItemList;	
	} 
	public static ToroPricingMethodData retrieveDataForAwardPrice(String pricingProgramExternalId, decimal MSRPPrice, decimal dnetPrice,  decimal awardPrice) {
		system.debug(logginglevel.info, 'retrieveDataForAwardPrice pricingProgramExternalId =' + pricingProgramExternalId + ' MSRPPrice =' + MSRPPrice + ' dnetPrice= ' + dnetPrice + ' awardPrice=' + awardPrice);
		ToroPricingMethodData returnData = null;
		
		if(dnetPrice != 0) {
			decimal dnetPercent = awardPrice/dnetPrice;
			dnetPercent = dnetPercent.setScale(5, roundingMode.HALF_UP);
			system.debug(logginglevel.info, 'dnetPercent=' + dnetPercent);
			returnData = retrieveDataForDNetPercent(pricingProgramExternalId, MSRPPrice, dnetPrice, dnetPercent); 
		} 
		              	 
		return returnData;
	}   
	public static ToroPricingMethodData retrieveDataForDNetPercent(String pricingProgramExternalId, decimal MSRPPrice, decimal dnetPrice,  decimal dnetPercent) {
		system.debug('dnet percent=' + dnetPercent + ' MSRP price =' + MSRPPrice);
		ToroPricingMethodData returnData = null;
		if(!DNetPercentMap.containsKey(pricingProgramExternalId)) {
			List<Toro_PricingProgramLine__c> pplList = [Select Id, Award_Price_as_a_Percent_of_DN__c, Distributor_Margin__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId order by Award_Price_as_a_Percent_of_DN__c desc];
		    Map<decimal, ToroPricingMethodData> dnet2PM = new Map<decimal, ToroPricingMethodData>();
		    for(Toro_PricingProgramLine__c  ppl : pplList) {
		    	dnet2PM.put((ppl.Award_Price_as_a_Percent_of_DN__c/100).setScale(5, roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
									ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, dnetPrice));	
		    }
			DNetPercentMap.put(pricingProgramExternalId, dnet2PM);	
			system.debug(DNetPercentMap);	
		}
		//system.debug(logginglevel.info,'DNetPercentMap.containsKey(pricingProgramExternalId)=' + DNetPercentMap.containsKey(pricingProgramExternalId));
		//system.debug(logginglevel.info,'DNetPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + DNetPercentMap.get(pricingProgramExternalId).get(dnetPercent));
		dnetPercent = dnetPercent.setScale(5, roundingMode.HALF_UP);
		if(DNetPercentMap.containsKey(pricingProgramExternalId) && DNetPercentMap.get(pricingProgramExternalId).containsKey(dnetPercent)) {
			return DNetPercentMap.get(pricingProgramExternalId).get(dnetPercent);	
		}
		//system.debug(logginglevel.info,'----------------------');
		if(DNetPercentMap.containsKey(pricingProgramExternalId)) {
			ToroPricingMethodData topRow = null;
			ToroPricingMethodData bottomRow = null;
			
			Map<decimal, ToroPricingMethodData> dnet2PMMap = DNetPercentMap.get(pricingProgramExternalId);
			if(dnetPercent > dnet2PMMap.values()[0].percentOfDNet) {
				return dnet2PMMap.values()[0];
			} else if(dnetPercent < dnet2PMMap.values()[dnet2PMMap.values().size()-1].percentOfDNet){
				return dnet2PMMap.values()[dnet2PMMap.values().size()-1];
			}
			//system.debug(logginglevel.info,'------------dnet2PMMap.values() size----------' + dnet2PMMap.values().size());
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
				decimal x1=topRow.percentOfDNet;
				decimal x2=bottomRow.percentOfDNet;
				decimal y1=topRow.rebatePercent;
				decimal y2=bottomRow.rebatePercent;
				decimal x3 = dnetPercent;
				decimal rebatePercent  = y2 -(((x3-x2)*(y2-y1)));
				//system.debug(logginglevel.info,'---dnetPrice----' + dnetPrice + '  dnetPercent=   ' + dnetPercent);
				decimal awardPrice = dnetPrice * dnetPercent;
				decimal msrpPercent = 0;
				if(MSRPPrice != null) {
					msrpPercent = (MSRPPrice - awardPrice)/MSRPPrice;	
				} else {
				}
				decimal rebate = dnetPrice * rebatePercent;
				decimal gpMargin = 1-((dnetPrice-rebate)/awardPrice);
				returnData = new ToroPricingMethodData(msrpPercent*100, dnetPercent*100,
									rebatePercent*100, gpMargin*100, dnetPrice);
			}               	
		}
		 
		return returnData;
	}   
	public static ToroPricingMethodData retrieveDataForDistributorMarginDollar(String pricingProgramExternalId, decimal dnetPrice, double gp) {
		ToroPricingMethodData returnData = null;
		ToroPricingMethodData topRow = null;
		ToroPricingMethodData bottomRow = null;
		
		if(!pricingProgramLinesMap.containsKey(pricingProgramExternalId)) {
			pricingProgramLinesMap.put(pricingProgramExternalId, [Select Id, Award_Price_as_a_Percent_of_DN__c, Distributor_Margin__c, Off_Mfg_Sugg_Ttl__c, Rebate_as_a_Percent_of_DN__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.ExternalId__c = :pricingProgramExternalId order by Distributor_Margin__c asc]);					    
		}
		List<Toro_PricingProgramLine__c> PricingProgramLines = pricingProgramLinesMap.get(pricingProgramExternalId);
		for(integer i=0; i < PricingProgramLines.size()-1; i++) {
			
			topRow = new ToroPricingMethodData(PricingProgramLines[i].Off_Mfg_Sugg_Ttl__c, PricingProgramLines[i].Award_Price_as_a_Percent_of_DN__c,
									PricingProgramLines[i].Rebate_as_a_Percent_of_DN__c, PricingProgramLines[i].Distributor_Margin__c, dnetPrice);
			bottomRow = new ToroPricingMethodData(PricingProgramLines[i+1].Off_Mfg_Sugg_Ttl__c, PricingProgramLines[i+1].Award_Price_as_a_Percent_of_DN__c,
								PricingProgramLines[i+1].Rebate_as_a_Percent_of_DN__c, PricingProgramLines[i+1].Distributor_Margin__c, dnetPrice);	
			if(gp == topRow.grossProfit) {
				return topRow;	
			} 
			if(gp < topRow.grossProfit && gp > bottomRow.grossProfit ) {
				break;
			}	
		}    
		
		if(topRow != null && bottomRow != null) {
			
			decimal rebatePercent = calculateRebatePercent(topRow, bottomRow, gp);
			decimal gpPercent = calculateGPPercent(topRow, bottomRow, gp);
			decimal percentOfDNet = calculatePercentOfDNet(topRow, bottomRow, gp);
			decimal percentOffMSRP = calculatePercentOffMSRP(topRow, bottomRow, gp);
			returnData = new ToroPricingMethodData(percentOffMSRP, percentOfDNet,
									percentOfDNet, percentOffMSRP, dnetPrice);
		}                 
		
		return returnData;
	}   
	public static decimal calculateRebatePercent(ToroPricingMethodData topRow, ToroPricingMethodData bottomRow, decimal gp) {
		/*
			X3	Rebate%		x3 = x1 + ( (x2-x1) * ( 1- ( (y3-y2)/(y1-y2) ) ) )			
			X1	Top Row Rebate %		7.40%			
			X2	Bottom Row Rebate %		8.00%			
			Y1	Top Row GP $		 $2,040 			
			Y2	Bottom Row GP $		 $2,000 			
			Y3	GP $		 $2,010 			
						
			X3 	Rebate%		7.85%			
		*/	
		decimal x1 = topRow.rebatePercent;
		decimal x2 = bottomRow.rebatePercent;
		decimal y1 = topRow.grossProfit;
		decimal y2 = bottomRow.grossProfit;
		decimal y3 = gp;
		return x1 + ((x2-x1)*(1-((y3-y2)/(y1-y2))));		
	}  
	public static decimal calculateGPPercent(ToroPricingMethodData topRow, ToroPricingMethodData bottomRow, decimal gp) {
		/*
			2b	Dist Margin % use Values from Top and Bottom to Calculate					
						
			X3	Dist Margin %		x3 = x1 + ( (x2-x1) * ( 1- ( (y3-y2)/(y1-y2) ) ) )			
			X1	Top Row % of Dnet		18.10%			
			X2	Bottom Row % of Dnet		17.90%			
			Y1	Top Row GP $		 $2,040 			
			Y2	Bottom Row GP $		 $2,000 			
			Y3	GP $		 $2,010 			
									
			X3 	Dist Margin %		17.95%					
		*/	
		decimal x1 = topRow.grossProfitPercent;
		decimal x2 = bottomRow.grossProfitPercent;
		decimal y1 = topRow.grossProfit;
		decimal y2 = bottomRow.grossProfit;
		decimal y3 = gp;
		return x1 + ((x2-x1)*(1-((y3-y2)/(y1-y2))));		
	}  
	public static decimal calculatePercentOfDNet(ToroPricingMethodData topRow, ToroPricingMethodData bottomRow, decimal gp) {
		/*
			2c	% of Dnet use Values from Top and Bottom to Calculate				
					
			X3	% of Dnet		x3 = x1 + ( (x2-x1) * ( 1- ( (y3-y2)/(y1-y2) ) ) )		
			X1	Top Row % of Dnet		113.00%		
			X2	Bottom Row % of Dnet		112.00%		
			Y1	Top Row GP $		 $2,040 		
			Y2	Bottom Row GP $		 $2,000 		
			Y3	GP $		 $2,010 		
								
			X3 	% of Dnet		112.25%						
		*/	
		decimal x1 = topRow.percentOfDNet;
		decimal x2 = bottomRow.percentOfDNet;
		decimal y1 = topRow.grossProfit;
		decimal y2 = bottomRow.grossProfit;
		decimal y3 = gp;
		return x1 + ((x2-x1)*(1-((y3-y2)/(y1-y2))));		
	}  
	public static decimal calculatePercentOffMSRP(ToroPricingMethodData topRow, ToroPricingMethodData bottomRow, decimal gp) {
		/*
			2d	% off MSRP use Values from Top and Bottom to Calculate				
					
			X3	% off MSRP		x3 = x1 + ( (x2-x1) * ( 1- ( (y3-y2)/(y1-y2) ) ) )		
			X1	Top Row % off MSRP		20.90%		
			X2	Bottom Row % off MSRP		21.60%		
			Y1	Top Row GP $		 $2,040 		
			Y2	Bottom Row GP $		 $2,000 		
			Y3	GP $		 $2,010 		
								
			X3 	% off MSRP		21.43%							
		*/	
		decimal x1 = topRow.percentOfMSRP;
		decimal x2 = bottomRow.percentOfMSRP;
		decimal y1 = topRow.grossProfit;
		decimal y2 = bottomRow.grossProfit;
		decimal y3 = gp;
		return x1 + ((x2-x1)*(1-((y3-y2)/(y1-y2))));		
	}  
}