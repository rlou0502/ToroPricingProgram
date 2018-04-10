public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean result 									{ get; set; }
	@AuraEnabled public Boolean success                                 { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 						{ get; set; }
	@AuraEnabled public List<QuoteItem> quoteItemList 					{ get; set; }
	@AuraEnabled public Decimal Distributor_Responsibility 				{ get; set; }
	// @AuraEnabled public List<Support_Plus_Holder__c> supportPlusList 	{ get; set; }
	@AuraEnabled public List<QuoteItem> supportPlusList				{ get; set; }

	public ToroSupportPlusData() {
		this.quoteItemList   = new List<QuoteItem>();
		this.supportPlusList = new List<QuoteItem>();

		this.success = true;
		this.Distributor_Responsibility = 0;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static ToroSupportPlusData buildToroSupportPlusData(Id quoteId) {
		ToroSupportPlusData result = new ToroSupportPlusData();

		try {

		}

		catch (Exception e) {
			result.success = false;
		}

		return result;
	}
}