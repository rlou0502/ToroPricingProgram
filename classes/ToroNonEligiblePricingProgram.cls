public class ToroNonEligiblePricingProgram extends ToroLargePackagePricingProgramHelper { 
	public override void initialize(Id quoteId) {
		super.initialize(quoteId);
		this.quoteItems = setDefaultFields(this.quoteItems);
	}
	public override List<ToroSelectOption> retrievePricingMethodOptions() { 
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		if(!Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));	
		} else {
			ret.add(new ToroSelectOption('% of DNET','% of DNET'));
			ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
			ret.add(new ToroSelectOption('Total Award $','Total Award $'));
			ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		}
		return ret;
	}
	/*
	public override List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		boolean drivenByGP = false;
		decimal rebate = 0;
		decimal gpPercent = 0;
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)}; 
		Map<String, Revvy__MnStrategy2__c> productPricingProgramLineMap = new Map<String, Revvy__MnStrategy2__c>();
		for(Revvy__MnStrategy1__c rh : rebates) {
			drivenByGP = rh.DrivenByGP__c;
			if(rh.PricingProgramLines__r != null) {
				for(Revvy__MnStrategy2__c l : rh.PricingProgramLines__r) {
					rebate = l.Rebate_as_a_Percent_of_DN__c;
					gpPercent = l.Distributor_Margin__c;	
				}
			}
		}
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.DrivenByGP__c = drivenByGP;
			qi.Rebate_as_a_of_DN__c = rebate;
			
			if('Total Award $'.equalsIgnoreCase(priceMethod)) {
					
			} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
				
			} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
				qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c);
				qi.msrp_Price__c = CMnQuoteUtil.defaultDecimal(qi.msrp_Price__c);
				qi.Award_Price__c = qi.msrp_Price__c * (100-qi.Off_MSRP__c)/100;
				system.debug('ToroNonEligiblePricingProgram qi.Off_MSRP__c=' + qi.Off_MSRP__c);
				system.debug('ToroNonEligiblePricingProgram qi.msrp_Price__c=' + qi.msrp_Price__c);
				system.debug('ToroNonEligiblePricingProgram qi.Award_Price__c=' + qi.Award_Price__c);	
			} else if('% of DNET'.equalsIgnoreCase(priceMethod)) {
				qi.Award_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c);
				qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
				qi.Award_Price__c = qi.DNet_Price__c * qi.Award_of_DN__c/100;
			}
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Rebate_as_of_DNet__c = rebate;
					qis.Percent_Off_MSRP__c = CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c);
					if('Total Award $'.equalsIgnoreCase(priceMethod)) {
				
					} else if('Gross Profit %'.equalsIgnoreCase(priceMethod)) {
						
					} else if('% off MSRP'.equalsIgnoreCase(priceMethod)) {
						qis.Percent_Off_MSRP__c = CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c);
						qis.msrp_Price__c = CMnQuoteUtil.defaultDecimal(qis.msrp_Price__c);
						qis.Award_Price__c = qi.msrp_Price__c * (100-qis.Percent_Off_MSRP__c)/100;	
						system.debug('ToroNonEligiblePricingProgram qis.Percent_Off_MSRP__c=' + qis.Percent_Off_MSRP__c);
						system.debug('ToroNonEligiblePricingProgram qis.msrp_Price__c=' + qis.msrp_Price__c);
						system.debug('ToroNonEligiblePricingProgram qis.Award_Price__c=' + qis.Award_Price__c);
					} else if('% of DNET'.equalsIgnoreCase(priceMethod)) {
						qis.Percent_of_DNet__c = CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c);
						qis.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
						qis.Award_Price__c = qi.DNet_Price__c * qis.Percent_of_DNet__c/100;
					}
				}
			}
			
		}
		return quoteItemList;															
	}
	*/
	public override List<Revvy__MnStrategy4__c> setDefaultFields(List<Revvy__MnStrategy4__c> quoteItemList) {
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.DrivenByGP__c=false;
            qi.Off_MSRP__c = CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c);
            qi.Award_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Award_of_DN__c);
            qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
            qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_Award_Price__c);
            qi.Blended_GP__c = CMnQuoteUtil.defaultDecimal(qi.Blended_GP__c);
            //qi.Blended_MSRP__c = CMnQuoteUtil.defaultDecimal(qi.Blended_MSRP__c);
            qi.Blended_Rebate__c = CMnQuoteUtil.defaultDecimal(qi.Blended_Rebate__c);
            qi.Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_DNet_Price__c);
			if(!SObjectType.Revvy__MnStrategy4__c.fields.PricingMethodValue__c.isUpdateable()) {
				if(String.isBlank(qi.PricingMethodValue__c)) {
					qi.PricingMethodValue__c='0';		
				}	
			}	
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Percent_Off_MSRP__c = CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c);
                    qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
                    qis.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Extended_Award_Price__c);
                    qis.Percent_of_DNet__c = CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c);
					if(!SObjectType.Revvy__MnStrategy5__c.fields.PricingMethodValue__c.isUpdateable()) {
						if(String.isBlank(qis.PricingMethodValue__c)) {
							qis.Percent_Off_MSRP__c=0;
							qis.PricingMethodValue__c='0';		
						}
					}
				}
			}
		}	
		return quoteItemList;
	} 
}