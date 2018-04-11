({
	rerender: function (cmp, helper) {
		console.log('@ToroSupportPlusRenderer:rerender');
		this.superRerender();

		var autocomplete = document.getElementById("add_product_input");
		// var autocomplete_result = document.getElementById("autocomplete_result");
		// var autocomplete_section = document.getElementById('autocomplete_section');

		/*
		var db = cmp.get('v.searchResult');
		if (db == null) {
			console.log('hide autocomplete');
			autocomplete_result.innerHTML = "";
			autocomplete_section.style.display = "none";
			return;
		}
		*/

		var lastSearchTerm = cmp.get('v.lastSearchTerm');
		if (lastSearchTerm != autocomplete) {
			// var db = cmp.get("v.searchResult");
			var a = new RegExp(autocomplete.value, "i");
			for (var x = 0, b = document.createDocumentFragment(), c = false; x < db.length; x++) {
                if (a.test(db[x].REVVY__Product__r.REVVY__Id__c) || a.test(db[x].REVVY__Product__r.Name)) {
					c = true;

					var productName = db[x].REVVY__Product__r.Name;
					var productId = db[x].REVVY__Product__r.REVVY__Id__c;

                    /* example generated node */
                    /*
						<li role="presentation" class="slds-listbox__item">
						    <div id="listbox-option-id-2" class="slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta"
					        role="option" tabindex="0">
						        <span class="slds-media__figure">
					            	<span class="slds-icon_container slds-icon-standard-account" title="Description of icon when needed">
					                	<lightning:icon iconName="utility:account" size="x-small" />
					                	<span class="slds-assistive-text">Description of icon when needed</span>
					            	</span>
					        </span>
					        <span class="slds-media__body">
					            <span class="slds-listbox__option-text slds-listbox__option-text_entity">Acme</span>
					            <span class="slds-listbox__option-meta slds-listbox__option-meta_entity">Account • San Francisco</span>
					        </span>
					    </div>
					</li>
                    */

					/*
                    var searchResultText = document.createElement('span');
                    searchResultText.className = 'slds-listbox__option-text slds-listbox__option-text_entity';
                    searchResultText.innerText = productName;

                    var searchResultMeta = document.createElement('span');
                    searchResultMeta.className = 'slds-listbox__option-meta slds-listbox__option-meta_entity';
                    searchResultMeta.innerText = productId;

                    var searchResultBody = document.createElement('span');
                    searchResultBody.className = 'slds-media__body';

                    searchResultBody.appendChild(searchResultText);
                    searchResultBody.appendChild(searchResultMeta);

                    var searchResultDiv = document.createElement('div');
                    searchResultDiv.className = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
                    // searchResultDiv.setAttribute('role', 'option');

                    searchResultDiv.appendChild(searchResultBody);

                    var searchResult = document.createElement('li');
                    searchResult.className = 'slds-listbox__item';
                    // searchResult.setAttribute('role', 'presentation');
					searchResult.appendChild(searchResultDiv);

                    searchResult.setAttribute("onclick", "add_product_input.value=this.innerText;autocomplete_section.style.display='none';");

                    b.appendChild(searchResult);
					*/

					/*
					var d = document.createElement("p");
					d.innerText = db[x].REVVY__Product__r.REVVY__Id__c;
					d.setAttribute("onclick", "autocomplete.value=this.innerText;autocomplete_result.innerHTML='';autocomplete_result.style.display='none';");
					b.appendChild(d);
                    */

					var cmpProductNameSpan = [
						'aura:HTML',
						{
							tag: 'span',
							HTMLAttributes: {
								class: 'slds-listbox__option-text slds-listbox__option-text_entity',
								innerText: productName
							}
						}
					];

					var cmpProductIdSpan = [
						'aura:HTML',
						{
							tag: 'span',
							HTMLAttributes: {
								class: 'slds-listbox__option-meta slds-listbox__option-meta_entity',
								innerText: productId
							}
						}
					];

					var cmpMainSpan = [
						'aura:HTML',
						{
							tag: 'span',
							HTMLAttributes: {
								class: 'slds-media__body'
							}
						}
					];

					var cmpDiv = [
						'aura:HTML',
						{
							tag: 'div',
							HTMLAttributes: {
								class: 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta'
							}
						}
					];

					var cmpLi = [
						'aura:HTML',
						{
							tag: 'li',
							HTMLAttributes: {
								class: 'slds-listbox__item'
							}
						}
					];

					$A.createComponents(
						[
							cmpProductNameSpan,
							cmpProductIdSpan,
							cmpMainSpan,
							cmpDiv,
							cmpLi
						],
						function(components, status, errorMessage) {
							var cmpProductNameSpan = components[0];
							var cmpProductIdSpan   = components[1];
							var cmpMainSpan        = components[2];
							var cmpDiv             = components[3];
							var cmpLi              = components[4];

							var mainSpanBody = cmpMainSpan.get('v.body');
							mainSpanBody.push(cmpProductNameSpan);
							mainSpanBody.push(cmpProductIdSpan);
							cmpMainSpan.set('v.body', mainSpanBody);

							var divBody = cmpDiv.get('v.body');
							divBody.push(cmpMainSpan);
							cmpDiv.set('v.body', divBody);

							var liBody = cmpLi.get('v.body');
							liBody.push(cmpDiv);
							cmpLi.set('v.body', liBody);

							var targetCmp = cmp.find('autocomplete_result_list');
							if (targetCmp.isValid()) {
								console.log('targetCmp is valid');
								var targetBody = targetCmp.get('v.body');
								targetBody.push(cmpLi);
								// targetCmp.set('v.body', targetBody);
							}
						}
					);
				}
			} // end for

			/*
			if (c == true) {
				autocomplete_result.innerHTML = "";
				autocomplete_result.style.display = "block";
				// autocomplete_result.appendChild(b);
				var clientHeight = autocomplete_result.clientHeight;
				autocomplete_result.style.bottom = (clientHeight + 28).toString() + "px";
                autocomplete_section.style.display = "block";
			}*/
		}
	}
})