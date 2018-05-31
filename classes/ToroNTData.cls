/**
 * ToroNTData
 *
 * Data wrapper class for Non-Toro Products page
 *
 */
public with sharing class ToroNTData {
	@AuraEnabled public Boolean success                 { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 		{ get; set; }
	@AuraEnabled public List<ToroQIBase> qiWrappers 	{ get; set; }
	@AuraEnabled public List<ToroQIBase> addNewWrappers { get; set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroNTData() {
		this.qiWrappers = new List<ToroQIBase>();
		this.addNewWrappers = new List<ToroQIBase>();
		this.success = true;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroNTData(Id quoteId) {
		this();
		try {
			this.quote = ToroSupportPlusHelper.getQuote(quoteId);

			for (REVVY__MnQuoteItem__c qi : ToroSupportPlusHelper.getNonToroQuoteItems(quoteId)) {
				this.qiWrappers.add(new ToroQIBase(qi));
			}
		}

		catch (Exception e) {
			this.success = false;
			throw e;
		}
	}
}