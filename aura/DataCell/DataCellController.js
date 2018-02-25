({
	doInit : function(component, helper) {
        debugger;
        var sObject= component.get('v.mapObject');
        var fieldSetMember = component.get('v.fieldSetMember');
        var outputText = component.find("outputTextId");

        outputText.set("v.value",sObject[fieldSetMember.fieldPath]);

    }
})