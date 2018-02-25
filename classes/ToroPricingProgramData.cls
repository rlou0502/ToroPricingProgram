public with sharing class ToroPricingProgramData {
	public ToroPricingProgramData(String selectedPricingProgram) {
		if(String.isNotBlank(selectedPricingProgram)){
			List<String> parts = selectedPricingProgram.split(';');
			if(parts.size() == 2) {
				externalId = parts[0];
				subType = parts[1];	
			} else if(parts.size() ==1)	{
				externalId = parts[0];	
			}	
		}	
	}  
	public String externalId { get; set;}
	public String subType { get; set; }  
}