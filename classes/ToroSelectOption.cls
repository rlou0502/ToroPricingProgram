public with sharing class ToroSelectOption  implements Comparable {
    @AuraEnabled public String value { get; set; }
    @AuraEnabled public String label { get; set; }
	@AuraEnabled public boolean defaultSelected { get; set; }
	public ToroSelectOption(String value, String label) {
        this.value = value;
        this.label = label;
    }
	public ToroSelectOption(String value, String label, boolean defaultSelected) {
		this(value, label);
        this.defaultSelected = defaultSelected;
    }
    public Integer compareTo(Object compareTo) {
		ToroSelectOption compareToObj = (ToroSelectOption) compareTo;
		return this.label.compareTo(compareToObj.label);
	}
}