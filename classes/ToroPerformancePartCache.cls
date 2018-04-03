public with sharing class ToroPerformancePartCache implements Cache.CacheBuilder {
	public Object doLoad(String pricelistExternalId) {
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
		                                  Where REVVY__PriceList__r.REVVY__ID__c = :pricelistExternalId
		                                    AND REVVY__PriceList__r.REVVY__START_DATE__c <= TODAY
		                                    AND REVVY__PriceList__r.REVVY__END_DATE__c >= TODAY
		                                    AND REVVY__PriceList__r.REVVY__Status__c = 'Active'
		                                    AND REVVY__PriceField4__c > 0

		  								 ]) {
			ppMap.put(pl.REVVY__Product_Id__c, pl.REVVY__PriceField4__c);   	
		}		
		return ppMap;
    }    
    
}