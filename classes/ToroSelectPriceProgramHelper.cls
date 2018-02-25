public with sharing class ToroSelectPriceProgramHelper {
	public Revvy__MnQuote__c quote { get; set; }
	public List<Revvy__MnQuoteItem__c> quoteItems { get; set; }
	public List<Schema.FieldSetMember> getQuoteItemSublineFields() {
		return SObjectType.Revvy__MnQuoteItemSubline__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public List<Schema.FieldSetMember> getQuoteItemFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public List<Schema.FieldSetMember> getQuoteFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}
	public ToroSelectPriceProgramHelper() {
		quoteFieldMap = Schema.SObjectType.Revvy__MnQuote__c.fields.getMap();	
		quoteItemFieldMap = Schema.SObjectType.Revvy__MnQuoteItem__c.fields.getMap();	
		quoteItemSublineFieldMap = Schema.SObjectType.Revvy__MnQuoteItemSubline__c.fields.getMap();	
	}
	public ToroSelectPriceProgramHelper(Id quoteId) {
		this();
		//system.debug('getQuoteFieldsUpdatable =' + getQuoteFieldsUpdatable());
		//system.debug('getQuoteItemFieldsUpdatable =' + getQuoteItemFieldsUpdatable());
		//system.debug('getQuoteItemSublineFieldsUpdatable =' + getQuoteItemSublineFieldsUpdatable());
		String quoteQuery = 'select ' + getQuoteFieldAPINameQuery() + 'REVVY__Account__r.BillingStateCode from Revvy__MnQuote__c where id=:quoteId';
		//system.debug('query=' + quoteQuery);
			
		String quoteLineQuery = 'Select ' + getQuoteItemFieldAPINamesQuery() + 'REVVY__Product_Name_F__c, REVVY__Product_Id_F__c, Selected_Off_MSRP__c, Select_Price_Program_Type__c, Select_a_Price_Method__c, Award_of_DN__c,'+ '(Select ' + getQuoteItemSublineFieldAPINamesQuery().removeEnd(',');
		quoteLineQuery += ', revvy__QuoteItem__r.Select_a_Price_Method__c from REVVY__QuoteItemSubLine__r) from  REVVY__MnQuoteItem__c where revvy__Quote__c = :quoteId';
		//system.debug('query=' + quoteLineQuery);

		quote = Database.query(quoteQuery);
		quoteItems = Database.query(quoteLineQuery);
		system.debug('quote =' + quote);
		system.debug('quote items =' + quoteItems);
	}

	public Map<String, boolean> getQuoteFieldsUpdatable() {
		Set<String> fs = new Set<String>();
		Map<String, boolean> ret = new Map<String, boolean>();
		for(String s : getQuoteFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		system.debug(fs);
	/*	
		for(String key : quoteFieldMap.keyset()) {
			//system.debug('key=' + key);
			//system.debug('fs.contains(key)=' + fs.contains(key) + ' quoteFieldMap.get(key).getDescribe().isUpdateable()=' + quoteFieldMap.get(key).getDescribe().isUpdateable());
			if(fs.contains(key) && quoteFieldMap.get(key).getDescribe().isUpdateable()) {
				ret.put(key.toLowerCase(), true);
			} else {
				ret.put(key.toLowerCase(), false);
			}
		}
		*/
		return ret;
	}

	public Map<String, boolean> getQuoteItemFieldsUpdatable() {
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		//system.debug(fs);
	/*	
		for(String key : quoteItemFieldMap.keyset()) {
			if(fs.contains(key) && quoteItemFieldMap.get(key).getDescribe().isUpdateable()) {
				ret.put(key.toLowerCase(), true);
			} else {
				ret.put(key.toLowerCase(), false);
			}
		}
		*/
		return ret;
	}

	public Map<String, boolean> getQuoteItemSublineFieldsUpdatable(String pricingMethod) {
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemSublineFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		//system.debug(fs);
		/*
		for(String key : quoteItemSublineFieldMap.keyset()) {
			if(fs.contains(key) && quoteItemSublineFieldMap.get(key).getDescribe().isUpdateable()) {
				ret.put(key.toLowerCase(), true);
			} else {
				ret.put(key.toLowerCase(), false);
			}
		}
		*/
		return ret;
	}

	
	private List<String> getQuoteFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}
	private String getQuoteFieldAPINameQuery() {
		String query = '';
		for(String s : getQuoteFieldAPINames()) {
			query += s +',';
		}
		return query;
	}
	
	private List<String> getQuoteItemFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}
	private String getQuoteItemFieldAPINamesQuery() {
		String query = '';
		for(String s : getQuoteItemFieldAPINames()) {
			query += s +',';
		}
		return query;
	}
	
	private List<String> getQuoteItemSublineFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteItemSublineFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}
	private String getQuoteItemSublineFieldAPINamesQuery() {
		String query = '';
		for(String s : getQuoteItemSublineFieldAPINames()) {
			query += s +',';
		}
		return query;
	}
	private Map<String, Schema.SObjectField> quoteFieldMap { get; set; }
	private Map<String, Schema.SObjectField> quoteItemFieldMap { get; set; }
	private Map<String, Schema.SObjectField> quoteItemSublineFieldMap { get; set; }
}