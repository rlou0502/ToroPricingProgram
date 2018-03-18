trigger PP_QISublineExtAfterCreate on REVVY__MnStrategy5__c (after insert) {
	List<REVVY__MnStrategy5__c> tQIs = (List<REVVY__MnStrategy5__c>) trigger.new;      
    List<Id> tqiIds = new List<Id>();
    for(REVVY__MnStrategy5__c tqi : tQIs) {
        tqiIds.add(tqi.Id);     
    }
    ToroQISLExtensionCreatedBatch b = new ToroQISLExtensionCreatedBatch(tqiIds);   
    Database.executeBatch(b);    
}