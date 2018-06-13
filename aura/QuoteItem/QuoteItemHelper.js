({
    handleQuoteItemInfo : function(component, overId) {
        var cmpEvent = component.getEvent("refreshInfoBoxEvent");
        cmpEvent.setParams({
            "objId" : overId
        });
        cmpEvent.fire();
    },
    handleQuoteItemSublineInfo : function(component, overId) {
        var cmpEvent = component.getEvent("refreshInfoBoxEvent");
        cmpEvent.setParams({
            "objId" : overId
        });
        cmpEvent.fire(); 
    },
    handleInfoBoxRefresh : function(component, obj, lineType) {
    	var cmpEvent = component.getEvent("refreshInfoBoxEvent");
        cmpEvent.setParams({
            "infoBoxData" : obj,
            "infoBoxType" : lineType
        });
        cmpEvent.fire();    
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    onUpdatableValueChange: function( event, component) {
        var self=this;
        var listenMSRPChange = component.get('v.listenMSRPChange');
        var pricingMethod = component.get('v.selectedPricingMethod');
        var fieldName = event.currentTarget.dataset.fieldname;
        
        var curObj = event.currentTarget;
        if(fieldName == "PricingMethodValue__c" || fieldName == "Award_Price__c") {
            var newVal = event.currentTarget.value; 
            var quoteItemId = event.currentTarget.closest('tr').id;
            if(listenMSRPChange) {
            	var originalVal = event.currentTarget.dataset.originalvalue;
                var oldValue = event.currentTarget.dataset.oldvalue;
                var newVal = parseFloat(newVal);
                var origVal = parseFloat(originalVal);
                console.log('-------------newVal =' + newVal);
                console.log('-------------oldVal =' + oldValue);
                var validAdjustment = true;
                var msg = '';
                if(fieldName == "PricingMethodValue__c"){
                    validAdjustment = newVal >= origVal;
                    msg = 'Please enter a value higher than ';
                } else if(fieldName == "Award_Price__c") {
                    validAdjustment = newVal <= origVal;
                    msg = 'Please enter a value lower than ';
                }
                    
                if(!validAdjustment) {
                    alert(msg + origVal);
                    event.currentTarget.value=oldValue;
                    curObj.focus();
                    return false;
                } else {
                    var elms =event.currentTarget.closest("tr").querySelectorAll("input[type=text]");
                    for(var i = 0; i < elms.length; i++) {
                        if(elms[i] != event.currentTarget) {
                            elms[i].dataset.overridden = false;    
                        }    
                    }
                    curObj.dataset.overridden="true";
                } 
            } else {
            	var pm = component.get("v.selectedPricingMethod");
            	if(fieldName == "PricingMethodValue__c" && pm !="Total Award $") {
	                var sublines = document.querySelectorAll("[data-parentquoteitem='"+ quoteItemId +"'][data-fieldname='"+fieldName+"']");
	                for (var i=0; i<sublines.length; i++) {
	                    sublines[i].value=newVal;
	                }
            	}
            	
            	
                curObj.dataset.overridden="true";
            }
        } else {
            event.currentTarget.dataset.overridden="true";
        }
        var cmpEvent2 = component.getEvent("setDirtyFlagEvent");
        	var msg = $A.get("$Label.c.PP_Dirty_Warning_Message");
        	cmpEvent2.setParams({
                warningMessage : msg
        });
        cmpEvent2.fire();
    },
	handleRowClick : function(component, selectedQuoteItem) {
        var nodeList = document.querySelectorAll(".collapsible."+selectedQuoteItem);
        for(var index=0; index < nodeList.length; index++ ) {          
            if(nodeList[index].style.display == "none") {
                nodeList[index].style.display=""; 
               
            } else {
                nodeList[index].style.display = "none";
                
            }
        }
        
        /*
        var sublines = component.get('v.sublineMap');
        var sublineFields = component.get('v.fieldsSub');
        var summaryFields = component.get('v.fieldsSummary');
        component.set('v.selectedQuoteItem', selectedQuoteItem);
        
        var fields = component.get('v.fields');
        var quoteItemMap = component.get('v.quoteItemMap');
        var quoteItem = quoteItemMap[selectedQuoteItem];
        var pricingMethod = component.get('v.selectedPricingMethod');
        if(sublines) {
        	sublines = sublines[selectedQuoteItem]; 
            if(sublines) {
                var clickOnSelf=false;
                var existing = document.getElementById("QuoteItemPricingProgram");
                if(existing) {
                    if(existing.previousSibling.id == selectedQuoteItem ) {
                    	clickOnSelf = true;    
                    }
                	existing.parentElement.removeChild(existing);
                    existing = document.getElementById("QuoteItemSubLine");
                    if(existing) {
                        existing.parentElement.removeChild(existing);
                    } 
                    
                    existing = document.getElementById("QuoteItemSummary");
                    if(existing) {
                        existing.parentElement.removeChild(existing);
                    }
                }
                              
                if(!clickOnSelf) {
            		this.populateQuoteItemSubLine(component, sublines, fields, sublineFields, selectedQuoteItem);
                    this.renderQuoteItemPricingProgramSection(component, fields, selectedQuoteItem);
                    this.renderQuoteItemSummarySection(component, quoteItem, fields, summaryFields, selectedQuoteItem);
                }
            }
        }
        */
    },
    formatPercentWithDecimal : function(percent, scale) {
        var lPercent = percent;
        if(typeof percent == "string") {
        	lPercent = parseFloat(percent);    
        }
        return lPercent.toFixed(scale);
    },
    renderTable : function(fields, sObj, parentRow, quoteItemId, component, isMainLine, lineType) {
        var self=this;
        var bFroze = sObj["FreezePricing__c"];
        //var pp = component.get('v.performancePart');
        var pricingMethod = component.get('v.selectedPricingMethod');
  		fields.forEach(function(field){
            //console.log('field name' + field.fieldPath);
            var tableData = document.createElement('td');
            tableData.className += field.fieldPath;
            var cellText = document.createElement('div');
            cellText.className += " slds-truncate slds-cell-wrap";
            var freeze = sObj["Freeze_Line__c"];
            var prodId = sObj["Product_Id__c"];
            var vToroProd = true;
            if(prodId != "" && prodId.startsWith("L00")) {
                vToroProd = false;
            }
			console.log("--- renderTable +" + prodId + " - " + vToroProd);            
            //check quote item
            var performancePart = sObj["Performance_Parts_Product__c"];
            if(performancePart === undefined) {
                //check quote item subline
           		performancePart = sObj["Performance_part__c"];    
            }
            var onlyInCPL = sObj["OnlyExistedInCPL__c"];
            
            var supportPlusFlag = sObj["Support_Plus_Item__c"];
            if(supportPlusFlag === undefined) {
                //check quote item subline
           		supportPlusFlag = sObj["Apply_Support_Plus__c"];    
            }
                    
            var totalAwardUpdatable = true;
            if(!isMainLine && (pricingMethod == "Total Award $" || pricingMethod == "Gross Profit %")  && field.fieldPath=="PricingMethodValue__c") {
            	totalAwardUpdatable = false;
                if(pricingMethod == "Total Award $") {
                	sObj["PricingMethodValue__c"]="";
                }
            }        
            if((totalAwardUpdatable && vToroProd && field.updatable && !freeze && !supportPlusFlag &&(!performancePart || (field.fieldPath=="Award_Price__c" || field.fieldPath=="Total_Toro_Award__c") )) 
            || (onlyInCPL && field.fieldPath=="Award_Price__c")
            ){
                //var tableDataNode = document.createTextNode(sObj[field.fieldPath]);
                var tableDataNode = document.createElement('input');
                if(field.required) {
                	tableDataNode.required=true;  
                    cellText.className += " has-required-field ";
                }
                tableDataNode.value = sObj[field.fieldPath] ? self.formatPercentWithDecimal(sObj[field.fieldPath], 4) : '';
                var decimalPoint = 4;
                if(pricingMethod == "Total Award $") {
                	decimalPoint=2;    
                }
                //
                if(onlyInCPL && field.fieldPath=="Award_Price__c") {
                    var msg = $A.get("$Label.c.PP_OnlyExistInCPL"); 
                	tableDataNode.placeholder = msg; 
            	}
                tableDataNode.value = sObj[field.fieldPath] ? self.formatPercentWithDecimal(sObj[field.fieldPath], decimalPoint) : '';
                tableDataNode.type='text';
                tableDataNode.dataset.overridden=sObj['Unit_Award_Overridden__c'];
                if(quoteItemId) {
                    //this is a subline
                	tableDataNode.dataset.parentquoteitem=quoteItemId; 
                    
                    if(field.fieldPath=="Award_Price__c" || field.fieldPath=="PricingMethodValue__c") {
                    	tableDataNode.addEventListener('change', function(event){ 
                            this.dataset.overridden =true;
                            var elms =event.currentTarget.closest("tr").querySelectorAll("input[type=text]");
                            for(var i = 0; i < elms.length; i++) {
                                if(elms[i] != event.currentTarget) {
                                    elms[i].dataset.overridden = false;    
                                }    
                            }
                        }, false);    
                    }
                } else {
                    //this is a quote line                   
                    var listenMSRPChange = component.get("v.listenMSRPChange");
                    if(listenMSRPChange) {
                        if(field.fieldPath=="PricingMethodValue__c") {
                            tableDataNode.dataset.originalvalue=sObj["Selected_Off_MSRP__c"]; 
                            tableDataNode.dataset.overridden=sObj['Off_MSRP_Overridden__c'];
                        } else if(field.fieldPath=="Award_Price__c" || field.fieldPath=="Total_Toro_Award__c") {
                            tableDataNode.dataset.originalvalue=sObj["Original_Award_Price__c"];
                        }
                    } else {
                        if(pricingMethod == "Total Award $" && field.fieldPath=="PricingMethodValue__c") {
                        	tableDataNode.dataset.overridden = false;    
                        }
                    }                 
                  
                    tableDataNode.dataset.quoteitem=sObj["Id"];
                    tableDataNode.addEventListener('change', function(event){this.dataset.overridden =true; self.onUpdatableValueChange(event, component);}, false);
                    tableDataNode.addEventListener('focus', function(event){ this.dataset.oldvalue=this.value;}, false);
                }
                tableDataNode.className += " sfdcid-"+sObj["Id"];
                tableDataNode.dataset.fieldname=field.fieldPath;
                //tableDataNode.dataset.overridden="false";
                //tableDataNode.className += " " + field.type.toLowerCase() + "-" + field.fieldPath;
                if(field.type.toLowerCase() === 'boolean') {
                    tableDataNode.type='checkbox';
                    tableDataNode.checked = sObj[field.fieldPath];
                } 
                cellText.appendChild(tableDataNode);
            } else {
                if(field.fieldPath == "Product_Id__c") {
                	tableData.addEventListener('mouseenter', function(){self.handleInfoBoxRefresh(component, sObj, lineType);}, false);
                }
                if(field.type.toLowerCase() === 'double') {
                    if(sObj[field.fieldPath]!= undefined) {
                        cellText.innerHTML=	parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, {minimumFractionDigits: 0, maximumFractionDigits: 0}); 
                    }  
                } else if(field.type.toLowerCase() === 'currency') {
                    if(sObj[field.fieldPath]!= undefined) {
                        cellText.innerHTML=	parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
                    }
                } else if(field.type.toLowerCase() === 'boolean') {
                    var tableDataNode = document.createElement('input');
                    tableDataNode.type='checkbox'; 
                    tableDataNode.checked = sObj[field.fieldPath];
                    tableDataNode.disabled=true;
                    cellText.appendChild(tableDataNode);
                } else if(field.type.toLowerCase() === 'percent') {
                   if(sObj[field.fieldPath] != undefined) {
                       cellText.innerHTML=parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, {minimumFractionDigits: 4, maximumFractionDigits: 4}); 
                    } 
                } else if(field.type.toLowerCase() === 'string') {
                    var dispVal = sObj[field.fieldPath];
                    if(field.fieldPath=="PricingMethodValue__c") {                       
                    	dispVal = parseFloat(sObj[field.fieldPath]).toLocaleString(undefined, {minimumFractionDigits: 4, maximumFractionDigits: 4});  

                    } 
                    if(dispVal != "NaN") {
                        cellText.innerHTML = dispVal;
                        cellText.title=dispVal;
                    }
                }              
            }
            tableData.appendChild(cellText);
            if(field.required) {
                var cellErrorMsg = document.createElement('div');
                cellErrorMsg.className += "  validation-error sfdcid-"+sObj["Id"];
                var msg = $A.get("$Label.c.PP_Validation_Error_Message");
                cellErrorMsg.innerHTML = msg;
                tableData.appendChild(cellErrorMsg);
            }
            parentRow.appendChild(tableData);
    	});      
    },
    renderQuoteItemSummarySection : function(component, quoteItem, fields, summaryFields, selectedQuoteItem) {
        var tableRow = document.createElement('tr'); 
        tableRow.className += " noBorder collapsible "+selectedQuoteItem;
        tableRow.id = "QuoteItemSummary";
        tableRow.style.display="none";
        var colspan = fields.length+1;
        var tableCol = document.createElement('td');
        var self = this;
        tableCol.colSpan = colspan.toString();
        tableRow.appendChild(tableCol);
        var childTable = document.createElement('table');
        childTable.className += " slds-table slds-table--striped slds-table--cell-buffer slds-table--fixed-layout"; 
        var childTableHeader = document.createElement('thead'); 
        var headerRow = document.createElement('tr');
        headerRow.className += "slds-text-heading--label ";
        summaryFields.forEach(function(f) { 
            var hearderRowCell = document.createElement('th');
            hearderRowCell.className += f.fieldPath;
            if(f.type.toLowerCase() === 'boolean') {
            	hearderRowCell.className += ' type-'+f.type;	    
            }  
            hearderRowCell.scope="col";
            var cellText = document.createElement('div');
            cellText.className += " slds-truncate slds-cell-wrap";
            cellText.innerHTML = f.label;
            cellText.title=f.label;
            hearderRowCell.appendChild(cellText);
            headerRow.appendChild(hearderRowCell);
        });
        childTableHeader.appendChild(headerRow);
        childTable.appendChild(childTableHeader);
        tableCol.appendChild(childTable);
		var childTableBody = document.createElement('tbody');
        var summaryLineTableRow = document.createElement('tr');
        summaryLineTableRow.id = quoteItem["Id"];
        summaryLineTableRow.className += " quoteItem summary";
        self.renderTable(summaryFields, quoteItem, summaryLineTableRow, null, component, false, "TractionUnit");           

        childTableBody.appendChild(summaryLineTableRow);
        childTable.appendChild(childTableBody);
        //var target = document.getElementById("QuoteItemSubLine");
        var target = document.getElementById(selectedQuoteItem);
    	target.parentNode.insertBefore(tableRow, target.nextSibling );
    },
    renderQuoteItemPricingProgramSection : function(component, quoteItem, fields, selectedQuoteItem) {
    	//console.log('fields.length=' + fields.length); 
    	
        var quoteItem = component.get('v.quoteItemMap')[selectedQuoteItem];
        var pricingProgram = component.get('v.selectedPricingProgram'); //quoteItem["Pricing_Program__c"];
        console.log('-------------pricingProgram=' + pricingProgram);
        var secondaryProgramKeys = component.get('v.secondaryProgramKeys');
        if(!secondaryProgramKeys) {
            return;
        }
        /*
        var pps = pricingProgram.split(";");
        if(pps.length == 2 && pps[1] != "Large_Package") {           
            return;
        }
        */
        var tableRow = document.createElement('tr');
        tableRow.className += " noBorder collapsible "+selectedQuoteItem;
        tableRow.style.display="none";
        tableRow.id = "QuoteItemPricingProgram";
        var colspan = fields.length+1;
        var tableCol = document.createElement('td');
        var self = this;
        tableCol.colSpan = colspan.toString();
        tableRow.appendChild(tableCol);
        var childTable = document.createElement('table');
        childTable.className += " slds-table slds-table_bordered slds-table--striped slds-table--cell-buffer";         
        
        var dataRow = document.createElement('tr');       
        var dataRowCellPricingProgram = document.createElement('td');
        dataRowCellPricingProgram.scope="col";
        var cellTextPricingProgram = document.createElement('span');
        
        cellTextPricingProgram.className += ' slds-p-bottom_x-small';
        cellTextPricingProgram.innerHTML = "SECONDARY PROGRAMS";
        dataRowCellPricingProgram.appendChild(cellTextPricingProgram);
        var pricingProgramSelectDiv = document.createElement('span');
        pricingProgramSelectDiv.className += ' secondary-pricing-program';
        dataRowCellPricingProgram.appendChild(pricingProgramSelectDiv);
        var pricingProgramSelect = document.createElement('select');
        pricingProgramSelect.dataset.quoteitemid=selectedQuoteItem;
        pricingProgramSelect.addEventListener('change', 
        	function(event){ 
            	var sfdcid = this.dataset.quoteitemid;
                var qi = document.getElementById(sfdcid);
                if(qi) {
                    qi.dataset.pricingprogram = event.currentTarget.value;
                    qi.dataset.pricingprogram_overridden = true;
                }
            }, false);    
        var secondaryPrograms = component.get('v.secondaryPrograms');
        var selectedPricingProgram = quoteItem['Pricing_Program__c'];
        for(var k=0; k <secondaryProgramKeys.length; k++ ) {
            var key = secondaryProgramKeys[k];
        	var spVal = secondaryPrograms[key];
            if(typeof spVal == "string" ) {
            	var option1 = document.createElement("option");
        		option1.value = key;
    			option1.text = spVal;
                option1.selected = false;
                if(selectedPricingProgram == option1.value) {
                    option1.selected = true;
                }
            	pricingProgramSelect.appendChild(option1);	    
            } else if(typeof spVal == "object") {
            	
                for (var prop in spVal) {
                	var opt = document.createElement('option');
                    opt.text = spVal[prop];
                    opt.value = prop;
                    opt.selected = false;
                    if(selectedPricingProgram == opt.value) {
                        opt.selected = true;
                    }
                    pricingProgramSelect.appendChild(opt);
                }
                
            }
        }
        
        dataRow.appendChild(dataRowCellPricingProgram);
        pricingProgramSelectDiv.appendChild(pricingProgramSelect);
        childTable.appendChild(dataRow);
        tableCol.appendChild(childTable);
        var target = document.getElementById(selectedQuoteItem);
    	target.parentNode.insertBefore(tableRow, target.nextSibling );
    },
    populateQuoteItemSubLine : function(component, sublines, fields, sublineFields,selectedQuoteItem) {
    	var tableRow = document.createElement('tr'); 
        tableRow.className += " noBorder collapsible "+selectedQuoteItem;
        tableRow.style.display="none";
        tableRow.id = "QuoteItemSubLine";
        var colspan = fields.length+1;
        var tableCol = document.createElement('td');
        var self = this;
        tableCol.colSpan = colspan.toString();
        tableRow.appendChild(tableCol);
        var childTable = document.createElement('table');
        childTable.className += "sublnes-table slds-table slds-table--cell-buffer slds-table--fixed-layout"; 
        var childTableHeader = document.createElement('thead'); 
        var headerRow = document.createElement('tr');
        headerRow.className += "slds-text-heading--label";
        sublineFields.forEach(function(f) { 
            var hearderRowCell = document.createElement('th');
            hearderRowCell.className += ' slds-cell-wrap ' + f.fieldPath;
            if(f.type.toLowerCase() === 'boolean') {
            	hearderRowCell.className += ' type-'+f.type;	    
            }  
            hearderRowCell.scope="col";
            var cellText = document.createElement('div');
            if(f.type.toLowerCase() === 'string') {
            	cellText.className += " " + f.fieldPath; 
                
            }
            
            //cellText.className += " slds-truncate";
            cellText.innerHTML = f.label;
            cellText.title=f.label;
            //console.log('---------' + cellText.innerHTML);
            hearderRowCell.appendChild(cellText);
            headerRow.appendChild(hearderRowCell);
        });
        childTableHeader.appendChild(headerRow);
        childTable.appendChild(childTableHeader);
        tableCol.appendChild(childTable);
		var childTableBody = document.createElement('tbody');
        if(sublines) {
        	sublines.forEach(function(s) {
                var subLineTableRow = document.createElement('tr');
                subLineTableRow.className += " quoteItemSubline ";
                subLineTableRow.id = s["Id"];
                //subLineTableRow.addEventListener('mouseenter', function(){self.handleQuoteItemSublineInfo(component, subLineTableRow.id);}, false); 
                self.renderTable(sublineFields, s, subLineTableRow, selectedQuoteItem, component, false,"Subline");           
                childTableBody.appendChild(subLineTableRow);
            });    
        }
        
        childTable.appendChild(childTableBody);
        var target = document.getElementById(selectedQuoteItem);
    	target.parentNode.insertBefore(tableRow, target.nextSibling );
    },
    //not used for now...
    renderQuoteItems : function(component) {
        var self=this;
    	var quoteItems = component.get("v.quoteItems");
        
        var sublinesMap = component.get('v.sublineMap');
        var sublineFields = component.get('v.fieldsSub');
        var summaryFields = component.get('v.fieldsSummary');
        //component.set('v.selectedQuoteItem', selectedQuoteItem);
        
        var fields = component.get('v.fields');
        var quoteItemMap = component.get('v.quoteItemMap');
        var pricingMethod = component.get('v.selectedPricingMethod');
        var pricingProgram = component.get('v.selectedPricingProgram');
        
        var fields = component.get("v.fields");
        var listenMSRPChange = component.get("v.listenMSRPChange");
        //console.log('----------- fields =' + fields);
        quoteItems.forEach(function(s) {
            var tableRow = document.createElement('tr');
            tableRow.id = s["Id"];
            tableRow.className += " quoteItem";
            if(s['Pricing_Program__c']) {
            	pricingProgram = s['Pricing_Program__c'] 
            }
            
            tableRow.dataset.pricingprogram=pricingProgram;
            tableRow.dataset.pricingprogram_overridden=s["Pricing_Program_Overridden__c"];
            
            //tableRow.addEventListener('mouseenter', function(){self.handleQuoteItemInfo(component, tableRow.id);}, false);
            var chevronTd = document.createElement('td');
            var chevronSpan = document.createElement('span');
            chevronSpan.className += " chevron right";
            chevronSpan.addEventListener('click', function(event){
                if(event.currentTarget.classList.contains('chevron')) {
                    if(event.currentTarget.classList.contains('bottom')) {
                        event.currentTarget.classList.replace('bottom','right') ;   
                    } else {
                        event.currentTarget.classList.replace('right','bottom') ;
                    }
                }
                self.handleRowClick(component, tableRow.id);
            }, false);
            chevronTd.appendChild(chevronSpan);
            tableRow.appendChild(chevronTd); 
            self.renderTable(fields, s, tableRow, null, component, true, "MainLine"); 
            document.getElementById("quoteItems").appendChild(tableRow);   
            var qiId = s["Id"];
            var sublines = sublinesMap[qiId];
           
            if(sublines) {
            	self.populateQuoteItemSubLine(component, sublines, fields, sublineFields, qiId); 
            }
            self.renderQuoteItemSummarySection(component, s, fields, summaryFields, qiId);
            self.renderQuoteItemPricingProgramSection(component, s, fields, qiId); 
            var nodeList = document.getElementsByClassName("collapsible");
            var collapsibles = component.get('v.collapsibles');
            for(var index=0; index < nodeList.length; index++ ) {
                nodeList[index].style.display=collapsibles[index];
            }            
            
            //console.log('----' + document.querySelector("tr#QuoteItem th.Product_Name__c").offsetWidth);
            
            
            
 /*           
            //if(listenMSRPChange) {
            	var qi = document.querySelectorAll(".sfdcid-"+ qiId );
                for (var i=0; i<qi.length; i++) {
                    if(qi[i].dataset.fieldname =="PricingMethodValue__c") {
                    	//qi[i].addEventListener('change', function(event){ self.onUpdatableValueChange(event, component);}, false);    
                    }              
                }    
            //}
*/            
        });
        
        self.hideSpinner();
        /*
        var qiId = component.get("v.selectedQuoteItem");
        if(qiId){
        	self.handleRowClick(component, qiId);
        }
        */
    },
	populateQuoteItems : function(component) {
		var quoteId = component.get('v.quoteId');
		var pricingProgram = component.get('v.selectedPricingProgram');
        var pricingMethod = component.get('v.selectedPricingMethod');
        console.log('populateQuoteItems.pricingProgram =' + pricingProgram);
        var getAction = component.get('c.getQuoteItemFields');
		var self = this;
        getAction.setParams({
            pricingProgram: pricingProgram,
            pricingMethod: pricingMethod,
            objId: quoteId
        });
		getAction.setCallback(this, 
	        function(response) {
	            var state = response.getState();
	            if (component.isValid() && state === "SUCCESS") {  
	                var data = response.getReturnValue();
	                var retResponse = response.getReturnValue();
                    
                    var retRecords = retResponse.values;
                    var fields = retResponse.fieldSetMembers;
                    component.set('v.fields', fields);
                    component.set('v.fieldsSub', retResponse.fieldSetSubMembers); 
                    component.set('v.fieldsSummary', retResponse.fieldSetSummaryMembers);
                    component.set('v.quoteItems', retRecords);
                    component.set('v.demoPricingProgramOptions', retResponse.demoPricingProgramOptions);
                    component.set('v.listenMSRPChange', retResponse.listenMSRPChange);
                    var sublineMap = {};  
                    var quoteItemMap={};
                    
                    retRecords.forEach(function(s) {
                        quoteItemMap[s["Id"]]=s;
                        if(s["Toro_Quote_Item_Sub_Lines__r"]) {
                            sublineMap[s["Id"]]= s["Toro_Quote_Item_Sub_Lines__r"];  
                        }
                        //var tableRow = document.createElement('tr');
                        //tableRow.id = s["Id"];
                        //tableRow.className += " quoteItem";
                        //tableRow.addEventListener('click', function(){self.handleRowClick(component, tableRow.id);}, false);
                        //self.renderTable(fields, s, tableRow); 
                        //document.getElementById("quoteItems").appendChild(tableRow);
                     });
                    component.set('v.sublineMap', sublineMap);
                    component.set('v.quoteItemMap', quoteItemMap);
                    component.set('v.selectedPricingProgram', retResponse.selectedPricingProgram);
        			component.set('v.selectedPricingMethod', retResponse.selectedPricingMethod);
                    component.set('v.fields', fields);
            		component.set('v.demoPricingProgramOptions', retResponse.demoPricingProgramOptions);
            
            		component.set('v.listenMSRPChange', retResponse.listenMSRPChange);
            		component.set('v.secondaryPrograms', retResponse.secondaryPrograms);
            		component.set('v.secondaryProgramKeys', retResponse.secondaryProgramKeys);
                    self.hideSpinner();
                    var items = document.getElementById("quoteItems");
                    self.cleanInnerNodes(items);
                    self.renderQuoteItems(component);
                    var cmpEvent = component.getEvent("calculationCompleteEvent");
                    cmpEvent.setParams({
                        "quote" : retResponse.quote,
                        "allowSupportPlus" : retResponse.allowSupportPlus,
                        "isSaveOperation" : "true"
                    });
                    cmpEvent.fire();
                    //var qiId = component.get("v.selectedQuoteItem");
                    //if(qiId){
                    //	self.handleRowClick(component, qiId);
                    //}
	            }
	        }
	    );
		$A.enqueueAction(getAction);
	},
    renderView : function(component, response) {
    	console.log("render view" + Date.now());
        var self = this;
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {  
            var data = response.getReturnValue();
            var retResponse = response.getReturnValue();
            var retRecords = retResponse.values;
            var fields = retResponse.fieldSetMembers;
            component.set('v.fields', fields);
            component.set('v.fieldsSub', retResponse.fieldSetSubMembers); 
            component.set('v.fieldsSummary', retResponse.fieldSetSummaryMembers);
            component.set('v.quoteItems', retRecords);
            component.set('v.demoPricingProgramOptions', retResponse.demoPricingProgramOptions);
            component.set('v.selectedPricingProgram', retResponse.selectedPricingProgram);
            component.set('v.listenMSRPChange', retResponse.listenMSRPChange);
            component.set('v.secondaryPrograms', retResponse.secondaryPrograms);
            component.set('v.secondaryProgramKeys', retResponse.secondaryProgramKeys);
            
            component.set('v.selectedPricingMethod', retResponse.selectedPricingMethod);
            var sublineMap = {};  
            var quoteItemMap={};
            retRecords.forEach(function(s) {
                quoteItemMap[s["Id"]]=s;
                if(s["Toro_Quote_Item_Sub_Lines__r"]) {
                    sublineMap[s["Id"]]= s["Toro_Quote_Item_Sub_Lines__r"];  
                }
                //var tableRow = document.createElement('tr');
                //tableRow.id = s["Id"];
                //tableRow.className += " quoteItem";
                //tableRow.addEventListener('click', function(){self.handleRowClick(component, tableRow.id);}, false);
                //self.renderTable(fields, s, tableRow); 
                //document.getElementById("quoteItems").appendChild(tableRow);
            });
            component.set('v.sublineMap', sublineMap);
            component.set('v.quoteItemMap', quoteItemMap);
            self.hideSpinner();
            var items = document.getElementById("quoteItems");
            self.cleanInnerNodes(items);
            self.renderQuoteItems(component);
        }    
    },
    svc_SetPricingProgram : function(component, pricingProgram) {
		var self = this;
        var quoteId = component.get('v.quoteId');
        var getAction = component.get('c.setPricingProgramMethodRemote');
        getAction.setParams({
            pricingProgram: pricingProgram,
            objId: quoteId
        });
        getAction.setCallback(this, 
	        function(response) {
                var retResponse = response.getReturnValue();
                if(retResponse.nextAction == "calculation") {
                	var cmpEvent = component.getEvent("calculateEvent");   
                    cmpEvent.fire();
                } else {
            		self.renderView(component, response); 
                }
	        }
	    );
		$A.enqueueAction(getAction);
        
        //var items = document.getElementById("quoteItems");
        //self.cleanInnerNodes(items);           
        //self.populateQuoteItems(component); 
	},
    svc_SetPricingMethod : function(component, pricingProgram, pricingMethod) {
		var self = this;
        var quoteId = component.get('v.quoteId');
        var getAction = component.get('c.setPricingProgramMethodRemote');
        getAction.setParams({
            pricingProgram: pricingProgram,
            pricingMethod: pricingMethod,
            objId: quoteId
        });
        getAction.setCallback(this, 
	        function(response) {
            	self.renderView(component, response);    
	        }
	    );
		$A.enqueueAction(getAction);
        
        //var items = document.getElementById("quoteItems");
        //self.cleanInnerNodes(items);           
        //self.populateQuoteItems(component); 
	},
    cleanInnerNodes : function(node) {
		while (node.hasChildNodes()) {
        	this.clear(node.firstChild);
      	}    
    },
    clear : function(node) {
    	while (node.hasChildNodes()) {
            this.clear(node.firstChild);
		}
		node.parentNode.removeChild(node);    
    },
    showSpinner : function(node) {
    	document.getElementById("spinner").style.display="block";   
    },
    hideSpinner : function(node) {
    	document.getElementById("spinner").style.display="none";   
    },
    updateQuoteItemView : function(component, response) {
    	console.log("render view" + Date.now());
        var self = this;
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {  
            var data = response.getReturnValue();
            var retResponse = response.getReturnValue();
            var retRecords = retResponse.values;
            var fields = retResponse.fieldSetMembers;
            var subFields = retResponse.fieldSetSubMembers;
            component.set('v.fields', fields);
            component.set('v.fieldsSub', retResponse.fieldSetSubMembers); 
            component.set('v.fieldsSummary', retResponse.fieldSetSummaryMembers);
            component.set('v.quoteItems', retRecords);  
            component.set('v.listenMSRPChange', retResponse.listenMSRPChange);
            var sublineMap = {};  
            var quoteItemMap={};
            retRecords.forEach(function(s) {
                quoteItemMap[s["Id"]]=s;
                if(s["Toro_Quote_Item_Sub_Lines__r"]) {
                    sublineMap[s["Id"]]= s["Toro_Quote_Item_Sub_Lines__r"];  
                }
            });
 
            var currentQuoteItemId = retResponse.currentQuoteItem;
            var currentQuoteItem = quoteItemMap[currentQuoteItemId];
            var sublines = sublineMap[currentQuoteItemId];
            var qiRow = document.getElementById(currentQuoteItemId);
            fields.forEach(function(f, index) { 
                var td = qiRow.cells[index+1];
                var type = f.type.toLowerCase();
                var updatable = f.updatable;
                var val = currentQuoteItem[f.fieldPath];
                if(updatable) {
                    var inputBox = td.getElementsByTagName("input")[0];
                	inputBox.value = val;    
                } else {
                    var firstChild = td.firstChild ;
                    if(type === 'double') {
                        firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
                    } else if(type === 'currency') {
                        firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
                    } else if(type === 'boolean') {
                        firstChild.checked = val;
                    } else if(type === 'percent') {
                       firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + "%"; 
                    } else if(type === 'string') {
                        firstChild.innerHTML = val;
                        firstChild.title=val;
                    }
                } 
            });
            for(var i=0; i < sublines.length; i++){
                var subline = sublines[i];
                var qiRow = document.getElementById(subline.Id);
                for(var j=0; j < subFields.length; j++){ 
                    var f = subFields[j];
                    var td = qiRow.cells[j];
                    var type = f.type.toLowerCase();
                    var updatable = f.updatable;
                    var val = subline[f.fieldPath];
                    if(updatable) {
                        var inputBox = td.getElementsByTagName("input")[0];
                        inputBox.value = val;    
                    } else {
                        var firstChild = td.firstChild ;
                        if(type === 'double') {
                            firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
                        } else if(type === 'currency') {
                            firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2});
                        } else if(type === 'boolean') {
                            firstChild.checked = val;
                        } else if(type === 'percent') {
                            firstChild.innerHTML = parseFloat(val).toLocaleString(undefined, {minimumFractionDigits: 2, maximumFractionDigits: 2}) + "%"; 
                        } else if(type === 'string') {
                            firstChild.innerHTML = val;
                            firstChild.title=val;
                        }
                    } 
				}    
            } 
            
            component.set('v.sublineMap', sublineMap);
            component.set('v.quoteItemMap', quoteItemMap);
            self.hideSpinner();
            /*
            var items = document.getElementById("quoteItems");
            self.cleanInnerNodes(items);
            self.renderQuoteItems(component);
            */
        }    
    },
    handleQIPricingMethodChange : function(component, event,  quoteItem) {
		var newVal = event.currentTarget.value;
        var quoteId = component.get('v.quoteId');
        var pricingMethod = quoteItem["Select_a_Price_Method__c"];
        var pricingProgram = quoteItem["Pricing_Program__c"];
		var getAction = component.get('c.svc_setPricingMethodValue');
        //getAction.setStorable();       
		var self = this;
        
        self.showSpinner();
        getAction.setParams({
            pricingProgram: pricingProgram,
            pricingMethod: pricingMethod,
            qiId: quoteItem.Id,
            value: newVal,
            quoteId: quoteId
        }); 
        
        getAction.setCallback(this, 
	        function(response) {
                
	            self.updateQuoteItemView(component, response); 
	        }
	    );
		$A.enqueueAction(getAction);
        
    },
    updateSaveQuote: function(component, pricingProgram, pricingMethod, setupFeePercent, performancePart, save, returnUrl) {
    	//console.log('updateQuote'); 
    	var self = this;
        var invalid = false;
        if(!pricingProgram) {
        	invalid = true;
            document.querySelector(".pricing-program.validation-error").style.display="block";    
        } else {
            document.querySelector(".pricing-program.validation-error").style.display="none";  
        }
        if(!pricingMethod) {
        	invalid = true;
            document.querySelector(".pricing-method.validation-error").style.display="block";    
        } else {
            document.querySelector(".pricing-method.validation-error").style.display="none";  
        }
        var requiredFieldlist = document.querySelectorAll("input:required");
    	for(var i=0; i < requiredFieldlist.length; i++) {
    		var elm = requiredFieldlist[i];
    		var clsList = elm.classList;
            for(var j=0; j < clsList.length; j++) {
            	var cls = clsList[j];
                if(cls.startsWith("sfdcid-")) {
                    if(!elm.value) { 
                        invalid = true;
                        document.querySelector(".validation-error."+cls).style.display="block"; 
                    } else {
                        document.querySelector(".validation-error."+cls).style.display="none";
                    }
                }
            }
    	}
        if(invalid) {
            self.hideSpinner();
            return false;
        }
        var quoteItemsData = {};
        var qiSublinesData = {};
        component.set('v.performancePart', performancePart);
        component.set('v.selectedPricingProgram', pricingProgram);
        
        var quoteItems = document.querySelectorAll(".quoteItem input[type=text]");
        for (var i=0; i<quoteItems.length; i++) {
            var qId = quoteItems[i].closest('tr').id;
            var qPricingProgram = quoteItems[i].closest('tr').dataset.pricingprogram;
            var qiPricingProgramOverridden = quoteItems[i].closest('tr').dataset.pricingprogram_overridden;
            
            console.log("----qPricingProgram---" + qPricingProgram);
            var fieldname = quoteItems[i].dataset.fieldname;
            var value = quoteItems[i].value;
            var overridden = quoteItems[i].dataset.overridden;
            if(!quoteItemsData[qId]) {
                quoteItemsData[qId]={};
            }
            var qiData = quoteItemsData[qId];
            qiData[fieldname] = value;
            if(qPricingProgram !== undefined) {
            	qiData["Pricing_Program__c"] = qPricingProgram;
            }
            
            if(qiPricingProgramOverridden) {
            	qiData["Pricing_Program_Overridden__c"] = qiPricingProgramOverridden;
            } 
            
            if(fieldname == "Award_Price__c" || fieldname == "Total_Toro_Award__c") {
                qiData["Unit_Award_Overridden__c"] = overridden;	    
            } else if(fieldname == "PricingMethodValue__c") {
                qiData["Off_MSRP_Overridden__c"] = overridden;
            }
            console.log("qiData " + i + " =" + JSON.stringify(quoteItemsData));
            //
        }
        var qiSublines = document.querySelectorAll(".quoteItemSubline  input[type=text]");
        for (var i=0; i<qiSublines.length; i++) {
            console.log(qiSublines[i].closest('tr').id + '---' + qiSublines[i].value);
            console.log("dataset.parentquoteitem =" + qiSublines[i].dataset.parentquoteitem + ' field name=' + qiSublines[i].dataset.fieldname);
            var qId = qiSublines[i].closest('tr').id;
            var fieldname = qiSublines[i].dataset.fieldname;
            var value = qiSublines[i].value;
            var overridden = qiSublines[i].dataset.overridden;
            if(!qiSublinesData[qId]) {
                qiSublinesData[qId]={};
            }
            var qisData = qiSublinesData[qId];
            qisData[fieldname] = value;
            if(fieldname == "Award_Price__c" || fieldname == "Total_Toro_Award__c") {
                qisData["Unit_Award_Overridden__c"] = overridden;	    
            }
        }  
        var quoteItemsDataJSON = JSON.stringify(quoteItemsData);
        var qiSublinesDataJSON = JSON.stringify(qiSublinesData);
        console.log('quoteItemsDataJSON=' + quoteItemsDataJSON);
        console.log(qiSublinesDataJSON);
        var quoteId = component.get('v.quoteId');
        
        console.log('populateQuoteItems.pricingProgram =' + pricingProgram);
        console.log('populateQuoteItems.pricingMethod =' + pricingMethod);
        var getAction = component.get('c.svc_updateQuoteData2');
       
        var nodeList = document.getElementsByClassName("collapsible");
        var collapsibles = [];
        for(var index=0; index < nodeList.length; index++ ) {
            collapsibles[index] = nodeList[index].style.display;
        }
        component.set('v.collapsibles', collapsibles);
        getAction.setParams({
            values: {
                quoteId: quoteId,
                pricingProgram: pricingProgram,
                pricingMethod: pricingMethod,
                setupFeePercent: setupFeePercent, 
                performancePart: performancePart
            },      
            quoteItemsDataJSON: quoteItemsDataJSON,
            qiSublinesDataJSON : qiSublinesDataJSON,
            save: save
        });
        getAction.setCallback(this, 
        	function(response) {
            	var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {                    
                    if(save && returnUrl && returnUrl != "/") {
                        document.location = returnUrl;
                    }
                    
                    var data = response.getReturnValue();
                    var retResponse = response.getReturnValue();
                    var retRecords = retResponse.values;
                    var fields = retResponse.fieldSetMembers;
                    component.set('v.fields', fields);
                    component.set('v.fieldsSub', retResponse.fieldSetSubMembers); 
                    component.set('v.fieldsSummary', retResponse.fieldSetSummaryMembers);
                    component.set('v.quoteItems', retRecords);
                    component.set('v.demoPricingProgramOptions', retResponse.demoPricingProgramOptions);
                    component.set('v.listenMSRPChange', retResponse.listenMSRPChange);
                    component.set('v.secondaryPrograms', retResponse.secondaryPrograms);
                    component.set('v.secondaryProgramKeys', retResponse.secondaryProgramKeys);
                    component.set('v.selectedPricingMethod', retResponse.selectedPricingMethod);
                    var cmpEvent = component.getEvent("calculationCompleteEvent");
                    console.log("------REVVY__NeedsApproval__c =" + retResponse.quote.REVVY__NeedsApproval__c);
                    console.log("------Toro_ApprovalReason__c =" + retResponse.quote.Toro_ApprovalReason__c);
                    cmpEvent.setParams({
                        "quote" : retResponse.quote,
                        "allowSupportPlus" : retResponse.allowSupportPlus,
                        "isSaveOperation" : save
                    });
                    cmpEvent.fire();
                    
                    var sublineMap = {};  
                    var quoteItemMap={};
                    retRecords.forEach(function(s) {
                        quoteItemMap[s["Id"]]=s;
                        if(s["Toro_Quote_Item_Sub_Lines__r"]) {
                            sublineMap[s["Id"]]= s["Toro_Quote_Item_Sub_Lines__r"];  
                        }
                    });
                    component.set('v.sublineMap', sublineMap);
                    component.set('v.quoteItemMap', quoteItemMap);
                    self.hideSpinner();
                    
                    var items = document.getElementById("quoteItems");
                    self.cleanInnerNodes(items);
                    self.renderQuoteItems(component);
                } else {
                	self.hideSpinner();
                	// Parse custom error data & report it
                	let errors = response.getError();
                	let message = 'Unknown error'; // Default error message
                	// Retrieve the error message sent by the server
                	if (errors && Array.isArray(errors) && errors.length > 0) {
                	    message = errors[0].message;
                	}
                	// Display the message
                	console.error(JSON.parse(message).message);
                	console.error(JSON.parse(message).stackTrace);              	    
            	    // Fire error toast
            	    alert(JSON.parse(message).message);
                }
            }
        );
        $A.enqueueAction(getAction);
    },
    adjustSummarySublineColumnWidth : function () {
        var cellWidths = [];
        var headerCells = document.querySelectorAll("table#quote-item-table tr#QuoteItem th");
        for(var i=0; i < headerCells.length; i++) {
            cellWidths[i] = headerCells[i].offsetWidth + 'px';
        }
        var summaryHeaderRows = document.querySelectorAll("tr#QuoteItemSummary");
        for(var j =0; j < summaryHeaderRows.length; j++) {
        	var summaryHeaderCells = summaryHeaderRows[j].querySelectorAll("th");
            for(var i=0; i < summaryHeaderCells.length; i++) {
                //console.log('---------------quote item--onRender set cell width =' + i);
                if(cellWidths[i+1]) {
                    summaryHeaderCells[i].style.width=cellWidths[i+1];    
                    if((i == summaryHeaderCells.length-1) && (summaryHeaderCells.length != cellWidths.length-1) ) {
                        summaryHeaderCells[i].style.width='100%';	    
                    }
                }
            }    
        }
        var sublineHeaderRows = document.querySelectorAll("tr#QuoteItemSubLine");
        for(var j =0; j < sublineHeaderRows.length; j++) {
        	var sublineHeaderCells = sublineHeaderRows[j].querySelectorAll("th");
            for(var i=0; i < sublineHeaderCells.length; i++) {
                //console.log('---------------quote item--onRender set cell width =' + i);
                if(cellWidths[i+1]) {
                    sublineHeaderCells[i].style.width=cellWidths[i+1];    
                    if((i == sublineHeaderCells.length-1) && (sublineHeaderCells.length != cellWidths.length-1) ) {
                        sublineHeaderCells[i].style.width='100%';	    
                    }
                }
            }    
        }
        
        //console.log('---------------quote item--onRender =' + cellWidths);
    }
})