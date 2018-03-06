({
	init: function(cmp, event, helper) {
        //console.log('QuoteHeader.init');
        helper.populateQuoteItems(cmp);
    },
    onRender: function(cmp, event, helper) {
        console.log('---------------quote item--onRender');
    },
    toggleChevron : function(cmp, event, helper) {
        var isCollapsed = cmp.get("v.IsCollapsed");
        var nodeList = document.getElementsByClassName("collapsible");
        var collapse = !isCollapsed;
        cmp.set("v.IsCollapsed", collapse);
        var display = collapse ? "none" : "";
        for(var index=0; index < nodeList.length; index++ ) {
            nodeList[index].style.display = display;
        }
        var chevronList = document.getElementsByClassName("chevron");
        for(var index=0; index < chevronList.length; index++ ) {
            if(collapse) {
            	chevronList[index].classList.replace('bottom','right') ;
            } else {
               chevronList[index].classList.replace('right','bottom') ;  
            }   
        }  
    },
    calculate: function(component, event, helper) {
    	//console.log('updateQuote'); 
    	helper.showSpinner();
    	var params = event.getParam('arguments');
        if(params) { 
            var pricingProgram = params.pricingProgram;
            var pricingMethod = params.pricingMethod;
            var setupFeePercent = params.setupFeePercent;
            var performancePart = params.performancePart;
            helper.updateSaveQuote(component, pricingProgram, pricingMethod, setupFeePercent, performancePart, false);
        }
        
    },
    saveQuote: function(component, event, helper) {
    	//console.log('updateQuote'); 
    	helper.showSpinner();
    	var params = event.getParam('arguments');
        if(params) { 
            var pricingProgram = params.pricingProgram;
            var pricingMethod = params.pricingMethod;
            var setupFeePercent = params.setupFeePercent;
            var performancePart = params.performancePart;
            helper.updateSaveQuote(component, pricingProgram, pricingMethod, setupFeePercent, performancePart, true);
        }
        
    },
    setPricingProgramSvc: function(cmp, event, helper) {
    	//console.log('setPricingProgramSvc');
        var params = event.getParam('arguments');
        if(params) {
            //cmp.set("v.selectedPricingProgram", params.selectedPricingProgram);
            helper.showSpinner();
            helper.svc_SetPricingProgram(cmp, params.selectedPricingProgram, params.selectedPricingMethod);
        }
    },
    setPricingMethodSvc: function(cmp, event, helper) {
    	console.log('setPricingProgramSvc');
        var params = event.getParam('arguments');
        if(params) {
            //cmp.set("v.selectedPricingProgram", params.selectedPricingProgram);
            helper.showSpinner();
            helper.svc_SetPricingMethod(cmp, params.selectedPricingProgram, params.selectedPricingMethod);
        }
    },
    calculateAndReload: function(cmp, event, helper) {
        //console.log('calculate and reload');
        var params = event.getParam('arguments');
        if(params) {
            cmp.set("v.selectedPricingProgram", params.selectedPricingProgram);
            cmp.set("v.selectedPricingMethod", params.selectedPricingMethod);
        	//console.log('selectedPricingProgram->' + params.selectedPricingProgram);
            //console.log('selectedPricingMethod->' + params.selectedPricingMethod);
        }

    },
    setPricingProgram: function(cmp, event, helper) {
        //console.log('set pricing program');
        var params = event.getParam('arguments');
        if(params) {
            cmp.set("v.selectedPricingProgram", params.newPricingProgram);
        }
    },
    setPricingMethod: function(cmp, event, helper) {
        console.log('set pricing method');      
        var params = event.getParam('arguments');
        if(params) {
            cmp.set("v.selectedPricingMethod", params.newPricingMethod);
            var elements = document.getElementsByClassName("PricingMethodValue__c");
            console.log("elements.length: " + elements.length);
            for (var i=0; i<elements.length; i++) {
                //console.log(elements[i].innerHTML);
                elements[i].innerHTML = params.newPricingMethod;
            }     
        }
    },
    
    setPMTotalAwardDollars: function(cmp, event, helper) {
        console.log('setPMTotalAwardDollars');      
        var params = event.getParam('arguments');
        if(params) {
            helper.showSpinner();
            var pricingProgram = params.pricingProgram;
            var pricingMethod = params.pricingMethod;
            var awardPrice = params.awardPrice;
            var quoteId = cmp.get('v.quoteId');
            var getAction = cmp.get('c.setTotalAwardDollarPMRemote');
            var self = this;
            getAction.setParams({
                quoteId: quoteId,
                pricingProgram: pricingProgram,
                pricingMethod: pricingMethod,
                awardPrice: awardPrice
            });
        	
            getAction.setCallback(this, 
                function(response) {
                    var state = response.getState();
                    
                    if (cmp.isValid() && state === "SUCCESS") {  
                        var data = response.getReturnValue();
                        var retResponse = response.getReturnValue();
               			for (var key in retResponse) {
                            if (retResponse.hasOwnProperty(key)) {
                                var elms = document.querySelectorAll(".sfdcid-"+key);
                                if(elms) {
                                    for(var i=0; i < elms.length; i++){
                                    	elms[i].value = retResponse[key];    
                                    }    
                                }
                            }
                        }
                    }
                    helper.hideSpinner();
                }
            );
            $A.enqueueAction(getAction);
        }
    },
    setPMGPPercent: function(cmp, event, helper) {
        console.log('setPMGPPercent');      
        var params = event.getParam('arguments');
        if(params) {
            var pricingProgram = params.pricingProgram;
            var pricingMethod = params.pricingMethod;
            var gpPercent = params.gpPercent; 
            var quoteId = cmp.get('v.quoteId');
            var getAction = cmp.get('c.setGPPercentRemote');
            var self = this;
            getAction.setParams({
                quoteId: quoteId,
                pricingProgram: pricingProgram,
                pricingMethod: pricingMethod,
                gpPercent: gpPercent
            });
        	
            getAction.setCallback(this, 
                function(response) {
                    var state = response.getState();
                    if (cmp.isValid() && state === "SUCCESS") {  
                        var data = response.getReturnValue();
                    	var retResponse = response.getReturnValue();
                    	var retRecords = retResponse.values;
                    	var fields = retResponse.fieldSetMembers;
                    	cmp.set('v.fields', fields);
                    	cmp.set('v.fieldsSub', retResponse.fieldSetSubMembers); 
                    	cmp.set('v.fieldsSummary', retResponse.fieldSetSummaryMembers);
                    	cmp.set('v.quoteItems', retRecords);
                    	cmp.set('v.demoPricingProgramOptions', retResponse.demoPricingProgramOptions);
                     	var cmpEvent = cmp.getEvent("calculationCompleteEvent");
                        cmpEvent.setParams({
                            "quote" : retResponse.quote
                        });
                        cmpEvent.fire();
                        var sublineMap = {};  
                        var quoteItemMap={};
                        retRecords.forEach(function(s) {
                            quoteItemMap[s["Id"]]=s;
                            if(s["Toro_Quote_Item_Sub_Lines__r"]) {
                                sublineMap[s["Id"]]= s["Toro_Quote_Item_Sub_Lines__r"];  
                            }
                        });
                        cmp.set('v.sublineMap', sublineMap);
                        cmp.set('v.quoteItemMap', quoteItemMap);
                        helper.hideSpinner();
                        var items = document.getElementById("quoteItems");
                        helper.cleanInnerNodes(items);
                        helper.renderQuoteItems(cmp);           			
                    }
                }
            );
            $A.enqueueAction(getAction);
        }
    }

})