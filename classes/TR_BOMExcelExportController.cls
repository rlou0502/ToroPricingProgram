public with sharing class TR_BOMExcelExportController {
	public string xmlheader {get;set;}
	public string endfile{get;set;}
	public List<string> listString{get;set;}
	public TR_BOMExcelExportController() {
		xmlheader ='<?xml version="1.0"?>';
		
		endfile = '</Workbook>';
		listString = new List<string>();
		listString.add('1');
		listString.add('2');	
	}
}