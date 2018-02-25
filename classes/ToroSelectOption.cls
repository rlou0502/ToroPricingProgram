public with sharing class ToroSelectOption {
	public ToroSelectOption(String value, String label) {
        this.value = value;
        this.label = label;
    }

    @AuraEnabled
    public String value { get;set; }

    @AuraEnabled
    public String label { get;set; }
    
}