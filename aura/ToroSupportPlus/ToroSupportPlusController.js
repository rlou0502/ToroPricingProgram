({
	initialize: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:initialize');
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
        var modal = cmp.find('addModal');
        if (modal.classList.contains('hideDiv')) {
            $A.util.removeClass(modal, 'hideDiv');
        }

        else {
            $A.util.addClass(modal, 'hideDiv');
        }
    },
    showAddModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.removeClass(modal, 'hideDiv');
    },
    hideAddModal: function (cmp, event, helper) {
        var modal = cmp.find("addModal");
        $A.util.addClass(modal, 'hideDiv');
        cmp.set('v.searchResult', null);
        cmp.set('v.lastSearchTerm', null);
    },
    handleHideAutoComplete: function (cmp, event, helper) {
        var autoCompleteSection = cmp.find('autocomplete_section');
    },
    addProduct: function(cmp, event, helper) {
        console.log('@ToroSupportPlusController:addProduct');
        var productId                        = cmp.get('v.lastSearchTerm');
        var newItemSPQuantity                = cmp.get('v.newItemSPQuantity');
        var newItemDistributorResponsibility = cmp.get('v.newItemDistributorResponsibility');

        var inputIsValid = true;
        var errorMessage = 'The following values are required: ';

        if (!productId) {
            inputIsValid = false;
            errorMessage += ' Product ID';
        }

        if (!newItemSPQuantity) {
            inputIsValid = false;
            errorMessage += ', SP Quantity';
        }

        if (!newItemDistributorResponsibility) {
            inputIsValid = false;
            errorMessage += ', Distributor Responsibility';
        }



        if (!inputIsValid) {
            alert(errorMessage);
        }

        else {
            helper.addProduct(cmp, productId, newItemSPQuantity, newItemDistributorResponsibility);
        }
    },
    submit: function(cmp, event, helper) {
        alert ('submit placeholder');
        var quote = cmp.get('v.quote');

        // helper.submit(quote, quoteItems);
    },
    createSearchResultHTML: function (productName, productId) {
        var components = [];
        components.push(
            [
                'aura:html',
                {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'slds-icon_container slds-icon-standard-account'
                    }
                }
            ],
            [
                'aura:html',
                {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'slds-media__figure'
                    }
                }
            ],
            [
                'aura:html',
                {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'slds-listbox__option-text slds-listbox__option-text_entity',
                        innerText: productName
                    }
                }
            ],
            [
                'aura:html',
                {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'slds-listbox__option-meta slds-listbox__option-meta_entity',
                        innerText: productId
                    }
                }
            ],
            [
                'aura:html',
                {
                    tag: 'span',
                    HTMLAttributes: {
                        class: 'slds-media__body'
                    }
                }
            ],
            [
                'aura:html',
                {
                    tag: 'div',
                    HTMLAttributes: {
                        class: 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta'
                    }
                }
            ]
        );

        return components;
    }
})