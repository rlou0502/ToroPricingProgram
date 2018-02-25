({
	render : function(cmp, helper) {
        var ret = this.superRender();
        console.log("------------Quote Item render...");
        return ret;
    },
    rerender : function(cmp, helper){
        var ret = this.superRerender();
        console.log("------------Quote Item rerender..." + Date.now());
        return ret;
        //console.log("------------Quote Item rerender..." + Date.now());
        //var items = document.getElementById("quoteItems");
        //helper.cleanInnerNodes(items);
        //helper.renderQuoteItems(cmp);
    },
    afterRender: function (component, helper) {
        var r = this.superAfterRender();
        console.log("------------Quote Item afterRender...");
        return r;
        //console.log("------------Quote Item afterRender...");
        // interact with the DOM here
        // var items = document.getElementById("quoteItems");
        //helper.cleanInnerNodes(items);
        //helper.renderQuoteItems(cmp);
    },
})