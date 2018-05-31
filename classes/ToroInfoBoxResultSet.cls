public with sharing class ToroInfoBoxResultSet {
	@AuraEnabled
	public boolean result { get; set; }
	@AuraEnabled
    public List<FieldSetMember> quoteItemMainFieldSet { get;set; }
    @AuraEnabled
    public List<FieldSetMember> quoteItemTractionUnitFieldSet { get;set; }  
    @AuraEnabled
    public List<FieldSetMember> quoteSublineFieldSet { get;set; }  
}