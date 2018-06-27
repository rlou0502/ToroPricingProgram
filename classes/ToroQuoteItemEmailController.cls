global class ToroQuoteItemEmailController {
    
    global String quoteId {
    	get;
    	set;
    }
    
    global REVVY__MnQuote__c getQuoteData() {
    	REVVY__MnQuote__c quote = new REVVY__MnQuote__c();
		List<REVVY__MnQuote__c> qList = [Select Id, Total_Award__c, Pricing_Program__c
		                                      , Toro_Blended_Percent_of_DN__c, Gross_Profit_Percent__c
		                                      , Toro_Support_Plus_Allowance__c, SP_Total_Extended_DNET__c
		                                	From REVVY__MnQuote__c
		                                  Where Id = :quoteId
		                                ];    	
		if(qlist!=null && qList.size()>0) {
			quote = qlist[0];
		}
    	return quote;
    }
    
    global List<REVVY__MnQuoteItem__c> getRetrieveQuoteItem() {
    	List<REVVY__MnQuoteItem__c> qiList = new List<REVVY__MnQuoteItem__c>();
    	System.debug('>>> ToroQuoteItemEmailController retrieveQuoteItem quoteId =' + quoteId);
    	
		String query = ' Select REVVY__Product_ID_F__c, REVVY__Catalog_Node__c, REVVY__Catalog_Node__r.Name, REVVY__Quantity__c, Quote_Item_Extension__c, Quote_Item_Extension__r.Extended_Award_Price__c '
		             + ' From REVVY__MnQuoteItem__c where REVVY__Quote__c = :quoteId';
    	System.debug('>>> ToroQuoteItemEmailController retrieveQuoteItem query =' + query);
		qiList = (List<REVVY__MnQuoteItem__c>)	Database.query(query);
    	System.debug('>>> ToroQuoteItemEmailController retrieveQuoteItem qiList =' + qiList);
    	
    	/*
    	String sfield ='';
    	Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.REVVY__MnQuoteItem__c.fieldSets.getMap();
    	if(fieldSetMap!=null && fieldSetMap.containsKey('EmailTemplate')) {
    		Schema.FieldSet fs = fieldSetMap.get('EmailTemplate');
    		List<Schema.FieldSetMember> fsMemberList = fs.getFields();
			for(Schema.FieldSetMember f : fsMemberList) {
            	sfield += ',' + f.getFieldPath();
			}
			sfield = sfield.replaceFirst(',','');    		
    		String query = 'Select ' + sfield + ' From REVVY__MnQuoteItem__c where REVVY__Quote__c = :quoteId';
    		qiList = (List<REVVY__MnQuoteItem__c>)	Database.query(query);
    	}
    	*/
    	return qiList;
    }
}