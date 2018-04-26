public with sharing class ToroSupportPlusData {
	@AuraEnabled public Boolean success                             			{ get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 								{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> quoteItems 					{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> supportPlusOnlyItems 			{ get; set; }
	@AuraEnabled public List<DistRespOption> distributorResponsibilities 	{ get; private set; }
	@AuraEnabled public Boolean showDistributorResponsibility                   { get; set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusData() {
		this.quoteItems                  = new List<ToroSupportPlusItem>();
		this.supportPlusOnlyItems        = new List<ToroSupportPlusItem>();
		this.distributorResponsibilities = new List<DistRespOption>();
		this.success                     = true;
		this.showDistributorResponsibility = Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible();
	}

	public ToroSupportPlusData(Id quoteId) {
		this();

		try {
			this.quote = ToroSupportPlusHelper.getQuote(quoteId);
		}

		catch (Exception e) {

		}
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static ToroSupportPlusData createToroSupportPlusData(Id quoteId) {
		ToroSupportPlusData result = new ToroSupportPlusData();

		try {
			// get the quote
			REVVY__MnQuote__c quote = ToroSupportPlusHelper.getQuote(quoteId);

			// get the distributor responsibilities. update quote if necessary
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

			// set the quote to the default responsibility if it is not set
			if (quote.Distributor_Responsibility__c == null) {
				quote.Distributor_Responsibility__c = defaultDistRespValue;
			}
			update quote;

			// build the responsibility wrappers
			List<DistRespOption> options = new List<DistRespOption>();
			for (Decimal value : distRespValueSet) {
				DistRespOption option = new DistRespOption(value);
				if (value == defaultDistRespValue) option.setAsDefault();
				system.debug('responsibility wrappers Distributor_Contribution__c=' + quote.Distributor_Contribution__c + ' value=' + value);
				if (value == quote.Distributor_Responsibility__c) option.setAsSelected();
				options.add(option);
			}

			result.quote = quote;
			result.distributorResponsibilities = options;

			// get the quote items and support plus items
			List<REVVY__MnQuoteItem__c> quoteItems = ToroSupportPlusHelper.getQuoteItems(quoteId);

			// build a list of the main quote line item
			// build a map of the main quote item to its support plus line item
			// (note that support plus items added by "add new" are not handled here)
			final List<REVVY__MnQuoteItem__c> mainQuoteItems = new List<REVVY__MnQuoteItem__c>();
			final Map<Id,REVVY__MnQuoteItem__c> mainQuoteItemToSupportPlusItemMap = new Map<Id,REVVY__MnQuoteItem__c>();
			for (REVVY__MnQuoteItem__c quoteItem : quoteItems) {
				if (quoteItem.Support_Plus_Original_Item__c == null) {
					// this is not a support plus item since it is not linked to a main item
					mainQuoteItems.add(quoteItem);
				}

				else {
					// this is a support plus item since it points to a main item
					mainQuoteItemToSupportPlusItemMap.put(quoteItem.Support_Plus_Original_Item__c, quoteItem);
				}
			}

			// create wrappers for the main quote items. here, we need to differentiate between main quote items
			// and support plus items added by "add new".
			final List<ToroSupportPlusItem> mainQuoteItemWrappers = new List<ToroSupportPlusItem>();
			final List<ToroSupportPlusItem> addNewSupportPlusItemWrappers = new List<ToroSupportPlusItem>();
			for (REVVY__MnQuoteItem__c quoteItem : mainQuoteItems) {
				if (quoteItem.Is_Support_Plus_Item_Only__c) {
					// these are items previously added by "add new"
					addNewSupportPlusItemWrappers.add(new ToroSupportPlusItem(quoteItem));
				}

				else if (mainQuoteItemToSupportPlusItemMap.containsKey(quoteItem.Id)) {
					// these are items that have quantity allocated to support plus
					REVVY__MnQuoteItem__c supportPlusItem = mainQuoteItemToSupportPlusItemMap.get(quoteItem.Id);
					mainQuoteItemWrappers.add(new ToroSupportPlusItem(quoteItem, supportPlusItem));
				}

				else {
					// these are items with no quantity allocated to support plus
					mainQuoteItemWrappers.add(new ToroSupportPlusItem(quoteItem));
				}
			}

			result.supportPlusOnlyItems = addNewSupportPlusItemWrappers;
			result.quoteItems = mainQuoteItemWrappers;
		}

		catch (Exception e) {
			result.success = false;
		}

		return result;
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
	// title
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

		public void setAsDefault() { this.label += ' (default)'; }
		public void setAsSelected() { this.selected = true; }

		public Integer compareTo(Object compareTo) {
			DistRespOption compareToObj = (DistRespOption) compareTo;
			if (this.value == compareToObj.value) return 0;
			if (this.value > compareToObj.value) return 1;
			return -1;
		}
	}
}