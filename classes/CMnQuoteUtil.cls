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

	public static Integer getNumberOfTractionUnits(List<Revvy__MnStrategy4__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Revvy__MnStrategy4__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good') {
				count++;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}
	public static void setupData() {
		if(Test.isRunningTest()) {
			List<sObject> disti = Test.loadData(Account.sObjectType, 'TestData_PP_Distributor');
			Id RecordTypeIdDisti = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Channel Partner').getRecordTypeId();
			List<User_Distributor__c> userDistributors = new List<User_Distributor__c>();
			for(sObject s : disti) {
				Account a = (Account) s;
				a.recordtypeid = RecordTypeIdDisti;
				userDistributors.add(new User_Distributor__c(User_Name__c=userInfo.getUserId(), Distributor__c=s.Id));
			}
			update disti;
			insert userDistributors;

			List<sObject> corporateAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CorporateAccount');
			Id RecordTypeIdCorporate = Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId();
			for(sObject s : corporateAccount) {
				Account a = (Account) s;
				a.recordtypeid = RecordTypeIdCorporate;
			}
			update corporateAccount;
			List<sObject> customerAccount = Test.loadData(Account.sObjectType, 'TestData_PP_CustomerAccount');
			for(sObject s : customerAccount) {
				Account a = (Account) s;
				a.recordtypeid = RecordTypeIdCorporate;
			}
			update customerAccount;
			List<sObject> pricingProgram = Test.loadData(Revvy__MnStrategy1__c.sObjectType, 'TestData_PP_PricingProgram');
			List<sObject> eligilibility = Test.loadData(Revvy__MnStrategy3__c.sObjectType, 'TestData_PP_Eligibility');
			List<sObject> ppHelper = Test.loadData(Toro_PricingProgramHelperFactory__c.sObjectType, 'TestData_PP_Helper');
			List<sObject> pricingProgramLine = Test.loadData(Revvy__MnStrategy2__c.sObjectType, 'TestData_PP_PricingProgramLine');
			List<sObject> priceList = Test.loadData(Revvy__MnPriceList__c.sObjectType, 'TestData_PP_PriceList');
			List<sObject> products = Test.loadData(Revvy__MnCatalogNode__c.sObjectType, 'TestData_PP_CatalogNode');
			List<sObject> quote = Test.loadData(Revvy__MnQuote__c.sObjectType, 'TestData_PP_Quote');
			system.debug('------------quote=' + quote[0].get('REVVY__Id__c'));
			List<sObject> quoteItem = Test.loadData(Revvy__MnQuoteItem__c.sObjectType, 'TestData_PP_QuoteItem');
			List<sObject> quoteItemSubline = Test.loadData(Revvy__MnQuoteItemSubline__c.sObjectType, 'TestData_PP_QuoteItemSubline');
		}
	}
}