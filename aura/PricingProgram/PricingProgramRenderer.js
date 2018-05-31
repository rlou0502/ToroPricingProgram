({
    afterRender : function(cmp, helper) {
        document.body.addEventListener('drop', function(event) {
            var rect = document.getElementById("docked_quote_header").getBoundingClientRect();
            var bottom = rect.bottom;
            var offset = event.dataTransfer.getData("text/plain").split(',');
            var dm = document.getElementById("popover-root");
            dm.style.left = (event.clientX + parseInt(offset[0],10)) + 'px';
            var top = event.clientY + parseInt(offset[1],10);
            if(top <= bottom) {
                top = bottom;
            }
            dm.style.top = top + 'px';
            event.preventDefault();
            return false;    
 /*           
            var xPos = e.clientX - xOffset;
            var yPos = e.clientY - yOffset;
            if(!e.clientX){
            	xPos = e.screenX - xOffset;
                yPos = e.screenY - 255 - yOffset;
            }
            if(rect && yPos <= rect.bottom ) {
            	yPos = rect.bottom;  
            }
            console.log('-----drag end  xOffset = ' + xOffset);
            console.log('-----drag end  yOffset = ' + yOffset);
            console.log('-----drag end  xPos = ' + xPos);
            console.log('-----drag end  yPos = ' + yPos);
                document.getElementById("popover-root").style.top =  yPos + "px";
            	document.getElementById("popover-root").style.left = xPos + "px";
*/
            
        });
        document.getElementById("popover-root").addEventListener('dragstart', function(event) {
            debugger;
            var style = window.getComputedStyle(event.target, null);
    		event.dataTransfer.setData("text/plain",
    		(parseInt(style.getPropertyValue("left"),10) - event.clientX) + ',' + (parseInt(style.getPropertyValue("top"),10) - event.clientY));
        });
        document.body.addEventListener('dragover', function(event) {    
            console.log('--------');
            event.preventDefault();
    		return false;
        });
    }
})