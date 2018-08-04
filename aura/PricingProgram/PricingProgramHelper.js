({
    openWindow : function(component, event, helper) {
		$A.createComponent(
            "c:ConfirmationDialog",
            {
                "forwardUrl": component.get("v.forwardUrl"),
                "quoteId": component.get("v.quoteId")
            },
            function(msgBox, status, errorMessage){
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    openSupportPlusDisclaimer : function(component, event, helper) {
		$A.createComponent(
            "c:ToroSPDisclaimerDlg",
            {
                "quoteId": component.get("v.quoteId")
            },
            function(msgBox, status, errorMessage){
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    openSaveBeforeProceedDlg : function(component, event, helper) {
		$A.createComponent(
            "c:ToroPromptSaveBeforeNonToroDlg",
            {
                "quoteId": component.get("v.quoteId"),
                "forwardUrl": component.get("v.forwardUrl")
            },
            function(msgBox, status, errorMessage){
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    calculateHelper : function(component, quoteId) { 
        var self = this;
        self.resetQuoteApproval(component, quoteId);
        var quoteHeaderCmp = component.find("cmpQuoteHeader");
        var result = quoteHeaderCmp.getQuoteInfo();
    	var childCmp = component.find("cmpQuoteItem");
		childCmp.calculate(result.PricingProgram, result.PricingMethod,
                           result.SetupFeePercent, result.PerformancePart, result.SetupFeeOverride);    
    },
    resetQuoteApproval : function(component, quoteId) {
        var action = component.get('c.resetQuoteApproval');
        action.setParams({
            quoteId : quoteId
        });
        action.setCallback(
            this
            , function(response) {
                console.log('quote approval reset...');
            }
        );
        $A.enqueueAction(action);
    },
    loadQuoteHeader : function(component, quoteId) {
    	var getAction = component.get('c.loadQuoteHeader');
		getAction.setParams({
	        quoteId: quoteId
	    });
		getAction.setCallback(this,
	        function(response) {
	            var state = response.getState();
	            //console.log('ToroPricingProgramController getFormAction callback');
	            //console.log("callback state: " + state);
	            if (component.isValid() && state === "SUCCESS") {
	                var quote = response.getReturnValue();
                    component.set('v.quote', quote);
	            }
	        }
	    );
		$A.enqueueAction(getAction);
    },
    renderInfoBox : function(component) {
        if(document.getElementById("popover-root")) {
            var fields = component.get("v.fields");
            var sObj = component.get("v.sObject");
            var self = this;
            var items = document.getElementById("popover-body");
            self.cleanInnerNodes(items);
            var tmp = document.createDocumentFragment();
            var table = document.createElement("TABLE");
            tmp.appendChild(table);
            table.id = "infoBox";
            fields.forEach(function(field) {
                var type = field.type.toLowerCase();
                var tableRow = document.createElement('tr');
                var tableColLabel = document.createElement('td');
                var cellLabel = document.createElement('span');
                cellLabel.className += " slds-truncate";
                cellLabel.innerHTML = field.label;
                cellLabel.title=field.label;
                tableColLabel.appendChild(cellLabel);
                tableRow.appendChild(tableColLabel);
                var tableColValue = document.createElement('td');
                tableColValue.className += " slds-truncate attr-value";
                var cellValue = document.createElement('span');
                cellValue.className += " slds-truncate";
                cellValue.innerHTML = sObj[field.fieldPath];
                if(type === 'double') {
                    if(sObj[field.fieldPath] != undefined) {
                        cellValue.innerHTML= parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, {minimumFractionDigits: 0, maximumFractionDigits: 0}); 
                    }  
                } else if(type === 'currency') {
                    if(sObj[field.fieldPath] != undefined) {
                        cellValue.innerHTML =	'$'+parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, 
                                                   {minimumFractionDigits: 2, 
                                                    maximumFractionDigits: 2
                                                    
                                                   });
                    }
                } else if(type === 'boolean') {
                    var tableDataNode = document.createElement('input');
                    tableDataNode.type='checkbox'; 
                    tableDataNode.checked = sObj[field.fieldPath];
                    tableDataNode.disabled=true;
                    cellValue.appendChild(tableDataNode);
                } else if(type === 'percent') {
                   if(sObj[field.fieldPath] != undefined) {
                       cellValue.innerHTML=parseFloat(sObj[field.fieldPath]/100).toLocaleString(undefined, 
                                                    {minimumFractionDigits: 4, 
                                                     maximumFractionDigits: 4,
													 style : 'percent'                                                     
                                                    }); 
                    } 
                } else if(type === 'string') {
                    var dispVal = sObj[field.fieldPath]; 
                    if(dispVal != "NaN") {
                        cellValue.innerHTML = dispVal;
                        cellValue.title=dispVal;
                    }
                }                           
                tableColValue.appendChild(cellValue);
                tableRow.appendChild(tableColValue);
                table.appendChild(tableRow);
            });

            document.getElementById("popover-body").appendChild(tmp);
            if(document.getElementById("popover-root")) {
            	document.getElementById("popover-root").style.display="block";
            }

        }
    },
    cleanInnerNodes : function(node) {
		while (node.hasChildNodes()) {
        	this.clear(node.firstChild);
      	}
    },
    clear : function(node) {
    	while (node.hasChildNodes()) {
            this.clear(node.firstChild);
		}
		node.parentNode.removeChild(node);
    },
    handleMouseDown : function(cmp, event) {
        var self = this;
        var targetElm = document.getElementById("popover-header");
        var x = event.clientX;
        var y = event.clientY;
        cmp.set("v.pos3", x);
        cmp.set("v.pos4", y);
        console.log('mousedown x='+x + ' y=' + y);
        targetElm.addEventListener('mousemove', function(e) { self.handleMouseMove(cmp, e); });
    	targetElm.addEventListener('mouseup', function(e) { self.handleMouseUp(cmp, e); });
    },
    handleMouseMove : function(cmp, event) {
        var x = event.clientX;
        var y = event.clientY;

        var startX = cmp.get("v.pos3");
        var startY = cmp.set("v.pos4");
        var pos1 = startX-x;
        var pos2 = startY-y
        cmp.set("v.pos1", pos1 );
        cmp.set("v.pos2", pos2 );
        var elm = document.getElementById("popover-root");
        elm.style.top = (elm.offsetTop - pos2) + "px";
        elm.style.left = (elm.offsetLeft  - pos1) + "px";
        console.log('mousemove x='+x + ' y=' + y);
    },
    handleMouseUp : function(cmp, event) {
        console.log('mouseup ');
        var elm = document.getElementById("popover-header");
        elm.removeEventListener('mousemove', function(e) { self.handleMouseMove(cmp, e); });
    	elm.removeEventListener('mouseup', function(e) { self.handleMouseUp(cmp, e); });
    },
    retrieveObjectInfo : function(component, infoBoxData, infoBoxType) {
        var self = this;
        //console.log('----------retrieveObjectInfo');
    	var getAction = component.get('c.getInfoBoxFieldSets');
        getAction.setStorable();
        getAction.setCallback(this,
        	function(response) {
                //console.log('----------retrieveObjectInfo 3');
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var data = response.getReturnValue();
                    var retResponse = response.getReturnValue();
                    switch(infoBoxType) {
                        case "TractionUnit":
                            component.set('v.fields', retResponse.quoteItemTractionUnitFieldSet);
                            component.set('v.infoBoxType', $A.get("$Label.c.PP_Traction_Unit"));                          
                            break;
                        case "Subline":
                            component.set('v.fields', retResponse.quoteSublineFieldSet);
                            component.set('v.infoBoxType', $A.get("$Label.c.PP_Subline")); 
                            break;
                        case "MainLine":
                            component.set('v.fields', retResponse.quoteItemMainFieldSet);
                            component.set('v.infoBoxType', $A.get("$Label.c.PP_Configuration_Line")); 
                            break;
                        default:
    						component.set('v.fields', retResponse.quoteFieldSet);
                            component.set('v.infoBoxType', $A.get("$Label.c.PP_Quote_Header")); 
                            
                    }
                    component.set('v.sObject', infoBoxData || {});
                    self.renderInfoBox(component);
                }
            }
        );
        $A.enqueueAction(getAction);
    },
    isLightning: function() {
        return $A.get("e.force:showToast");
    },
    isMobile: function() {
        var userAgent=window.navigator.userAgent.toLowerCase();
        return (-1!=userAgent.indexOf('mobile'));
    },
    hasSforceOne : function() {
        var sf;
        try {
            sf=(sforce && sforce.one);
        }
        catch (exc) {
            sf=false;
        }
          
        return sf;
    },
    isSalesforceOne : function() {
    	return isLightning() && isMobile();
    },
    isLightningX : function() {
    	return isLightning() && (!isMobile())
    },
    isLightningOut : function() {
    	return (!isLightning()) && hasSforceOne();
    },
    isClassic : function() {
    	return (!isLightning()) && (!hasSforceOne());
    },
    closeInfoBox : function(component) {
    	document.getElementById("popover-root").style.display="none";
    },
    showSpinner : function(node) {
        if(document.getElementById("spinner-1")) {
        	document.getElementById("spinner-1").style.display="block";    
        }   	   
    },
    hideSpinner : function(node) {
        if(document.getElementById("spinner-1")){
            document.getElementById("spinner-1").style.display="none";
        }
    	   
    },

})