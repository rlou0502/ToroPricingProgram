({
	rerender: function (cmp, helper) {
		this.superRerender();

		if (cmp.get('v.searchType') == 'supportplus') {
			var previousSearchTerm = cmp.get('v.previousSearchTerm');
			var currentSearchTerm = cmp.get('v.currentSearchTerm');
			var searchResults = cmp.get('v.searchResults');
			var wasAutoCompleted = cmp.get('v.wasAutoCompleted');

			var showAutoComplete = false;
			if (previousSearchTerm != currentSearchTerm && searchResults && currentSearchTerm.length >= 3 && !wasAutoCompleted) {
				// create new results
				var regEx = new RegExp(currentSearchTerm, "i");
				for (var x = 0; x < searchResults.length; x++) {

					var productName = searchResults[x].REVVY__Product__r.Name;
					var productId   = searchResults[x].REVVY__Product__r.REVVY__Id__c;
					var dnetPrice   = searchResults[x].REVVY__SuggestedPrice__c;
					var msrpPrice   = searchResults[x].REVVY__SuggestedPrice__c;
					var awardPrice  = searchResults[x].REVVY__SuggestedPrice__c;
					var description = searchResults[x].REVVY__Product__r.Name; //searchResults[x].REVVY__Product__r.REVVY__Description__c ? searchResults[x].REVVY__Product__r.REVVY__Description__c : productName;

					if (regEx.test(productId)) {
						if (!showAutoComplete) {
							var targetCmp = cmp.find('autocomplete_results');
							targetCmp.set('v.body', '');
							showAutoComplete = true;
						}

						var cmpProductNameText = [
							'ui:outputText',
							{
								value: productName
							}
						];

						var cmpProductIdText = [
							'ui:outputText',
							{
								value: productId
							}
						];

						var cmpProductNameSpan = [
							'aura:HTML',
							{
								tag: 'span',
								HTMLAttributes: {
									class: 'slds-listbox__option-text slds-listbox__option-text_entity'
								}
							}
						];

						var cmpProductIdSpan = [
							'aura:HTML',
							{
								tag: 'span',
								HTMLAttributes: {
									class: 'slds-listbox__option-meta slds-listbox__option-meta_entity'
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
									class             : 'slds-listbox__item',
									'data-productid'  : productId,
									'data-productname': productName,
									'data-dnetprice'  : dnetPrice,
									'data-msrpprice'  : msrpPrice,
									'data-awardprice' : awardPrice,
									'data-description': description,
									onclick           : cmp.getReference('c.populateAddNewModalFields')
								}
							}
						];

						$A.createComponents(
							[
								cmpProductNameText,
								cmpProductIdText,
								cmpProductNameSpan,
								cmpProductIdSpan,
								cmpMainSpan,
								cmpDiv,
								cmpLi
							],
							function (components, status, errorMessage) {
								var cmpProductNameText = components[0];
								var cmpProductIdText = components[1];
								var cmpProductNameSpan = components[2];
								var cmpProductIdSpan = components[3];
								var cmpMainSpan = components[4];
								var cmpDiv = components[5];
								var cmpLi = components[6];

								var productNameSpanBody = cmpProductNameSpan.get('v.body');
								productNameSpanBody.push(cmpProductNameText);
								cmpProductNameSpan.set('v.body', productNameSpanBody);

								var productIdSpanBody = cmpProductIdSpan.get('v.body');
								productIdSpanBody.push(cmpProductIdText);
								cmpProductIdSpan.set('v.body', productIdSpanBody);

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
								// cmpLi.set('v.onclick', );

								var targetCmp = cmp.find('autocomplete_results');
								if (targetCmp.isValid()) {
									// clear existing results
									var targetBody = targetCmp.get('v.body');
									targetBody.push(cmpLi);
									targetCmp.set('v.body', targetBody);
								}
							}
						);
					}
				}
			}

			if (showAutoComplete) {
				var autocompleteSectionCmp = cmp.find('autocomplete_section');
				$A.util.removeClass(autocompleteSectionCmp, 'slds-hide');
			}

			else {
				var autocompleteSectionCmp = cmp.find('autocomplete_section');
				$A.util.addClass(autocompleteSectionCmp, 'slds-hide');
			}
		}
	}

	/* example generated node
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
})