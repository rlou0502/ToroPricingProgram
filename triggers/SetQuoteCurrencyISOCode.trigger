trigger SetQuoteCurrencyISOCode on REVVY__MnQuote__c (before insert, before update) {
	if(SetQuoteCurrencyISOCodeRunOnce.runSetQuoteCurrencyOnce()) {
	    List<REVVY__MnQuote__c> quotes = (List<REVVY__MnQuote__c>) trigger.new;
	    for(REVVY__MnQuote__c q : quotes) {
	        if(String.isNotBlank(q.Currency2__c))   {           
	            String[] parts = q.Currency2__c.split('_');             
	            String newCurrencyCode = parts[0];
	            if(parts.size() == 2) {
	                newCurrencyCode = parts[1]; 
	            } 
	            q.CurrencyISOCode = newCurrencyCode;    
	            q.revvy__currency__c = newCurrencyCode;
	        }
	    }
	}
}