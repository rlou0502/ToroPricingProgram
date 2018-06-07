public with sharing class ToroSupportPlusHelper {
	private static REVVY__MnSequenceGen__c qiSequenceGen;

	private static Map<String,REVVY__MnStrategy1__c> pricingProgramMap = new Map<String,REVVY__MnStrategy1__c>();

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static Decimal generateQiExtId() {
		if (qiSequenceGen == null) {
			qiSequenceGen = [SELECT
								REVVY__CurrentValue__c
							FROM
								REVVY__MnSequenceGen__c
							WHERE
								REVVY__ObjectName__c = 'MnQuoteItem__c' LIMIT 1
			];
		}

		return ++qiSequenceGen.REVVY__CurrentValue__c;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static void saveSequenceGen() {
		if (qiSequenceGen != null) update qiSequenceGen;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static Map<Id,ToroSupportPlusItem> buildQuoteItemWrapperMap(List<ToroSupportPlusItem> wrappers) {
		Map<Id,ToroSupportPlusItem> result = new Map<Id,ToroSupportPlusItem>();
		for (ToroSupportPlusItem wrapper : wrappers) {
			result.put(wrapper.qiObj.Id, wrapper);
		}
		return result;
	}

	public static Map<Id,ToroSupportPlusItem> buildSublineWrapperMap(List<ToroSupportPlusItem> wrappers) {
		Map<Id,ToroSupportPlusItem> result = new Map<Id,ToroSupportPlusItem>();
		for (ToroSupportPlusItem wrapper : wrappers) {
			result.put(wrapper.sublineObj.Id, wrapper);
		}
		return result;
	}

	public static REVVY__MnStrategy1__c getPricingProgram(String externalId) {
		if (!pricingProgramMap.containsKey(externalId)) {
			REVVY__MnStrategy1__c pricingProgram = [
				SELECT
					Determines_Support_Plus_Allowance__c
				FROM
					REVVY__MnStrategy1__c
				WHERE
					ExternalId__c = :externalId
				LIMIT 1
			];

			pricingProgramMap.put(externalId, pricingProgram);
		}

		return pricingProgramMap.get(externalId);
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static REVVY__MnQuote__c getQuote(Id quoteId) {
		REVVY__MnQuote__c quote = [
			SELECT
				Toro_Total_DNet__c // Total DNet BEFORE deducting Toro Contribution for Support Plus Items. Used to get Maximum Support value
				, Toro_Award__c // Used to get Maximum Support value for Base with Value Dollar pricing Program
				, SP_Adjusted_Toro_Award__c
				, Id
				, Name
				, Toro_Support_Plus_Allowance__c // (SHOWN)
				, Toro_Support_Plus_Allowance_Used__c
				, Toro_Blended_Percent_of_DN__c
				, SP_Toro_Responsibility__c // (SHOWN) (Toro Contribution/Responsibility)
				, SP_Ext_Dist_Responsibility__c
				, SP_Adjusted_Ext_Award__c
				, SP_Total_Extended_DNET__c // (SHOWN) Total DNet AFTER deducting Toro Contribution for Support Plus Items
				, Distributor_Responsibility__c // (SHOWN) Set on load of Support Plus page. Can be overriden by user.
				, Pricing_Program_Name__c
			FROM
				REVVY__MnQuote__c
			WHERE
				Id = :quoteId
		];

		quote.Toro_Support_Plus_Allowance__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Support_Plus_Allowance__c);
		quote.SP_Toro_Responsibility__c      = CMnQuoteUtil.defaultDecimal(quote.SP_Toro_Responsibility__c);
		quote.SP_Ext_Dist_Responsibility__c  = CMnQuoteUtil.defaultDecimal(quote.SP_Ext_Dist_Responsibility__c);
		quote.SP_Adjusted_Ext_Award__c       = CMnQuoteUtil.defaultDecimal(quote.SP_Adjusted_Ext_Award__c);
		quote.SP_Total_Extended_DNET__c      = CMnQuoteUtil.defaultDecimal(quote.SP_Total_Extended_DNET__c);
		return quote;
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
				Id // sfid
				, REVVY__Id__c
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				// , Distributor_Responsibility__c
				// , REVVY__Product_Name_F__c // REVVY__Catalog_Node__r.Name
				// , REVVY__Product_ID_F__c // REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c

				, REVVY__PricelistLine__c

				, Support_Plus_From_Add_New__c
				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Item__c
				, Support_Plus_Original_Item__r.Id
				, Support_Plus_Original_Item__r.REVVY__Quantity__c
				, Quote_Item_Extension__c
				, Quote_Item_Extension__r.Id
				, Quote_Item_Extension__r.External_Id__c
				, Quote_Item_Extension__r.Adjusted_Quantity__c
				, Quote_Item_Extension__r.Award_Price__c
				, Quote_Item_Extension__r.Pricing_Program__c
				, Quote_Item_Extension__r.Pricing_Program_Overridden__c
				/*
				, (SELECT
						Id
						, REVVY__Id__c // why is this null for regular quote items?
						, REVVY__Quantity__c
						, REVVY__SuggestedPrice__c
						, Description__c
						// , Distributor_Responsibility__c

						, REVVY__QuoteItem__c

						// , Product_ID2__c // REVVY__Catalog_Node__r.REVVY__Id__c
						, REVVY__Catalog_Node__c
						, REVVY__Catalog_Node__r.Name
						, REVVY__Catalog_Node__r.REVVY__Id__c

						, REVVY__PricelistLine__c

						, Support_Plus_Original_Price__c
						, Support_Plus_Original_Item__c
						, Support_Plus_Original_Item__r.Id
						, Support_Plus_Original_Item__r.REVVY__Quantity__c
						, Quote_Item_Subline_Extension__r.Id
						, Quote_Item_Subline_Extension__r.External_Id__c
						, Quote_Item_Subline_Extension__r.Adjusted_Quantity__c
					FROM
						REVVY__QuoteItemSubLine__r
					ORDER BY
						REVVY__Catalog_Node__r.Name)
					*/
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
		      //And REVVY__Catalog_Node__r.Non_Toro_Product__c = false
		];
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static List<REVVY__MnQuoteItem__c> getNonToroQuoteItems(Id quoteId) {
		return [
			SELECT
				Id
				, REVVY__Id__c
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c
				, REVVY__PricelistLine__c
				, Quote_Item_Extension__c
				, Quote_Item_Extension__r.Id
				, Quote_Item_Extension__r.External_Id__c
				, Quote_Item_Extension__r.Adjusted_Quantity__c
                , Quote_Item_Extension__r.Award_Price__c
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
				//AND REVVY__Catalog_Node__r.Non_Toro_Product__c = false
		];
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static List<REVVY__MnQuoteItemSubline__c> getSublines(Id quoteItemId) {
		return [
			SELECT
				Id
				, REVVY__Id__c // why is this null for regular quote items?
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				// , Distributor_Responsibility__c

				, REVVY__QuoteItem__c

				// , Product_ID2__c // REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c

				, REVVY__PricelistLine__c

				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Item__c
				, Support_Plus_Original_Item__r.Id
				, Support_Plus_Original_Item__r.REVVY__Quantity__c
				, Quote_Item_Subline_Extension__r.Id
				, Quote_Item_Subline_Extension__r.External_Id__c
				, Quote_Item_Subline_Extension__r.Adjusted_Quantity__c
				, Quote_Item_Subline_Extension__r.Award_Price__c
			FROM
				REVVY__MnQuoteItemSubLine__c
			WHERE
				REVVY__QuoteItem__c = :quoteItemId
			ORDER BY
				REVVY__Catalog_Node__r.Name];
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static List<Support_Plus_Contribution__c> getSupportPlusContributions(String pricingProgramExtId) {
		return [
			SELECT
				Award_Price_Low__c
				, Award_Price_High__c
				, Toro_Contribution__c
				, Distributor_Contribution__c
			FROM
				Support_Plus_Contribution__c
			WHERE
				Pricing_Program__r.ExternalId__c = :pricingProgramExtId
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
	public static List<Support_Plus_Plan__c> getSupportPlusPlans(String pricingProgramExtId) {
		return [
			SELECT
				Total_DNet_Low__c
				, Total_DNet_High__c
				, Maximum_Support__c
			FROM
				Support_Plus_Plan__c
			WHERE
				Pricing_Program__r.ExternalId__c = :pricingProgramExtId
			ORDER BY
				Total_DNet_Low__c
		];
	}
}