({
	populateQuoteItems : function(component) {
		var quoteId = component.get('v.quoteId');
		var getAction = component.get('c.getQuoteItemFields');

        getAction.setParams({
            pricingProgram: "Market Support Chart Large Package",
            objId: quoteId
        });
        
		getAction.setCallback(this, 
	        function(response) {
	            var state = response.getState();
				console.log('ToroPricingProgramController getQuoteItemFields callback');
                console.log("callback state: " + state);
                
	            if (component.isValid() && state === "SUCCESS") {  
	                var data = response.getReturnValue();
	                var retResponse = response.getReturnValue();
	                var retRecords = retResponse.values;
	                var fields = retResponse.fieldSetMembers;
	                component.set('v.fields', fields);
                    component.set('v.quoteItems', retRecords);
                    /*
	                retRecords.forEach(function(s) {
	                    var tableRow = document.createElement('tr');
	                    fields.forEach(function(field){
                            debugger;
	                        var tableData = document.createElement('td');
	                        var tableDataNode = document.createTextNode(s[field.fieldPath]);
	                        tableData.appendChild(tableDataNode);
	                        tableRow.appendChild(tableData);
	                    });
	                    document.getElementById("quoteItems").appendChild(tableRow);
	                 });
                     */
	            }
	        }
	    );
		$A.enqueueAction(getAction);
	}    
})