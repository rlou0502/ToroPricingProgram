public class ToroExportToExcelMultipleSheets {
	public boolean displayMSRPOnly {get; set;}
	public List<ToroGenModelBOM.Model> models { get; set;}
    public String generatedDate {get;set;}
    public String effectiveStartDate { get; set; }
    public String effectiveEndDate { get; set; }
    public Integer socMergeAcross {get; set;}
    public Integer tabMergeAcross {get; set;}
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
    	socMergeAcross = 6;
    	tabMergeAcross = 3;
    	displayMSRPOnly = false;
        generatedDate = System.now().format('MM/dd/yyyy HH:mm');
        models = ToroGenModelBOM.genBOM().BOMs;
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
        stockOrderLists = ToroGenModelBOM.getStockOrder();
        REVVY__MnPriceList__c priceList = [Select REVVY__Start_Date__c, REVVY__End_Date__c From REVVY__MnPriceList__c where name = 'Commercial' limit 1];
        effectiveStartDate = priceList.REVVY__Start_Date__c.format()+' - Today';
    }
 
    public Pagereference exportAll(){
        
        return new Pagereference('/apex/ToroExportToExcelMultipleSheets');
	}
 
}