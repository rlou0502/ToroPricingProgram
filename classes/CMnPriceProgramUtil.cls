/**
 * CMnPriceProgramUtil
 *
 * class_description
 *
 * @author Roy Lou
 */
public with sharing class CMnPriceProgramUtil {
	// ============================================================================
	// title
	public class PriceProgramInfo {
		public Map<String,Revvy__MnStrategy1__c> rebateMap 			{ get; set; }
		public Map<String,Set<String>> rebateApplicableProducts 	{ get; set; }
	}

	/**
	 *
	 * description
	 *
	 * @param  priceProgramExternalId    this is actually the Name of the Pricing Program record
	 * @return return_type
	 */
	public static PriceProgramInfo collectPriceProgram(String priceProgramExternalId) {
		PriceProgramInfo ret = new PriceProgramInfo();
		List<Revvy__MnStrategy1__c> rebates = [
			SELECT
				r.Name, r.ExternalId__c, r.ApplicableProducts__c
				, (SELECT
						Off_Mfg_Sugg_Ttl__c, Award_Price_as_a_Percent_of_DN__c, Rebate_as_a_Percent_of_DN__c
						, Distributor_Margin__c, ApplicableProducts__c
					FROM PricingProgramLines__r)
			FROM
				Revvy__MnStrategy1__c r
			WHERE
				Name = :priceProgramExternalId];

		Map<String,Revvy__MnStrategy1__c> rebateMap = new Map<String,Revvy__MnStrategy1__c>();
		Map<String,Set<String>> rebateApplicableProducts = new Map<String,Set<String>>();

		for (Revvy__MnStrategy1__c rh : rebates) {
			rebateMap.put(rh.ExternalId__c, rh);
			if (!rebateApplicableProducts.containsKey(rh.ExternalId__c)) {
				rebateApplicableProducts.put(rh.ExternalId__c, new Set<String>());
			}

			if (String.isNotBlank(rh.ApplicableProducts__c)) {
				String[] parts = rh.ApplicableProducts__c.split(',');
				rebateApplicableProducts.get(rh.ExternalId__c).addAll(parts);
			}

		}

		ret.rebateMap = rebateMap;
		ret.rebateApplicableProducts = rebateApplicableProducts;
		return ret;
	}
}