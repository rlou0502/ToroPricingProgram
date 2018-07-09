({
	init: function(cmp, event, helper) {
        //console.log('QuoteHeader.init');
        helper.populateQuoteHeader(cmp);
    },
    
    getPricingProgramMethod: function(cmp, event, helper) {
        var pp = cmp.get("v.selectedPricingProgram");
        var pm = cmp.get("v.selectedPricingMethod");
        return {"PricingProgram" : pp, "PricingMethod" : pm};
    },
    onInputPress: function(cmp, event, helper) {
    	var cal = document.querySelector('.js-calculate').disabled = true; 
        var save = document.querySelector('.js-saveAndClose').disabled = true;
    },
    getQuoteInfo: function(cmp, event, helper) {
        var pp = cmp.get("v.selectedPricingProgram");
        var pm = cmp.get("v.selectedPricingMethod");
        var setupFeePercent = cmp.find("setupFeePercent") != null ? cmp.find("setupFeePercent").get("v.value") : 0;
        var performancePart = cmp.find("performancePart") != null ? cmp.find("performancePart").get("v.value") : false;
        return {"PricingProgram" : pp, 
                "PricingMethod" : pm,
                "SetupFeePercent" : setupFeePercent,
                "PerformancePart" : performancePart};
    },
    onTotalAwardPriceChange: function(cmp, event, helper) {
        var cal = document.querySelector('.js-calculate').disabled = false; 
        var save = document.querySelector('.js-saveAndClose').disabled = false;
    	var changedValue = event.currentTarget.value; 
        var pp = cmp.get("v.selectedPricingProgram");
        var pm = cmp.get("v.selectedPricingMethod");
        var performancePart = cmp.find("performancePart") != null ? cmp.find("performancePart").get("v.value") : false;
        var cmpEvent = cmp.getEvent("PMAwardPriceChangeEvent");
        cmpEvent.setParams({
            "pricingProgram" : pp,
            "pricingMethod" : pm,
            "awardPrice" : changedValue,
            "performancePart" : performancePart
        });
        cmpEvent.fire();
    },
    onGpPercentChange: function(cmp, event, helper){
        var cal = document.querySelector('.js-calculate').disabled = false; 
        var save = document.querySelector('.js-saveAndClose').disabled = false;
        var changedValue = event.currentTarget.value;
        var pp = cmp.get("v.selectedPricingProgram");
        var pm = cmp.get("v.selectedPricingMethod");
        var performancePart = cmp.find("performancePart") != null ? cmp.find("performancePart").get("v.value") : false;
        var cmpEvent = cmp.getEvent("PMGPPercentChangeEvent");
        cmpEvent.setParams({
            "pricingProgram" : pp,
            "pricingMethod" : pm,
            "gpPercent" : changedValue,
            "performancePart" : performancePart
        });
        cmpEvent.fire();
    },    
    onRender: function(cmp, event, helper) {
        var existing = document.getElementById("quoteRow");
        if(existing) {
            existing.parentElement.removeChild(existing);
        }
        var q = cmp.get('v.quote');
        var fields = cmp.get('v.fields');
        console.log("Quote Header rerender.........");
        var tableRow = document.createElement('tr');
        tableRow.id = "quoteRow";
        var tableCaptionData = document.createElement('td');
        var cellCaptionText = document.createElement('div');
        tableCaptionData.addEventListener('mouseenter', function(){helper.handleInfoBoxRefresh(cmp, q, "quote");}, false);
        tableCaptionData.appendChild(cellCaptionText);
        tableRow.appendChild(tableCaptionData);
        fields.forEach(function(field){ 
            var tableData = document.createElement('td');
            var cellText = document.createElement('div');
            cellText.className += " quote " + field.fieldPath;
            tableData.appendChild(cellText);
            var data = q[field.fieldPath];
           
            if(field.type.toLowerCase() === 'double') {
                if(data != undefined) {
                    cellText.innerHTML=	parseFloat(data).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}); 
                    tableData.className += " align-right ";
                }  
            } else if(field.type.toLowerCase() === 'currency') {
                if(data != undefined) {
                    cellText.innerHTML=	parseFloat(data).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}); 
                    tableData.className += " align-right ";
                }
            } else if(field.type.toLowerCase() === 'percent') {
                if(data != undefined) {
                    cellText.innerHTML=	parseFloat(data).toLocaleString(undefined, {minimumFractionDigits: 4, maximumFractionDigits: 4}); 
                    tableData.className += " align-right ";
                }
            } else {
                cellText.innerHTML=data;
            }
            
            //tableData.appendChild(tableDataNode);
            tableRow.appendChild(tableData);
        });
        document.getElementById("quoteHeader").appendChild(tableRow);
        console.log("quote header rerender exit time=" + Date.now());
    },
    //this is a value change handler of field v.selectedPricingProgram
    //This field is set via apex code returned from remote call
    handlePricingProgramChange: function(cmp, event, helper) {
        var whichOne = event.getSource().getLocalId();
	    console.log('-------handlePricingProgramChange source =' +whichOne);
        var selectedProgram = cmp.find("pricingProgram").get("v.value");
        var selectedMethod = cmp.find("pricingMethod").get("v.value");
        //console.log('selectedMethod=' + selectedMethod);
        var cmpEvent = cmp.getEvent("pricingProgramSetEvent");
        cmpEvent.setParams({
            "pricingProgram" : selectedProgram
        });
        cmpEvent.fire();      
    },
    //this is a value change handler of field v.selectedPricingMethod
    //This field is set via apex code returned from remote call
    handlePricingMethodChange: function(cmp, event, helper) {
        var whichOne = event.getSource().getLocalId();
	    console.log('-------handlePricingMethodChange source =' +whichOne);
        
        var selectedMethod = cmp.find("pricingMethod").get("v.value");
        var selectedProgram = cmp.find("pricingProgram").get("v.value");
        var cmpEvent = cmp.getEvent("pricingMethodSetEvent");
        cmpEvent.setParams({
            "pricingMethod" : selectedMethod
        });
        cmpEvent.fire();
    },
    //this is a change event handler of a lightning:select field pricingProgram 
    //triggered by user's selection change
    onPricingProgramSelectChange: function(cmp, event, helper) {
        var whichOne = event.getSource().getLocalId();
        var perP= cmp.find("performancePart");
        if(perP) {
           perP.set("v.value", false); 
        }
        
	    console.log('-------onPricingProgramSelectChange source =' +whichOne);
        helper.handlePricingProgramSelectChange(cmp);  
        cmp.set('v.selectedPricingMethod','% off MSRP');
    },
    //this is a change event handler of a lightning:select field pricingMethod 
    //triggered by user's selection change
 	onPricingMethodSelectChange: function(cmp, event, helper) {
        var whichOne = event.getSource().getLocalId();
	    console.log('-------onPricingMethodSelectChange source =' +whichOne);
        var selectedProgram = cmp.find("pricingProgram").get("v.value");
        //console.log('onPricingMethodSelectChange=' + selectedProgram);
        var selectedMethod = cmp.find("pricingMethod").get("v.value");
        var msg = $A.get("$Label.c.PP_Dirty_Warning_Message");
        cmp.set("v.contractMessage",msg);
        //console.log('selectedMethod=' + selectedMethod);
        if(selectedMethod && selectedProgram) {
            var cmpEvent = cmp.getEvent("pricingMethodEvent");
            cmpEvent.setParams({
                "selectedPricingMethod" : selectedMethod,
            	"selectedPricingProgram" : selectedProgram
            });
            cmpEvent.fire();
        }
    },
    savePricingProgramMethod: function(cmp, event, helper) {
        var params = event.getParam('arguments');
        if(params) { 
            var quoteId = cmp.get('v.quoteId');
            var pp = cmp.get("v.selectedPricingProgram");
        	var pm = cmp.get("v.selectedPricingMethod");
            var setupFeePercent = cmp.find("setupFeePercent") != null ? cmp.find("setupFeePercent").get("v.value") : 0;
        	var performancePart = cmp.find("performancePart") != null ? cmp.find("performancePart").get("v.value") : false;
            var getAction = cmp.get('c.savePricingProgramMethodRemote');
        
            getAction.setParams({
                pricingProgram: pp,
                pricingMethod: pm,
                setupFeePercent: setupFeePercent,
                performancePart: performancePart,
                quoteId: quoteId
            });
            getAction.setCallback(this, 
            		function(response) {
                        
                        var state = response.getState();
                        if (cmp.isValid() && state === "SUCCESS") {  
                            
                        }
                    });
            $A.enqueueAction(getAction);
        }
    }
})