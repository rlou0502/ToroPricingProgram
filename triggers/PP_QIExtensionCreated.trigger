trigger PP_QIExtensionCreated on Toro_QuoteItem__c (after insert) {
    List<Toro_QuoteItem__c> tQIs = (List<Toro_QuoteItem__c>) trigger.new;   
    List<Id> tqiIds = new List<Id>();
    for(Toro_QuoteItem__c tqi : tQIs) {
        tqiIds.add(tqi.Id);     
    }
    ToroQIExtensionCreatedBatch b = new ToroQIExtensionCreatedBatch(tqiIds);   
    Database.executeBatch(b);
}