public with sharing class ToroNationalAccountGSAPPHelper extends ToroGSAPricingProgramHelper {
	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('Federal','Federal'));
		return ret;
	}
	public override List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.GSA_Quote_Header.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.GSA_Quote_Line_Cols.getFields();
		
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.National_Account_Quote_Line_Updtbl_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.GSA_Quote_SubLine_Cols.getFields();
	}
	
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.GSA_Quote_Summary.getFields();
	}
	public override decimal retrieveAwardPrice(REVVY__MnPriceListLine__c ppl) {
		return ppl.revvy__PriceField1__c;	
	} 
	public override List<Revvy__MnStrategy4__c> overrideCommissions(List<Revvy__MnStrategy4__c> quoteItemList) {
		return quoteItemList;
	}
}