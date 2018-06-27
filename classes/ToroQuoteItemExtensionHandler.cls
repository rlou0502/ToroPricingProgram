public with sharing class ToroQuoteItemExtensionHandler {
	public static void hanleQuoteItemExtensionCreated(List<Id> quoteItemExtensions) {
		if(!System.isBatch() && !System.isFuture()) {
			if(quoteItemExtensions.size() > 0) {
				ToroQIExtensionCreatedBatch b = new ToroQIExtensionCreatedBatch(quoteItemExtensions);
				Database.executeBatch(b);
			}	
		}	
	}  
	public static void hanleQuoteItemSublineExtensionCreated(List<Id> quoteItemSublineExtensions) {
		if(!System.isBatch() && !System.isFuture()) {
			if(quoteItemSublineExtensions.size() > 0) {
				ToroQISLExtensionCreatedBatch b = new ToroQISLExtensionCreatedBatch(quoteItemSublineExtensions);
				Database.executeBatch(b);
			}	
		}
	}    
}