public class ToroPricingProgramInfoBoxController {
	@AuraEnabled
    public static ToroSObjectResultSet refreshInfoBoxSvc( ID objId) {
    	system.debug('refreshInfoBox');
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	system.debug('refreshInfoBox');	
    	rs.result=true;
    	List<Schema.FieldSetMember> fs= objId.getSObjectType().getDescribe().FieldSets.getMap().get('Price_Program_Line_Info_Cols').getFields();
    	String objName = objId.getSObjectType().getDescribe().getName();
    	List<String> fieldNames = new List<String>();
    	List<FieldSetMember> fset = new List<FieldSetMember>();
		system.debug('refreshInfoBox');
        for (Schema.FieldSetMember f: fs) {
        	fieldNames.add(f.getFieldPath());
        	FieldSetMember nfsm = new FieldSetMember(f);
            fset.add(nfsm);
        }	
        system.debug('refreshInfoBox');
        String query = 'Select ' + String.join(fieldNames, ',') + ' from ' + objName + ' where id=\'' + objId + '\'';
        system.debug('refreshInfoBox=' + query);
		sObject[] dataObjs = database.query(query);
		rs.fieldSetMembers = fset;
		rs.values = dataObjs;
    	return rs;	
    }
    @AuraEnabled
    public static Revvy__MnQuote__c loadQuoteHeader(Id quoteId) {
    	return ToroCacheManager.getQuote(quoteId);
    }
}