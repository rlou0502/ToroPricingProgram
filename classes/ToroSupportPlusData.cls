public with sharing class ToroSupportPlusData {
	@AuraEnabled public Boolean success                             	 { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 						 { get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> qiWrappers 			 { get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> addNewWrappers 		 { get; set; }
	@AuraEnabled public List<DistRespOption> distributorResponsibilities { get; private set; }
	@AuraEnabled public Boolean showDistributorResponsibility            { get; set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusData() {
		this.qiWrappers                    = new List<ToroSupportPlusItem>();
		this.addNewWrappers                = new List<ToroSupportPlusItem>();
		this.distributorResponsibilities   = new List<DistRespOption>();
		this.success                       = true;
		this.showDistributorResponsibility = Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible();
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusData(Id quoteId) {
		this();

		try {
			// ============================================================================
			// get the quote and dist resps.
			// ============================================================================
			REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);
			Decimal defaultDistRespValue = 50.0;
			Set<Decimal> distRespValueSet = new Set<Decimal>();
			for (Support_Plus_Contribution__c contrib : getSupportPlusContributions()) {
				distRespValueSet.add(contrib.Distributor_Contribution__c);
				if (
					quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
					&& quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
				) {
					defaultDistRespValue = contrib.Distributor_Contribution__c;
				}
			}
			if (quote.Distributor_Responsibility__c == null) {
				quote.Distributor_Responsibility__c = defaultDistRespValue;
			}
			update quote;

			// build the responsibility wrappers
			List<DistRespOption> options = new List<DistRespOption>();
			for (Decimal value : distRespValueSet) {
				DistRespOption option = new DistRespOption(value);
				if (value == defaultDistRespValue) option.setAsDefault();
				if (value == quote.Distributor_Responsibility__c) option.setAsSelected();
				options.add(option);
			}

			this.quote = quote;
			this.distributorResponsibilities = options;

			// get the quote items and support plus items
			// build a map of the main quote item to its support plus line item
			// (note that support plus items added by "add new" are not handled here)
			final List<REVVY__MnQuoteItem__c> allQuoteItems    = ToroSupportPlusHelper.getQuoteItems(quoteId);
			final List<REVVY__MnQuoteItem__c> addNewQuoteItems = new List<REVVY__MnQuoteItem__c>();

			final Map<Id,REVVY__MnQuoteItem__c> qItemIdToSpItemObjMAP = new Map<Id,REVVY__MnQuoteItem__c>();
			for (REVVY__MnQuoteItem__c qiObj : allQuoteItems) {
				if (qiObj.Support_Plus_Original_Item__c != null) {
					// this is a support plus item since it points to a main item
					qItemIdToSpItemObjMAP.put(qiObj.Support_Plus_Original_Item__c, qiObj);
				}
			}

			// create wrappers for the main quote items. here, we need to differentiate between main quote items
			// and support plus items added by "add new".
			final List<ToroSupportPlusItem> qiWrappers = new List<ToroSupportPlusItem>();
			final List<ToroSupportPlusItem> addNewWrappers = new List<ToroSupportPlusItem>();
			for (REVVY__MnQuoteItem__c quoteItem : allQuoteItems) {

				// support plus items added in "add new"
				if (quoteItem.Support_Plus_From_Add_New__c) {
					addNewWrappers.add(new ToroSupportPlusItem(quoteItem));
				}

				else if (quoteItem.Support_Plus_Original_Item__c != null) {
					// skip
				}
				// quote items with support plus
				else if (qItemIdToSpItemObjMAP.containsKey(quoteItem.Id)) {
					REVVY__MnQuoteItem__c supportPlusItem = qItemIdToSpItemObjMAP.get(quoteItem.Id);
					qiWrappers.add(new ToroSupportPlusItem(quoteItem, supportPlusItem));
					System.debug('\n\n@@quoteItem: ' + quoteItem + '\n\n');
					System.debug('\n\n@@supportPlusItem: ' + supportPlusItem + '\n\n');
				}

				// quote items without support plus
				else {
					qiWrappers.add(new ToroSupportPlusItem(quoteItem));
				}
			}

			this.addNewWrappers = addNewWrappers;
			this.qiWrappers = qiWrappers;
		}

		catch (Exception e) {
			this.success = false;
		}
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private static List<Support_Plus_Contribution__c> getSupportPlusContributions() {
		return [
			SELECT
				Award_Price_Low__c
				, Award_Price_High__c
				, Toro_Contribution__c
				, Distributor_Contribution__c
			FROM
				Support_Plus_Contribution__c
			ORDER BY
				Award_Price_Low__c asc
		];
	}

	// ============================================================================
	// DISTRIBUTOR RESPONSIBILITY OPTIONS FOR DROPDOWN
	// ============================================================================
	public class DistRespOption implements Comparable {
		@AuraEnabled public Decimal value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		public DistRespOption(Decimal value) {
			this.value = value;
			this.label = value.format() + '%';
			this.selected = false;
		}

		public void setAsDefault() { this.label += ' (chart)'; }
		public void setAsSelected() { this.selected = true; }

		public Integer compareTo(Object compareTo) {
			DistRespOption compareToObj = (DistRespOption) compareTo;
			if (this.value == compareToObj.value) return 0;
			if (this.value > compareToObj.value) return 1;
			return -1;
		}
	}
}