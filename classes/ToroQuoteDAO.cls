/**
 * ToroQuoteDAO
 *
 * contains all queries for pre calc and executive summary
 *
 * @author Scott Santarromana
 */
public class ToroQuoteDAO {
	public static Revvy__MnQuote__c retrieveQuoteWithFieldset(Id quoteId) {
		String quoteQuery = 'select ' + CMnQuoteUtil.getQuoteQuery('Setup_Fee__c, Toro_Support_Plus_Allowance__c, Toro_Blended_Percent_of_DN__c, SP_Toro_Responsibility__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c,Blended_Percent_of_DN__c') + ' from Revvy__MnQuote__c where id=:quoteId';
        Revvy__MnQuote__c q = (Revvy__MnQuote__c) Database.query(quoteQuery);
        return q;
	}
    public static final Set<String> QUOTE_FIELDS = new Set<String> {
        'Id'
        , 'Name'
        , 'CurrencyIsoCode'
        //, 'REVVY__ContractStartDate__c' (deprecated)
        //, 'REVVY__ContractEndDate__c' (deprecated)
        , 'REVVY__StartDateContract__c'
        , 'REVVY__EndDateContract__c'
        , 'REVVY__Account__r.Name'
        , 'REVVY__Version_Number__c'
        , 'REVVY__Id__c'
        , 'REVVY__One_Time_Unit_Price_S__c'
        , 'Extended_Target_Price__c'
        , 'Extended_Pat1__c'
        , 'Extended_Pat2__c'
        , 'HISS_Deal_Margin__c'
        , 'HISS_Target_Margin__c'
        , 'HISS_Total_Cost_Price__c'
        , 'HISS_Total_List_Price__c'
        , 'HISS_Total_Sell_Price__c'
    };

    public static final Set<String> QUOTE_SOLUTION_ATTRIBUTE_FIELDS = new Set<String> {
        'REVVY__AttributeValue__c'
        , 'REVVY__CatalogAttribute__r.REVVY__Format__c'
        , 'REVVY__CatalogAttribute__r.REVVY__Id__c'
    };

    public static final Set<String> QUOTE_ITEM_FIELDS = new Set<String> {
        'Id'
        , 'REVVY__Id__c'
        , 'Name'
        , 'REVVY__Quote__c'
        , 'REVVY__Extended_Price_F__c'
        , 'REVVY__Product_Name_F__c'
        , 'REVVY__Price__c'
        , 'REVVY__TotalCostPrice__c'
        , 'REVVY__Catalog_Node__c'
        , 'REVVY__Catalog_Node__r.Id'
        , 'REVVY__Catalog_Node__r.REVVY__Id__c'
        , 'Off_MSRP__c'
        , 'Award_Price__c'
        , 'Rebate_as_a_of_DN__c'
        , 'Fee_Percentage__c'
        , 'Part_Percentage__c'
        , 'Toro_Product_Tier__c'
        , 'MSRP_Price__c'
        , 'Original_off_MSRP__c'
        , 'Oroginal_of_DNet__c'
        , 'Unit_Award_Overridden__c'
        , 'QuoteItem__r.REVVY__Catalog_Node__r.REVVY__Id__c'
        , 'QuoteItem__r.REVVY__Catalog_Node__r.Name'
        , 'Select_Price_Program_Type__c'
        , 'QuoteItem__r.REVVY__SuggestedPrice__c'
        , 'Misc_Style__c '
        , 'DNet_Price__c'
        , 'QuoteItem__r.REVVY__Price__c'
        , 'Off_MSRP__c'
        , 'Selected_Off_MSRP__c'
        , 'Pricing_Program__c'
        , 'Select_a_Price_Method__c'
        , 'Award_of_DN__c'
        , 'Standard_Price__c'
    };

    public static final Set<String> QUOTE_ITEM_ATTRIBUTE_FIELDS = new Set<String> {
        'REVVY__QuoteItem__c'
        , 'REVVY__ActualValue__c'
        , 'REVVY__AttributeValue__c'
        , 'REVVY__CatalogAttribute__r.Name'
        , 'REVVY__CatalogAttribute__r.REVVY__Id__c'
        , 'REVVY__CatalogAttribute__r.REVVY__Format__c'
    };

    public static final Set<String> SUBLINE_FIELDS = new Set<String> {
        'Id'
        , 'Name'
        , 'REVVY__Id__c'
        , 'REVVY__QuoteItem__c'
        , 'REVVY__Catalog_Node__c'
        , 'REVVY__Catalog_Node__r.Name'
        , 'REVVY__Catalog_Node__r.Id'
        , 'REVVY__Catalog_Node__r.REVVY__Id__c'
        , 'REVVY__TotalCostPrice__c'
        , 'REVVY__Extended_Price_F__c'
        , 'Award_Price__c'
        , 'Rebate_as_of_DNet__c'
        , 'Fee_Percentage__c'
        , 'Part_Percentage__c'
        , 'Toro_Product_Tier__c'
        , 'Exclude_from_Rebate__c'
        , 'Unit_Award_Overridden__c'
        , 'Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.REVVY__Id__c'
        , 'Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name'
		, 'DNet_Price_2__c '
        , 'Misc_Style__c'
        , 'DNet_Price__c '
        , 'Standard_Price__c'
        , 'Quote_Item_Sub_Line__r.REVVY__Price__c'
        , 'Quote_Item_Sub_Line__r.REVVY__SuggestedPrice__c'
        , 'Toro_Quote_Item__r.Select_a_Price_Method__c'
        , 'Percent_Off_MSRP__c'
        , 'Percent_of_DNet__c'
    };

    public static final Set<String> SUBLINE_ATTRIBUTE_FIELDS = new Set<String> {
        'REVVY__QuoteItemSubLine__c'
        , 'REVVY__QuoteItemSubline__r.REVVY__QuoteItem__c'
        , 'REVVY__ActualValue__c'
        , 'REVVY__AttributeValue__c'
        , 'REVVY__CatalogAttribute__r.Name'
        , 'REVVY__CatalogAttribute__r.REVVY__Id__c'
        , 'REVVY__CatalogAttribute__r.REVVY__Format__c'
    };

    public static final Set<String> CATALOG_NODE_FIELDS = new Set<String> {
        'Id'
        , 'Name'
        , 'REVVY__LocaleName_F__c'
        , 'REVVY__Id__c'
        , 'REVVY__Type__c'
        , 'Article_NR__c'
        , 'Pre_Calc_Category__c'
        , 'Pre_Calc_Description__c'
        , 'Pre_Calc_Section__c'
        , 'Pre_Calc_GL_Account__c'
        , 'Source_Dimension__c'
    };

    public static final Set<String> CATALOG_NODE_ATTRIBUTE_FIELDS = new Set<String> {
        'Name'
        , 'REVVY__Catalog_Attribute__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Id__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Format__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Default_Value__r.REVVY__Value__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Default_Value__r.REVVY__Value_Number__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Default_Value__r.REVVY__Value_Boolean__c'
        , 'REVVY__Catalog_Attribute__r.REVVY__Default_Value__r.REVVY__Value_Display__c'
        , 'REVVY__Catalog_Node__c'
        , 'REVVY__Catalog_Node__r.REVVY__Id__c'
        , 'REVVY__Id__c'
        , 'REVVY__Value__c'
    };

    public static final Set<String> PRICE_LIST_LINE_FIELDS = new Set<String> {
        'Id'
        , 'Name'
        , 'TargetPrice__c'
        , 'REVVY__ListedPrice__c'
        , 'REVVY__CostPrice__c'
        , 'PAT1__c'
        , 'PAT2__c'
        , 'REVVY__Product__c'
        , 'REVVY__Product__r.REVVY__Id__c'
        , 'REVVY__Product_Name__c'
    };

    /**
     *
     * get the quote
     *
     * @param quoteId
     * @return REVVY__MnQuote__c
     */
    public static REVVY__MnQuote__c getQuote(Id quoteId) {
        return Database.query(buildQuery(
            QUOTE_FIELDS
            , 'REVVY__MnQuote__c'
            , 'Id = :quoteId LIMIT 1'));
    }

    /**
     *
     * get the quote items
     *
     * @param quoteId
     * @return List<REVVY__MnQuoteItem__c>
     */
    public static List<REVVY__MnQuoteItem__c> getQuoteItems(Id quoteId) {
        return Database.query(buildQuery(
            QUOTE_ITEM_FIELDS
            , 'REVVY__MnQuoteItem__c'
            , 'REVVY__Quote__c = :quoteId'));
    }

    /**
     *
     * get the quote item sublines
     *
     * @param quoteItemIds
     * @return List<REVVY__MnQuoteItemSubLine__c>
     */
    public static List<REVVY__MnQuoteItemSubLine__c> getSublines(Set<Id> quoteItemIds) {
        return Database.query(buildQuery(
            SUBLINE_FIELDS
            , 'REVVY__MnQuoteItemSubLine__c'
            , 'REVVY__QuoteItem__c IN :quoteItemIds'));
    }

    /**
     *
     * get the quote solution attributes
     *
     * @param quoteId
     * @return List<REVVY__MnQuoteSolutionAttribute__c>
     */
    public static List<REVVY__MnQuoteSolutionAttribute__c> getQuoteSolutionAttributes(Id quoteId) {
        return Database.query(buildQuery(
            QUOTE_SOLUTION_ATTRIBUTE_FIELDS
            , 'REVVY__MnQuoteSolutionAttribute__c'
            , 'REVVY__QuoteSolution__r.REVVY__Quote__c = :quoteId'));
    }

    /**
     *
     * get the quote item attributes
     *
     * @param  quoteId
     * @return List<REVVY__MnQuoteItemAttribute__c>
     */
    public static List<REVVY__MnQuoteItemAttribute__c> getQuoteItemAttributes(Id quoteId) {
        return Database.query(buildQuery(
            QUOTE_ITEM_ATTRIBUTE_FIELDS
            , 'REVVY__MnQuoteItemAttribute__c'
            , 'REVVY__QuoteItem__r.REVVY__Quote__c = :quoteId'
        ));
    }

    /**
     *
     * get the subline attributes
     *
     * @param  quoteId
     * @return List<REVVY__MnQiSubLineAttribute__c>
     */
    public static List<REVVY__MnQiSubLineAttribute__c> getSublineAttributes(Id quoteId) {
        return Database.query(buildQuery(
            SUBLINE_ATTRIBUTE_FIELDS
            , 'REVVY__MnQiSubLineAttribute__c'
            , 'REVVY__QuoteItemSubLine__r.REVVY__QuoteItem__r.REVVY__Quote__c = :quoteId'
        ));
    }

    /**
     *
     * get the catalog nodes
     *
     * @param quoteItems
     * @param sublines
     * @return List<REVVY__MnCatalogNode__c>
     */
    public static List<REVVY__MnCatalogNode__c> getCatalogNodes(List<REVVY__MnQuoteItem__c> quoteItems
                                                                , List<REVVY__MnQuoteItemSubLine__c> sublines
    ) {
        final List<Id> catalogNodeIds = new List<Id>();
        if (quoteItems != null) {
            for (REVVY__MnQuoteItem__c quoteItem : quoteItems) {
                catalogNodeIds.add(quoteItem.REVVY__Catalog_Node__c);
            }
        }

        if (sublines != null) {
            for (REVVY__MnQuoteItemSubLine__c subline : sublines) {
                catalogNodeIds.add(subline.REVVY__Catalog_Node__c);
            }
        }

        return Database.query(buildQuery(
            CATALOG_NODE_FIELDS
            , 'REVVY__MnCatalogNode__c'
            , 'Id IN :catalogNodeIds'));
    }

    /**
     *
     * get the catalog node attributes
     *
     * @param catalogNodeIds
     * @return List<REVVY__MnCatalogNodeAttr__c
     */
    public static List<REVVY__MnCatalogNodeAttr__c> getCatalogNodeAttributes(Set<Id> catalogNodeIds) {
        return Database.query(buildQuery(
            CATALOG_NODE_ATTRIBUTE_FIELDS
            , 'REVVY__MnCatalogNodeAttr__c'
            , 'REVVY__Catalog_Node__c IN :catalogNodeIds'));
    }

    /**
     *
     * get the price list lines
     *
     * @param catalogNodeIds
     * @return List<REVVY__MnPriceListLine__c>
     */
    public static List<REVVY__MnPriceListLine__c> getPriceListLines(Set<Id> catalogNodeIds) {
        return Database.query(buildQuery(
            PRICE_LIST_LINE_FIELDS
            , 'REVVY__MnPriceListLine__c'
            , 'REVVY__Product__c IN :catalogNodeIds'));
    }

    /**
     *
     * build query string
     *
     * @param fields    the fields to query
     * @param obj       the name of the object
     * @return query string
     */
    public static String buildQuery(Set<String> fields, String obj) {
        return buildQuery(fields, obj, null);
    }
    public static String buildQuery(Set<String> fields, String obj, String criteria) {
        return 'SELECT ' + joinArray(fields, ', ')
                + ' FROM ' + obj
                + (String.isNotBlank(criteria) ? ' WHERE ' + criteria : '');
    }

    /**
     *
     * concatenate list of fields
     *
     * @param values       the list of fields
     * @param separator    the separator
     * @return concatenated string
     */
    private static String joinArray(Set<String> values, String separator) {
        List<String> valuesCopy = new List<String>();
        valuesCopy.addAll(values);
        if (valuesCopy.isEmpty()) return null;
        String result = valuesCopy[0];
        valuesCopy.remove(0);
        while (!valuesCopy.isEmpty()) {
            result += separator + valuesCopy[0];
            valuesCopy.remove(0);
        }
        return result;
    }
}