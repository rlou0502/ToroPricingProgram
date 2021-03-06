global with sharing class ToroQIExtensionCreatedBatch implements Database.Batchable<sObject>, Database.stateful {
	String query;
	List<Id> qiExtensionList {get; set; }
	global ToroQIExtensionCreatedBatch(List<Id> qiExtensions) {
		this.qiExtensionList = qiExtensions;
		query = 'select id, external_Id__c from Revvy__MnStrategy4__c where id in :qiExtensionList';
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
    }  
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	List<REVVY__MnQuoteItem__c> qis = new List<REVVY__MnQuoteItem__c>();
    	List<Revvy__MnStrategy4__c> quoteItemList = (List<Revvy__MnStrategy4__c>)scope;
    	for(Revvy__MnStrategy4__c tqi : quoteItemList) {
    		 qis.add(new REVVY__MnQuoteItem__c(Id =tqi.External_Id__c, Quote_Item_Extension__c = tqi.Id));		
    	}
    	update qis;	
    }  
    global void finish(Database.BatchableContext BC) {
    	 
    }
}