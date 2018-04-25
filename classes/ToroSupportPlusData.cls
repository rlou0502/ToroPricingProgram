public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean success                             			{ get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 								{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> quoteItems 					{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> supportPlusOnlyItems 			{ get; set; }
	@AuraEnabled public List<DistributorResponsibilityOption> distributorResponsibilities 	{ get; private set; }

	// ============================================================================
	// title
	// ============================================================================
	public class DistributorResponsibilityOption implements Comparable {
		@AuraEnabled public Decimal value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		public DistributorResponsibilityOption(Decimal value) {
			this.value = value;
			this.label = value.format() + '%';
			this.selected = false;
		}

		public void setAsDefault() {
			this.label += ' (default)';
		}

		public void setAsSelected() {
			this.selected = true;
		}

		public Integer compareTo(Object compareTo) {
			DistributorResponsibilityOption compareToObj = (DistributorResponsibilityOption) compareTo;
			if (this.value == compareToObj.value) return 0;
			if (this.value > compareToObj.value) return 1;
			return -1;
		}
	}

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
		this.distributorResponsibilities = new List<DistributorResponsibilityOption>();
		this.success                     = true;
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
			REVVY__MnQuote__c quote = getQuote(quoteId);

			// get the distributor responsibilities. update quote if necessary
			Decimal defaultResponsibility = 50.0;
			Set<Decimal> responsibilityValues = new Set<Decimal>();
			for (Support_Plus_Contribution__c contribution : getSupportPlusContributions()) {
				responsibilityValues.add(contribution.Distributor_Contribution__c);
				if (
					quote.Toro_Blended_Percent_of_DN__c >= contribution.Award_Price_Low__c
					&& quote.Toro_Blended_Percent_of_DN__c < contribution.Award_Price_High__c
				) {
					defaultResponsibility = contribution.Distributor_Contribution__c;
				}
			}

			// set the quote to the default responsibility if it is not set
			if (quote.Distributor_Responsibility__c == null) {
				quote.Distributor_Responsibility__c = defaultResponsibility;
			}
			update quote;

			// build the responsibility wrappers
			List<DistributorResponsibilityOption> options = new List<DistributorResponsibilityOption>();
			for (Decimal value : responsibilityValues) {
				DistributorResponsibilityOption option = new DistributorResponsibilityOption(value);
				if (value == defaultResponsibility) option.setAsDefault();
				system.debug('responsibility wrappers Distributor_Contribution__c=' + quote.Distributor_Contribution__c + ' value=' + value);
				//if (value == quote.Distributor_Contribution__c) option.setAsSelected();
				if (value == quote.Distributor_Responsibility__c) option.setAsSelected();
				options.add(option);
			}

			result.quote = quote;
			result.distributorResponsibilities = options;

			// get the quote items and support plus items
			List<REVVY__MnQuoteItem__c> quoteItems = ToroSupportPlusItem.getQuoteItems(quoteId);

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

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private static REVVY__MnQuote__c getQuote(Id quoteId) {
			REVVY__MnQuote__c quote = [
				SELECT
					Toro_Total_DNet__c // Total DNet BEFORE deducting Toro Contribution for Support Plus Items
					, Id
					, Name
					, Toro_Support_Plus_Allowance__c // (SHOWN)
					, Toro_Support_Plus_Allowance_Used__c
					, Toro_Blended_Percent_of_DN__c
					, SP_Toro_Responsibility__c // (SHOWN) (Toro Contribution/Responsibility)
					, SP_Ext_Dist_Responsibility__c
					, SP_Total_Extended_DNET__c // (SHOWN) Total DNet AFTER deducting Toro Contribution for Support Plus Items
					, Distributor_Responsibility__c // (SHOWN) Set on load of Support Plus page. Can be overriden by user.
				FROM
					REVVY__MnQuote__c
				WHERE
					Id = :quoteId
			];
			System.debug('\n\n@@quote: ' + quote + '\n\n');

			quote.Toro_Support_Plus_Allowance__c = 0.0;

			List<Support_Plus_Plan__c> supportPlusPlans = [
				SELECT
					Total_DNet_Low__c
					, Total_DNet_High__c
					, Maximum_Support__c
				FROM
					Support_Plus_Plan__c
				ORDER BY
					Total_DNet_Low__c
			];
			System.debug('\n\n@@supportPlusPlans: ' + supportPlusPlans + '\n\n');

			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (quote.Toro_Total_DNet__c >= plan.Total_DNet_Low__c
					&& quote.Toro_Total_DNet__c < plan.Total_DNet_High__c
				) {
					quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}

			// update quote;
			quote.SP_Toro_Responsibility__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Toro_Responsibility__c);
			quote.SP_Ext_Dist_Responsibility__c = CMnQuoteUtil.defaultDecimal(quote.SP_Ext_Dist_Responsibility__c);
			quote.SP_Total_Extended_DNET__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Total_Extended_DNET__c);
			return quote;
	}
}