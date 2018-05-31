({
   /* 
    afterRender : function(cmp, helper) {
    	var rect = document.getElementById("ppContainer").getBoundingClientRect();
        if(rect) {
            var top = rect.top;
            var x = document.getElementById("popover-root").style.top=top + "px";
        }
    }
    */
    afterRender : function(cmp, helper) {
        document.getElementById("popover-root").addEventListener('dragend', function(e) {
            if(e.preventDefault) { e.preventDefault(); }
    		if(e.stopPropagation) { e.stopPropagation(); }
            //console.log('----drag end transfer data=' + e.dataTransfer.getData('text/plain'));
            var xOffset = document.getElementById("xOffset").value;
            var yOffset = document.getElementById("yOffset").value;
            var xCurrent = document.getElementById("xCurrent").value;
            var yCurrent =document.getElementById("yCurrent").value;
            
            var xc = document.getElementById("xCurrent").value ;
            var yc = document.getElementById("yCurrent").value ;
            //console.log('-----drag end  xc = ' + xc);
            //console.log('------drag end  yc = ' + yc);
			//console.log('-----drag end  clientX = ' + e.clientX);
            //console.log('------drag end  clientY = ' + e.clientY); 
            //console.log('-----drag end  screenX = ' + e.screenX);
            //console.log('------drag end  screenY = ' + e.screenY);
            //document.getElementById("popover-root").style.top = (e.clientX-xOffset) + "px";
            //document.getElementById("popover-root").style.left = (e.clientY-yOffset) + "px";
            var rect = document.getElementById("docked_quote_header").getBoundingClientRect();
            var lLeft = rect.left;
            var bottom = rect.bottom;
            console.log('-----drag end  clientX = ' + e.clientX);
            console.log('-----drag end  clientY = ' + e.clientY);
            console.log('-----drag end  screenX = ' + e.screenX);
            console.log('-----drag end  screenY = ' + e.screenY);
            console.log('-----drag end  pageX = ' + e.pageX);
            console.log('-----drag end  pageY = ' + e.pageY);
            console.log('-----drag end  offsetX = ' + e.offsetX);
            console.log('-----drag end  offsetY = ' + e.offsetY);
            console.log('-----drag end  movementX = ' + e.movementX);
            console.log('-----drag end  movementY = ' + e.movementY);
            
            //if(rect) {
            //debugger;
            //if(yCurrent != 0) {
             	//document.getElementById("popover-root").style.top =  (yCurrent - yOffset ) + "px";
            	//document.getElementById("popover-root").style.left = (xCurrent - xOffset ) + "px";   
            //} else {
            
            var xPos = e.clientX - xOffset;
            var yPos = e.clientY - yOffset;
            if(rect && yPos <= rect.bottom ) {
            	yPos = rect.bottom;  
            }
                document.getElementById("popover-root").style.top =  yPos + "px";
            	document.getElementById("popover-root").style.left = xPos + "px";
            //}
            
            //}
            //console.log('yCurrent = ' + yCurrent);
            //console.log('yOffset = ' + yOffset);
            //console.log('xCurrent  = ' + xCurrent);
            //console.log('xOffset  = ' + xOffset);
            //console.log('rect x = ' + rect.left);
            //console.log('rect y = ' + rect.top);
            return false; 
            
        });
        document.getElementById("popover-root").addEventListener('dragstart', function(e) {
            //console.log('drag start x = ' + e.clientX);
            //console.log('drag start y = ' + e.clientY);
            e.dataTransfer.setData('text/plain', e.clientX + ";" + e.clientY);
            e.dataTransfer.effectAllowed = "move";
            e.dataTransfer.dropEffect="move";
            var rect = document.getElementById("popover-root").getBoundingClientRect();
            
            //console.log('drag rect x = ' + rect.left);
            //console.log('drag rect y = ' + rect.top);
            var offsetX =e.clientX-rect.left;
            var offsetY =e.clientY-rect.top;
            document.getElementById("xOffset").value = offsetX;
            document.getElementById("yOffset").value = offsetY;
            
            //console.log('drag offset x = ' + document.getElementById("xOffset").value);
            //console.log('drag offset y = ' + document.getElementById("yOffset").value);
            
            //document.getElementById("popover-root").style.top = e.clientX + "px";
            //document.getElementById("popover-root").style.left = e.clientY + "px";
        });
        document.getElementById("popover-root").addEventListener('drag', function(e) {
            
            //console.log('----drag  clientX = ' + e.clientX);
            //console.log('----drag  clientY = ' + e.clientY);
            //console.log('----drag  screenX = ' + e.screenX);
            //console.log('----drag  screenY = ' + e.screenY);
            //console.log('----drag transfer data=' + e.dataTransfer.getData('text/plain'));
            
            var xc = document.getElementById("xCurrent").value ;
            var yc = document.getElementById("yCurrent").value ;
            //console.log('-----drag  xc = ' + xc);
            //console.log('------drag  yc = ' + yc);
            if(e.clientX) {
            	document.getElementById("xCurrent").value = e.clientX;
            }
            if(e.clientY) {
            	document.getElementById("yCurrent").value = e.clientY;
            }
        });
        
        /*
        var svg = cmp.find("icon_container");
        if(svg) {
        var value = svg.getElement().innerText;
        value = value.replace("<![CDATA[", "").replace("]]>", "");
        svg.getElement().innerHTML = value;
        }
        */
        /*
    	var svgns = "http://www.w3.org/2000/svg";
    	var xlinkns = "http://www.w3.org/1999/xlink";
        var svgroot = document.createElementNS(svgns, "svg");
    	var iconClassName = "slds-icon slds-icon_small ";
        
        svgroot.setAttribute("aria-hidden", "true");
    	svgroot.setAttribute("class", iconClassName);
        svgroot.setAttribute("name", "close");
        var shape = document.createElementNS(svgns, "use");
        var profUrl = $A.get('$Resource.slds25') + '/assets/icons/action-sprite/svg/symbols.svg#close';
    	
        shape.setAttributeNS(xlinkns, "href", profUrl);
    	svgroot.appendChild(shape);
    	var container = document.getElementById("icon_container");
        if(container){
    	container.insertBefore(svgroot, container.firstChild);
        }
        */
    }
})