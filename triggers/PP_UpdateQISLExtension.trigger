trigger PP_UpdateQISLExtension on REVVY__MnQuoteItemSubLine__c (after update) {
	if(ToroTriggerRunOnce.runQuoteItemSublineRunOnce()) {
		List<REVVY__MnQuoteItemSubLine__c> qis = (List<REVVY__MnQuoteItemSubLine__c>) trigger.new;
		List<Id> Ids = new List<Id>();
	    for (REVVY__MnQuoteItemSubLine__c qi : qis) {
	    	if (Trigger.oldMap.get(qi.Id).REVVY__Quantity__c != qi.REVVY__Quantity__c) {
	    		Ids.add(qi.Id);
	    	}
	    }
	
	    if (Ids.size() > 0) {
	    	Map<Id,REVVY__MnQuoteItemSubLine__c> QisMap = new Map<Id,REVVY__MnQuoteItemSubLine__c>(
				[SELECT
					Id
					, REVVY__Quantity__c
					, REVVY__QuoteItem__r.REVVY__Quantity__c
				FROM
					REVVY__MnQuoteItemSubLine__c
				WHERE
					Id in :Ids]
			);
	    	List<Revvy__MnStrategy5__c> tQIs = new List<Revvy__MnStrategy5__c>();
	
			for (REVVY__MnQuoteItemSubLine__c qi : qis) {
				REVVY__MnQuoteItemSubLine__c qisExt = QisMap.get(qi.Id);
				if(qisExt.REVVY__QuoteItem__r != null) {
		    		Decimal extQty = CMnQuoteUtil.defaultDecimal(qisExt.REVVY__Quantity__c) * CMnQuoteUtil.defaultDecimal(qisExt.REVVY__QuoteItem__r.REVVY__Quantity__c);
		
					tQIs.add(
						new Revvy__MnStrategy5__c(
							  External_Id__c       = qi.Id
							, Toro_Quantity__c     = qi.REVVY__Quantity__c
							, Adjusted_Quantity__c = extQty
						)
					);
				}
			}
	
			upsert tQIs External_Id__c;
	
	
			/*
			List<Revvy__MnStrategy5__c> subExtObjs = [
				SELECT
					External_Id__c
					, Toro_Quantity__c
					, Adjusted_Quantity__c
				FROM
					Revvy__MnStrategy5__c
				WHERE
					External_Id__c IN :qisMap.keySet()
			];
	
			Map<Id,Revvy__MnStrategy5__c> freshSubExtObjMap = new Map<Id,REVVY__MnStrategy5__c>(subExtObjs);
	
			List<Revvy__MnStrategy5__c> subExtObjsToUpdate = new List<REVVY__MnStrategy5__c>();
	
			for (REVVY__MnQuoteItemSubLine__c qi : qis) {
				REVVY__MnQuoteItemSubLine__c qisExt = QisMap.get(qi.Id);
				Decimal extQty = qisExt.REVVY__Quantity__c * qisExt.REVVY__QuoteItem__r.REVVY__Quantity__c;
	
				Revvy__MnStrategy5__c subExtObjToUpdate = freshSubExtObjMap.get(qisExt.Id);
	
				subExtObjToUpdate.Toro_Quantity__c = qi.REVVY__Quantity__c;
				subExtObjToUpdate.Adjusted_Quantity__c = extQty;
				subExtObjsToUpdate.add(subExtObjToUpdate);
			}
	
			update subExtObjsToUpdate;
			*/
	    }
	}
}