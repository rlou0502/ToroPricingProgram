public with sharing class ToroSObjectResultSet {
	public ToroSObjectResultSet() {	
	}
	@AuraEnabled
	public SObject quote { get; set; }
	@AuraEnabled
	public boolean result { get; set; }
	@AuraEnabled
    public List<FieldSetMember> fieldSetMembers { get;set; }
    @AuraEnabled
    public List<FieldSetMember> fieldSetSummaryMembers { get;set; }
    @AuraEnabled
    public String selectedPricingMethod { get;set; }
    @AuraEnabled
    public String selectedPricingProgram { get;set; }
    @AuraEnabled
    public List<FieldSetMember> fieldSetSubMembers { get;set; }
    @AuraEnabled
    public List<SObject> values { get;set; } 
    @AuraEnabled
    public List<ToroSelectOption> pricingProgramOptions { get;set; }
    @AuraEnabled
    public List<ToroSelectOption> pricingMethodOptions { get;set; }
    @AuraEnabled
    public List<ToroSelectOption> demoPricingProgramOptions { get;set; }
    @AuraEnabled
    public boolean displayPerformancePart { get;set; }
    @AuraEnabled
    public Id currentQuoteItem { get;set; }
    @AuraEnabled
    public decimal setupFee { get;set; }
    @AuraEnabled
    public boolean displaySetupFee { get;set; }
    @AuraEnabled
    public boolean chainCall { get;set; }
    @AuraEnabled
    public string payload { get;set; }
    @AuraEnabled
    public string nextAction { get;set; }
    @AuraEnabled
    public boolean listenMSRPChange { get;set; }
    @AuraEnabled
    public boolean allowSupportPlus { get;set; }
    @AuraEnabled
    public Map<String, Object> secondaryPrograms { get;set; }
}