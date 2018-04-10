public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean result 									{ get; set; }
	@AuraEnabled public Boolean success                                 { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 						{ get; set; }
	@AuraEnabled public List<QuoteItem> quoteItemList 					{ get; set; }
	@AuraEnabled public Decimal Distributor_Responsibility 				{ get; set; }
	// @AuraEnabled public List<Support_Plus_Holder__c> supportPlusList 	{ get; set; }
	@AuraEnabled public List<QuoteItem> supportPlusList				{ get; set; }


	@AuraEnabled public List<ToroSupportPlusItem> supportPlusItems 	{ get; set; }

	public ToroSupportPlusData() {
		this.quoteItemList   = new List<QuoteItem>();
		this.supportPlusList = new List<QuoteItem>();

		this.supportPlusItems = new List<ToroSupportPlusItem>();

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

			Revvy__MnQuote__c tmpQ = [select Toro_Total_DNet__c from Revvy__MnQuote__c where id = :quoteId];
			List<Support_Plus_Plan__c> plans = [select Total_DNet_Low__c, Total_DNet_High__c, Maximum_Support__c from Support_Plus_Plan__c order by Total_DNet_Low__c];
			for(Support_Plus_Plan__c sp : plans) {
				if((tmpQ.Toro_Total_DNet__c >= sp.Total_DNet_Low__c) && (tmpQ.Toro_Total_DNet__c < sp.Total_DNet_High__c)) {
					tmpQ.Toro_Support_Plus_Allowance__c = sp.Maximum_Support__c;
					break;
				}
			}
			//update quote;
			update tmpQ;
		}

		catch (Exception e) {
			result.success = false;
		}

		return result;
	}
}