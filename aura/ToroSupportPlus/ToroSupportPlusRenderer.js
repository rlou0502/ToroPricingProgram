({
	rerender: function (cmp, helper) {
		console.log('@ToroSupportPlusRenderer:rerender');
		this.superRerender();
		var autocomplete = document.getElementById("add_product_input");
		var autocomplete_result = document.getElementById("autocomplete_result");
        var autocomplete_section = document.getElementById('autocomplete_section');
		var lastSearchTerm = cmp.get('v.lastSearchTerm');
		if (lastSearchTerm && autocomplete) {
			console.log("lastSearchTerm = " + lastSearchTerm);
			var db = cmp.get("v.searchResult");
			var a = new RegExp(autocomplete.value, "i");
			for (var x = 0, b = document.createDocumentFragment(), c = false; x < db.length; x++) {
                if (a.test(db[x].REVVY__Product__r.REVVY__Id__c) || a.test(db[x].REVVY__Product__r.Name)) {
					c = true;

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

                    var searchResultIconInner = document.createElement('span');
                    searchResultIconInner.className = 'slds-icon_container slds-icon-standard-account';

                    var searchResultIcon = document.createElement('span');
                    searchResultIcon.className = 'slds-media__figure';
					searchResultIcon.appendChild(searchResultIconInner);

                    var searchResultText = document.createElement('span');
                    searchResultText.className = 'slds-listbox__option-text slds-listbox__option-text_entity';
                    searchResultText.innerText = db[x].REVVY__Product__r.Name;

                    var searchResultMeta = document.createElement('span');
                    searchResultMeta.className = 'slds-listbox__option-meta slds-listbox__option-meta_entity';
                    searchResultMeta.innerText = db[x].REVVY__Product__r.REVVY__Id__c;

                    var searchResultBody = document.createElement('span');
                    searchResultBody.className = 'slds-media__body';

                    searchResultBody.appendChild(searchResultText);
                    searchResultBody.appendChild(searchResultMeta);

                    var searchResultDiv = document.createElement('div');
                    searchResultDiv.className = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta';
                    searchResultDiv.setAttribute('role', 'option');

                    searchResultDiv.appendChild(searchResultIcon);
                    searchResultDiv.appendChild(searchResultBody);

                    var searchResult = document.createElement('li');
                    searchResult.className = 'slds-listbox__item';
                    searchResult.setAttribute('role', 'presentation');
                    searchResult.appendChild(searchResultDiv);
                    searchResult.setAttribute("onclick", "add_product_input.value=this.innerText;autocomplete_section.style.display='none';");

                    b.appendChild(searchResult);


					/*
					var d = document.createElement("p");
					d.innerText = db[x].REVVY__Product__r.REVVY__Id__c;
					d.setAttribute("onclick", "autocomplete.value=this.innerText;autocomplete_result.innerHTML='';autocomplete_result.style.display='none';");
					b.appendChild(d);
                    */
				}
			}
			if (c == true) {
				autocomplete_result.innerHTML = "";
				autocomplete_result.style.display = "block";
				autocomplete_result.appendChild(b);
				var clientHeight = autocomplete_result.clientHeight;
				autocomplete_result.style.bottom = (clientHeight + 28).toString() + "px";
                autocomplete_section.style.display = "block";
			} else {
                console.log('hide autocomplete section');
				autocomplete_result.innerHTML = "";
				autocomplete_result.style.display = "none";
                autocomplete_section.style.display = "none";
			}
		}
	}


})