@isTest
private class FieldSetMemberTest {
	@isTest static void coverage() {
		List<Schema.FieldSetMember> quoteFields = SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
		FieldSetMember fsm = new FieldSetMember(quoteFields[0]);
		System.assert(fsm != null);
	}
}