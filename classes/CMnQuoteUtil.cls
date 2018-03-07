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
		if(d!=null && d>0) {
			result = d;
		}
		return result;
	}   
	
	
	public static String getQuoteQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		List<Schema.FieldSetMember> fieldSetMemberList = SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
		for(Schema.FieldSetMember fs : fieldSetMemberList) {
			fieldNames.add(fs.getFieldPath());
		}
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldNames);
		return String.join(new List<String>(nameSet), ',');
	}
	
}