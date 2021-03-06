public with sharing class ToroSupportPlusHelper {
	public static final String DETERMINES_SP_ALLOWANCE_DNET = 'Total DNet Only';
	public static final String DETERMINES_SP_ALLOWANCE_AWARD = 'Award Only';
	public static final String DETERMINES_SP_ALLOWANCE_DNET_AND_AWARD = 'Total DNet and Award';


	// holds sequence gen record for MnQuoteItem__c
	private static REVVY__MnSequenceGen__c qiSequenceGen;

	//  Pricing Program ExternalId__c => Pricing Program
	private static Map<String,REVVY__MnStrategy1__c> pricingProgramMap = new Map<String,REVVY__MnStrategy1__c>();

	private static Map<Id,List<REVVY__MnQuoteItemSubline__c>> quoteItemIdToSublinesMap = new  Map<Id, List<REVVY__MnQuoteItemSubline__c>>();

	/**
	 *
	 * generates a new sequence number for Quote Items
	 *
	 * @return new sequence number
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
	 * saves the latest sequence number for the Quote Item (THIS MUST BE CALLED WHENEVER NEW QUOTE ITEMS ARE CREATED
	 * USING THIS NUMBER)
	 *
	 */
	public static void saveSequenceGen() {
		if (qiSequenceGen != null) update qiSequenceGen;
	}

	/**
	 *
	 * builds map of CPQ Quote Item ID to the wrapper
	 *
	 * @param  wrappers    list of quote item wrappers
	 * @return map of CPQ Quote Item ID => wrapper
	 */
	public static Map<Id,ToroSupportPlusItem> buildQuoteItemWrapperMap(List<ToroSupportPlusItem> wrappers) {
		Map<Id,ToroSupportPlusItem> result = new Map<Id,ToroSupportPlusItem>();
		for (ToroSupportPlusItem wrapper : wrappers) {
			result.put(wrapper.qiObj.Id, wrapper);
		}
		return result;
	}

	/**
	 *
	 * builds map of CPQ subline ID to the wrapper
	 *
	 * @param  wrappers    list of subline wrappers
	 * @return map of CPQ subline ID => wrapper
	 */
	public static Map<Id,ToroSupportPlusItem> buildSublineWrapperMap(List<ToroSupportPlusItem> wrappers) {
		Map<Id,ToroSupportPlusItem> result = new Map<Id,ToroSupportPlusItem>();
		for (ToroSupportPlusItem wrapper : wrappers) {
			result.put(wrapper.sublineObj.Id, wrapper);
		}
		return result;
	}


	/**
	 *
	 * gets the pricing program for the quote
	 *
	 * @param  quote    The CPQ quote record
	 * @return the pricing program record
	 */
	public static REVVY__MnStrategy1__c getPricingProgram(REVVY__MnQuote__c quote) {
		return getPricingProgram(quote.Pricing_Program_Name__c.split(';')[0]);
	}
	public static REVVY__MnStrategy1__c getPricingProgram(String externalId) {
		if (!pricingProgramMap.containsKey(externalId)) {
			REVVY__MnStrategy1__c pricingProgram = [
				SELECT
					Determines_Support_Plus_Allowance__c
					, Maximum_Support_Value_To_Use__c
					, ExternalId__c
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
				, Distributor_Contribution__c
				, Pricing_Program_Name__c
				, DSM_Approved_Amount__c
				, Is_Dirty__c
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
		quote.Distributor_Contribution__c    = CMnQUoteUtil.defaultDecimal(quote.Distributor_Contribution__c);

		for (REVVY__MnQuoteItemSubline__c subline : getSublinesForQuote(quoteId)) {
			if (quoteItemIdToSublinesMap.containsKey(subline.REVVY__QuoteItem__c)) {
				quoteItemIdToSublinesMap.get(subline.REVVY__QuoteItem__c).add(subline);
			}

			else {
				quoteItemIdToSublinesMap.put(
					subline.REVVY__QuoteItem__c
					, new List<REVVY__MnQuoteItemSubline__c> { subline }
				);
			}
		}

		return quote;
	}

	/**
	 *
	 * get CPQ quote items with required fields for support plus
	 *
	 * @param  quoteId
	 * @return list of CPQ quote items
	 */
	public static List<REVVY__MnQuoteItem__c> getQuoteItems(Id quoteId) {
		return [
			SELECT
				Id
				, REVVY__Id__c
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				, Item_Config_ID_Tx__c
				, REVVY__Is_Configuration_Complete__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c
				, REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c
				, REVVY__PricelistLine__c
				, REVVY__Quote__r.Pricing_Program_Name__c
				, Support_Plus_From_Add_New__c
				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Award_Price__c
				, Support_Plus_Original_Item__c
				, Support_Plus_Original_Item__r.Id
				, Support_Plus_Original_Item__r.REVVY__Quantity__c
				, Quote_Item_Extension__c
				, Quote_Item_Extension__r.Id
				, Quote_Item_Extension__r.External_Id__c
				, Quote_Item_Extension__r.Adjusted_Quantity__c
				, Quote_Item_Extension__r.Award_Price__c
				, Quote_Item_Extension__r.Pricing_Program__c // pricing program external Id (String). not a lookup field
				, Quote_Item_Extension__r.Pricing_Program_Overridden__c // indicates if the pricing program is overridden (DOES NOT RESET ONCE IT IS OVERRIDDEN THE FIRST TIME)
				, Quote_Item_Extension__r.Has_Support_Plus__c
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
			ORDER BY
				Description__c asc
		];
	}

	/**
	 *
	 * get CPQ quote items for non-toro page
	 *
	 * @param  quoteId
	 * @return list of CPQ quote items
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
				, REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c
				, REVVY__PricelistLine__c
				, Quote_Item_Extension__c
				, Quote_Item_Extension__r.Id
				, Quote_Item_Extension__r.External_Id__c
				, Quote_Item_Extension__r.Adjusted_Quantity__c
                , Quote_Item_Extension__r.Award_Price__c
				, Quote_Item_Extension__r.Has_Support_Plus__c
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
				AND REVVY__Catalog_Node__r.Non_Toro_Product__c = true
		];
	}

	/**
	 *
	 * get sublines for the quote item
	 *
	 * @param  quoteItemId    the id of the CPQ quote item
	 * @return list of CPQ sublines
	 */
	public static List<REVVY__MnQuoteItemSubline__c> getSublines(Id quoteItemId) {
		if (quoteItemIdToSublinesMap.containsKey(quoteItemId)) {
			return quoteItemIdToSublinesMap.get(quoteItemId);
		}

		return [
			SELECT
				Id
				, REVVY__Id__c // why is this null for regular quote items?
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				, REVVY__QuoteItem__c
				, REVVY__QuoteItem__r.REVVY__Quote__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c
				, REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c
				, REVVY__PricelistLine__c
				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Award_Price__c
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

	public static List<REVVY__MnQuoteItemSubline__c> getSublinesForQuote(Id quoteId) {
		return [
			SELECT
				Id
				, REVVY__Id__c // why is this null for regular quote items?
				, REVVY__Quantity__c
				, REVVY__SuggestedPrice__c
				, REVVY__Price__c
				, Award_Price__c
				, Description__c
				, REVVY__QuoteItem__c
				, REVVY__QuoteItem__r.REVVY__Quote__c
				, REVVY__Catalog_Node__c
				, REVVY__Catalog_Node__r.Name
				, REVVY__Catalog_Node__r.REVVY__Id__c
				, REVVY__Catalog_Node__r.Non_Toro_Product__c
				, REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c
				, REVVY__PricelistLine__c
				, Support_Plus_Original_Price__c
				, Support_Plus_Original_Award_Price__c
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
				REVVY__QuoteItem__r.REVVY__Quote__c = :quoteId
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
	public static List<Support_Plus_Contribution__c> getSupportPlusContributions(REVVY__MnQuote__c quote) {
		return getSupportPlusContributions(quote.Pricing_Program_Name__c.split(';')[0]);
	}
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
				, Award_Price_as_Percent_of_DN_Low__c
				, Award_Price_as_Percent_of_DN_High__c
				, Maximum_Support__c
				, Maximum_Support_Percent__c
			FROM
				Support_Plus_Plan__c
			WHERE
				Pricing_Program__r.ExternalId__c = :pricingProgramExtId
			ORDER BY
				Total_DNet_Low__c
		];
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static Decimal getDistributorResponsibility(REVVY__MnQuote__c quote) {
		Decimal defaultDistRespValue = 50.0;
		// Set<Decimal> distRespValueSet = new Set<Decimal>();
		List<Support_Plus_Contribution__c> contribs = ToroSupportPlusHelper.getSupportPlusContributions(quote);
		for (Support_Plus_Contribution__c contrib : contribs) {
			if (
				quote.Toro_Blended_Percent_of_DN__c >= contrib.Award_Price_Low__c
				&& quote.Toro_Blended_Percent_of_DN__c < contrib.Award_Price_High__c
			) {
				defaultDistRespValue = contrib.Distributor_Contribution__c;
			}
		}

		return defaultDistRespValue;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public static ToroPricingProgram getPricingProgramWithoutSecondaryProgramItems(Id quoteId, String pricingProgram, List<REVVY__MnStrategy4__c> quoteItemList) {
		System.debug('\n\n@@getPricingProgramWithoutSecondaryProgramItems\n\n');
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
		REVVY__MnQuote__c newQuote = new REVVY__MnQuote__c(Id = quoteId);
		pp.quote = newQuote;
		System.debug('\n\n@@pp.quote: ' +pp.quote + '\n\n');
		if (quoteItemList != null) {
			pp.quoteItems = quoteItemList;
		}

		else {
			pp.initializeQuoteItems(quoteId);
		}
		List<Revvy__MnStrategy4__c> filteredQuoteItems = new List<Revvy__MnStrategy4__c>();
		for (Revvy__MnStrategy4__c qi : pp.quoteItems) {
			if (String.isNotBlank(qi.Pricing_Program__c)) {
				ToroPricingProgramData qiPPD = new ToroPricingProgramData(qi.pricing_program__c);
				if (ppd.externalId.equalsIgnoreCase(qiPPD.externalId)) {
					filteredQuoteItems.add(qi);
				}
			}
		}
		System.debug('\n\n@@filteredQuoteItems: ' + filteredQuoteItems + '\n\n');
		pp.quoteItems = pp.calculateExtendedFields(filteredQuoteItems);
		return pp;
	}

	/**
	 *
	 * clears the SP+ values on the quote
	 *
	 * @param  quote    the quote record
	 */
	public static void clearSupportPlusValuesOnQuote(REVVY__MnQuote__c quote) {
		quote.Toro_Support_Plus_Allowance__c      = null;
		quote.Distributor_Responsibility__c       = null;
		quote.Toro_Support_Plus_Allowance_Used__c = null;
		quote.SP_Total_Extended_DNET__c           = null;
		quote.SP_Adjusted_Toro_Award__c           = null;
		quote.SP_Adjusted_Ext_Award__c            = null;
		quote.SP_Toro_Responsibility__c           = null;
		quote.SP_Ext_Dist_Responsibility__c       = null;
	}
}