public with sharing class CMnPriceProgramUtil {
	public class PriceProgramInfo {
		public map<string, Revvy__MnStrategy1__c> rebateMap {get; set; }
		public map<string, set<String>> rebateApplicableProducts { get; set; }
	}

	public static PriceProgramInfo collectPriceProgram(String priceProgramExternalId) {
		PriceProgramInfo ret = new PriceProgramInfo();
		List<Revvy__MnStrategy1__c> rebates = [Select r.Name, r.ExternalId__c, r.ApplicableProducts__c, 
				(Select Off_Mfg_Sugg_Ttl__c, Award_Price_as_a_Percent_of_DN__c, Rebate_as_a_Percent_of_DN__c, 
				Distributor_Margin__c, ApplicableProducts__c From PricingProgramLines__r) From Revvy__MnStrategy1__c r where name = :priceProgramExternalId];
		map<string, Revvy__MnStrategy1__c> rebateMap = new map<string, Revvy__MnStrategy1__c>();
		map<string, set<String>> rebateApplicableProducts = new map<string, set<String>>();
		for(Revvy__MnStrategy1__c rh : rebates) {
			rebateMap.put(rh.ExternalId__c, rh);
			if(!rebateApplicableProducts.containsKey(rh.ExternalId__c)) {
				rebateApplicableProducts.put(rh.ExternalId__c, new set<String>());	
			}	
			if(string.isNotBlank(rh.ApplicableProducts__c)) {
				String[] parts = rh.ApplicableProducts__c.split(',');
				rebateApplicableProducts.get(rh.ExternalId__c).addAll(parts);	
			}
			
		}
		ret.rebateMap = rebateMap;
		ret.rebateApplicableProducts = rebateApplicableProducts;
		return ret;
	}

	
}