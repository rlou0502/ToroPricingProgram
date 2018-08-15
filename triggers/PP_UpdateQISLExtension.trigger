trigger PP_UpdateQISLExtension on REVVY__MnQuoteItemSubLine__c (after update) {
	if(ToroTriggerRunOnce.runQuoteItemSublineRunOnce()) {
		List<REVVY__MnQuoteItemSubLine__c> qis = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new;
		List<Id> Ids = new List<Id>();
	    for (REVVY__MnQuoteItemSubLine__c qi : qis) {
	    	if ((Trigger.oldMap.get(qi.Id).REVVY__Quantity__c != qi.REVVY__Quantity__c) || (Trigger.oldMap.get(qi.Id).TPP_DNet__c != qi.TPP_DNet__c) ) {
	    		Ids.add(qi.Id);
	    	} 
	    }
	
	    if (Ids.size() > 0) {
	    	Map<Id,REVVY__MnQuoteItemSubLine__c> QisMap = new Map<Id,REVVY__MnQuoteItemSubLine__c>(
				[SELECT
					Id
					, REVVY__Quantity__c
					, REVVY__QuoteItem__r.REVVY__Quantity__c
					, TPP_DNet__c
					, REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c
					, REVVY__SuggestedPrice__c
				FROM
					REVVY__MnQuoteItemSubLine__c
				WHERE
					Id in :Ids]
			);
	    	List<Revvy__MnStrategy5__c> tQIs = new List<Revvy__MnStrategy5__c>();
	
			for (REVVY__MnQuoteItemSubLine__c qi : qis) {
				REVVY__MnQuoteItemSubLine__c qisExt = QisMap.get(qi.Id);
				if(qisExt != null && qisExt.REVVY__QuoteItem__r != null) {
		    		Decimal extQty = CMnQuoteUtil.defaultDecimal(qisExt.REVVY__Quantity__c) * CMnQuoteUtil.defaultDecimal(qisExt.REVVY__QuoteItem__r.REVVY__Quantity__c);
					Decimal dnetPrice = qisExt.REVVY__SuggestedPrice__c;
					if(qisExt.REVVY__Catalog_Node__r.Pricing_Program_Product_Type__c == 'TPP') {
						dnetPrice = qi.TPP_DNet__c;			
					}
					tQIs.add(
						new Revvy__MnStrategy5__c(
							  External_Id__c       = qi.Id
							, Toro_Quantity__c     = qi.REVVY__Quantity__c
							, Adjusted_Quantity__c = extQty
							, TPP_DNet__c = qi.TPP_DNet__c
							, DNet_Price__c = dnetPrice
						)
						
					);
				}
			}
	
			upsert tQIs External_Id__c;
	    }
	}
}