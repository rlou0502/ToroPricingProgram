({
    handleSPQuantityChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:handleSPQuantityChange');
        var cmpEvent = cmp.getEvent("spQuantityChangeEvent");
        cmpEvent.fire();
    },
    handleSPContributionChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:handleSPContributionChange');
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