public with sharing class ToroPricingProgramCache implements Cache.CacheBuilder {
	public Object doLoad(String pricingProgramExternalId) {	 
        List<Revvy__MnStrategy1__c> rebates = [Select r.Setup_Fee__c, r.PricingProgramType__c, r.PricingProgramStyle__c, 
        	r.OverriddenPriceList__c, r.OutCrossThreshold__c, r.Name, r.MinimumTractionUnits__c, r.MinimumThreshold__c, 
        	r.IsTaxSupported__c, r.IsFirstTee__c, r.Id, r.ExternalId__c, r.Exclude__c, 
        	(
        		Select Award_Price_as_a_Percent_of_DN__c, Distributor_Margin__c, Fee_Percentage__c, ApplicableProducts__c, 
        		Max_Qty__c, Min_Qty__c, Off_Mfg_Sugg_Ttl__c, Part_Percentage__c, Pricing_1__c, Pricing_2__c, 
        		Rebate_as_a_Percent_of_DN__c, Sequence__c, Tier__c From PricingProgramLines__r 
        		order by Award_Price_as_a_Percent_of_DN__c desc
        	) 
        	From REVVY__MnStrategy1__c r where r.ExternalId__c = :pricingProgramExternalId];
		return rebates[0];  
    }    
}