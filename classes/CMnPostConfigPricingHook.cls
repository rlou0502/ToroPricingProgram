global class CMnPostConfigPricingHook implements revvy.IMnPostConfigPricingHookPlugin {
    global void preBOMUpdateHook(revvy.CMnPricingParams pricingParams){
        List<revvy__MnQuoteItem__c> qiList = pricingParams.qiList;
        List<revvy__MnQuoteItemSubLine__c> qislList = pricingParams.qiSubLineList;
        Map<String,List<revvy.UserEnteredAttr>> attrMap = pricingParams.lineAndSublineAttrMap;
        system.debug('qiList =' + qiList);
        system.debug('qislList =' + qislList);
        system.debug('attrMap =' + attrMap);
        //integer r = 12/0;
        if ( qiList != null && qiList.size() != 0){
            for(revvy__MnQuoteItem__c mnQuoteItem: qiList){
                //system.debug('Select_Price_Program_Type__c =' + mnQuoteItem.Select_Price_Program_Type__c);
                //system.debug('Select_a_Price_Method__c =' + mnQuoteItem.Select_a_Price_Method__c);
                /*
                if(mnQuoteItem.revvy__UID__c == 'TestQuoteItem_1'){
                    List<revvy.UserEnteredAttr> userEnteredAttrList = attrMap.get(mnQuoteItem.revvy__UID__c);
                    // Set price of a quote item based on a specific value of an attribute.
                    if (userEnteredAttrList != null && userEnteredAttrList.size() != 0){
                        revvy.UserEnteredAttr qiAttr = userEnteredAttrList[0];
                        if (qiAttr.type == 'Text' && qiAttr.value == 'TestAttrValue'){
                            mnQuoteItem.revvy__Unit_Price__c = 50001;
                            System.debug('Quote Item UnitPrice is set to 50001 when attr is equal to TestAttrValue: ' + qiList[0]);
                        }
                    }
                }
                */
            }
        }
        if ( qislList != null && qislList.size() != 0){
            for(revvy__MnQuoteItemSubLine__c mnQuoteItemSubLine:qislList){
                /*
                if(mnQuoteItemSubLine.revvy__UID__c == 'TestQuoteItemSubLine_1'){
                    mnQuoteItemSubLine.revvy__Unit_Price__c = 50000;
                    System.debug('Quote Item SubLine UnitPrice is set to 50000 ' + qislList[0]);
                }
*/
            }
        }
    }
}