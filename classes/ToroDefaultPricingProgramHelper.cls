public with sharing class ToroDefaultPricingProgramHelper extends ToroPricingProgram {
	public override List<Schema.FieldSetMember> getQuoteItemSublineFields() {
		return SObjectType.Revvy__MnQuoteItemSubline__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteItemFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	} 
	public override List<SelectOption> getPriceMethodOptions() { 
		return new List<SelectOption> {  new SelectOption('% off MSRP','% off MSRP')};
	}   
	public override List<Revvy__MnQuoteItem__c> calculateRebateAndMargin(Id quoteId, String priceProgramExternalId, String priceMethod, List<QuoteItem> quoteItemWrapperList) {  
		return null;
	}  
}