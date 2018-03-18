global with sharing class ToroQISLExtensionCreatedBatch implements Database.Batchable<sObject>, Database.stateful {
	String query;
	List<Id> qiExtensionList { get; set; }
	global ToroQISLExtensionCreatedBatch(List<Id> qiExtensions) {
		qiExtensionList = qiExtensions;
		query = 'select id, external_Id__c from Revvy__MnStrategy5__c where id in :qiExtensionList';
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
    }  
    global void execute(Database.BatchableContext BC, List<sObject> scope) { 
    	
    	List<REVVY__MnQuoteItemSubLine__c> qis = new List<REVVY__MnQuoteItemSubLine__c>();
    	List<REVVY__MnStrategy5__c> quoteItemList = (List<REVVY__MnStrategy5__c>)scope;
    	
    	for(REVVY__MnStrategy5__c tqi : quoteItemList) {
    		qis.add(new REVVY__MnQuoteItemSubLine__c(Id =tqi.External_Id__c, Quote_Item_Sub_Line_Extension__c = tqi.Id));
    		//tqi.Toro_Quote_Item__r = new Revvy__MnStrategy4__c(External_Id__c = qiIdMap.get(tqi.External_Id__c));		
    	}
    	update qis;	
    	//update quoteItemList;
    	
    }  
    global void finish(Database.BatchableContext BC) {
    	 
    }    
}