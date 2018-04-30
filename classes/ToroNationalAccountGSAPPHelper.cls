public with sharing class ToroNationalAccountGSAPPHelper extends ToroGSAPricingProgramHelper {
	public override decimal retrieveAwardPrice(REVVY__MnPriceListLine__c ppl) {
		return ppl.revvy__PriceField1__c;	
	} 
}