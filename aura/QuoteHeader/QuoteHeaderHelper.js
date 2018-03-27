({
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
                    //component.find("pricingMethod").set("v.value", "");
                    
                    //selectedPricingMethod
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
	                
	                component.set('v.fields', fields);
                    component.set('v.pricingProgramOptions', retResponse.pricingProgramOptions);
                    component.set('v.pricingMethodOptions', retResponse.pricingMethodOptions);
                    component.set('v.displayPerformancePart', retResponse.displayPerformancePart);
                    component.set('v.selectedPricingProgram', retRecords[0]["Pricing_Program_Name__c"]);
                    component.set('v.selectedPricingMethod', retRecords[0]["Price_Method__c"]);
                    component.set('v.quote', retRecords[0]);
                    component.set('v.displaySetupFee', retResponse.displaySetupFee);
                    //console.log(component.get('v.selectedPricingProgram'));
                    //console.log(component.get('v.selectedPricingMethod'));
                    /*
	                retRecords.forEach(function(s) {    
	                    var tableRow = document.createElement('tr');
	                    fields.forEach(function(field){ 
	                        var tableData = document.createElement('td');
	                        var tableDataNode = document.createTextNode(s[field.fieldPath]);
	                        tableData.appendChild(tableDataNode);
	                        tableRow.appendChild(tableData);
	                    });
	                    document.getElementById("quoteHeader").appendChild(tableRow);
	                 });
                     */
	            }
	        }
	    );
		$A.enqueueAction(getAction);
	}    
})