public with sharing class CMnQuoteUtil {
	private static Id defaultPriceList = null;
	public static final String defaultPriceListName = 'Commercial';
	public static Id getDefaultPriceList() {
		if(defaultPriceList == null) {
			defaultPriceList = [select id from REVVY__MnPriceList__c where name = :defaultPriceListName limit 1].Id;		
		}
		return defaultPriceList;
	}
	private static String kHexChars = '0123456789abcdef';
	 public static String getNewGuid() {

        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }
    private static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;

        if (index == str.length()) return null;

        return str.substring(index, index+1);
    }
    public static Decimal defaultDecimal(Decimal d) {
		Decimal result = 0;
		if(d!=null) {
			result = d;
		}
		return result;
	}
	
	public static String getQuoteQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Revvy__MnQuote__c.FieldSets.Pricing_Program_Quote_Header_Fields.getFields();
		List<Schema.FieldSetMember> fieldSetMemberList2 = SObjectType.Revvy__MnQuote__c.FieldSets.Price_Program_Quote_Info.getFields();
		for(Schema.FieldSetMember fs : fieldSetMemberList) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		if(fieldSetMemberList2 != null) {
			for(Schema.FieldSetMember fs : fieldSetMemberList2) {
				fieldNames.add(fs.getFieldPath().toLowerCase());
			}
		}
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldNames);
		return String.join(new List<String>(nameSet), ',');
	}

	public static List<Revvy__MnStrategy4__c> checkIfApprovalNeeded(REVVY__MnQuote__c quote, String priceProgram, 
						String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList) {
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(priceProgram);
		System.debug('\n\n@@approval flag - quote: ' + quote + '\n\n');
		Boolean containsOutCross = CMnQuoteUtil.checkForOutCrossProducts(quoteItemList);
		Integer numberOfTractionUnits = CMnQuoteUtil.getNumberOfTractionUnits(quoteItemList);	
		Boolean needsApproval = false;
		String approvalMessage = '';

		if (containsOutCross && quote.Toro_Total_DNet__c < pricingProgram.OutCrossThreshold__c) {
			needsApproval = true;
			approvalMessage = 'Total Extended DNet must exceed ' + pricingProgram.OutCrossThreshold__c + '.' + ' (It is ' + quote.Toro_Total_DNet__c + ').';
		}	
		else if (!containsOutcross && quote.Toro_Total_DNet__c < pricingProgram.MinimumThreshold__c) {
			needsApproval = true;
			approvalMessage = 'Total Extended DNet must exceed ' + pricingProgram.MinimumThreshold__c + '.' + ' (It is ' + quote.Toro_Total_DNet__c + ').';
		}

		if (quote.Toro_Blended_Percent_of_DN__c < pricingProgram.Blended_DNet_Threshold__c) {
			needsApproval = true;
			approvalMessage += ' Blended Percent of DNet must exceed ' + pricingProgram.Blended_DNet_Threshold__c + '%.';
		}

		if (numberOfTractionUnits < pricingProgram.MinimumTractionUnits__c) {
			needsApproval = true;
			approvalMessage += ' Quote must contain at least ' + pricingProgram.MinimumTractionUnits__c + ' traction unit(s).';
		}

		if (needsApproval) {
			quote.REVVY__NeedsApproval__c = true;
			quote.Toro_ApprovalReason__c = approvalMessage;
			quote.Toro_ApprovalReason__c +='  '+  Label.PP_ApprovalRequiredWarning;
		}

		else {
			quote.REVVY__NeedsApproval__c = false;
			quote.Toro_ApprovalReason__c = '';
		}


		return	quoteItemList;
	}
	
	
	public static Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good') {
				count += (Integer) quoteItem.Adjusted_Quantity__c;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}

	/**
	 *
	 * check if the quote items contain an Out-Cross unit
	 *
	 * @param  quoteItemList    the list of Toro Quote Items
	 * @return true/false
	 */
	public static Boolean checkForOutCrossProducts(List<Revvy__MnStrategy4__c> quoteItemList) {
		System.debug('\n\n@@checkForOutCrossProducts quoteItemList: ' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product_Name__c.startsWithIgnorecase('OUTCROSS')) {
				System.debug('\n\n@@contains outcross\n\n');
				return true;
			}
		}

		return false;
	}

	
}