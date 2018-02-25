public with sharing class ToroSupportPlusData {

	@AuraEnabled public boolean result 									{ get; set; }
	@AuraEnabled public REVVY__MnQuote__c quote 						{ get; set; }
	@AuraEnabled public List<QuoteItem> quoteItemList 					{ get; set; }
	@AuraEnabled public Decimal Distributor_Responsibility 				{ get; set; }
	@AuraEnabled public List<Support_Plus_Holder__c> supportPlusList 	{ get; set; }

	public ToroSupportPlusData() {
		// result = true;
	}
}