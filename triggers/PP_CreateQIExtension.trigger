trigger PP_CreateQIExtension on REVVY__MnQuoteItem__c (after insert) {
    List<REVVY__MnQuoteItem__c> qis = (List<REVVY__MnQuoteItem__c>) trigger.new;
    List<Revvy__MnStrategy4__c>  tQIs = new List<Revvy__MnStrategy4__c>();
    for(REVVY__MnQuoteItem__c qi : qis) {
        // Decimal dawardPrice = null;
        Decimal dawardPrice = qi.Award_Price__c;

        if('S00001'.equalsIgnoreCase(qi.REVVY__Product_ID_F__c)) {
            dawardPrice = qi.Revvy__Price__c;
        }

        tQIs.add(new Revvy__MnStrategy4__c(
            External_Id__c       = qi.Id,
            Product__c           = qi.REVVY__Catalog_Node__c,
            QuoteItem__c         = qi.Id,
            MSRP_Price__c        = qi.REVVY__Price__c,
            DNet_Price__c        = qi.REVVY__SuggestedPrice__c,
            Mn_Quote__c          = qi.Revvy__Quote__c,
            Adjusted_Quantity__c = qi.REVVY__Quantity__c,
            Award_Price__c       = dawardPrice,
            Support_Plus_Item__c = (qi.Support_Plus_Original_Item__c != null || qi.Support_Plus_From_Add_New__c),
            Support_Plus_Original_Price__c = qi.Support_Plus_Original_Price__c,
            Description__c = qi.Description__c
        ));
    }

    System.debug('\n\n@@new quote item extension records: \n\n');
    System.debug('\n\n@@tQIs: ' + tQIs + '\n\n');
    insert tQIs;
}