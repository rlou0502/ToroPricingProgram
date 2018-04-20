public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean success                             			{ get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 								{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> quoteItems 					{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> supportPlusOnlyItems 			{ get; set; }
	@AuraEnabled public List<DistRespPair> distributorResponsibilities 			{ get; private set; }

	public class DistRespPair implements Comparable {
		@AuraEnabled public Decimal value;
		@AuraEnabled public String label;

		public DistRespPair(Decimal value, String label) {
			this.value = value;
			this.label = label;
		}

		public Integer compareTo(Object compareTo) {
			DistRespPair compareToObj = (DistRespPair) compareTo;
			if (this.value == compareToObj.value) return 0;
			if (this.value > compareToObj.value) return 1;
			return -1;
		}
	}

	public ToroSupportPlusData() {
		this.quoteItems                  = new List<ToroSupportPlusItem>();
		this.supportPlusOnlyItems        = new List<ToroSupportPlusItem>();
		this.distributorResponsibilities = new List<DistRespPair>();
		this.success                     = true;
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
					Toro_Total_DNet__c // Total DNet BEFORE deducting Toro Contribution for Support Plus Items
					, Id
					, Name
					, Toro_Support_Plus_Allowance__c // (SHOWN)
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

			final Set<Decimal> distRespOptions = new Set<Decimal>();
			for (Support_Plus_Contribution__c contrib : contributions) {
				if (
					quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
					&& quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
				) {
					quote.Distributor_Responsibility__c = contrib.Distributor_Contribution__c;
					// break;
				}

				distRespOptions.add(contrib.Distributor_Contribution__c);
			}

			for (Decimal option : distRespOptions) {
				DistRespPair newOption;
				if (option == quote.Distributor_Responsibility__c) {
					newOption = new DistRespPair(option, option.format() + '% (default)');
				}

				else {
					newOption = new DistRespPair(option, option.format() + '%');
				}

				result.distributorResponsibilities.add(newOption);
			}

			result.quote = quote;

			// get quote items and support plus items
			final List<REVVY__MnQuoteItem__c> originalQuoteItems = new List<REVVY__MnQuoteItem__c>();
			final Map<Id,REVVY__MnQuoteItem__c> quoteItemIdToSupportPlusItemMap = new Map<Id,REVVY__MnQuoteItem__c>();
			for (REVVY__MnQuoteItem__c quoteItem : getQuoteItems(quoteId)) {
				if (quoteItem.Support_Plus_Original_Item__c == null) {
					originalQuoteItems.add(quoteItem);
				}

				else {
					quoteItemIdToSupportPlusItemMap.put(quoteItem.Support_Plus_Original_Item__c, quoteItem);
				}
			}

			// build wrappers
			for (REVVY__MnQuoteItem__c quoteItemObj : originalQuoteItems) {
				ToroSupportPlusItem wrapper = new ToroSupportPlusItem(quoteItemObj);
				if (quoteItemObj.Is_Support_Plus_Item_Only__c) {
					result.supportPlusOnlyItems.add(wrapper);
				}

				else if (quoteItemIdToSupportPlusItemMap.containsKey(quoteItemObj.Id)) {
					final REVVY__MnQuoteItem__c supportPlusItem = quoteItemIdToSupportPlusItemMap.get(quoteItemObj.Id);
					wrapper.quantity += supportPlusItem.REVVY__Quantity__c;
					wrapper.spQuantity = supportPlusItem.REVVY__Quantity__c;
				}

				result.quoteItems.add(wrapper);
			}
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
	public static List<REVVY__MnQuoteItem__c> getQuoteItems(Id quoteId) {
		return [
			SELECT
				Id
				, REVVY__Product_Name_F__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Product_ID_F__c
				, REVVY__Id__c
				, REVVY__Quantity__c
				, Support_Plus_Quantity__c
				, Is_Support_Plus_Item_Only__c
				, Description__c
				, Distributor_Responsibility__c
				, REVVY__PricelistLine__c
				, REVVY__Catalog_Node__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Support_Plus_Original_Item__c
				, Support_Plus_Original_Item__r.REVVY__Quantity__c
				, (SELECT
						Id
						, REVVY__Quantity__c
						, Support_Plus_Quantity__c
						, REVVY__Catalog_Node__r.Name
						, Product_ID2__c
						, Description__c
						, Distributor_Responsibility__c
						, REVVY__SuggestedPrice__c
						, REVVY__Price__c
						, REVVY__Id__c
						, Support_Plus_Item__r.REVVY__Quantity__c
					FROM
						REVVY__QuoteItemSubLine__r
					ORDER BY
						REVVY__Catalog_Node__r.Name)
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
		];
	}
}