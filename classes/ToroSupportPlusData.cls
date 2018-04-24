public with sharing class ToroSupportPlusData {

	@AuraEnabled public Boolean success                             			{ get; private set; }
	@AuraEnabled public REVVY__MnQuote__c quote 								{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> quoteItems 					{ get; set; }
	@AuraEnabled public List<ToroSupportPlusItem> supportPlusOnlyItems 			{ get; set; }
	@AuraEnabled public List<DistRespPair> distributorResponsibilities 			{ get; private set; }

	public class DistRespPair implements Comparable {
		@AuraEnabled public Decimal value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		public DistRespPair(Decimal value, String label) {
			this.value = value;
			this.label = label;
			this.selected = false;
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
					Award_Price_Low__c asc
			];
			System.debug('\n\n@@contributions: ' + contributions + '\n\n');

			final Set<Decimal> distRespOptions = new Set<Decimal>();
			Decimal defaultResponsibility = 50.00;
			for (Support_Plus_Contribution__c contrib : contributions) {
				if (
					quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
					&& quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
				) {
					defaultResponsibility = contrib.Distributor_Contribution__c;
					// quote.Distributor_Responsibility__c = contrib.Distributor_Contribution__c;
					// break;
				}

				distRespOptions.add(contrib.Distributor_Contribution__c);
			}

			if (quote.Distributor_Responsibility__c == null) {
				quote.Distributor_Responsibility__c = defaultResponsibility;
			}

			for (Decimal optionValue : distRespOptions) {
				DistRespPair newOption;
				if (optionValue == defaultResponsibility) {
					newOption = new DistRespPair(optionValue, optionValue.format() + '% (default)');
				}

				else {
					newOption = new DistRespPair(optionValue, optionValue.format() + '%');
				}

				if (optionValue == quote.Distributor_Responsibility__c) {
					newOption.selected = true;
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
				for (ToroSupportPlusItem sublineWrapper : wrapper.sublines) {
				}
				if (quoteItemObj.Is_Support_Plus_Item_Only__c) {
					wrapper.spQuantity = quoteItemObj.REVVY__Quantity__c;
					result.supportPlusOnlyItems.add(wrapper);

				}

				else if (quoteItemIdToSupportPlusItemMap.containsKey(quoteItemObj.Id)) {
					final REVVY__MnQuoteItem__c supportPlusItem = quoteItemIdToSupportPlusItemMap.get(quoteItemObj.Id);
					wrapper.quantity += supportPlusItem.REVVY__Quantity__c;
					wrapper.spQuantity = supportPlusItem.REVVY__Quantity__c;
					if (wrapper.dnetPrice == 0) {
						wrapper.dnetPrice = quoteItemObj.Support_Plus_Original_Price__c;
					}
					result.quoteItems.add(wrapper);
				}

				else {
					result.quoteItems.add(wrapper);
				}
			}

			System.debug('\n\n@@result.quote: ' + result.quote + '\n\n');
			System.debug('\n\n@@result.distributorResponsibilities: ' + result.distributorResponsibilities + '\n\n');
			System.debug('\n\n@@result.quoteItems: ' + result.quoteItems + '\n\n');
			System.debug('\n\n@@result.supportPlusOnlyItems: ' + result.supportPlusOnlyItems + '\n\n');
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
	public static Boolean removeSupportPlusItemsForQuote(Id quoteId) {
		Boolean wasSuccessful = true;
		try {
			final List<REVVY__MnQuoteItem__c> quoteItemsToDelete = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnQuoteItem__c> quoteItemsToUpdate = new List<REVVY__MnQuoteItem__c>();

			final List<REVVY__MnQuoteItem__c> quoteItems = getQuoteItems(quoteId);

			final List<REVVY__MnQuoteItem__c> originalQuoteItems = new List<REVVY__MnQuoteItem__c>();
			final Map<Id,REVVY__MnQuoteItem__c> quoteItemIdToSupportPlusItemMap = new Map<Id,REVVY__MnQuoteItem__c>();

			// build map of the original quote item to the support plus item
			for (REVVY__MnQuoteItem__c quoteItem : quoteItems) {
				if (quoteItem.Support_Plus_Original_Item__c == null) {
					originalQuoteItems.add(quoteItem);
				}

				else {
					quoteItemIdToSupportPlusItemMap.put(quoteItem.Support_Plus_Original_Item__c, quoteItem);
				}
			}

			// for quote items that also have a support plus item, the quantity allocated to Support Plus
			// needs to be restored to the original quote item. Update the quantity and prepare it to be updated.
			// Also, mark the support plus quote item for deletion.
			for (REVVY__MnQuoteItem__c originalQuoteItem : originalQuoteItems) {
				if (quoteItemIdToSupportPlusItemMap.containsKey(originalQuoteItem.Id)) {
					REVVY__MnQuoteItem__c supportPlusItem = quoteItemIdToSupportPlusItemMap.get(originalQuoteItem.Id);
					Decimal qty = originalQuoteItem.REVVY__Quantity__c;
					Decimal spQty = supportPlusItem.REVVY__Quantity__c;
					originalQuoteItem.REVVY__Quantity__c = qty + spQty;
					quoteItemsToUpdate.add(originalQuoteItem);
					quoteItemsToDelete.add(supportPlusItem);
				}
			}

			// re-check the quote items and delete any support plus items that were added via "add new"
			for (REVVY__MnQuoteItem__c quoteItem : quoteItems) {
				if (quoteItem.Is_Support_Plus_Item_Only__c) {
					quoteItemsToDelete.add(quoteItem);
				}
			}

			System.debug('\n\n@@quoteItemsToUpdate: ' + quoteItemsToUpdate + '\n\n');
			System.debug('\n\n@@quoteItemsToDelete: ' + quoteItemsToDelete + '\n\n');
		}

		catch (Exception e) {
			wasSuccessful = false;
		}

		return wasSuccessful;
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
				, Description__c
				// , Distributor_Responsibility__c
				, REVVY__PricelistLine__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__SuggestedPrice__c
				, Is_Support_Plus_Item_Only__c
				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Item__c
				, Support_Plus_Original_Item__r.Id
				, Support_Plus_Original_Item__r.REVVY__Quantity__c
				, (SELECT
					Id
					, Support_Plus_Item__c
					FROM
						Toro_Quote_Item__r) // Toro Quote Item (REVVY__MnStrategy4__c)
				, (SELECT
						Id
						, REVVY__Quantity__c
						, REVVY__Catalog_Node__r.Name
						, Product_ID2__c
						, Description__c
						// , Distributor_Responsibility__c
						, REVVY__PricelistLine__c
						, REVVY__Catalog_Node__c
						, REVVY__QuoteItem__c
						, REVVY__SuggestedPrice__c
						, REVVY__Id__c
						, Support_Plus_Original_Price__c
						, Support_Plus_Original_Item__c
						, Support_Plus_Original_Item__r.Id
						, Support_Plus_Original_Item__r.REVVY__Quantity__c
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