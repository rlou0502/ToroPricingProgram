/**
 * QuoteItem
 *
 * wrapper class for quote item used in lightning pages
 *
 * @author Roy Lou
 */
public class QuoteItem {
    @AuraEnabled public REVVY__MnQuoteItem__c qi					{ get; set; }
    @AuraEnabled public List<REVVY__MnQuoteItemSubLine__c> qislList	{ get; set; }

    public List<PricingProgramSelector> ppSelectors { get; set; }
    public transient List<SelectOption> qiTypeList 	{ get; set; }
    public transient String qiType 					{ get; set; }
    public transient Decimal qidType 				{ get; set; }

	public QuoteItem() { }

	public QuoteItem(REVVY__MnQuoteItem__c quoteItem) {
		this.qi = quoteItem;

		if (String.isBlank(this.qi.Description__c)) {
			this.qi.Description__c = qi.REVVY__Product_Name_F__c;
		}

		if (quoteItem.REVVY__QuoteItemSubLine__r != null
			&& quoteItem.REVVY__QuoteItemSubLine__r.size() > 0
		) {
			this.qislList = qi.REVVY__QuoteItemSubLine__r;
			for (REVVY__MnQuoteItemSubLine__c qis : this.qislList) {
				if (String.isBlank(qis.Description__c)) {
					qis.Description__c = qis.REVVY__Catalog_Node__r.Name;
				}
			}
		}
	}

    public class PricingProgramSelector {
    	public Id sfdcId 						{ get; set; }
    	public String pricingProgram 			{ get; set; }
    	public String pricingMethod 			{ get; set; }
    	public decimal percentOffMSRP 			{ get; set; }
    	public decimal originalPercentOffMSRP 	{ get; set; }
    	public decimal awardPercentOfDNet 		{ get; set; }

    	public PricingProgramSelector(Id sfdcId
										, String pp
										, String pm
										, Decimal msrp
										, Decimal dNet
										, Decimal origMsrp
		) {
    		this.pricingProgram         = pp;
    		this.pricingMethod          = pm;
    		this.percentOffMSRP         = msrp;
    		this.awardPercentOfDNet     = dNet;
    		this.sfdcId                 = sfdcId;
    		this.originalPercentOffMSRP = origMsrp;
    	}
	}
}