public with sharing class CMnQuoteUtil {
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

	private String CombineSelectClauses(List<String> fieldListFromFS, String extraFields ) {
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldListFromFS);
		return String.join(new List<String>(nameSet), ',');
	}
	
	public static String getQuoteQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
		List<Schema.FieldSetMember> fieldSetMemberList2 = SObjectType.Revvy__MnQuote__c.FieldSets.Price_Program_Quote_Info.getFields();
		for(Schema.FieldSetMember fs : fieldSetMemberList) {
			fieldNames.add(fs.getFieldPath());
		}
		if(fieldSetMemberList2 != null) {
			for(Schema.FieldSetMember fs : fieldSetMemberList2) {
				fieldNames.add(fs.getFieldPath());
			}
		}
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldNames);
		return String.join(new List<String>(nameSet), ',');
	}

	public static Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good') {
				count += (Integer) quoteItem.Quantity__c;
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