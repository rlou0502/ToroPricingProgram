public with sharing class CMnQuoteComparisonController {
	public class QuoteComparisonRemoteStatus {
        public Boolean success { get; set; }
        public String quoteId { get; set;}
        public String status { get; set; }
        public Object data { get; set; }
        public String reportId { get; set; }
        public QuoteComparisonRemoteStatus() {
            success = false;
        }
    }
    ApexPages.StandardSetController setCon;
    List<REVVY__MnQuote__c> quotes;
    public Integer selectedQuotesSize { get; set; }
    public Integer quoteComparisonLimit { get; set; }
    public string retURL { get; set; }
    public string errorMsg { get; set; }
    public void init() {
        List<Id> qIds = new List<Id>();
        List<REVVY__MnQuote__c> selectedQuotes = (List<REVVY__MnQuote__c>) setCon.getSelected();
        selectedQuotesSize = selectedQuotes.size();
        errorMsg='';
       
        for(REVVY__MnQuote__c q : selectedQuotes) {
            qIds.add(q.Id);
        }
        quotes = [select id, revvy__Id__c, name, REVVY__Current_Status__c from REVVY__MnQuote__c where id in :qIds];
    }
    public CMnQuoteComparisonController(ApexPages.StandardSetController controller) {
        setCon = controller;
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }
    @RemoteAction
    public static QuoteComparisonRemoteStatus createQuoteComparisonRecord(String quoteId, string uuid) {
        QuoteComparisonRemoteStatus status = new QuoteComparisonRemoteStatus();
        status.quoteId = quoteId;
        if(string.isNotBlank(quoteId)) {
        	try {
                list<REVVY__MnQuoteItem__c> quoteItemss = [Select r.REVVY__Product_Name_F__c, 
                				(Select REVVY__Catalog_Node__r.Name From REVVY__QuoteItemSubLine__r) From REVVY__MnQuoteItem__c r
								where revvy__quote__c = :quoteId];	
				String equipments = '';		
				for(REVVY__MnQuoteItem__c qi : quoteItemss) {
					if(qi.REVVY__Product_Name_F__c.startsWithIgnoreCase('xn300') || qi.REVVY__Product_Name_F__c.startsWithIgnoreCase('xn900') ) {
						equipments += qi.REVVY__Product_Name_F__c + ';';
					}
					for(Revvy__MnQuoteItemSubLine__c sqi : qi.REVVY__QuoteItemSubLine__r){
						if(sqi.REVVY__Catalog_Node__r.Name.startsWithIgnoreCase('xn300') || sqi.REVVY__Catalog_Node__r.Name.startsWithIgnoreCase('xn900') ) {
							equipments += sqi.REVVY__Catalog_Node__r.Name + ';';
						}
						
					}
					
				}
				equipments = equipments.removeEnd(';');
				if(equipments.length() > 255) {
					equipments = equipments.substring(0,254);	
				} 
                String newGuid = CMnQuoteUtil.getNewGuid(); 
                REVVY__MnQuoteComparison__c qc = new REVVY__MnQuoteComparison__c(
                	REVVY__Quote__c=quoteId,
                    REVVY__Id__c=newGuid,
                    REVVY__ReportId__c = uuid,
                    Equipment_List__c = equipments 
                );
                insert qc;
                status.success = true;
                status.data = qc.Id;
                status.reportId = uuid;
            } catch (Exception e) {
                system.debug('---------' + e.getMessage() + ' stack trace=' + e.getStackTraceString());
                status.success = false;
                status.data = e.getMessage() + '=> stack trace=' + e.getStackTraceString();
            }
            
        }
        return status;
    } 
}