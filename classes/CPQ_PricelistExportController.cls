public without sharing class CPQ_PricelistExportController {

    public List<SelectOption> priceListOptions {get;set;}
    public String selectedPricelist {get;set;}
    
	public Map<String,List<TR_BOM__c>> dataBOM {get;set;}
	public String xlsHeader{
    	get{
        	String strHeader = '';
        	strHeader += '<?xml version="1.0"?>';
        	strHeader += '<?mso-application progid="Excel.Sheet"?>';
        	return strHeader;
    	}
	}

    public CPQ_PricelistExportController() {
        
    }
	public PageReference loadData(){
        return null;
    }
	public void executeXLS(){
		dataBOM = new Map<String,List<TR_BOM__c>>();
		for(TR_BOM__c bom:[Select Id, Name, Model__c, Model__r.Name, DNet__c, MSRP__c
		                        , Option__c, Option__r.Name
		                        , Option_Group__c, Product_Id__c 
		                    From TR_BOM__c
		                   Limit 10000]) {
			List<TR_BOM__c> tlist = new List<TR_BOM__c>();
			if(dataBom.containsKey(bom.Model__r.Name)) {
				tlist = dataBom.get(bom.Model__r.Name);
			}	                   	
			tlist.add(bom);
			dataBOM.put(bom.Model__r.Name,tlist);
		}
	}
	
	public Pagereference exportAll(){
    	return new Pagereference('/apex/exportAll');
    }
}