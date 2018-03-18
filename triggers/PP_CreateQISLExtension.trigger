trigger PP_CreateQISLExtension on REVVY__MnQuoteItemSubLine__c (after insert) {
	List<REVVY__MnQuoteItemSubLine__c> qis = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new;   
	List<REVVY__MnStrategy5__c>  tQIs = new List<REVVY__MnStrategy5__c>();
	for(REVVY__MnQuoteItemSubLine__c qi : qis) {
		
		tQIs.add(new REVVY__MnStrategy5__c(External_Id__c = qi.Id, Product__c = qi.REVVY__Catalog_Node__c, 
			TPP_DNET__c = qi.TPP_DNET__c, TPP_Line_Item__c=qi.TPP_Line_Item__c, Exclude_from_Rebate__c=qi.Exclude_from_Rebate__c,
			Product_ID2__c=qi.Product_ID2__c, Toro_Quantity__c = qi.REVVY__Quantity__c,
			Quote_Item_Sub_Line__c=qi.Id, MSRP_Price__c=qi.REVVY__Price__c, DNet_Price__c = qi.REVVY__SuggestedPrice__c,
			Toro_Quote_Item__r = new REVVY__MnStrategy4__c(External_Id__c =qi.Revvy__QuoteItem__c)));				
	}
	insert tQIs;    
}