trigger PP_UpdateQISLExtension on REVVY__MnQuoteItemSubLine__c (after update) {
	List<REVVY__MnQuoteItemSubLine__c> qis = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new;   
	List<Toro_QuoteItem_SubLine__c> tQIs = new List<Toro_QuoteItem_SubLine__c>();
	for(REVVY__MnQuoteItemSubLine__c qi : qis) {
		tQIs.add(new Toro_QuoteItem_SubLine__c(External_Id__c = qi.Id, TPP_DNET__c = qi.TPP_DNET__c, 
		Toro_Quantity__c = qi.REVVY__Quantity__c,
		TPP_Line_Item__c=qi.TPP_Line_Item__c, Exclude_from_Rebate__c=qi.Exclude_from_Rebate__c));		
	}
	upsert tQIs External_Id__c;   
}