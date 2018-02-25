global with sharing class ToroQISLExtensionCreatedBatch implements Database.Batchable<sObject>, Database.stateful {
	String query;
	List<Id> qiExtensionList { get; set; }
	global ToroQISLExtensionCreatedBatch(List<Id> qiExtensions) {
		qiExtensionList = qiExtensions;
		query = 'select id, external_Id__c from Toro_QuoteItem_SubLine__c where id in :qiExtensionList';
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
    }  
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	
    	List<REVVY__MnQuoteItemSubLine__c> qis = new List<REVVY__MnQuoteItemSubLine__c>();
    	List<Toro_QuoteItem_SubLine__c> quoteItemList = (List<Toro_QuoteItem_SubLine__c>)scope;
    	/*
    	List<Id> qiSublineIds = new List<Id> ();
    	for(Toro_QuoteItem_SubLine__c tqi : quoteItemList) {
    		qiSublineIds.add(tqi.External_Id__c);	
    	}
    	map<Id, Id> qiIdMap = new map<Id,Id>();
    	for(REVVY__MnQuoteItemSubLine__c qisl : [select id, revvy__quoteitem__c from REVVY__MnQuoteItemSubLine__c where id in :qiSublineIds]) {
    		qiIdMap.put(qisl.Id, qisl.revvy__quoteitem__c);	
    	}
    	*/
    	for(Toro_QuoteItem_SubLine__c tqi : quoteItemList) {
    		qis.add(new REVVY__MnQuoteItemSubLine__c(Id =tqi.External_Id__c, Quote_Item_Sub_Line_Extension__c = tqi.Id));
    		//tqi.Toro_Quote_Item__r = new Toro_Quoteitem__c(External_Id__c = qiIdMap.get(tqi.External_Id__c));		
    	}
    	update qis;	
    	//update quoteItemList;
    	
    }  
    global void finish(Database.BatchableContext BC) {
    	 
    }    
}