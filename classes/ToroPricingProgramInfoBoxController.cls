public class ToroPricingProgramInfoBoxController {
	@AuraEnabled
    public static ToroSObjectResultSet refreshInfoBoxSvc( ID objId) {
    	system.debug('refreshInfoBox');
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	system.debug('refreshInfoBox');
    	rs.result=true;
    	system.debug('ToroPricingProgramInfoBoxController obj type = ' + objId.getSObjectType());
    	List<Schema.FieldSetMember> fs= objId.getSObjectType().getDescribe().FieldSets.getMap().get('Price_Program_Traction_Unit_Info').getFields();
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

	@AuraEnabled
	public static void resetQuoteApproval(Id quoteId) {
		Revvy__MnQuote__c quote = [SELECT
										Toro_ApprovalReason__c
										, REVVY__NeedsApproval__c
									FROM
										Revvy__MnQuote__c
									WHERE
										Id = :quoteId LIMIT 1];

		quote.Toro_ApprovalReason__c = '';
		quote.REVVY__NeedsApproval__c = false;
		update quote;
	}
}