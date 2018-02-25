({
	rerender : function(cmp, helper){
        this.superRerender();
        //console.log("rerender-------------");
        //helper.populateValues(cmp);
        //var top = window.pageYOffset;
        //console.log('-----------top =' + top);
    },
    afterRender: function (component, helper) {
        this.superAfterRender();
        //console.log("info box afterRender...");
        // interact with the DOM here
    }
})