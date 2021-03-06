({
	refreshSearchResults: function (cmp, previousSearchTerm, currentSearchTerm, searchType, spSearchType) {
		var action = cmp.get('c.fetchSearchResults');
		action.setStorable();
		action.setParams({
			searchTerm: currentSearchTerm
			, searchType: searchType
			, spSearchType: spSearchType
		});
		action.setCallback(this
			, function (response) {
				var state = response.getState();
				if (cmp.isValid() && state === "SUCCESS") {
					cmp.set('v.searchResults', response.getReturnValue());
					cmp.set('v.previousSearchTerm', previousSearchTerm);
					cmp.set('v.currentSearchTerm', currentSearchTerm);
				}
			}
		);

		$A.enqueueAction(action);
	},
})