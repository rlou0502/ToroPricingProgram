({
	initialize : function(cmp, event, helper) {
		helper.initialize(cmp);
	},
    returnToPricing: function (cmp, event, helper) {
    	console.log('@ToroSupportPlusController:returnToPricing');
    	var quoteId = cmp.get("v.quoteId");
    	document.location = '/apex/PricingProgramLgtnOut?Id=' + quoteId;
	},
	handleShowAddNewModal: function(cmp, event, helper) {
		alert('handleShowAddNewModal placeholder');
	},
	handleSave: function(cmp, event, helper) {
		alert('handleSave placeholder');
	},
	handleSaveAndClose: function (cmp, event, helper) {
		alert('handleSaveAndClose placeholder');
	}
})