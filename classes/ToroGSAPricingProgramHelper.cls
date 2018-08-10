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
			String priceListId = CMnQuoteUtil.getDefaultPriceList();
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
				qi.Rebate_as_a_of_DN__c=0;
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
						qis.Rebate_as_of_DNet__c=0;
						system.debug('ToroContractPriceListPPHelper--product = ' + qis.Product_Name__c + '  -OnlyExistedInCPL__c-- ' + qis.OnlyExistedInCPL__c);			
					}
				}	
			}
		}
		return 	quoteItemList;															
	}     
								
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgramExternalId,
		 				String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList) {
		system.debug('ToroGSAPricingProgramHelper calculateRebateMarginImpl entry point');
		quoteItems = loadPricesFromPricelist(priceProgramExternalId, quoteItemList);
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgramExternalId)};
		decimal gpPercent = 0;
		decimal rebatePercent = 0;
		boolean drivenByGP = false; 
		for(Revvy__MnStrategy1__c rh : rebates) {
			drivenByGP = rh.DrivenByGP__c;
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					if(drivenByGP) {
						gpPercent = l.Distributor_Margin__c;	
					} else {
						rebatePercent = l.Rebate_as_a_Percent_of_DN__c;
					}	
				}
			}
		} 	 
		
		system.debug('gsa checkpoint gpPercent = ' + gpPercent);
		system.debug('gsa checkpoint rebatePercent = ' + rebatePercent);
		system.debug('gsa checkpoint drivenByGP = ' + drivenByGP);
		for(Revvy__MnStrategy4__c qi : quoteItems) {
			qi.DrivenByGP__c = drivenByGP;
			qi.Toro_Com_Dollar__c = 0;
			qi.award_price__c = CMnQuoteUtil.defaultDecimal(qi.award_price__c);
			qi.Rebate_as_a_of_DN__c = rebatePercent;
			system.debug('gsa checkpoint gpPercent = ' + gpPercent);
			system.debug('gsa checkpoint rebatePercent = ' + rebatePercent);
			system.debug('gsa checkpoint qi.OnlyExistedInCPL__c = ' + qi.OnlyExistedInCPL__c);
			if(qi.DrivenByGP__c) {
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
				decimal rebate = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) - CMnQuoteUtil.defaultDecimal(qi.award_price__c) + CMnQuoteUtil.defaultDecimal(qi.Toro_Gross_Profit_Value__c);
				//decimal rebate=0;
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
			}
			if(qi.DNet_Price__c != null && qi.DNet_Price__c != 0) {
				qi.Award_of_DN__c = qi.award_price__c/qi.DNet_Price__c*100;
			}
			if(qi.MSRP_Price__c != null && qi.MSRP_Price__c != 0) {
				qi.Off_MSRP__c = (1-qi.award_price__c/qi.MSRP_Price__c)*100;
			}
			system.debug('gsa checkpoint drivenByGP = ' + qi.DrivenByGP__c);
			system.debug('gsa checkpoint Distributor_Margin__c = ' + qi.Toro_Gross_Profit_Percent__c);
			system.debug('gsa checkpoint Rebate_as_a_of_DN__c = ' + qi.Rebate_as_a_of_DN__c);
			
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);	
					qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					qis.Rebate_as_of_DNet__c = qi.Rebate_as_a_of_DN__c;
					if(qi.DrivenByGP__c) {
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
							qisRebate=0;
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
					} 
					if(qis.DNet_Price__c != null && qis.DNet_Price__c!=0){
						qis.Percent_of_DNet__c = qis.award_price__c/qis.DNet_Price__c*100;	
					}
					if(qis.MSRP_Price__c !=null && qis.MSRP_Price__c !=0) {
						qis.Percent_Off_MSRP__c = (1-qis.award_price__c/qis.MSRP_Price__c)*100;
					}
					system.debug('gsa checkpoint qis Gross_Profit_Percent__c = ' + qis.Gross_Profit_Percent__c);
					system.debug('gsa checkpoint qis drivenByGP = ' + qi.DrivenByGP__c);
					system.debug('gsa checkpoint qis Rebate_as_a_of_DN__c = ' + qis.Rebate_as_of_DNet__c);
				}
			}
		}	
		return quoteItems;		
	}
	
	public override List<Revvy__MnStrategy4__c> calculateExtendedFields(List<Revvy__MnStrategy4__c> quoteItemList) {
		quoteItemList = super.calculateExtendedFields(quoteItemList);
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.Toro_Com_Dollar__c = qi.Total_Gross_Profit_Value__c;
			qi.Commission__c = qi.Toro_Gross_Profit_Percent__c;
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Commission__c = qis.Gross_Profit_Percent__c;
					qis.Commission_Dollar__c = qis.Gross_Profit_Value__c;		
				}
			}
		}
		quote.Commission_Dollar__c = quote.Toro_Total_Quote_Gross_Profit__c;
		quote.Commission__c = quote.Toro_Total_Quote_Gross_Profit_Percent__c;
		quoteItemList = overrideCommissions(quoteItemList);
		return quoteItemList;
	}    
	public virtual List<Revvy__MnStrategy4__c> overrideCommissions(List<Revvy__MnStrategy4__c> quoteItemList) {
		quoteItemList = super.calculateExtendedFields(quoteItemList);
		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.Commission__c = null;
			qi.Commission_Dollar__c = null;
			qi.Toro_Com_Dollar__c = null;
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Commission__c = null;
					qis.Commission_Dollar__c = null;		
				}
			}
		}
		quote.Commission_Dollar__c = null;
		quote.Commission__c = null;
		
		return quoteItemList;
	}    
}