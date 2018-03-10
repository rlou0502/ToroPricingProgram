({ 
    returnToQuote : function(component, event, helper) {
        component.set("v.forwardUrl", "/");
        helper.openWindow(component, event, helper);   
    },
    
    manageProduct: function(component, event, helper) {
        //var quoteId = component.get('v.quoteId');
        component.set("v.forwardUrl", "/apex/REVVY__PMnUIShell#mnquote/detail/");
        helper.openWindow(component, event, helper);
        
        //document.location = '/apex/REVVY__PMnUIShell#mnquote/detail/'+quoteId;
    },
    calculate : function(component, event, helper) {
        var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
		childCmp.calculate(result.PricingProgram, result.PricingMethod, 
                           result.SetupFeePercent, result.PerformancePart);        
    },
    handleCalculationComplete: function(component, event, helper) {
    	var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var quote=event.getParam("quote");
        quoteHeaderCmp.set("v.quote", quote);
    },
    saveAndClose: function(component, event, helper) {
    	var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
		childCmp.saveQuote(result.PricingProgram, result.PricingMethod, 
                           result.SetupFeePercent, result.PerformancePart); 
        quoteHeaderCmp.savePricingProgramMethod();
    },
    addSupportPlus: function(component, event, helper) {
        component.set("v.forwardUrl", "/apex/ToroSupportPlusLgtnOut?Id=");
        helper.openWindow(component, event, helper);
    },
    init : function(component, event, helper) {
        var quoteId = component.get('v.quoteId');
        if(quoteId) {
        	helper.loadQuoteHeader(component, quoteId);
        }
     
    },
    handleAwardPriceChange: function(component, event, helper) {
        
    	var pricingProgram=event.getParam("pricingProgram");
        var pricingMethod=event.getParam("pricingMethod");
        var awardPrice=event.getParam("awardPrice");
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPMTotalAwardDollars(pricingProgram, pricingMethod, awardPrice);    
    },
    handleGPPercentChange: function(component, event, helper) {
    	var pricingProgram=event.getParam("pricingProgram");
        var pricingMethod=event.getParam("pricingMethod");
        var gpPercent=event.getParam("gpPercent");
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPMGPPercent(pricingProgram, pricingMethod, gpPercent);    
    },
    collapseAll : function(component, event, helper) {
    	//console.log('updateQuote');  
        var nodeList = document.getElementsByClassName("collapsible");
        for(var index=0; index < nodeList.length; index++ ) {
        	nodeList[index].style.display = "none";
        }
        var chevronList = document.getElementsByClassName("chevron");
        for(var index=0; index < chevronList.length; index++ ) {
        	chevronList[index].classList.replace('bottom','right') ;
        }
    },
    expandAll : function(component, event, helper) {
        event.preventDefault();
    	var nodeList = document.getElementsByClassName("collapsible");
        for(var index=0; index < nodeList.length; index++ ) {
        	nodeList[index].style.display = "";
        }
        var chevronList = document.getElementsByClassName("chevron");
        for(var index=0; index < chevronList.length; index++ ) {
        	chevronList[index].classList.replace('right','bottom') ;
        }
    },
    closeInfoBox : function(component, event, helper) {
    	document.getElementById("popover-root").style.display="none";    
    },
    handleRefeshInfoBox : function(component, event, helper) {
        var objId=event.getParam("objId");
        helper.retrieveObjectInfo(component, objId);     
    },
    //Handle component event c:PricingProgramSetFromDBEvent, this handler simply set each subline's
    //pricing program, but not actually re-calculate rebate/discount
    handleSetPricingProgram: function(component, event, helper) {
        var newPricingProgram=event.getParam("pricingProgram");
        //console.log('handlePricingProgramChange :newPricingProgram ' + event.getParam("newPricingProgram"));
        var childCmp = component.find("cmpQuoteItem");        
    },
	//Handle component event c:PricingMethodSetFromDBEvent, this handler simply set each subline's
    //pricing method, but not actually re-calculate rebate/discount
    handleSetPricingMethod: function(component, event, helper) {  
        var newPricingProgram=event.getParam("selectedPricingProgram");
        var newPricingMethod=event.getParam("pricingMethod");
        //console.log('handlePricingMethodChange :newPricingMethod ' + event.getParam("pricingMethod"));
        //component.set("v.appContacts", event.getParam("contacts"));
        var childCmp = component.find("cmpQuoteItem");    
    },
	//Handle component event c:PricingProgramChangeEvent
    handlePricingProgramChange: function(component, event, helper) {
        var selectedPricingProgram=event.getParam("selectedPricingProgram");
        var selectedPricingMethod=event.getParam("selectedPricingMethod");
        //console.log('handlePricingProgramChange :selectedPricingProgram ' + event.getParam("selectedPricingProgram"));
        //console.log('handlePricingProgramChange :selectedPricingMethod ' + event.getParam("selectedPricingMethod"));
        //component.set("v.appContacts", event.getParam("contacts"));
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPricingProgramSvc(selectedPricingProgram, function(result) {
            //console.log("callback for aura:method was executed");
            //console.log("result: " + result);
        });        
    },
	//Handle component event c:PricingMethodChangeEvent
    handlePricingMethodChange: function(component, event, helper) {
        var selectedPricingProgram=event.getParam("selectedPricingProgram");
        var selectedPricingMethod=event.getParam("selectedPricingMethod");
        //console.log('handlePricingMethodChange :selectedPricingProgram ' + event.getParam("selectedPricingProgram"));
        //console.log('handlePricingMethodChange :selectedPricingMethod ' + event.getParam("selectedPricingMethod"));
        //component.set("v.appContacts", event.getParam("contacts"));
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPricingMethodSvc(selectedPricingProgram, selectedPricingMethod, function(result) {
            //console.log("callback for aura:method was executed");
            console.log("result: " + result);
        });    
    }
    
})