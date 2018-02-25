({
	refreshInfoBox: function(component, event, helper) {
		console.log('----------refreshInfoBox');
        var params = event.getParam('arguments');
        if(params) {
            var objId=params.ObjId;
            helper.retrieveObjectInfo(component, objId);
        }  
        
             
    },
})