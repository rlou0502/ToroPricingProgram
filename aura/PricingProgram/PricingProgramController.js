({
    handleSetDirtyFlag: function(component, evt, helper) { 	    
        var msg=evt.getParam("warningMessage");
        var quoteHeaderCmp = component.find("cmpQuoteHeader");
        quoteHeaderCmp.set("v.contractMessage", msg);
        component.set("v.dirtyFlag", true);
    },
    handleQuoteHeaderLoaded : function(component, evt, helper) { 	
        var allowSupportPlus=evt.getParam("allowSupportPlus");
        component.set("v.allowSupportPlus", allowSupportPlus);
    },
    showDetailInfoBox : function(component, event, helper) {
        helper.retrieveObjectInfo(component, null, null);
    },
    returnToQuote : function(component, event, helper) {
        var dirtyFlag = component.get("v.dirtyFlag");
        if(dirtyFlag) {
            component.set("v.forwardUrl", "/");
            helper.openWindow(component, event, helper);
        } else {
            var quoteId = component.get("v.quoteId");
            document.location = "/"+quoteId;
        }
    },
    manageProduct: function(component, event, helper) {
        var quoteId = component.get('v.quoteId');
        //component.set("v.forwardUrl", "/apex/REVVY__PMnUIShell#mnquote/detail/");
        //helper.openWindow(component, event, helper);
        document.location = '/apex/REVVY__PMnUIShell#mnquote/detail/'+quoteId;
    },
    calculate : function(component, event, helper) {
        var quoteId = component.get('v.quoteId');
        if (quoteId) {
            helper.calculateHelper(component, quoteId);
        }
        helper.closeInfoBox(component);
    },
    handleCalculationComplete: function(component, event, helper) {
    	var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var quote=event.getParam("quote");
        var allowSupportPlus = event.getParam("allowSupportPlus");
        var isSaveOperation = event.getParam("isSaveOperation");
        component.set("v.allowSupportPlus", allowSupportPlus);
        quoteHeaderCmp.set("v.quote", quote);
        quoteHeaderCmp.set("v.contractMessage", null);
        if(isSaveOperation) {
        	component.set("v.dirtyFlag", false);
        } else {
            component.set("v.dirtyFlag", true);
        }
    },
    saveAndClose: function(component, event, helper) {
    	var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
        var returnUrl = component.get("v.forwardUrl");
		childCmp.saveQuote(result.PricingProgram, result.PricingMethod,
                           result.SetupFeePercent, result.PerformancePart, returnUrl);
        quoteHeaderCmp.savePricingProgramMethod();
    },
    handleProceedToSupportPlus: function(component, event, helper) {
        var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
        var returnUrl = component.get("v.forwardUrl");
		childCmp.saveQuote(result.PricingProgram, result.PricingMethod,
                           result.SetupFeePercent, result.PerformancePart, returnUrl);
        quoteHeaderCmp.savePricingProgramMethod();
    },
    handleProceedToNonToro: function(component, event, helper) {
        var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
        var quoteId = event.getParam("quoteId");
        var forwardUrl = event.getParam("forwardUrl");
		childCmp.saveQuote(result.PricingProgram, result.PricingMethod,
                           result.SetupFeePercent, result.PerformancePart, forwardUrl);
        quoteHeaderCmp.savePricingProgramMethod();
    },
    addSupportPlus: function(component, event, helper) {
        var quoteId =component.get("v.quoteId");
        component.set("v.forwardUrl", "/apex/ToroSupportPlusLgtnOut?Id="+quoteId);
        helper.openSupportPlusDisclaimer(component, event, helper);
    },
    addNonToroProducts: function(component, event, helper) {
        var quoteId = component.get('v.quoteId');
        //document.location = '/apex/ToroNTLgtnOut?Id=' + quoteId;
        component.set("v.forwardUrl", "/apex/ToroNTLgtnOut?Id=" + quoteId);
        helper.openSaveBeforeProceedDlg(component, event, helper);
    },
    init : function(component, event, helper) {
    	console.log('isLightning = ' + helper.isLightning());
    	console.log('isMobile = ' + helper.isMobile());
    	console.log('hasSforceOne = ' + helper.hasSforceOne());
        var quoteId = component.get('v.quoteId');
        if(quoteId) {
        	helper.loadQuoteHeader(component, quoteId);
        }

    },
    handleAwardPriceChange: function(component, event, helper) {

    	var pricingProgram=event.getParam("pricingProgram");
        var pricingMethod=event.getParam("pricingMethod");
        var awardPrice=event.getParam("awardPrice");
        var performancePart=event.getParam("performancePart");
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPMTotalAwardDollars(pricingProgram, pricingMethod, awardPrice, performancePart);
    },
    handleGPPercentChange: function(component, event, helper) {
    	var pricingProgram=event.getParam("pricingProgram");
        var pricingMethod=event.getParam("pricingMethod");
        var gpPercent=event.getParam("gpPercent");
        var performancePart=event.getParam("performancePart");
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPMGPPercent(pricingProgram, pricingMethod, gpPercent, performancePart);
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
    	helper.closeInfoBox(component);
    },
    handleRefeshInfoBox : function(component, event, helper) {
        var dm = document.getElementById("popover-root");
        debugger;
        if(dm.style.display != "none") {
        	var infoBoxData =event.getParam("infoBoxData");
        	var infoBoxType =event.getParam("infoBoxType");
        	helper.retrieveObjectInfo(component, infoBoxData, infoBoxType);
    	}
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
        var allowSupportPlus = event.getParam("allowSupportPlus");
        component.set("v.allowSupportPlus", allowSupportPlus);
        //console.log('handlePricingProgramChange :selectedPricingProgram ' + event.getParam("selectedPricingProgram"));
        //console.log('handlePricingProgramChange :selectedPricingMethod ' + event.getParam("selectedPricingMethod"));
        //component.set("v.appContacts", event.getParam("contacts"));
        var childCmp = component.find("cmpQuoteItem");
		childCmp.setPricingProgramSvc(selectedPricingProgram, function(result) {
            //console.log("callback for aura:method was executed");
            debugger;
            console.log("result: " + result);
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