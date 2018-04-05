global class KMnQuoteLifeCycleSelectPriceProgram extends REVVY.CMnLifeCycleActionScript {
	global override Map<String, String> doAction(Map<String,String> values) {
		Id quoteId = values.get('objectId');
		Map<String,String> pageRefMap = new Map<String,String>();
        //pageRefMap.put('PageReference', '/'+ quoteId);
        //pageRefMap.put('PageReference', 'https://toro--cpqdev.cs91.my.salesforce.com/apex/ToroSelectPriceProgram?id='+quoteId);
        REVVY__MnProperty__c hostName = REVVY__MnProperty__c.getValues('ToroCPQHostName');
        String hostNameVal='enter_your_host_name';
        if(hostName != null && String.isNotBlank(hostName.Revvy__Value__c)) {
        	hostNameVal = 	hostName.Revvy__Value__c;
        } 
        pageRefMap.put('PageReference', hostNameVal+'/apex/PricingProgramLgtnOut?id='+quoteId);
        //pageRefMap.put('PageReference', 'https://google.com');
        return pageRefMap;
	}
}