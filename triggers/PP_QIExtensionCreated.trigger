trigger PP_QIExtensionCreated on REVVY__MnStrategy4__c (after insert) {
	List<REVVY__MnStrategy4__c> tQIs = (List<REVVY__MnStrategy4__c>) trigger.new;   
    List<Id> tqiIds = new List<Id>();
    for(REVVY__MnStrategy4__c tqi : tQIs) {
        tqiIds.add(tqi.Id);     
    }
    if(!System.isBatch() && !System.isFuture()) {
        ToroQIExtensionCreatedBatch b = new ToroQIExtensionCreatedBatch(tqiIds);   
        Database.executeBatch(b);
    }
}