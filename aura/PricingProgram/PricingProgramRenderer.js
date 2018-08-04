({
    afterRender : function(cmp, helper) {
        document.body.addEventListener('dragover', function(e) {    
            console.log('drag over --------');
            e.preventDefault();
    		return false;
        });
        
        document.body.addEventListener('drop', function(e) {
            console.log('drop --------');
            var rect = document.getElementById("docked_quote_header").getBoundingClientRect();
            var bottom = rect.bottom;
            var offset = e.dataTransfer.getData("text/plain").split(',');
            var dm = document.getElementById("popover-root");
            dm.style.left = (e.clientX + parseInt(offset[0],10)) + 'px';
            var top = e.clientY + parseInt(offset[1],10);
            if(top <= bottom) {
                top = bottom;
            }
            dm.style.top = top + 'px';
            e.preventDefault();
            return false;    
        });
        document.getElementById("popover-root").addEventListener('dragstart', function(e) {
            console.log('drag start --------');
            var style = window.getComputedStyle(e.target, null);
    		e.dataTransfer.setData("text/plain",
    		(parseInt(style.getPropertyValue("left"),10) - e.clientX) + ',' + (parseInt(style.getPropertyValue("top"),10) - e.clientY));
        });
        helper.showSpinner();
    }
})