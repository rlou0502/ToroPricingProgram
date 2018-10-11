public class ToroExportToExcelMultipleSheets {
	public boolean displayMSRPOnly {get; set;}
	public List<ToroGenModelBOM.Model> models { get; set;}
	public String priceListName { get; set; }
    public String generatedDate {get;set;}
    public String effectiveStartDate { get; set; }
    public String effectiveEndDate { get; set; }
    public static final Integer socMergeAcross = 6;
    public static final Integer tabMergeAcross = 3;
    public Integer getSOCMergeAcross() {
    	Integer val = socMergeAcross;
    	if(!getCanAccessDNet() || displayMSRPOnly) {
    		val--;	
    	}
    	return val;
    }
    public Integer getTABMergeAcross() {
    	Integer val = tabMergeAcross;
    	if(!getCanAccessDNet() || displayMSRPOnly) {
    		val--;	
    	}
    	return val;
    }
    public boolean getCanAccessDNet() {
    	return Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible();
    }
    public list<list<ToroGenModelBOM.StockOrder>> stockOrderLists { get; set; }
    public String xlsHeader {
            get {
                String strHeader = '';
                strHeader += '<?xml version="1.0"?>';
                strHeader += '<?mso-application progid="Excel.Sheet"?>';
                return strHeader;
            }
        }
    
    public ToroExportToExcelMultipleSheets(){
    	List<User_Distributor__c> uds = [Select u.User_Name__c, u.Price_Segment__c From User_Distributor__c u where u.User_Name__c = :userInfo.getUserId() ];
    	String priceSegment = 'Commercial';
        for(User_Distributor__c ud : uds) {
        	if(String.isNotBlank(ud.Price_Segment__c)) {
        		priceSegment = ud.Price_Segment__c;		
        	}
        }
        REVVY__MnPriceList__c priceList = [Select Id, Name, REVVY__Start_Date__c, REVVY__End_Date__c From REVVY__MnPriceList__c where REVVY__Segment__c = :priceSegment and (REVVY__Start_Date__c < Today AND REVVY__End_Date__c > Today) limit 1];
        effectiveStartDate = Date.today().format();
        priceListName = priceList.Name; 
    	displayMSRPOnly = false;
        generatedDate = System.now().format('MM/dd/yyyy HH:mm');
        models = ToroGenModelBOM.genBOM(priceList.Id).BOMs;
        Integer j = 0;
		while (j < models.size())
		{
		  if(models.get(j).modelName.startsWith('test'))
		  {
		    models.remove(j);
		  }else
		  {
		    j++;
		  }
		}
		
        stockOrderLists = ToroGenModelBOM.getStockOrder(priceList.Id);
        
        
    }
 
    public Pagereference exportAll(){
        
        return new Pagereference('/apex/ToroExportToExcelMultipleSheets');
	}
 
}