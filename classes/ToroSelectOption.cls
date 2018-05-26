public with sharing class ToroSelectOption  implements Comparable {
    @AuraEnabled public String value { get; set; }
    @AuraEnabled public String label { get; set; }

	public ToroSelectOption(String value, String label) {
        this.value = value;
        this.label = label;
    }
    public Integer compareTo(Object compareTo) {
		ToroSelectOption compareToObj = (ToroSelectOption) compareTo;
		return this.label.compareTo(compareToObj.label);
	}
}