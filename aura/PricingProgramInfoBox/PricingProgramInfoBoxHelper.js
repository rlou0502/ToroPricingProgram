({
/*
     *  Map the Field to the desired component config, including specific attribute values
     *  Source: https://www.salesforce.com/us/developer/docs/apexcode/index_Left.htm#CSHID=apex_class_Schema_FieldSetMember.htm|StartTopic=Content%2Fapex_class_Schema_FieldSetMember.htm|SkinName=webhelp
     *
     *  Change the componentDef and attributes as needed for other components
     */
    configMap: {
        'anytype': { componentDef: 'ui:outputText', attributes: {} },
        'base64': { componentDef: 'ui:outputText', attributes: {} },
        'boolean': {componentDef: 'ui:inputCheckbox', attributes: {} },
        'combobox': { componentDef: 'ui:outputText', attributes: {} },
        'currency': { componentDef: 'ui:outputText', attributes: {} },
        'datacategorygroupreference': { componentDef: 'ui:outputText', attributes: {} },
        'date': {
            componentDef: 'ui:outputDate',
                attributes: {
                    format: 'MM/dd/yyyy'
                }
            },
        'datetime': { componentDef: 'ui:outputDateTime', attributes: {} },
        'double': { componentDef: 'ui:outputNumber', attributes: {} },
        'email': { componentDef: 'ui:outputEmail', attributes: {} },
        'encryptedstring': { componentDef: 'ui:outputText', attributes: {} },
        'id': { componentDef: 'ui:outputText', attributes: {} },
        'integer': { componentDef: 'ui:outputNumber', attributes: {} },
        'multipicklist': { componentDef: 'ui:outputText', attributes: {} },
        'percent': { componentDef: 'ui:outputNumber', attributes: {} },
        'phone': { componentDef: 'ui:outputPhone', attributes: {} },
        'picklist': { componentDef: 'ui:outputText', attributes: {} },
        'reference': { componentDef: 'ui:outputText', attributes: {} },
        'string': { componentDef: 'ui:outputText', attributes: {} },
        'textarea': { componentDef: 'ui:outputText', attributes: {} },
        'time': { componentDef: 'ui:outputDateTime', attributes: {} },
        'url': { componentDef: 'ui:outputText', attributes: {} }
    },
    populateValues : function(component) {
    	var fields = component.get("v.fields");	
        var sObj = component.get("v.sObject");
        var self = this;
        fields.forEach(function(field, index) {
            var idx ="infoValue"+index; 
            console.log("----------idx=" + idx);
            var c = document.getElementById(idx);
            //console.log("----------sObj=" + sObj);
            //console.log("----------field.fieldPath=" + field.fieldPath);
            //console.log("----------sObj[field.fieldPath]=" + sObj[field.fieldPath]);
            if(c) {
                c.innerHTML = sObj[field.fieldPath];
            }
            //c.set("v.body", sObj[field.fieldPath]);
        });
    },
    renderInfoBox : function(component) {
		var fields = component.get("v.fields");	
        var sObj = component.get("v.sObject");	      
        var self = this;
        var items = document.getElementById("infoBox");
        self.cleanInnerNodes(items);
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
            document.getElementById("infoBox").appendChild(tableRow);
        });
        var infoBox = document.getElementById("infoBox");
        document.getElementById("popover-root").appendChild(infoBox);
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
    retrieveObjectInfo : function(component, objId) {
        var self = this;
        console.log('----------retrieveObjectInfo');
    	var getAction = component.get('c.refreshInfoBoxSvc');
        getAction.setStorable();
        getAction.setParams({
            objId: objId
        });
        getAction.setCallback(this, 
        	function(response) {
                console.log('----------retrieveObjectInfo 3');
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