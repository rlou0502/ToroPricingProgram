public virtual class ToroQIBase {
	// @AuraEnabled public List<ToroQIBase> sublines 					{ get; set; }
	@AuraEnabled public REVVY__MnQuoteItem__c qiObj  				{ get; private set; }
	@AuraEnabled public REVVY__MnStrategy4__c qiExtObj 				{ get; private set; }
	@AuraEnabled public REVVY__MnQuoteItemSubLine__c sublineObj 	{ get; private set; }
	@AuraEnabled public REVVY__MnStrategy5__c sublineExtObj     	{ get; private set; }

	@AuraEnabled public Id catalogNodeId { get; private set; }
	@AuraEnabled public Id pricelistLineId { get; private set; }

	// used in lightning page
	@AuraEnabled public Id sfid            { get; private set; }
	@AuraEnabled public String productId   { get; private set; }
	@AuraEnabled public Decimal msrpPrice  { get; set; }
	@AuraEnabled public Decimal awardPrice { get; set; }
	@AuraEnabled public Decimal dnetPrice  { get; set; }
	@AuraEnabled public String description { get; private set; }
	@AuraEnabled public Decimal quantity   { get; private set; }

	@AuraEnabled public Boolean isNonToroProduct { get; private set; }

	/**
	 *
	 * wrap a quote item
	 */
	public ToroQIBase(REVVY__MnQuoteItem__c qi) {
		this.qiObj            = qi;
		this.qiExtObj         = qi.Quote_Item_Extension__r;
		this.sublineObj       = null;
		this.sublineExtObj    = null;
		this.catalogNodeId    = null;
		this.pricelistLineId  = null;
		this.sfid             = qi.Id;
		this.productId        = qi.REVVY__Catalog_Node__r.REVVY__Id__c;
		this.dnetPrice        = qi.REVVY__SuggestedPrice__c;
		this.msrpPrice        = qi.REVVY__Price__c;
		this.awardPrice       = qi.Award_Price__c; //qi.Quote_Item_Extension__r.Award_Price__c;
		this.description      = qi.REVVY__Catalog_Node__r.Name; //String.isBlank(qi.Description__c) ? qi.REVVY__Catalog_Node__r.Name : qi.Description__c;
		this.quantity         = qi.REVVY__Quantity__c;
		this.isNonToroProduct = qi.REVVY__Catalog_Node__r.Non_Toro_Product__c;
	}

	/**
	 *
	 * wrap a quote item subline
	 */
	public ToroQIBase(REVVY__MnQuoteItem__c qi, REVVY__MnQuoteItemSubLine__c subline) {
		this.qiObj            = qi;
		this.qiExtObj         = qi.Quote_Item_Extension__r;
		this.sublineObj       = subline;
		this.sublineExtObj    = subline.Quote_Item_Subline_Extension__r;
		this.catalogNodeId    = null;
		this.pricelistLineId  = null;
		this.sfid             = subline.Id;
		this.productId        = subline.REVVY__Catalog_Node__r.REVVY__Id__c;
		this.dnetPrice        = subline.REVVY__SuggestedPrice__c;
		this.msrpPrice        = subline.REVVY__Price__c;
		this.awardPrice       = subline.Quote_Item_Subline_Extension__r.Award_Price__c;
		this.description      = subline.REVVY__Catalog_Node__r.Name; //String.isBlank(subline.Description__c) ? subline.REVVY__Catalog_Node__r.Name : subline.Description__c;
		this.quantity         = subline.REVVY__Quantity__c * qi.REVVY__Quantity__c;
		this.isNonToroProduct = subline.REVVY__Catalog_Node__r.Non_Toro_Product__c;
	}

	/**
	 *
	 * builds a wrapper shell when adding a new quote item (not in db)
	 */
	public ToroQIBase(REVVY__MnCatalogNode__c catalogNode, REVVY__MnPriceListLine__c pricelistLine, Decimal msrpPrice, Decimal awardPrice, Decimal quantity, String description) {
		this.qiObj            = null;
		this.qiExtObj         = null;
		this.sublineObj       = null;
		this.sublineExtObj    = null;
		this.catalogNodeId    = catalogNode.Id;
		this.pricelistLineId  = pricelistLine.Id;
		this.sfid             = null;
		this.productId        = catalogNode.REVVY__Id__c;
		this.msrpPrice        = msrpPrice;
		this.awardPrice       = awardPrice;
		this.description      = catalogNode.Name; //String.isBlank(description) ? catalogNode.Name : description;
		this.quantity         = quantity;
		this.isNonToroProduct = catalogNode.Non_Toro_Product__c;
	}
}