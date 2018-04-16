public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean success                             { get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 					{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> quoteItems 		{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> supportPlusItems 	{ get; set; }
	@AuraEnabled public List<SelectOption> distributorResponsibilityOptions { get; private set; }

	public ToroSupportPlusData() {
		this.quoteItems                       = new List<ToroSupportPlusItem>();
		this.supportPlusItems                 = new List<ToroSupportPlusItem>();
		this.distributorResponsibilityOptions = new List<SelectOption>();
		this.success                          = true;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static ToroSupportPlusData retrieveAndBuildData(Id quoteId) {
		ToroSupportPlusData result = new ToroSupportPlusData();

		try {
			REVVY__MnQuote__c quote = [
				SELECT
					Toro_Total_DNet__c
					, Id
					, Name
					, Toro_Support_Plus_Allowance__c
					, Toro_Blended_Percent_of_DN__c
					, SP_Toro_Responsibility__c
					, SP_Ext_Dist_Responsibility__c
					, SP_Total_Extended_DNET__c
					, Distributor_Responsibility__c
				FROM
					REVVY__MnQuote__c
				WHERE
					Id = :quoteId
			];

			List<Support_Plus_Plan__c> supportPlusPlans = [
				SELECT
					Total_DNet_Low__c
					, Total_DNet_High__c
					, Maximum_Support__c
				FROM
					Support_Plus_Plan__c
				ORDER BY
					Total_DNet_Low__c
				LIMIT 1
			];

			for (Support_Plus_Plan__c plan : supportPlusPlans) {
				if (quote.Toro_Total_DNet__c >= plan.Total_DNet_Low__c
					&& quote.Toro_Total_DNet__c < plan.Total_DNet_High__c
				) {
					quote.Toro_Support_Plus_Allowance__c = plan.Maximum_Support__c;
					break;
				}
			}
			update quote;

			quote.SP_Toro_Responsibility__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Toro_Responsibility__c);
			quote.SP_Ext_Dist_Responsibility__c = CMnQuoteUtil.defaultDecimal(quote.SP_Ext_Dist_Responsibility__c);
			quote.SP_Total_Extended_DNET__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Total_Extended_DNET__c);

			List<Support_Plus_Contribution__c> contributions = [
				SELECT
					Award_Price_Low__c
					, Award_Price_High__c
					, Toro_Contribution__c
					, Distributor_Contribution__c
				FROM
					Support_Plus_Contribution__c
				ORDER BY
					Award_Price_Low__c asc];

			for (Support_Plus_Contribution__c contrib : contributions) {
				if (
					quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
					&& quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
				) {
					quote.Distributor_Responsibility__c = contrib.Distributor_Contribution__c;
					// result.distributorResponsibilityOptions.add(new SelectOption(contrib.Distributor_Contribution__c + ' (default)', contrib.Distributor_Contribution__c.format()));
					break;
				}

				else {
					// result.distributorResponsibilityOptions.add(new SelectOption(contrib.Distributor_Contribution__c.format(), contrib.Distributor_Contribution__c.format()));
				}
			}

			result.quote = quote;

			for (REVVY__MnQuoteItem__c quoteItem : [SELECT
														Id
														, REVVY__Product_Name_F__c
														, REVVY__Catalog_Node__r.Name
														, REVVY__Product_ID_F__c
														, REVVY__Id__c
														, REVVY__Quantity__c
														, Support_Plus_Quantity__c
														, Support_Plus_Item__c
														, Description__c
														, Distributor_Responsibility__c
														, REVVY__SuggestedPrice__c
														, (SELECT
																Id
																, REVVY__Quantity__c
																, Support_Plus_Quantity__c
																, REVVY__Catalog_Node__r.Name
																, Product_ID2__c
																, Description__c
																, Distributor_Responsibility__c
																, REVVY__SuggestedPrice__c
															FROM
																REVVY__QuoteItemSubLine__r
															ORDER BY
																REVVY__Catalog_Node__r.Name)
													FROM
														REVVY__MnQuoteItem__c
													WHERE
														REVVY__Quote__c = :quoteId]
			) {
				ToroSupportPlusItem wrapper = new ToroSupportPlusItem(quoteItem);
				if (wrapper.isSupportPlusItem) {
					result.supportPlusItems.add(wrapper);
				}

				else {
					result.quoteItems.add(wrapper);
				}
			}
		}

		catch (Exception e) {
			result.success = false;
		}

		return result;
	}
}