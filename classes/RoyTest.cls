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
		/*
		List<String> sobjNames = new List<String> { 'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c',
			 'Revvy__MnStrategy1__c', 'Revvy__MnStrategy2__c', 'Revvy__MnStrategy3__c', 'Revvy__MnStrategy4__c', 'Revvy__MnStrategy5__c',
			 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c', 'Revvy__MnQuoteSolution__c', 'Revvy__MnQuoteSolutionAttribute__c'};
		*/
		//List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c','Toro_PricingProgram__c','Toro_PricingProgramLine__c','Toro_PricingProgramEligibility__c'};
		/*
		List<String> sobjNames = new List<String> { 'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'REVVY__MnConfigEngineOption__c', 'REVVY__MnConfigEngineOptionGroup__c',
			 'Toro_PricingProgramEligibility__c', 'Toro_PricingProgramLine__c', 'Toro_PricingProgram__c', 'Toro_QuoteItem_SubLine__c', 'Toro_QuoteItem__c',
			 'REVVY__MnQiSubLineAttribute__c', 'REVVY__MnQuoteItemAttribute__c', 'Revvy__MnQuoteSolution__c', 'Revvy__MnQuoteSolutionAttribute__c'};
		*/	 
		//List<String> sobjNames = new List<String> { 'Toro_PricingProgram__c','Toro_PricingProgramLine__c','Toro_PricingProgramEligibility__c','Toro_QuoteItem_SubLine__c', 'Toro_QuoteItem__c'};
		List<String> sobjNames = new List<String> {'REVVY__MnQuote__c', 'REVVY__MnCatalogNode__c', 'REVVY__MnQuoteItem__c', 'REVVY__MnQuoteItemSubLine__c',
			 'REVVY__MnPriceList__c', 'REVVY__MnPriceListLine__c', 'Revvy__MnStrategy1__c', 'Revvy__MnStrategy2__c', 'Revvy__MnStrategy3__c', 'Revvy__MnStrategy4__c', 'Revvy__MnStrategy5__c'};	 
		system.debug('<types>');
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
		}
		system.debug('<name>CustomField</name>');
		
		system.debug('</types>');
		system.debug('<types>');
		for(String sobjName : sobjNames) {
			Schema.Describesobjectresult dr = Schema.getGlobalDescribe().get(sobjName.toLowerCase()).getDescribe();
			Map<String, Schema.FieldSet> fss = dr.FieldSets.getMap();
			if(fss.size() > 0){
				for(String k : fss.keyset()) {
					system.debug('<members>'+sobjName + '.' +  fss.get(k).getName() + '</members>' );
				}
				
			}
		}
		system.debug('<name>FieldSet</name>');
		
		system.debug('</types>');
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
	
	public static void genFieldset() {
		String s1 ='pricingmethodvalue__c,pricing_program_overridden__c,drivenbygp__c,adjusted_quantity__c,onlyexistedincpl__c,original_award_price__c,off_msrp_overridden__c,product__r.toro_product_type__c,traction_unit__c,off_msrp__c,award_price__c,rebate_as_a_of_dn__c,fee_percentage__c,part_percentage__c,toro_product_tier__c,msrp_price__c,original_off_msrp__c,oroginal_of_dnet__c,unit_award_overridden__c,quoteitem__r.revvy__catalog_node__r.revvy__id__c,quoteitem__r.revvy__catalog_node__r.name,product__r.hierarchy_code__c,quoteitem__r.revvy__suggestedprice__c,dnet_price__c,quoteitem__r.revvy__price__c,selected_off_msrp__c,pricing_program__c,select_a_price_method__c,award_of_dn__c,standard_price__c,product_id__c,product_name__c,placeholder1__c,total_toro_msrp__c,placeholder2__c,total_toro_dnet__c,placeholder3__c,total_toro_award__c,support_plus_item__c,performance_parts_product__c,total_award__c,toro_gross_profit_percent__c,blended_msrp__c,toro_blend_of_dn__c,toro_total_rebate__c,total_gross_profit_value__c,extended_msrp_price__c,extended_dnet_price__c,extended_award_price__c,exc_rbt__c,toro_rebate__c,toro_gross_profit_value__c';
		String[] ss1 = s1.split(',');
		
		for(String s : ss1) {
			system.debug('<displayedFields>');
			system.debug('    <field>'+s+'</field>');
			system.debug('    <isFieldManaged>false</isFieldManaged>');
			system.debug('    <isRequired>false</isRequired>');
			system.debug('</displayedFields>');
		}
		
		
		system.debug('--------------');
		String s2 ='adjusted_quantity__c,original_off_msrp__c,onlyexistedincpl__c,pricingmethodvalue__c,award_price__c,rebate_as_of_dnet__c,fee_percentage__c,part_percentage__c,toro_product_tier__c,exclude_from_rebate__c,unit_award_overridden__c,quote_item_sub_line__r.revvy__catalog_node__r.revvy__id__c,dnet_price_2__c,dnet_price__c,quote_item_sub_line__r.revvy__catalog_node__r.name,standard_price__c,quote_item_sub_line__r.revvy__price__c,quote_item_sub_line__r.revvy__suggestedprice__c,toro_quote_item__r.select_a_price_method__c,percent_off_msrp__c,percent_of_dnet__c,quantity__c,product_id__c,product_name__c,msrp_price__c,extended_msrp_price__c,extended_dnet_price__c,extended_award_price__c,apply_support_plus__c,performance_part__c,gross_profit_percent__c,toro_subline_rebate__c,gross_profit_value__c';
		String[] ss2 = s2.split(',');
		
		for(String s : ss2) {
			system.debug('<displayedFields>');
			system.debug('    <field>'+s+'</field>');
			system.debug('    <isFieldManaged>false</isFieldManaged>');
			system.debug('    <isRequired>false</isRequired>');
			system.debug('</displayedFields>');
		}
			
	}
	public class ToroRelatedData {
		@AuraEnabled public String name	{ get; set; }	
		@AuraEnabled public String sku	{ get; set; }
		@AuraEnabled public decimal msrp	{ get; set; }
		@AuraEnabled public decimal dnet	{ get; set; }
		@AuraEnabled public Id attachment	{ get; set; }
		@AuraEnabled public String line1 {get; set;}
		@AuraEnabled public String line2 {get; set;}
	}
	@AuraEnabled
	public static List<ToroRelatedData> retrieveRelatedData() {
		List<ToroRelatedData> retData = new List<ToroRelatedData>();
		List<Support_Plus_Holder__c> phs = [Select Id, Description__c From Support_Plus_Holder__c limit 5];
		List<String> skus = new List<String>();
		for(Support_Plus_Holder__c ph : phs) {
			skus.add(ph.Description__c);	
		}
		List<REVVY__MnCatalogNode__c> prods = [Select r.Id, revvy__Id__c, (Select Id From Attachments) From REVVY__MnCatalogNode__c r where revvy__Id__c in :skus];
		Map<String, Id> sku2Attachment = new Map<String, Id>();
		for(REVVY__MnCatalogNode__c p : prods) {
			if(p.Attachments != null) {
				for(Attachment a : p.Attachments) {
					sku2Attachment.put(p.revvy__Id__c, a.Id);
				}		
			}
		}
		List<REVVY__MnPriceListLine__c> plis = [SELECT Name, REVVY__Product_Id__c, REVVY__ListedPrice__c, 
				REVVY__SuggestedPrice__c, Revvy__Product__r.Name FROM REVVY__MnPriceListLine__c 
				where revvy__pricelist__r.name = 'Commercial' and (REVVY__Start_Date__c < Today AND REVVY__End_Date__c > Today) and revvy__Product__r.REVVY__Id__c in :skus];
		
		for(REVVY__MnPriceListLine__c pli : plis) {
			ToroRelatedData d = new ToroRelatedData();
			d.Name = pli.Revvy__Product__r.Name;
			d.sku = pli.REVVY__Product_Id__c;
			d.msrp = pli.REVVY__ListedPrice__c;
			d.dnet = pli.REVVY__SuggestedPrice__c;
			d.attachment = sku2Attachment.get(pli.REVVY__Product_Id__c);
			d.line1 = pli.Revvy__Product__r.Name + '('+pli.REVVY__Product_Id__c+')';
			d.line2 = 'MSRP : $' + pli.REVVY__ListedPrice__c.setScale(2).format() + '  /  DNet: $' + pli.REVVY__SuggestedPrice__c.setScale(2).format();
			retData.add(d);	
		}
		
		return retData;
	}
}