({
	init: function(cmp, event, helper) {
        var pricingMethod = cmp.get("v.pricingMethodLabel");
        var obj = cmp.get("v.quoteItem");
        if(pricingMethodLabel === "% of DNET") {
        	cmp.set("v.pricingMethodValue", obj["Award_of_DN__c"]);    
        } else if(pricingMethodLabel === "% off MSRP") {
            cmp.set("v.pricingMethodValue", obj["Off_MSRP__c"]);
        }
    }
})