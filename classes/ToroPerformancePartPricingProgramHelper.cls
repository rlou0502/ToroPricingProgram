public with sharing class ToroPerformancePartPricingProgramHelper {

	public static void reset(Id quoteId, String priceProgramExternalId, String priceMethod
	                                                      , Boolean bperformancePart
	                                                      , List<Toro_QuoteItem__c> quoteItemList) {

		system.debug('+++++++++++++++++ quoteItem' + quoteItemList);
		
		for(Toro_QuoteItem__c qi:quoteItemList) {
			qi.Performance_Parts_Product__c = false;
			qi.Performance_Parts_Product__c = false;
			if(!qi.Unit_Award_Overridden__c) {
				//Todo
	        	qi.Award_Price__c=0;//qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
	        	qi.Unit_Award_Overridden__c=true;
			}
	        //qi.revvy__freezepricing__c=false;
	        
	        if(qi.Toro_Quote_Item_Sub_Lines__r!=null && qi.Toro_Quote_Item_Sub_Lines__r.size()>0) {
	        	for(Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					qis.Performance_Part__c = false;
					if(!qis.Unit_Award_Overridden__c) {
						//Todo
			        	qis.Award_Price__c=qi.MSRP_Price__c; //qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
			        	qis.Unit_Award_Overridden__c = true;
					}
			        //qis.revvy__freezepricing__c=false;
	        		
	        	}
	        	
	        }
		}
	}    
	
	/*
	public static void reset(Id quoteId, String priceProgramExternalId, String priceMethod
	                                                      , Boolean bperformancePart
	                                                      , List<REVVY__MnQuoteItem__c> quoteItemList
	                                                      , List<REVVY__MnQuoteItemSubline__c> quoteItemSubLineList) {

		system.debug('+++++++++++++++++ quoteItem' + quoteItemList);
		system.debug('+++++++++++++++++ quoteItemSubLine' + quoteItemSubLineList);
		
		for(REVVY__MnQuoteItem__c qi:quoteItemList) {
			qi.Performance_Parts_Product__c = false;
			qi.Performance_Parts_Product__c = false;
			if(!qi.Unit_Award_Overridden__c) {
	        	qi.Award_Price__c=qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
			}
	        qi.revvy__freezepricing__c=false;
		}
		if(quoteItemSubLineList!=null) {
			for(REVVY__MnQuoteItemSubline__c qi:quoteItemSubLineList) {
				
				qi.Performance_Part__c = false;
				if(!qi.Unit_Award_Overridden__c) {
		        	qi.Award_Price__c=qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
				}
		        qi.revvy__freezepricing__c=false;
			}
		
		}
	}   	
	*/
	
	public static Map<String,Decimal> retrievePerformancePart() {
		Map<String,Decimal> ppMap = new Map<String,Decimal>();
		/*
		for(Toro_PricingProgramLine__c rl:[Select Id, ApplicableProducts__c, Pricing_1__c
		                          From Toro_PricingProgramLine__c
		                         Where PricingProgram__r.Name = 'Performance Part'
		                           and PricingProgram__r.PricingProgramType__c = 'Performance Part' ]) {
			ppMap.put(rl.ApplicableProducts__c, rl.Pricing_1__c);                           	
		}*/
		
		for(REVVY__MnPriceListLine__c pl:[Select Id, REVVY__Product_Id__c, REVVY__PriceList__c, REVVY__PriceField4__c
		                                   From REVVY__MnPriceListLine__c 
		                                  Where REVVY__PriceList__r.REVVY__ID__c = 'Commercial'
		                                    AND REVVY__PriceList__r.REVVY__START_DATE__c <= TODAY
		                                    AND REVVY__PriceList__r.REVVY__END_DATE__c >= TODAY
		                                    AND REVVY__PriceList__r.REVVY__Status__c = 'Active'
		                                    AND REVVY__PriceField4__c > 0

		  								 ]) {
			ppMap.put(pl.REVVY__Product_Id__c, pl.REVVY__PriceField4__c);   	
		}		
		return ppMap;
	}



	public static boolean applyPerformancePartForQuoteItem(Boolean bperformancePart,  Toro_QuoteItem__c qi, Map<String,Decimal> ppMap) {
		system.debug('+++++++++++++++++ PP quoteItem qi.Product_Id__c=' + qi.Product_Id__c + ' ppMap size=' + ppMap.size() + ' test='+ppMap.containsKey(qi.Product_Id__c));
 		boolean result = false;
		qi.Performance_Parts_Product__c = false;
		if(!qi.Unit_Award_Overridden__c) {
			//Todo
        	qi.Award_Price__c=0; //qi.REVVY__Unit_Price__c = qi.Revvy__Price__c; 
		}
        //qi.revvy__freezepricing__c=false;
		system.debug('+++++++++++++++++ PP QuoteItem bperformancePart=' + bperformancePart);
		if(bperformancePart!=null && bperformancePart
		&& ppMap !=null && ppMap.containsKey(qi.Product_Id__c)) {
			//qi.MSRP_Price__c = ppMap.get(qi.Product_Id__c);
			system.debug('&&&&&&&&&&&&&&&&&&&&&&& 1000 PP QuoteItem qi.Product_Id__c=' + qi.Product_Id__c + ' qi.MSRP_Price__c='+qi.MSRP_Price__c);
			qi.Performance_Parts_Product__c = true;
            //qi.revvy__freezepricing__c=true;
            qi.Off_MSRP__c = 0;
            //if(!qi.Unit_Award_Overridden__c) {
            	qi.Award_Price__c =ppMap.get(qi.Product_Id__c); //qi.REVVY__Unit_Price__c;
            	qi.Unit_Award_Overridden__c=true;
            //}
            result = true;
		}
		return result;
	}   
	
	public static Toro_QuoteItem_SubLine__c applyPerformancePartForQuoteItemSubLine(Boolean bperformancePart, Toro_QuoteItem_SubLine__c qi, Map<String,Decimal> ppMap) {
		system.debug('+++++++++++++++++ Performance Part quoteItem' + qi);
		
		qi.Performance_Part__c = false;
		if(!qi.Unit_Award_Overridden__c) {
        	qi.Award_Price__c=qi.MSRP_Price__c; //qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
		}
        //qi.revvy__freezepricing__c=false;
		system.debug('+++++++++++++++++ PP QuoteItemSubLine bperformancePart=' + bperformancePart);
		if(bperformancePart!=null && bperformancePart 
		&& ppMap !=null && ppMap.containsKey(qi.Product_ID__c)) {
			//qi.MSRP_Price__c = ppMap.get(qi.Product_ID2__c);
			system.debug('&&&&&&&&&&&&&&&&&&&&&&& PP QuoteItemSubLine qi.MSRP_Price__c=' + qi.MSRP_Price__c + ' - '+ qi.Product_ID__c + '---' + ppMap.get(qi.Product_Id__c));
			qi.Performance_Part__c = true;
            //qi.revvy__freezepricing__c=true;
            //if(!qi.Unit_Award_Overridden__c) {
            	qi.Award_Price__c =ppMap.get(qi.Product_Id__c); //qi.REVVY__Unit_Price__c;
            	system.debug('&&&&&&&&&&&&&&&&&&&&&&& PP QuoteItemSubLine qi.Award_Price__c=' + qi.Award_Price__c);
            	qi.Unit_Award_Overridden__c=true;
            //}
		}
		return qi;
	}	
	
	/*
	public static void applyPerformancePartForQuoteItem(Boolean bperformancePart, REVVY__MnQuoteItem__c qi, Map<String,Decimal> ppMap) {
		system.debug('+++++++++++++++++ PP quoteItem=' + qi);
		
		qi.Performance_Parts_Product__c = false;
		if(!qi.Unit_Award_Overridden__c) {
        	qi.Award_Price__c=qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
		}
        qi.revvy__freezepricing__c=false;
		system.debug('+++++++++++++++++ PP QuoteItem bperformancePart=' + bperformancePart);
		if(bperformancePart!=null && bperformancePart
		&& ppMap !=null && ppMap.containsKey(qi.REVVY__Product_ID_F__c)) {
			qi.REVVY__Unit_Price__c = ppMap.get(qi.REVVY__Product_ID_F__c);
			//system.debug('&&&&&&&&&&&&&&&&&&&&&&& PP QuoteItem qi.REVVY__Price__c=' + qi.REVVY__Price__c);
			qi.Performance_Parts_Product__c = true;
            qi.revvy__freezepricing__c=true;
            qi.Off_MSRP__c = 0;
            if(!qi.Unit_Award_Overridden__c) {
            	qi.Award_Price__c =qi.REVVY__Unit_Price__c;
            }
		}
	}   
	
	public static void applyPerformancePartForQuoteItemSubLine(Boolean bperformancePart, REVVY__MnQuoteItemSubline__c qi, Map<String,Decimal> ppMap) {
		system.debug('+++++++++++++++++ Performance Part quoteItem' + qi);
		
		qi.Performance_Part__c = false;
		if(!qi.Unit_Award_Overridden__c) {
        	qi.Award_Price__c=qi.REVVY__Unit_Price__c = qi.Revvy__Price__c;
		}
        qi.revvy__freezepricing__c=false;
		system.debug('+++++++++++++++++ PP QuoteItemSubLine bperformancePart=' + bperformancePart);
		if(bperformancePart!=null && bperformancePart 
		&& ppMap !=null && ppMap.containsKey(qi.Product_ID2__c)) {
			qi.REVVY__Unit_Price__c = ppMap.get(qi.Product_ID2__c);
			system.debug('&&&&&&&&&&&&&&&&&&&&&&& PP QuoteItemSubLine qi.REVVY__Price__c=' + qi.REVVY__Price__c + ' - '+ qi.Product_ID2__c);
			qi.Performance_Part__c = true;
            qi.revvy__freezepricing__c=true;
            if(!qi.Unit_Award_Overridden__c) {
            	qi.Award_Price__c =qi.REVVY__Unit_Price__c;
            }
		}
	}   
	*/	    
}