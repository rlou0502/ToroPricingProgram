trigger PP_QISLExtensionCreated on Toro_QuoteItem_SubLine__c (after insert) {
    List<Toro_QuoteItem_SubLine__c> tQIs = (List<Toro_QuoteItem_SubLine__c>) trigger.new;      
    List<Id> tqiIds = new List<Id>();
    for(Toro_QuoteItem_SubLine__c tqi : tQIs) {
        tqiIds.add(tqi.Id);     
    }
    ToroQISLExtensionCreatedBatch b = new ToroQISLExtensionCreatedBatch(tqiIds);   
    Database.executeBatch(b);
}