public with sharing class ToroPricingProgramCache implements Cache.CacheBuilder {
	public Object doLoad(String pricingProgramExternalId) {
        List<Revvy__MnStrategy1__c> rebates = [Select r.Name, r.ExternalId__c, r.ApplicableProducts__c,Blended_DNet_Threshold__c
        		,OutCrossThreshold__c, MinimumThreshold__c, MinimumTractionUnits__c, OverriddenPriceList__c
        		,PricingProgramType__c, AllowSupportPlus__c,
				(Select Off_Mfg_Sugg_Ttl__c, Award_Price_as_a_Percent_of_DN__c, Rebate_as_a_Percent_of_DN__c,
				Max_Qty__c, Min_Qty__c,
				Distributor_Margin__c, ApplicableProducts__c From PricingProgramLines__r order by Award_Price_as_a_Percent_of_DN__c desc) 
				From Revvy__MnStrategy1__c r where ExternalId__c = :pricingProgramExternalId ];
		return rebates[0]; 
    }    
}