public with sharing class ToroSupportPlusItem extends ToroQIBase {
	public static final String PP_PRODUCT_TYPE_APPROVED_ALLIED  = 'Approved Allied';
	public static final String PP_PRODUCT_TYPE_NON_TORO_ALLIED  = 'Non-Toro Allied';
	public static final String PP_PRODUCT_TYPE_TRADE_IN         = 'Trade Ins';
	public static final String PP_PRODUCT_TYPE_SERVICE_CONTRACT = 'Service Contracts';

	public static final Set<String> PP_PRODUCT_TYPES_TO_EXCLUDE_SET = new Set<String> {
		'Approved Allied', 'Non-Toro Allied', 'Trade Ins', 'Service Contracts'
	};
	
	@AuraEnabled public List<ToroSupportPlusItem> sublines 			{ get; private set; }
	// @AuraEnabled public REVVY__MnQuoteItem__c qiObj  				{ get; private set; }
	// @AuraEnabled public REVVY__MnStrategy4__c qiExtObj 				{ get; private set; }
	@AuraEnabled public REVVY__MnQuoteItem__c qiSpObj    			{ get; private set; }
	@AuraEnabled public REVVY__MnStrategy4__c qiSpExtObj 			{ get; private set; }
	// @AuraEnabled public REVVY__MnQuoteItemSubLine__c sublineObj 	{ get; private set; }
	// @AuraEnabled public REVVY__MnStrategy5__c sublineExtObj     	{ get; private set; }
	@AuraEnabled public REVVY__MnQuoteItemSubLine__c sublineSpObj   { get; private set; }
	@AuraEnabled public REVVY__MnStrategy5__c sublineSpExtObj		{ get; private set; }

	// @AuraEnabled public Id catalogNodeId { get; private set; }
	// @AuraEnabled public Id pricelistLineId { get; private set; }

	// used in lightning page
	// @AuraEnabled public Id sfid            { get; private set; }
	// @AuraEnabled public String productId   { get; private set; }
	// @AuraEnabled public Decimal dnetPrice  { get; private set; }
	// @AuraEnabled public String description { get; private set; }
	// @AuraEnabled public Decimal quantity   { get; private set; }
	@AuraEnabled public Decimal spQuantity { get; private set; }

	// values for controlling display
	@AuraEnabled public Boolean isFromAddNew { get; private set; }
	@AuraEnabled public String chevronStyle  { get; private set; }
	@AuraEnabled public String displayStyle  { get; private set; }
	@AuraEnabled public Boolean isNonToroProduct { get; private set; }
	@AuraEnabled public Boolean eligibleForSupportPlus { get; private set; }

	// this value is not set here. it is a placeholder for displaying the responsibility
	// based of the quote header
	@AuraEnabled public Decimal distributorResponsibility { private get; private set; }


	/**
	 *
	 * wrap a quote item that doesn't have any quantity allocated to support plus
	 *
	 * @param  qi    the OOTB quote item
	 */
	public ToroSupportPlusItem(REVVY__MnQuoteItem__c qi) {
		super(qi);

		this.sublines = buildSPSublineWrappers(qi);
		// this.qiObj           = qi;
		// this.qiExtObj        = qi.Quote_Item_Extension__r;
		this.qiSpObj         = null;
		this.qiSpExtObj      = null;
		this.isNonToroProduct = qi.REVVY__Catalog_Node__r.Non_Toro_Product__c != null ? qi.REVVY__Catalog_Node__r.Non_Toro_Product__c : false;

		// this.sublineObj      = null;
		// this.sublineExtObj   = null;
		this.sublineSpObj    = null;
		this.sublineSpExtObj = null;

		// this.catalogNodeId = null;
		// this.pricelistLineId = null;

		// this.sfid        = qi.Id;
		// this.productId   = qi.REVVY__Catalog_Node__r.REVVY__Id__c;

		// this.description = String.isBlank(qi.Description__c) ? qi.REVVY__Catalog_Node__r.Name : qi.Description__c;
		// this.quantity    = qi.REVVY__Quantity__c;

		if (qi.Support_Plus_From_Add_New__c) {
			this.isFromAddNew = true;
			this.dnetPrice    = qi.Support_Plus_Original_Price__c;
			this.awardPrice   = qi.Support_Plus_Original_Award_Price__c;
			this.spQuantity   = qi.Quote_Item_Extension__r.Adjusted_Quantity__c;
		}

		else {
			this.isFromAddNew = false;
			this.dnetPrice    = qi.REVVY__SuggestedPrice__c;
			this.spQuantity   = 0;
		}

		this.eligibleForSupportPlus = true;
		/* exclude
		Approved Allied
		Non-Toro Allied
		Trade Ins
		Service Contracts
		*/
		// if (this.isNonToroProduct || this.productId.startsWith('L1')) {
		if (this.isNonToroProduct == null) this.isNonToroProduct = false;
		if (this.isNonToroProduct || PP_PRODUCT_TYPES_TO_EXCLUDE_SET.contains(pricingProgramProductType)) {
			this.eligibleForSupportPlus = false;
		}


		else if (qiObj.Quote_Item_Extension__r.Pricing_Program_Overridden__c) {
			final String qiPricingProgramExtId = qiObj.Quote_Item_Extension__r.Pricing_Program__c.split(';')[0];
			final String quotePricingProgramExtId = qiObj.REVVY__Quote__r.Pricing_Program_Name__c.split(';')[0];
			if (qiPricingProgramExtId != quotePricingProgramExtId) {
				this.eligibleForSupportPlus = false;
			}
		}

		this.chevronStyle = 'right';
		this.displayStyle = 'display:none;';
	}

	/**
	 *
	 * wrap a quote item that has quantity allocated to support plus
	 *
	 * @param  qi     the parent OOTB quote item
	 * @param  spi    the separate support plus quote item
	 */
	public ToroSupportPlusItem(REVVY__MnQuoteItem__c qi, REVVY__MnQuoteItem__c spi) {
		super(qi);
		this.sublines = buildSPSublineWrappers(qi);

		// this.qiObj           = qi;
		// this.qiExtObj        = qi.Quote_Item_Extension__r;
		this.qiSpObj         = spi;
		this.qiSpExtObj      = spi.Quote_Item_Extension__r;

		// this.sublineObj      = null;
		// this.sublineExtObj   = null;
		this.sublineSpObj    = null;
		this.sublineSpExtObj = null;

		// this.catalogNodeId = null;
		// this.pricelistLineId = null;

		// this.sfid        = qi.Id;
		// this.productId   = qi.REVVY__Catalog_Node__r.REVVY__Id__c;
		// this.dnetPrice   = qi.REVVY__SuggestedPrice__c;
		// this.description = String.isBlank(qi.Description__c) ? qi.REVVY__Catalog_Node__r.Name : qi.Description__c;
		// this.quantity    = qi.REVVY__Quantity__c;
		this.spQuantity  = spi.Quote_Item_Extension__r.Adjusted_Quantity__c;
		this.eligibleForSupportPlus = true;

		this.isFromAddNew = false;
		this.chevronStyle = 'right';
		this.displayStyle = 'display:none;';
	}

	/**
	 *
	 * wrap a subline without support plus
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusItem(REVVY__MnQuoteItem__c qi, REVVY__MnQuoteItemSubLine__c subline) {
		super(qi, subline);
		this.sublines        = null;
		// this.qiObj           = qi;
		// this.qiExtObj        = qi.Quote_Item_Extension__r;
		this.qiSpObj         = null;
		this.qiSpExtObj      = null;

		// this.sublineObj      = subline;
		// this.sublineExtObj   = subline.Quote_Item_Subline_Extension__r;
		this.sublineSpObj    = null;
		this.sublineSpExtObj = null;

		// this.catalogNodeId = null;
		// this.pricelistLineId = null;

		// this.sfid          = subline.Id;
		// this.productId     = subline.REVVY__Catalog_Node__r.REVVY__Id__c;
		// this.dnetPrice     = subline.REVVY__SuggestedPrice__c;
		// this.description   = String.isBlank(subline.Description__c) ? subline.REVVY__Catalog_Node__r.Name : subline.Description__c;
		// this.quantity      = subline.REVVY__Quantity__c * qi.REVVY__Quantity__c;
		this.spQuantity    = 0;

		this.eligibleForSupportPlus = true;
		System.debug('\n\n@@this.isNonToroProduct: ' + this.isNonToroProduct + '\n\n');
		System.debug('\n\n@@this.pricingProgramProductType: ' + this.pricingProgramProductType + '\n\n');
		if (this.isNonToroProduct == null) this.isNonToroProduct = false; 
		if (this.isNonToroProduct || PP_PRODUCT_TYPES_TO_EXCLUDE_SET.contains(this.pricingProgramProductType)) {
			this.eligibleForSupportPlus = false; 
		}

		this.isFromAddNew = false;
		this.chevronStyle = '';
		this.displayStyle = 'display:none';
	}

	/**
	 *
	 * wrap a subline that has support plus
	 *
	 * @param  qi           the OOTB quote item
	 * @param  subline      the OOTB subline item
	 * @param  sublineSp    the separate OOTB support plus item
	 */
	public ToroSupportPlusItem(REVVY__MnQuoteItem__c qi, REVVY__MnQuoteItemSubLine__c subline, REVVY__MnQuoteItemSubLine__c sublineSp) {
		super(qi, subline);

		this.sublines        = null;
		// this.qiObj           = null;
		// this.qiExtObj        = null;
		this.qiSpObj         = null;
		this.qiSpExtObj      = null;

		// this.sublineObj      = subline;
		// this.sublineExtObj   = subline.Quote_Item_Subline_Extension__r;
		this.sublineSpObj    = sublineSp;
		this.sublineSpExtObj = sublineSp.Quote_Item_Subline_Extension__r;

		// this.catalogNodeId = null;
		// this.pricelistLineId = null;

		// this.sfid          = subline.Id;
		// this.productId     = subline.REVVY__Catalog_Node__r.REVVY__Id__c;
		// this.dnetPrice     = subline.REVVY__SuggestedPrice__c;
		// this.description   = String.isBlank(subline.Description__c) ? subline.REVVY__Catalog_Node__r.Name : subline.Description__c;
		// this.quantity      = subline.REVVY__Quantity__c * qi.REVVY__Quantity__c;
		this.spQuantity    = sublineSp.Quote_Item_Subline_Extension__r.Adjusted_Quantity__c;

		this.eligibleForSupportPlus = true;

		this.isFromAddNew = false;
		this.chevronStyle = '';
		this.displayStyle = 'display:none';
	}

	/**
	 * description
	 *
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusItem(REVVY__MnCatalogNode__c catalogNode
								, REVVY__MnPriceListLine__c pricelistLine
								, Decimal dnetPrice
								, Decimal awardPrice
								, Decimal spQuantity
	) {
		super(catalogNode, pricelistLine, 0, 0, spQuantity, catalogNode.Name);

		this.sublines        = null;
		// this.qiObj           = null;
		// this.qiExtObj        = null;
		this.qiSpObj         = null;
		this.qiSpExtObj      = null;

		// this.sublineObj      = null;
		// this.sublineExtObj   = null;
		this.sublineSpObj    = null;
		this.sublineSpExtObj = null;

		// this.catalogNodeId = catalogNode.Id;
		// this.pricelistLineId = pricelistLine.Id;

		// this.sfid         = null;
		// this.productId    = catalogNode.REVVY__Id__c;
		this.dnetPrice  = dnetPrice;
		this.awardPrice = awardPrice;
		// this.description  = catalogNode.Name;
		// this.quantity     = 1;
		this.spQuantity = spQuantity;

		this.isFromAddNew = true;
		this.chevronStyle = '';
		this.displayStyle = '';
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private List<ToroSupportPlusItem> buildSPSublineWrappers(REVVY__MnQuoteItem__c qi) {
		final List<ToroSupportPlusItem> sublineWrappers = new List<ToroSupportPlusItem>();
		List<REVVY__MnQuoteItemSubline__c> allSublines = ToroSupportPlusHelper.getSublines(qi.Id);
		// if (qi.REVVY__QuoteItemSubLine__r == null) return sublineWrappers;
		if (allSublines == null) return sublineWrappers;

		// 1) build a list of the main sublines
		// 2) build a map of the main subline to its support plus line
		final List<REVVY__MnQuoteItemSubLine__c> sublines = new List<REVVY__MnQuoteItemSubLine__c>();
		final Map<Id,REVVY__MnQuoteItemSubLine__c> sublinetoSpObjMap = new Map<Id,REVVY__MnQuoteItemSubLine__c>();
		// for (REVVY__MnQuoteItemSubLine__c subline : qi.REVVY__QuoteItemSubLine__r) {
		for (REVVY__MnQuoteItemSubLine__c subline : allSublines) {
			if (subline.Support_Plus_Original_Item__c == null) {
				sublines.add(subline);
			}

			else {
				sublinetoSpObjMap.put(subline.Support_Plus_Original_Item__c, subline);
			}
		}

		// create wrappers
		for (REVVY__MnQuoteItemSubLine__c subline : sublines) {
			if (sublinetoSpObjMap.containsKey(subline.Id)) {
				sublineWrappers.add(new ToroSupportPlusItem(qi, subline, sublinetoSpObjMap.get(subline.Id)));
			}

			else {
				sublineWrappers.add(new ToroSupportPlusItem(qi, subline));
			}
		}

		return sublineWrappers;
	}
}