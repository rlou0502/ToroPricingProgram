({
    supportPlusQtyChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:supportPlusQtyChange');
        var cmpEvent = cmp.getEvent("supportPlusQtyChangeEvent");
        cmpEvent.fire();
    },
    supportPlusContributionChange : function(cmp, event, helper) {
        console.log('@ToroSPQuoteItemController:supportPlusContributionChange');
        var cmpEvent = cmp.getEvent("supportPlusQtyChangeEvent");
        cmpEvent.fire();
    },
    toggleChevron: function(cmp, event, helper) {
    	debugger;
    	if(event.currentTarget.classList.contains('chevron')) {
            if(event.currentTarget.classList.contains('bottom')) {
                event.currentTarget.classList.replace('bottom','right') ;   
            } else {
                event.currentTarget.classList.replace('right','bottom') ;
            }
        }
        console.log('@ToroSPQuoteItemController:toggleSection');
        var qiId = event.currentTarget.dataset.id;
        var tbody = event.currentTarget.closest('tbody');
        var quoteItems = tbody.querySelectorAll("[data-quoteitem='"+ qiId +"']");
        for(var i=0; i < quoteItems.length; i++) {
        	if(quoteItems[i].style.display == "none") {
        		quoteItems[i].style.display=""; 
               
            } else {
            	quoteItems[i].style.display = "none";
                
            }
        }
    }
})