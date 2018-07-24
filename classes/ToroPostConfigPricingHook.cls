global with sharing class ToroPostConfigPricingHook implements REVVY.IMnPostConfigPricingHookPlugin  {
	global void preBOMUpdateHook(REVVY.CMnPricingParams pricingParams){

        Id qtId = pricingParams.quoteId;
        system.debug('--- ToroPostConfigPricingHook qtId =' + qtId);
        if(qtId != null) {
			Revvy__MnQuote__c qt = new Revvy__MnQuote__c(Id=qtId,Is_Dirty__c=true);
			update qt;
        }
       
	}   
}