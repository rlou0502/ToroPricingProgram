public with sharing class RoyTest {
	public static void getOptionCounts() {
		List<REVVY__MnConfigEngineOption__c> options = [Select REVVY__Id_Number__c,REVVY__Option_Group__r.revvy__Id__c  From REVVY__MnConfigEngineOption__c r];
		map<String, double> optionGroupMax = new map<String, double>();
		for(REVVY__MnConfigEngineOption__c opt : options) {
			if(!optionGroupMax.containsKey(opt.REVVY__Option_Group__r.revvy__Id__c)) {
				optionGroupMax.put(opt.REVVY__Option_Group__r.revvy__Id__c, opt.REVVY__Id_Number__c);
			} else {
				double m = math.max(optionGroupMax.get(opt.REVVY__Option_Group__r.revvy__Id__c), opt.REVVY__Id_Number__c);
				optionGroupMax.put(opt.REVVY__Option_Group__r.revvy__Id__c, m);
			}
		}
		for(string k : optionGroupMax.keyset()) {
			system.debug(k + '= ' + optionGroupMax.get(k));
		}
	}
	public static void genQueries() {
		List<String> sobjNames = new List<String> {'REVVY__MnCatalogNode__c','REVVY__MnCatalogNodeLocaleExt__c','REVVY__MnCatalogNodeEdge__c',
				'REVVY__MnPriceList__c','REVVY__MnPriceListLine__c','REVVY__MnCatalogAttribute__c','REVVY__MnCatalogAttributeValue__c',
				'REVVY__MnCatalogNodeAttr__c','REVVY__MnPrintTemplate__c','REVVY__MnConfigEngineModel__c','REVVY__MnConfigEngineOptionGroup__c',
				'REVVY__MnConfigEngineOption__c','REVVY__MnConfigEngineUILayout__c','REVVY__MnConfigEngineUISection__c','REVVY__MnConfigEngineRule__c',
				'REVVY__MnConfigEngineRuleDataCell__c','REVVY__MnExpression__c','REVVY__MnExpressionCondition__c','REVVY__MnExpressionRef__c',
				'REVVY__MnOptionGroupAttributeJunction__c','REVVY__MnImportFormat__c','REVVY__MnQuoteRecordTypeFieldSetMapping__c',
				'REVVY__MnConfigEngineModelOptionGroupJunction__c','REVVY__MnConfigEngineOGUISectionJunction__c',
				'REVVY__MnConfigEngineModelRuleJunction__c','REVVY__MnConfigEngineRuleOptionGroupJunction__c',
				'Discount__c','Discount_Item__c', 'OCD_Deal_Assessment__c','Deal_Assessment_Cost__c','Deal_Assessment_Detail__c','DA_Variable__c','OCD_Beh_Discount__c',
				'OCD_Beh_Discount_Item__c','OCD_Beh_Eligibility__c'};
		for(String sobjName : sobjNames) {
			RoyTest.genQuery(sobjName);
		}	
	}
	
	public static void genQuery2(String objName, boolean queryWithId) {
        String querySelect = 'Select ';
        String queryBody=''; 
        if(queryWithId) {
            queryBody = 'Id, ';
        }
        Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
        for( String fieldName : fieldMap.keySet() ) {
            if(String.isBlank(fieldName)) {
                continue;
            }
            
            Schema.Describefieldresult dField = fieldMap.get(fieldName).getDescribe();
            
            if((dField.isNameField() && !dField.isAutoNumber()) || (dField.isCustom() && (dField.isUpdateable() || dField.isCreateable())) || (dField.isCustom() && dField.getType() == Schema.DisplayType.Reference)) {
                if(!dField.isAutoNumber()) {
                	
                    queryBody += dField.getLocalName() + ',';
                }
            } 
        }
        if(UserInfo.isMultiCurrencyOrganization() && !queryBody.containsIgnoreCase('currencyIsoCode')) {
        	queryBody += 'currencyIsoCode,';
        }
        queryBody = queryBody.removeEnd(',');
        
        string query = querySelect + queryBody;
        System.debug(query);
        
    }
    
	public static String genQuery(String objName) {
		String querySelect = 'Select ';
		String queryBody=''; 
		
		Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe();
		Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
		for( String fieldName : fieldMap.keySet() ) {
			if(String.isBlank(fieldName)) {
				continue;
			}
			
			Schema.Describefieldresult dField = fieldMap.get(fieldName).getDescribe();
			
		    if((dField.isNameField() && !dField.isAutoNumber()) || (dField.isCustom() && (dField.isUpdateable() || dField.isCreateable()))) {
            	if(dField.getType() == Schema.DisplayType.Reference ) {
            		
            		list<Schema.sObjectType > referenceTo = dField.getReferenceTo();
            		String referenceName = referenceTo[0].getDescribe().getName();
            		
        			String ln = dField.getLocalName().replace('__c', '__r');
					ln += '.REVVY__Id__c';
					//System.debug('------------------- referenceTo to =' + ln);
					queryBody += ln + ',';
            		
					
				} else {
	            	queryBody += dField.getLocalName() + ',';
	            }
            } 
            
		}
		queryBody = queryBody.removeEnd(',');
		
        string query = querySelect + queryBody + ' from ' + dr.getName();
        System.debug(query);
        return query;
	}
	
	public static void checkUpdateables() {
		List<String> sobjNames = new List<String> {'REVVY__MnCatalogNode__c','REVVY__MnCatalogNodeLocaleExt__c','REVVY__MnCatalogNodeEdge__c','REVVY__MnPriceList__c','REVVY__MnPriceListLine__c','REVVY__MnCatalogAttribute__c','REVVY__MnCatalogAttributeValue__c','REVVY__MnCatalogNodeAttr__c','REVVY__MnPrintTemplate__c','REVVY__MnConfigEngineModel__c','REVVY__MnConfigEngineOptionGroup__c','REVVY__MnConfigEngineOption__c','REVVY__MnConfigEngineUILayout__c','REVVY__MnConfigEngineUISection__c','REVVY__MnConfigEngineRule__c','REVVY__MnConfigEngineRuleDataCell__c','REVVY__MnExpression__c','REVVY__MnExpressionCondition__c','REVVY__MnExpressionRef__c','REVVY__MnOptionGroupAttributeJunction__c','REVVY__MnImportFormat__c','REVVY__MnQuoteRecordTypeFieldSetMapping__c','REVVY__MnConfigEngineModelOptionGroupJunction__c','REVVY__MnConfigEngineOGUISectionJunction__c','REVVY__MnConfigEngineModelRuleJunction__c','REVVY__MnConfigEngineRuleOptionGroupJunction__c'};
		
		for(String sobjName : sobjNames) {
			system.debug('******' + sobjName);
			RoyTest.checkUpdateable(sobjName);
		}	
	}
	
	public static void checkUpdateable(String objName) {
		Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(objName.toLowerCase()).getDescribe();
		Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
		for( String fieldName : fieldMap.keySet() ) {
			if(String.isBlank(fieldName)) {
				continue;
			}
			
			Schema.Describefieldresult dField = fieldMap.get(fieldName).getDescribe();
			if((dField.getType() == Schema.DisplayType.Reference) && dField.isCustom() && !dField.isUpdateable() && dField.isCreateable()) {
				system.debug('-----' + fieldName);	
			}
		}
	}
	
	/*
	public static void temp() {
		String sQuery = OCDMNQuoteUtility.genQuery('REVVY__MnPriceListLine__c', false);
		sQuery += ' from REVVY__MnPriceListLine__c  where REVVY__Product_Id__c like \'Classic%\' and REVVY__Price_List_ID__c = \'IA_Open_Market_Price_Plan_2015\'' ;
		List<REVVY__MnPriceListLine__c> qItems = (List<REVVY__MnPriceListLine__c>)database.query(sQuery);
		list<REVVY__MnPriceListLine__c> l = new list<REVVY__MnPriceListLine__c>();
        for(REVVY__MnPriceListLine__c qli : qItems) {
        	system.debug(qli);
        	
        	REVVY__MnPriceListLine__c pli1 = qli.clone(false, true);
        	pli1.revvy__Id__c = null;
        	REVVY__MnPriceList__c pl = [Select r.REVVY__Start_Date__c, r.REVVY__Id__c, r.REVVY__End_Date__c, r.LOB__c From REVVY__MnPriceList__c r where id = 'a3g290000008bXNAAY'];
        	pli1.REVVY__Start_Date__c = pl.REVVY__Start_Date__c;
        	pli1.REVVY__End_Date__c = pl.REVVY__End_Date__c;
        	pli1.revvy__pricelist__c = 'a3g290000008bXNAAY';
        	l.add(pli1);
        	
        	REVVY__MnPriceListLine__c pli2 = qli.clone(false, true);
        	pli2.revvy__Id__c = null;
        	pli2.revvy__pricelist__c = 'a3g290000008evBAAQ';
        	pl = [Select r.REVVY__Start_Date__c, r.REVVY__Id__c, r.REVVY__End_Date__c, r.LOB__c From REVVY__MnPriceList__c r where id = 'a3g290000008evBAAQ'];
        	pli2.REVVY__Start_Date__c = pl.REVVY__Start_Date__c;
        	pli2.REVVY__End_Date__c = pl.REVVY__End_Date__c;
        	l.add(pli2);
        	
        	REVVY__MnPriceListLine__c pli3 = qli.clone(false, true);
        	pli3.revvy__Id__c = null;
        	pli3.revvy__pricelist__c = 'a3g290000008euuAAA';
        	pl = [Select r.REVVY__Start_Date__c, r.REVVY__Id__c, r.REVVY__End_Date__c, r.LOB__c From REVVY__MnPriceList__c r where id = 'a3g290000008euuAAA'];
        	pli3.REVVY__Start_Date__c = pl.REVVY__Start_Date__c;
        	pli3.REVVY__End_Date__c = pl.REVVY__End_Date__c;
        	l.add(pli3);
        	
        	REVVY__MnPriceListLine__c pli4 = qli.clone(false, true);
        	pli4.revvy__Id__c = null;
        	pli4.revvy__pricelist__c = 'a3g290000008euhAAA';
        	pl = [Select r.REVVY__Start_Date__c, r.REVVY__Id__c, r.REVVY__End_Date__c, r.LOB__c From REVVY__MnPriceList__c r where id = 'a3g290000008euhAAA'];
        	pli4.REVVY__Start_Date__c = pl.REVVY__Start_Date__c;
        	pli4.REVVY__End_Date__c = pl.REVVY__End_Date__c;
        	l.add(pli4);
        	
        	REVVY__MnPriceListLine__c pli5 = qli.clone(false, true);
        	pli5.revvy__Id__c = null;
        	pli5.revvy__pricelist__c = 'a3g290000008evGAAQ';
        	pl = [Select r.REVVY__Start_Date__c, r.REVVY__Id__c, r.REVVY__End_Date__c, r.LOB__c From REVVY__MnPriceList__c r where id = 'a3g290000008evGAAQ'];
        	pli5.REVVY__Start_Date__c = pl.REVVY__Start_Date__c;
        	pli5.REVVY__End_Date__c = pl.REVVY__End_Date__c;
        	l.add(pli5);
        	
        }
        insert l;
	}
	*/
	public static void genPackage() {
		 
		//List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
		//	 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnCatalogAttributeValue__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c',
		//	 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c'};
		List<String> sobjNames = new List<String> {'Toro_QuoteItem_SubLine__c','User', 'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c','Account',
			 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c', 'Revvy__MnQuoteSolution__c', 'Revvy__MnQuoteSolutionAttribute__c'};
		//List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c','Toro_PricingProgram__c','Toro_PricingProgramLine__c','Toro_PricingProgramEligibility__c'};
		for(String sobjName : sobjNames) {
			Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe();
			Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
			for( String fieldName : fieldMap.keySet() ) {
			    Schema.SObjectField field = fieldMap.get( fieldName );
			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			    if(fieldDescribe.isCustom()) {
			    	if(!fieldDescribe.getLocalName().startsWithIgnoreCase('REVVY__')) {
			    		system.debug('<members>'+sobjName + '.' +  fieldDescribe.getLocalName() + '</members>' );
			    	}
			    }
			}
			system.debug(dr.FieldSets.getMap());
		}
		
	}
	
	public static void genRevvyPackage() {
		 
		//List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
		//	 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnCatalogAttributeValue__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c',
		//	 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c'};
		List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c',  
			 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c', 'Revvy__MnQuoteSolution__c', 'Revvy__MnQuoteSolutionAttribute__c'};
		for(String sobjName : sobjNames) {
			Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe();
			Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
			for( String fieldName : fieldMap.keySet() ) {
			    Schema.SObjectField field = fieldMap.get( fieldName );
			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			    if(fieldDescribe.isCustom()) {
			    	if(fieldDescribe.getLocalName().startsWithIgnoreCase('REVVY__'))
			    		system.debug('<members>'+sobjName + '.' +  fieldDescribe.getLocalName() + '</members>' );
			    }
			}
		}
		
	}
	
	public static void genFLS() {
		 
		//List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
		//	 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnCatalogAttributeValue__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c',
		//	 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c'};
		List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c',  
			 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c', 'Revvy__MnQuoteSolution__c', 'Revvy__MnQuoteSolutionAttribute__c'};
		for(String sobjName : sobjNames) {
			Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe();
			Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
			for( String fieldName : fieldMap.keySet() ) {
			    Schema.SObjectField field = fieldMap.get( fieldName );
			    Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			    if(fieldDescribe.isCustom()) {
			    	//if(!fieldDescribe.getLocalName().startsWithIgnoreCase('REVVY__'))
			    	system.debug('<members>'+sobjName + '.' +  fieldDescribe.getLocalName() + '</members>' );
			    }
			}
		}
		
	}
	
	

}