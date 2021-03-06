public class ToroPricingProgramInfoBoxController {
    public static List<FieldSetMember> convertFieldSet(List<Schema.FieldSetMember> fs) {
    	List<FieldSetMember> fset = new List<FieldSetMember>();
    	for (Schema.FieldSetMember f: fs) {
        	FieldSetMember nfsm = new FieldSetMember(f);
            fset.add(nfsm);
        }	
        return fset;
    }
    @AuraEnabled
    public static ToroInfoBoxResultSet getInfoBoxFieldSets() {
    	ToroInfoBoxResultSet rs = new ToroInfoBoxResultSet();
    	system.debug('refreshInfoBox');
    	rs.result=true; 
    	rs.quoteItemTractionUnitFieldSet = convertFieldSet(removeDNetFieldsFromSet(SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Traction_Unit_Info.getFields(),
    					SObjectType.Revvy__MnStrategy4__c.FieldSets.DNet_Field_Set.getFields()));
    	rs.quoteItemMainFieldSet = convertFieldSet(removeDNetFieldsFromSet(SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Line_Info_Cols.getFields(),
    												SObjectType.Revvy__MnStrategy4__c.FieldSets.DNet_Field_Set.getFields()));
    	rs.quoteSublineFieldSet = convertFieldSet(removeDNetFieldsFromSet(SObjectType.Revvy__MnStrategy5__c.FieldSets.Price_Program_Subline_Info_Cols.getFields(),
    												SObjectType.Revvy__MnStrategy5__c.FieldSets.DNet_Field_Set.getFields()));
    	rs.quoteFieldSet = convertFieldSet(removeDNetFieldsFromSet(SObjectType.Revvy__MnQuote__c.FieldSets.Price_Program_Quote_Info.getFields(),
    												SObjectType.Revvy__MnQuote__c.FieldSets.DNet_Field_Set.getFields()));
    	return rs;
    }
    public static List<Schema.FieldSetMember> removeDNetFieldsFromSet(List<Schema.FieldSetMember> sourceFS, List<Schema.FieldSetMember> removeFS)  {
		
		if(!Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			Set<String> dnetMap = new Set<String>();
			for(Schema.FieldSetMember fs : removeFS) {
				dnetMap.add(fs.fieldPath);
			}
			system.debug('removeDNetFieldsFromSet--' + dnetMap);
			for(integer i = sourceFS.size()-1; i >= 0; i--) {
				Schema.FieldSetMember fs2 = sourceFS[i];
	
				if(dnetMap.contains(fs2.fieldPath)) {
					system.debug('removeDNetFieldsFromSet--fs2=' + fs2);
					Schema.FieldSetMember fs = sourceFS.remove(i);
					system.debug('removeDNetFieldsFromSet--removed =' + fs);
				}
			}
		}
		
		return sourceFS;
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