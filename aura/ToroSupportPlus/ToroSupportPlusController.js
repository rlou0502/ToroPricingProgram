({
	initialize: function(cmp, event, helper) {
        helper.initialize(cmp);
        /*
        window.addEventListener('scroll',  function(e) {
        	var headerBottom = document.getElementById("global-header").getBoundingClientRect().bottom;
        	var eleTop = document.getElementById("rolling-total").getBoundingClientRect().top;
        	var docScrollTop = document.documentElement.scrollTop;
        	console.log('bottom=' + headerBottom + '  scrolltop=' + eleTop + ' doc top=' + docScrollTop);
        	if(eleTop < headerBottom+3) {
        		console.log('new top = ' + (headerBottom + 3)+"px");
        		document.getElementById("rolling-total").style.position = "fixed";
        		document.getElementById("rolling-total").style.top =  (headerBottom + 3 ) + "px";
        	} else {

        	}
        });
        */

    },
    handleSupportPlusQtyChange: function(cmp, event, helper) {
        var childCmp = cmp.find("cmpRollingTotal");
        childCmp.updateRollingTotals();
    },
    handleAutoComplete: function(cmp, event, helper) {
        var searchTerm = event.target.value;
        if (searchTerm.length >= 3) {
            helper.retrieveAutocompleteResults(cmp, searchTerm);
        }

        else {
            cmp.set('v.searchResult', null);
            cmp.set('v.lastSearchTerm', null);
        }
    },
    toggleAddProductModal: function(cmp, event, helper) {
        helper.toggleAddProductModal(cmp);
    },
    showAddModal: function (cmp, event, helper) {
        helper.showAddModal(cmp);
    },
    hideAddModal: function (cmp, event, helper) {
        helper.hideAddModal(cmp);
    },
    handleHideAutoComplete: function (cmp, event, helper) {
        helper.hideAutoComplete(cmp);
    },
    addProduct: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:addProduct');
        var productId = cmp.get('v.lastSearchTerm');
        if (productId.length >= 3) {
            helper.addProduct(cmp, productId);
        }

        else {
            alert('a product id has not been entered');
        }
    },
    submit: function(cmp, event, helper) {
        alert ('submit placeholder');
        var quote = cmp.get('v.quote');
        var quoteItems = cmp.get('v.quoteItemList');
        helper.submit(quote, quoteItems);
    }
})