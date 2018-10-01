public with sharing class ToroStateContractCMASHelper extends ToroGSAPricingProgramHelper {
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('Federal','Federal')); 
		return ret;
	}
	public override List<Schema.FieldSetMember> getQuoteFields() {
		system.debug('ToroStateContractCMASHelper.getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.Pricing_Program_Quote_Header_Fields.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.CMAS_Contracts_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return null;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.CMAS_Contract_Price_Program_Quote_SubLin.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.CMAS_Contracts_Quote_Line_Summary_Cols.getFields();
	}
	public override decimal retrieveAwardPrice(REVVY__MnPriceListLine__c ppl) {
		return ppl.revvy__PriceField1__c;	
	} 
}