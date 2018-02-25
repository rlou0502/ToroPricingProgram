public with sharing class CMnQuoteComparisonReportController {
	public list<QuoteComparisonSection> quoteComparisonTranspose { get; set; }
	public String userLocale {get;set;}
	public string reportId { get; set; }
	public Boolean displayCurrency {get;set;}
    public Boolean displayOrgCurrency {get;set;}
    public Decimal selectedCurrencyRate {get;set;}
    public Decimal exchangeRate {get;set;}
	public list<ColumnHeader> columnHeader { get; set; }
	public string retURL { get; set; }
	public List<Data> chartData { get; set;}
    public String chartVertical { get; set; }
    public String yAxisTitle { get; set; }
    public String yAxisField { get; set; }
    public static Map<String, String> chartFilterCriteria = new Map<String, String> {
    		'totalQuoteAwardPrice'=>'Total Quote Award Price',
    		'totalDNet'=>'Total DNet',
    		'totalQuoteGrossProfit'=>'Total Quote Gross Profit'
    	};
    public CMnQuoteComparisonReportController() {
    	userLocale = UserInfo.getLocale();	
    	displayCurrency = true;
    	displayOrgCurrency = false;
    	//reportId = '55d6d0a1-12f3-487f-855e-95da0f7b10e3';
    	exchangeRate = 1.0;
    	selectedCurrencyRate = 1.0;
    	chartVertical = 'totalQuoteGrossProfit';
    	yAxisField = 'totalQuoteGrossProfit';
    	yAxisTitle = 'Total Quote Gross Profit';
    	reportId = ApexPages.Currentpage() != null ? ApexPages.Currentpage().getParameters().get('reportId') : '55d6d0a1-12f3-487f-855e-95da0f7b10e3';
    	exchangeRate = ApexPages.Currentpage() != null ? decimal.valueOf(ApexPages.Currentpage().getParameters().get('exchangeRate')) : 1.0;
    	selectedCurrencyRate = ApexPages.Currentpage() != null ? decimal.valueOf(ApexPages.Currentpage().getParameters().get('selectedCurrencyRate')) : 1.0;
    	retURL = ApexPages.Currentpage() != null ? string.valueOf(ApexPages.Currentpage().getParameters().get('retURL')) : '';
    }
    public void init() {
    	List<REVVY__MnQuoteComparison__c> quoteComaprisonRecords =  getQuoteComaprisonRecords(reportId);
    	quoteComparisonTranspose = createTransposedReport(quoteComaprisonRecords);	
    	chartData = getChartData(quoteComaprisonRecords);
    }
    public void test(string repId) {
    	
    	list<QuoteComparisonSection> t = createTransposedReport(getQuoteComaprisonRecords(repId));
    	system.debug('-------' + t);
    }
    public List<Schema.FieldSetMember> getFields() {
    	List<Schema.FieldSetMember> fieldSetMemberList = new List<Schema.FieldSetMember>();
    	Schema.DescribeSObjectResult sObjDescribe = REVVY__MnQuoteComparison__c.sObjectType.getDescribe();
		Map<String, Schema.FieldSet> FsMap = sObjDescribe.fieldSets.getMap();
		for(Schema.FieldSet fs : FsMap.values() ) {
			fieldSetMemberList.addAll(fs.getFields());	
		}
        return fieldSetMemberList;
    }
    
    public List<SelectOption> getFilterCriteria() {
    	List<SelectOption> options = new List<SelectOption>();
    	for (string s : chartFilterCriteria.keyset()) {
    		options.add(new SelectOption(s,chartFilterCriteria.get(s)));	
    	}
 	 	return options;
  	}
  	public void selectChart() {
  		system.debug('------------chartVertical = ' + chartVertical);
  		yAxisField = chartVertical;
  		yAxisTitle = chartFilterCriteria.get(yAxisField);	
  		system.debug('------------yAxisField = ' + yAxisField);
  		system.debug('------------yAxisTitle = ' + yAxisTitle);
  	}
    public String genQuery() {
    	String query = 'SELECT ';
        Schema.Describesobjectresult dr = REVVY__MnQuoteComparison__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
        Set<String> fieldsInSet = new Set<String>();
        for(Schema.FieldSetMember f : this.getFields()) {
        	Schema.Describefieldresult dField = fieldMap.get(f.getFieldPath()).getDescribe();
        	if(dField != null) {
        		if(dField.isAccessible()) {
        			if(!fieldsInSet.contains(f.getFieldPath())) {
            			query += f.getFieldPath() + ', ';
            			fieldsInSet.add(f.getFieldPath());
        			}
        		}
        	}
        }
        query += 'Id, Name, revvy__quote__r.name, revvy__quote__r.revvy__Id__c FROM REVVY__MnQuoteComparison__c ';	
        return query;
    }
    public List<REVVY__MnQuoteComparison__c> getQuoteComaprisonRecords(String reportId) {
        String query = genQuery();
        query += ' where REVVY__ReportId__c = :reportId';
        return Database.query(query);
    }
    
    
    public list<QuoteComparisonSection> createTransposedReport(List<REVVY__MnQuoteComparison__c> records) {
    	system.debug('createTransposedReport records size = ' + records.size());
    	integer nameWidth = 2;
    	list<QuoteComparisonSection> ret = new list<QuoteComparisonSection>();
    	columnHeader = new list<ColumnHeader>{new ColumnHeader('Name', 2)};
    	integer fieldWidth = (12-nameWidth) / records.size();
    	for(REVVY__MnQuoteComparison__c qc : records) {
    		columnHeader.add(new ColumnHeader(qc.revvy__quote__r.name + ' (' + qc.revvy__quote__r.revvy__Id__c + ')', fieldWidth));	
    	}
    	Schema.DescribeSObjectResult sObjDescribe = REVVY__MnQuoteComparison__c.sObjectType.getDescribe();
		Map<String, Schema.FieldSet> FsMap = sObjDescribe.fieldSets.getMap();
		//FsMap2 map from fieldset description(containing sequence number for displaying order) to fieldset object
		map<string, Schema.FieldSet> FsMap2 = new map<string, Schema.FieldSet>();
		for(Schema.FieldSet fs : FsMap.values() ) {
			FsMap2.put(fs.description, fs);
		}
		List<String> keySetList = new List<String>();
    	keySetList.addAll(FsMap2.keySet());
    	//sorted using sequence number stored in description field
    	keySetList.sort();
		system.debug('createTransposedReport keySetList size = ' + keySetList.size());
    	map<string, string> typeMapping = new map<string, string> {'currency'=>'decimal', 'double'=>'number', 'string'=>'text', 'boolean'=>'boolean', 'percent'=>'percent'};
    	
    	//List<Schema.FieldSetMember> flds = getFields();
    	Schema.Describesobjectresult dr = REVVY__MnQuoteComparison__c.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dr.fields.getMap();
    	
    	integer index = 0;
    	for(String key : keySetList) {
    		system.debug('check point 0 key = ' + key);
			Schema.FieldSet fSet = 	FsMap2.get(key);
			system.debug('check point 0 fSet = ' + fSet);
			List<Schema.FieldSetMember> flds = fSet.getFields();
			List<List<ObjectWrapper>> reportRecords = new List<List<ObjectWrapper>>();
			for(Schema.FieldSetMember fs : flds) {
				system.debug('check point 1');
	    		Schema.Describefieldresult dField = fieldMap.get(fs.getFieldPath()).getDescribe();
	        	if(dField != null && dField.isAccessible()) {
	        		system.debug('check point 2');
		    		system.debug(fs.type);
		    		list<ObjectWrapper> row = new list<ObjectWrapper>();
		    		integer decimalPoint = 2;
		    		row.add(new ObjectWrapper('text', fs.label, 'USD', decimalPoint));
		    		system.debug('check point 3');
		    		if(fs.label.containsIgnoreCase('revenue') || fs.label.containsIgnoreCase('volume') || fs.label.containsIgnoreCase('Contract Value'))
		    		{
		    			decimalPoint = 0;
		    		} 
			    	for(REVVY__MnQuoteComparison__c qc : records) {
			    		row.add(new ObjectWrapper(typeMapping.get(fs.type.name().toLowerCase()), qc.get(fs.getFieldPath()), 'USD', decimalPoint));
			       	}
			       	reportRecords.add(row);
	        	}
	    	}
	    	String fsLabel = fSet.getName();
	    	ret.add(new QuoteComparisonSection(fSet.label, reportRecords));
		}
   		for(QuoteComparisonSection qcs : ret) {
	    	for(list<ObjectWrapper> s : qcs.objList) {
	    		system.debug('QuoteComparisonSection --' + s);
	    	}
   		}
    	system.debug('column header' + columnHeader);
    	
    	return ret;
    }
    
    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public static List<Data> getChartData(List<REVVY__MnQuoteComparison__c> listQCData) {
        List<Data> data = new List<Data>();
        for(REVVY__MnQuoteComparison__c qc : listQCData) {
        	data.add(new Data(qc.Quote_Name__c, qc.Total_Quote_Award_Price__c, qc.Total_Quote_Gross_Profit__c, qc.Total_Quote_Gross_Profit_Per__c, qc.total_dnet__c));
        }
        return data;
    }
	public class ObjectWrapper {
 		public ObjectWrapper(String typeName, object value, string currencyCode, Integer decimalPoint) {
 			this.value = String.valueOf(value);
 			this.typeName = typeName;
 			this.currencyCode = currencyCode;
 			this.decimalPoint = decimalPoint;
 		}
 		public Integer decimalPoint {get; set; }
 		public String value { get; set; }
 		public String typeName { get; set; }
 		public String currencyCode { get; set; }
 	}
 	public class QuoteComparisonSection {
 		public QuoteComparisonSection(String headerName, List<List<ObjectWrapper>> objList) {
 			this.header = headerName;
 			this.objList = objList;
 		}
 		public List<List<ObjectWrapper>> objList { get; set; }
 		public String header { get; set; }
 	}
 	public class ColumnHeader {
 		public ColumnHeader(String caption, integer width) {
 			this.caption = caption;
 			this.width = width;	
 		}
 		public String caption { get; set; }
 		public Integer width { get; set; }	
 	}   
 	// Wrapper class
    public class Data {
        public String quoteName { get; set; }
        public Decimal totalDNet { get; set; }
        public Decimal totalQuoteAwardPrice { get; set; }
        public Decimal totalQuoteGrossProfit { get; set; }
        public Decimal totalQuoteGrossProfitPercent { get; set; }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3, Decimal data4) {
        	this.totalDNet = data4;
            this.QuoteName = name;
            this.totalQuoteAwardPrice = data1;
            this.totalQuoteGrossProfit = data2;
            this.totalQuoteGrossProfitPercent = data3;
        }
    } 
}