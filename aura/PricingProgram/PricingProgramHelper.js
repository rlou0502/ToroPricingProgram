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
                    debugger;
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
                var cellValue = document.createElement('span');
                cellValue.className += " slds-truncate";
                cellValue.innerHTML = sObj[field.fieldPath];
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
    retrieveObjectInfo : function(component, objId) {
        var self = this;
        //console.log('----------retrieveObjectInfo');
    	var getAction = component.get('c.refreshInfoBoxSvc');
        getAction.setStorable();
        getAction.setParams({
            objId: objId
        });
        getAction.setCallback(this,
        	function(response) {
                //console.log('----------retrieveObjectInfo 3');
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var data = response.getReturnValue();
                    var retResponse = response.getReturnValue();
                    component.set('v.fields', retResponse.fieldSetMembers);
                    component.set('v.sObject', retResponse.values[0]);
                    self.renderInfoBox(component);
                }
            }
        );
        $A.enqueueAction(getAction);
    }
})