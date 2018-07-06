public class ToroStateContractQtyModelHelper extends ToroStateContractModelQtyHelper { 
	public override Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList, Set<String> inclusiveExclusiveModels) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good' && inclusiveExclusiveModels.contains(quoteItem.Product_Id__c)) {
				count += (Integer) quoteItem.Quantity__c;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}
	public override REVVY__MnStrategy2__c getPricingProgramLine( REVVY__MnStrategy4__c qi) {
		Revvy__MnStrategy2__c line = productPricingProgramLineMap.get(qi.Product_Id__c);
		if(line != null) {
			line = qtyTierLine;	
		} else {
			line = productPricingProgramLineMap.get('All');
		}
		return line;
	}    
}