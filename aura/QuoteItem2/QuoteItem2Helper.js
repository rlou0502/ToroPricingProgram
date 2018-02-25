({
	populateQuoteItem : function(component) {
		var fields = component.get('v.fields');
		var quoteItem = component.get('v.quoteItem');
		fields.forEach(function(field){
			debugger;
            var tableData = document.createElement('td');
            var tableDataNode = document.createTextNode(quoteItem[field.fieldPath]);
            tableData.appendChild(tableDataNode);
            var qiSel = "quoteItem"+quoteItem.Id;
            var tmp = document.getElementById(qiSel);
            document.getElementById(qiSel).appendChild(tableData);
        });
	}    
})