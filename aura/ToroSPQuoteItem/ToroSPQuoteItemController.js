({
    handleDeleteClick: function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:handleDeleteClick');
        var cmpEvent = cmp.getEvent('spDeleteEvent');
        var productExtId = event.getSource().get('v.name');
        cmpEvent.setParams({
            'productExtId': productExtId
        });

        cmpEvent.fire();
    },
    handleSPQuantityChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:handleSPQuantityChange');

        var sfid      = event.getSource().get('v.name');
        var quoteItem = helper.getQuoteItem(sfid, cmp.get('v.quoteItems'));
        var value     = event.getSource().get('v.value');

        if (value > quoteItem.quantity && !quoteItem.isSupportPlusItem) {
            event.getSource().set('v.value', quoteItem.quantity);
        }

        else if (value < 0) {
            event.getSource().set('v.value', 0);
        }

        var cmpEvent = cmp.getEvent("spQuantityChangeEvent");
        cmpEvent.fire();
    },
    toggleChevron: function(cmp, event, helper) {
    	if (event.currentTarget.classList.contains('chevron')) {
            if (event.currentTarget.classList.contains('bottom')) {
                event.currentTarget.classList.replace('bottom','right');
            }

            else {
                event.currentTarget.classList.replace('right','bottom') ;
            }
        }

        var qiId  = event.currentTarget.dataset.id;
        var tbody = event.currentTarget.closest('tbody');

        var quoteItems = tbody.querySelectorAll("[data-quoteitem='"+ qiId +"']");
        for (var i = 0; i < quoteItems.length; i++) {
        	if (quoteItems[i].style.display == "none") {
        		quoteItems[i].style.display = "";
            }

            else {
            	quoteItems[i].style.display = "none";

            }
        }
    }
})