public with sharing class ToroPricingMethodHelper {
	private static Map<String, Map<decimal, ToroPricingMethodData> >DNetPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >();     
	private static Map<String, Map<decimal, ToroPricingMethodData> >GPPercentMap = new Map<String, Map<decimal, ToroPricingMethodData> >(); 
	public List<Revvy__MnStrategy4__c> quoteItemList { get; set;}
	public String primaryPricingProgramExtId { get; set; }
	public String pricingProgramExternalId { get; set {pricingProgramExternalId=value; pricingProgramExternalIds.add(value);} }
	public Set<String> pricingProgramExternalIds {get; set; }
	public void addPricingProgramExtId(String extId) {
		pricingProgramExternalIds.add(extId);	
		pricingProgramExternalId = extId;
	}
	public REVVY__MnQuote__c quote { get; set; }
	public ToroPricingMethodHelper() {
		pricingProgramExternalIds=new Set<String>();		
	}
	public Revvy__MnStrategy5__c setMSRPAwardPrice(Revvy__MnStrategy5__c qis) {
		if(!qis.Unit_Award_Overridden__c) {
			system.debug('check point 1');
			if(qis.Product_Id__c.startsWith('TPP') || qis.Product_Id__c.startsWith('L0') || qis.Product_Id__c.startsWith('L1')) {
				system.debug('check point 2');
				qis.Award_Price__c = qis.MSRP_Price__c;
			} else {
				system.debug('check point 3');
				qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * (1-(qis.Percent_Off_MSRP__c/100));
			}
		} else {
			if(qis.Performance_Part__c != true) {
				if(qis.MSRP_Price__c != null && qis.MSRP_Price__c != 0) {
					qis.Percent_Off_MSRP__c = (1 - CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)/qis.MSRP_Price__c) * 100;
					System.debug(logginglevel.info, 'setMSRPAwardPrice-- subline ' + qis.Product_Name__c + ' -award=- ' + qis.Award_Price__c + ' qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
				}
			}
		}
		//System.debug(logginglevel.info, 'setMSRPAwardPrice-- subline ' + qis.Product_Name__c + ' -award=- ' + qis.Award_Price__c + ' qis.Unit_Award_Overridden__c=' + qis.Unit_Award_Overridden__c);
		return qis;	
	}
	public Revvy__MnStrategy5__c setDNetAwardPrice(Revvy__MnStrategy5__c qis) {
		if(!qis.Unit_Award_Overridden__c) {
			system.debug('check point 1');
			if(qis.Product_Id__c.startsWith('TPP') || qis.Product_Id__c.startsWith('L0') || qis.Product_Id__c.startsWith('L1')) {
				system.debug('check point 2');
				qis.Award_Price__c = qis.MSRP_Price__c;
			} else {
				system.debug('check point 3');
				qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c)/100;
			}
		} else {
			if(qis.Performance_Part__c != true) {
				if(qis.DNET_Price__c != null && qis.DNET_Price__c != 0) {
					qis.Percent_Of_DNET__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)/qis.DNET_Price__c * 100;
				}
			}
		}
		return qis;	
	}
	public ToroPricingMethodHelper calculateBlendedDNetPercentFromMSRP() {
		Map<Id, decimal> retMap = new Map<Id, decimal>();	
		decimal quoteDNet = 0;
		decimal quoteAward = 0;	
		for (Revvy__MnStrategy4__c qi : quoteItemList) {			
			if(qi.Off_MSRP__c != null) {
				//qi.PricingMethodValue__c = string.valueOf(qi.Off_MSRP__c);
				decimal extDNet = 0;
				decimal extAward = 0;
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) *(1-CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100);
				}  
				qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				extDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				extAward = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
					qi.Award_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) *(1-CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100)/qi.DNet_Price__c * 100;
				}
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item ' + qi.Product_Name__c + ' -- ' + qi.Product_Name__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- quote item --MSRP-- ' + qi.MSRP_Price__c + '--DNet--' + qi.DNet_Price__c + '--qty--' + qi.Adjusted_Quantity__c);
				
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);	
						qis.Toro_Extended_Qty__c = extQty;
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_Off_MSRP__c == null) {
								qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;
								//qis.PricingMethodValue__c = string.valueOf(qis.Percent_Off_MSRP__c);
							}
							qis.PricingMethodValue__c = string.valueOf(qis.Percent_Off_MSRP__c);
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP --' + qis.Percent_Off_MSRP__c);
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) ) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) );
							extDNet += qis.Toro_DNet_Price__c * extQty;
							system.debug(logginglevel.info,'checking % off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);
							qis = setMSRPAwardPrice(qis);
							system.debug(logginglevel.info,'checking % off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);
							extAward += qis.Award_Price__c * extQty;
							if(qis.Toro_DNet_Price__c != null && qis.Toro_DNet_Price__c != 0 ) {
								qis.Percent_of_DNet__c = qis.Award_Price__c /qis.Toro_DNet_Price__c*100;
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- extDNet = ' + extDNet);			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- extAward = ' + extAward);							
						} else {				
							qis = setMSRPAwardPrice(qis);	
						}	
						System.debug(logginglevel.info, 'setMSRPAwardPrice-- subline ' + qis);
						qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);
					}	
					
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- total extDNet = ' + extDNet );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP-- total award = ' + extAward);				
				}
				
				if(extDNet != null && extDNet !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(extAward) / extDNet * 100;
					//qi.Award_of_DN__c = qi.Toro_Blend_Of_DN__c;
					//System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromMSRP 123 -- quote item Toro_Blend_Of_DN__c = ' + qi.Toro_Blend_Of_DN__c + ' --Award_of_DN__c-- ' + qi.Award_of_DN__c );
					//retrieveRebate(qi.Toro_Blend_Of_DN__c, qi);
				}
				
				quoteDNet += extDNet;
				quoteAward += extAward;
			}	
		}
		if(quoteDNet != null && quoteDNet !=0 ) {
			quote.Toro_Blended_Percent_of_DN__c = CMnQuoteUtil.defaultDecimal(quoteAward) / quoteDNet * 100;
			//retrieveRebateForQuote(quote.Toro_Blended_Percent_of_DN__c);
		}
		return this;			
	}
	public ToroPricingMethodHelper calculateBlendedDNetPercentFromDNet() { 
		Map<Id, decimal> retMap = new Map<Id, decimal>();
		decimal quoteDNet = 0;
		decimal quoteAward = 0;	
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			if(qi.Award_of_DN__c != null) {
				//qi.PricingMethodValue__c = string.valueOf(qi.Award_of_DN__c);
				decimal extDNet = 0;
				decimal extAward = 0;
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100;										
				} else {
					if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
						qi.Award_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) / CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * 100;
					}
				}
				qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				if(qi.MSRP_Price__c != null && qi.MSRP_Price__c!=0){
					qi.Off_MSRP__c = (1 - qi.Award_Price__c/qi.MSRP_Price__c)*100;
				}
				extDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				extAward = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) *CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100 * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item ' + qi.Product_Name__c + ' -- ' + qi.Product_Name__c + '% off msrp=' + qi.Off_MSRP__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item --DNet-- ' + qi.Award_of_DN__c + '--DNet--' + qi.DNet_Price__c + '--qty--' + qi.Adjusted_Quantity__c);
				System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item product- ' + qi.Product_Name__c + ' award =' + qi.Award_Price__c);
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);	
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);	
						System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --DNet=' + qis.DNet_Price__c + ' MSRP=' + qis.MSRP_Price__c);
						qis.Toro_Extended_Qty__c = extQty;
						if(!qis.Exclude_from_Rebate__c) {
							if(qis.Percent_of_DNet__c == null) {
								qis.Percent_of_DNet__c = qi.Award_of_DN__c;
								//qis.PricingMethodValue__c = string.valueOf(qis.Percent_of_DNet__c);
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --' + qis.Percent_of_DNet__c);
							qis.Toro_DNet_Price__c  = (qis.Product_Id__c.startsWith('TPP')) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c)) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c));
							qis = setDNetAwardPrice(qis);
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet -- qis.Award_Price__c' + (qis.Award_Price__c*extQty) + ' qis.MSRP_Price__c =' + qis.MSRP_Price__c +'-----'+qis.product_Id__c);
							if(qis.MSRP_Price__c!= null && qis.MSRP_Price__c !=0) {
								qis.Percent_Off_MSRP__c = (1 - qis.Award_Price__c/qis.MSRP_Price__c)*100;
							}
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet --' + qis.Percent_of_DNet__c + ' % off msrp=' + qis.Percent_Off_MSRP__c);
							extDNet += qis.Toro_DNet_Price__c*extQty;
							extAward += qis.Award_Price__c*extQty;
							
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- qis.extDNet = ' + extDNet);			
							System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- qis.extAward = ' + extAward );							
						} else {
							qis = setDNetAwardPrice(qis);	
						}	
					}	
					
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item extDNet = ' + extDNet );
					System.debug(logginglevel.info, 'calculateBlendedDNetPercentFromDNet-- quote item extAward = ' + extAward  );				
				}
				if(extDNet != null && extDNet !=0 ) {
					qi.Toro_Blend_Of_DN__c = CMnQuoteUtil.defaultDecimal(extAward) / extDNet * 100;
				}
				quoteDNet += extDNet;
				quoteAward += extAward;
			}
		}
		if(quoteDNet != null && quoteDNet !=0 ) {
			quote.Toro_Blended_Percent_of_DN__c = CMnQuoteUtil.defaultDecimal(quoteAward) / quoteDNet * 100;
			//for (Revvy__MnStrategy4__c qi : quoteItemList) {
			//	retrieveRebateForQuoteItem(quote.Toro_Blended_Percent_of_DN__c, qi);	
			//}
			
		}
		return this;			
	}
	
	public ToroPricingMethodHelper retrieveRebatePercent() {
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			system.debug('qi.Pricing_Program__c = ' + qi.Pricing_Program__c);
			if(String.isBlank(qi.Pricing_Program__c)) {
				qi.Rebate_as_a_of_DN__c = 0;	
			} else {
				system.debug('qi.Pricing_Program__c = ' + qi.Pricing_Program__c);
				ToroPricingProgramData ppd = new ToroPricingProgramData(qi.Pricing_Program__c);
				system.debug('retrieveRebatePercent ppd=' + ppd  + ' qi.Award_of_DN__c=' + qi.Award_of_DN__c);
				qi.Rebate_as_a_of_DN__c = retrieveRebatePercentBasedOnBlendedDNet(qi, qi.Toro_Blend_Of_DN__c, ppd.externalId);
			}	
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;					
					}	
				}	
			}
		}	
		return this;
	}
	public decimal retrieveRebatePercentBasedOnBlendedDNet(Revvy__MnStrategy4__c qi, decimal dnetPercent, String ppExtId) {
		ToroSecondaryPricingProgram secondary = ToroPriceProgramFactory.getSecondaryPricingProgram(ppExtId);
		system.debug('secondary = ' + secondary);
		return secondary.retrieveRebatePercentBasedOnBlendedDNet(qi, dnetPercent, ppExtId, primaryPricingProgramExtId);
		
	} 
	
	
	private decimal lookupDNetPercentFromGPPercent(String ppExtId, decimal gpPercent) {
		decimal dnetPercent = null;
		gpPercent = gpPercent.setScale(5, roundingMode.HALF_UP);
		system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent gpPercent = ' + gpPercent);
		system.debug('GPPercentMap.containsKey(pricingProgramExternalId)=' + GPPercentMap.containsKey(ppExtId));
		system.debug('GPPercentMap.get(pricingProgramExternalId).get(msrpPercent)=' + GPPercentMap.get(ppExtId));
		
		if(GPPercentMap.get(ppExtId) != null && GPPercentMap.get(ppExtId).containsKey(gpPercent)) {
			dnetPercent = GPPercentMap.get(ppExtId).get(gpPercent).percentOfDNet;	
			system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent match found dnetPercent= ' + dnetPercent);
		} else {
			system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent match not found dnetPercent= ' + dnetPercent);
			if(GPPercentMap.containsKey(ppExtId)) {
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---');
				ToroPricingMethodData topRow = null;
				ToroPricingMethodData bottomRow = null;
				Map<decimal, ToroPricingMethodData> gp2Map = GPPercentMap.get(ppExtId);
				ToroPricingMethodData upperBound = gp2Map.values()[0];
				ToroPricingMethodData lowerBound = gp2Map.values()[gp2Map.values().size()-1];
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---upperBound=' + upperBound);
				system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---lowerBound=' + lowerBound);
				if(gpPercent > upperBound.grossProfitPercent) {		
					dnetPercent = ((100 - upperBound.rebatePercent) / (100-gpPercent))*100;			
					
					system.debug(logginglevel.info, 'lookupDNetPercentFromGPPercent ---found upper bound=' + dnetPercent);
				} else if(gpPercent < lowerBound.grossProfitPercent) {
					dnetPercent = ((100 - lowerBound.rebatePercent) / (100-gpPercent))*100;
					//dnetPercent = lowerBound.percentOfDNet;	
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
		for(String ppExtId : pricingProgramExternalIds) {
			system.debug('convertGPPercentToDNetPercent ppExtId=' + ppExtId);
			if(ppExtId != null && !GPPercentMap.containsKey(ppExtId)) {
				Revvy__MnStrategy1__c pp = ToroCacheManager.getPricingProgram(ppExtId);
				system.debug('convertGPPercentToDNetPercent pp=' + pp);
				List<Revvy__MnStrategy2__c> pplList = pp.PricingProgramLines__r;
			    Map<decimal, ToroPricingMethodData> gpp2PM = new Map<decimal, ToroPricingMethodData>();
			    for(Revvy__MnStrategy2__c  ppl : pplList) {
			    	ToroPricingMethodData pmd = new ToroPricingMethodData();		    	
			    	gpp2PM.put((ppl.Distributor_Margin__c).setScale(5, roundingMode.HALF_UP), new ToroPricingMethodData(ppl.Off_Mfg_Sugg_Ttl__c, ppl.Award_Price_as_a_Percent_of_DN__c,
										ppl.Rebate_as_a_Percent_of_DN__c, ppl.Distributor_Margin__c, null));	
			    }
				GPPercentMap.put(ppExtId, gpp2PM);	
			}
		}
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.PricingMethodValue__c = String.valueOf(qi.Toro_Gross_Profit_Percent__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//if(!qis.Off_MSRP_Overridden__c) {
					//	qis.Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Percent__c;	
					//}
					qis.PricingMethodValue__c = String.valueOf(qis.Gross_Profit_Percent__c);
				}	
			}
		}
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			if(qi.Toro_Gross_Profit_Percent__c != null) {
				system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi gp%=' + qi.Toro_Gross_Profit_Percent__c + ' product = ' + qi.product_Id__c);
				system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi.Pricing_Program__c=' + qi.Pricing_Program__c);
				if(String.isBlank(qi.Pricing_Program__c)) {
					qi.Pricing_Program__c=pricingProgramExternalId;
				}
                qi.DrivenByGP__c = true;
				qi.Award_of_DN__c = lookupDNetPercentFromGPPercent(qi.Pricing_Program__c, qi.Toro_Gross_Profit_Percent__c);
				system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi Award_of_DN__c=' + qi.Award_of_DN__c + ' Unit_Award_Overridden__c= ' + qi.Unit_Award_Overridden__c);
				if(!qi.Unit_Award_Overridden__c) {
					qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c)/100;
					system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qi qi.Award_Price__c=' + qi.Award_Price__c + ' Unit_Award_Overridden__c= ' + qi.Unit_Award_Overridden__c);
				}
				if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
					qi.Off_MSRP__c = (1-qi.Award_Price__c/qi.MSRP_Price__c)*100 ;
				}
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(!qis.Exclude_from_Rebate__c && qis.Gross_Profit_Percent__c != null) {
							qis.Percent_of_DNet__c = lookupDNetPercentFromGPPercent(qi.Pricing_Program__c, qis.Gross_Profit_Percent__c);
							system.debug(logginglevel.info, 'convertGPPercentToDNetPercent-- qis.Percent_of_DNet__c=' +qis.Percent_of_DNet__c);
							qis = setDNetAwardPrice(qis);
							qis.Percent_Off_MSRP__c = (1-qis.Award_Price__c/qi.MSRP_Price__c)*100 ;
							
						} else {
							qis = setDNetAwardPrice(qis);	
						}	
					}	
				}
			}
		}
		return this;
	}  
	
	public ToroPricingMethodHelper convertAwardPriceToDNetPercent() {
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
            qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
			if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
				qi.Award_of_DN__c = qi.Award_Price__c/qi.DNet_Price__c * 100;
			}
			qi.Extended_DNet_Price__c = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						if(qis.DNet_Price__c != null && qis.DNet_Price__c != 0) {
							qis.Percent_of_DNet__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c) / qis.DNet_Price__c * 100;
						}
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
						qis.Toro_Extended_Qty__c = extQty;
						qis.Toro_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty;
						//Toro_Extended_MSRP_Price__c
					}	
				}	
			}
		}
		return this;	
	} 
	
	public boolean isNonToroProduct(Revvy__MnStrategy4__c qi) {
		boolean ret = false;
		String productId = qi.Product_Id__c;
		if(productId.startsWith('L')) {
			ret = true;
		}
		return ret;
	}
	
	public ToroPricingMethodHelper distributeQuoteItemTotalAwardDollors() {
		system.debug('distributeQuoteItemTotalAwardDollors -----');
		
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			if(isNonToroProduct(qi)) {
				continue;
			}
			system.debug('distributeQuoteItemTotalAwardDollors -----product=' + qi.Product_Id__c);
			system.debug('distributeQuoteItemTotalAwardDollors -----qi.Off_MSRP_Overridden__c=' + qi.Off_MSRP_Overridden__c);
			if(String.isBlank(qi.PricingMethodValue__c) || decimal.valueOf(qi.PricingMethodValue__c) == 0) {
				qi.Award_Price__c = 0;
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.Award_Price__c=0;
					}
				}	
			}	
			
			if(!qi.Off_MSRP_Overridden__c) {
				continue;	
			}
			system.debug('distributeQuoteItemTotalAwardDollors -----');
			decimal qiExtDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
			system.debug('distributeQuoteItemTotalAwardDollors -----');
			qi.Extended_DNet_Price__c = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
			qi.Total_Toro_DNET__c = qi.Extended_DNet_Price__c;
			system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qi.Total_Toro_DNET__c  =' + qi.Total_Toro_DNET__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
						qis.Toro_Extended_Qty__c = extQty;
						decimal qisExtDNet = (qis.TPP_Line_Item__c == true) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
						
						qis.Toro_DNet_Price__c = qisExtDNet;
						qiExtDNet += qis.Toro_DNet_Price__c;
						qi.Total_Toro_DNET__c += qis.Toro_DNet_Price__c;
						system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qi qiExtDNet  =' + qiExtDNet);
					}	
					system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qi.Total_Toro_DNET__c  =' + qi.Total_Toro_DNET__c);
				}	
			}
		}
		
		
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			if(!qi.Off_MSRP_Overridden__c) {
				continue;	
			}
			system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qi.PricingMethodValue__c  =' + qi.PricingMethodValue__c);
			decimal totalAwardPrice = String.isNotBlank(qi.PricingMethodValue__c) ? decimal.valueOf(qi.PricingMethodValue__c) : 0;
			system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors totalAwardPrice  =' + totalAwardPrice);
			system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors ratio  =' + qi.DNet_Price__c * qi.Adjusted_Quantity__c /qi.Total_Toro_DNET__c);
			qi.Award_Price__c = (totalAwardPrice * (qi.DNet_Price__c * qi.Adjusted_Quantity__c /qi.Total_Toro_DNET__c)/qi.Adjusted_Quantity__c); //.setScale(2,roundingMode.HALF_UP);
			qi.PricingMethodValue__c = string.valueOf(qi.Award_Price__c.setScale(2, roundingMode.HALF_UP));
			system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qi product   =' + qi.product_name__c + 'qi product id   =' + qi.product_id__c + ' qi.Award_Price__c=' + qi.Award_Price__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
						qis.Award_Price__c = totalAwardPrice * (qis.Toro_DNet_Price__c /qi.Total_Toro_DNET__c)/extQty;
						//qis.Award_Price__c = qis.Award_Price__c.setScale(2,roundingMode.HALF_UP);
						system.debug(logginglevel.info, 'distributeQuoteItemTotalAwardDollors qis product   =' + qis.product_name__c + 'qis product id   =' + qis.product_id__c + ' qis award price =' + qis.Award_Price__c);
					} else {
						qis.Award_Price__c = 0;
					}	
					qis.PricingMethodValue__c = string.valueOf(qis.Award_Price__c.setScale(2, roundingMode.HALF_UP));
				}	
			}
		}
		
		return this;	
	} 
	
	public static List<Revvy__MnStrategy4__c> distributeTotalAwardDollors(List<Revvy__MnStrategy4__c> quoteItemList, decimal totalAwardDollors) {
		decimal totalToroDNetPrice = 0;
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			decimal qiExtDNet = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
			system.debug(logginglevel.info, 'distributeTotalAwordDollors qi dnet  =' + qiExtDNet);
			qi.Extended_DNet_Price__c = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
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
			qi.Total_Toro_Award__c = qiExtDNet;
			system.debug(logginglevel.info, 'distributeTotalAwordDollors Toro_DNetWOTPPAllied__c  =' + qi.Toro_DNetWOTPPAllied__c);
			//totalToroDNetPrice += qi.Toro_DNetWOTPPAllied__c;
			totalToroDNetPrice += qiExtDNet;
			system.debug(logginglevel.info, 'distributeTotalAwordDollors totalToroDNetPrice  =' + totalToroDNetPrice);
		}
		
		system.debug(logginglevel.info, 'distributeTotalAwordDollors totalToroDNetPrice  =' + totalToroDNetPrice);
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.Award_Price__c = (totalAwardDollors * (qi.DNet_Price__c * qi.Adjusted_Quantity__c /totalToroDNetPrice)/qi.Adjusted_Quantity__c); //.setScale(2,roundingMode.HALF_UP);
			qi.PricingMethodValue__c = string.valueOf(qi.Award_Price__c.setScale(2, roundingMode.HALF_UP));
			system.debug(logginglevel.info, 'distributeTotalAwordDollors qi product   =' + qi.product_name__c + 'qi product id   =' + qi.product_id__c + ' qi.Award_Price__c=' + qi.Award_Price__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate__c) {
						
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
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