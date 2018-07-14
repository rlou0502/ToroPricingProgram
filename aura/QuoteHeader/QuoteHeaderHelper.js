({
    handleInfoBoxRefresh : function(component, obj, lineType) {
    	var cmpEvent = component.getEvent("refreshInfoBoxEvent");
        cmpEvent.setParams({
            "infoBoxData" : obj,
            "infoBoxType" : lineType
        });
        cmpEvent.fire();    
    },
    handlePricingProgramSelectChange : function(component) {
        var quoteId = component.get('v.quoteId');
    	var pricingProgram = component.find("pricingProgram").get("v.value");
        var getAction = component.get('c.svc_getPricingMethodOptions');
		var self = this;
        getAction.setParams({
            pricingProgram: pricingProgram,
            quoteId: quoteId
        });
        getAction.setCallback(this,
	        function(response) {
                console.log("set pricing Program " + Date.now());
	            var state = response.getState();
	            if (component.isValid() && state === "SUCCESS") {
	                var data = response.getReturnValue();
	                var retResponse = response.getReturnValue();

                    component.set('v.pricingMethodOptions', retResponse.pricingMethodOptions);
					component.set('v.displayPerformancePart', retResponse.displayPerformancePart);
                    component.set('v.selectedPricingMethod', retResponse.selectedPricingMethod);
                    component.set('v.displaySetupFee', retResponse.displaySetupFee);
                    component.set('v.allowSupportPlus', retResponse.allowSupportPlus);
                    component.set('v.contractMessage', retResponse.contractMessage);

                    var selectedProgram = component.find("pricingProgram").get("v.value");
                    var selectedMethod = component.find("pricingMethod").get("v.value");
                    var allowSupportPlus = component.get("v.allowSupportPlus");
                    var cmpEvent = component.getEvent("pricingProgramEvent");
                    cmpEvent.setParams({
                        "selectedPricingProgram" : selectedProgram,
                        "selectedPricingMethod" : selectedMethod,
                        "allowSupportPlus" : allowSupportPlus
                    });
                    cmpEvent.fire();
	            }
	        }
	    );
		$A.enqueueAction(getAction);
    },
	populateQuoteHeader : function(component) {
		var quoteId = component.get('v.quoteId');
		var getAction = component.get('c.getQuoteHeaderFields');
		getAction.setParams({
	        pricingProgram: "",
	        objId: quoteId
	    });
		getAction.setCallback(this,
	        function(response) {
	            var state = response.getState();
	            //console.log('ToroPricingProgramController getFormAction callback');
	            //console.log("callback state: " + state);
	            if (component.isValid() && state === "SUCCESS") {
	                var data = response.getReturnValue();
	                var retResponse = response.getReturnValue();
	                var retRecords = retResponse.values;
	                var fields = retResponse.fieldSetMembers;
					var quote = retRecords[0];
                    debugger;
	                component.set('v.fields', fields);
                    component.set('v.pricingProgramOptions', retResponse.pricingProgramOptions);
                    component.set('v.pricingMethodOptions', retResponse.pricingMethodOptions);
                    component.set('v.displayPerformancePart', retResponse.displayPerformancePart);
                    component.set('v.selectedPricingProgram', retResponse.selectedPricingProgram);
                    component.set('v.selectedPricingMethod', retResponse.selectedPricingMethod);
                    component.set('v.quote', retRecords[0]);
                    component.set('v.displaySetupFee', retResponse.displaySetupFee);
                    component.set('v.allowSupportPlus', retResponse.allowSupportPlus);
                    component.set('v.contractMessage', retResponse.contractMessage);
                    var selectedProgram = component.get("v.selectedPricingProgram");
                    var selectedMethod = component.find("v.selectedPricingMethod");
                    var allowSupportPlus = component.get("v.allowSupportPlus");
                    var cmpEvent = component.getEvent("quoteHeaderLoaded");
                    cmpEvent.setParams({
                        "selectedPricingProgram" : selectedProgram,
                        "selectedPricingMethod" : selectedMethod,
                        "allowSupportPlus" : allowSupportPlus,
                        "displaysetupFee" : retResponse.displaySetupFee,
                        "setupFeePercent" : quote.Setup_Fee__c
                    });
                    cmpEvent.fire();
                    
	            }
	        }
	    );
		$A.enqueueAction(getAction);
	}
})