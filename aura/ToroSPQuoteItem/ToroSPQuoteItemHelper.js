({
    getQuoteItem: function(sfid, quoteItems) {
        for (var i = 0; i < quoteItems.length; i++) {
            if (quoteItems[i].sfid == sfid) {
                return quoteItems[i];
            }

            for ( var j = 0; j < quoteItems[i].sublines.length; j++) {
                if (quoteItems[i].sublines[j].sfid == sfid) {
                    return quoteItems[i].sublines[j];
                }
            }
        }
        return null;
    }
})