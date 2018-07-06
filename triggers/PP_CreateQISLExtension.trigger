trigger PP_CreateQISLExtension on REVVY__MnQuoteItemSubLine__c (after insert) {
    List<REVVY__MnQuoteItemSubLine__c> qis = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new;
    List<Id> Ids = new List<Id>();
    for(REVVY__MnQuoteItemSubLine__c qi : qis) {
        Ids.add(qi.Id);
    }
    List<Revvy__MnStrategy5__c>  tQIs = new List<Revvy__MnStrategy5__c>();
    Map<Id, REVVY__MnQuoteItemSubLine__c> QisMap = new Map<Id, REVVY__MnQuoteItemSubLine__c>([Select Id, REVVY__Quantity__c, REVVY__QuoteItem__r.REVVY__Quantity__c from REVVY__MnQuoteItemSubLine__c where Id in :Ids]);
    for(REVVY__MnQuoteItemSubLine__c qi : qis) {
    	REVVY__MnQuoteItemSubLine__c qisExt = QisMap.get(qi.Id);
    	Decimal extQty = qisExt.REVVY__Quantity__c * qisExt.REVVY__QuoteItem__r.REVVY__Quantity__c;

        Boolean isSupportPlus = qi.Support_Plus_Original_Item__c != null;

    	tQIs.add(new Revvy__MnStrategy5__c(
            External_Id__c         = qi.Id,
            Product__c             = qi.REVVY__Catalog_Node__c,
            TPP_DNET__c            = qi.TPP_DNET__c,
            TPP_Line_Item__c       = qi.TPP_Line_Item__c,
            //Exclude_from_Rebate__c = qi.Exclude_from_Rebate__c,
            Product_ID2__c         = qi.Product_ID2__c,
            Toro_Extended_Qty__c   = extQty,
            Adjusted_Quantity__c   = isSupportPlus ? qisExt.REVVY__Quantity__c : extQty,
            Quote_Item_Sub_Line__c = qi.Id,
            MSRP_Price__c          = qi.REVVY__Price__c,
            DNet_Price__c          = qi.REVVY__SuggestedPrice__c,
            Apply_Support_Plus__c  = isSupportPlus,
            Support_Plus_Original_Price__c = qi.Support_Plus_Original_Price__c,

            Toro_Quote_Item_2__r = new Revvy__MnStrategy4__c(
                External_Id__c = qi.Revvy__QuoteItem__c)
        ));
    }
    insert tQIs;
    //update qis;
}