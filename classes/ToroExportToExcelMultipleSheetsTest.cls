/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ToroExportToExcelMultipleSheetsTest {
	@testSetup static void setup() {
		ToroTestData.loadTestData();
	}
    static testMethod void myUnitTest() {
        ToroExportToExcelMultipleSheets sheet = new ToroExportToExcelMultipleSheets();
        String header = sheet.xlsHeader;
        sheet.exportAll();
    }
    
    @isTest static void test_std_user() {
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    User u = new User(Alias = 'standt', Email='standarduser@test-toro.com', 
	    			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
	      			LocaleSidKey='en_US', ProfileId = p.Id, 
	      			TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@test-toro.com');
	
	    System.runAs(u) {       	
			ToroExportToExcelMultipleSheets sheet = new ToroExportToExcelMultipleSheets();
        	String header = sheet.xlsHeader;
        	sheet.getCanAccessDNet();
        	sheet.exportAll();
        	sheet.effectiveEndDate = '';
        	sheet.getSOCMergeAcross();
        	sheet.getTABMergeAcross();
	    }
      
	}
	@isTest static void test_misc() {
		ToroGenModelBOM.ProductModelView pmv= new ToroGenModelBOM.ProductModelView('test','test','test',10,10,10,10);
      	system.assertEquals('test',pmv.modelName);
      	system.assertEquals('test',pmv.productTab);
      	system.assertEquals('test',pmv.description);
      	system.assertEquals(10,pmv.msrp);
      	system.assertEquals(10,pmv.dnet);
      	system.assertEquals(10,pmv.stockOrder);
      	system.assertEquals(10,pmv.totalValue);
      	ToroGenModelBOM bom = new ToroGenModelBOM();
      	 
      	ToroGenModelBOM.DNetMSRGPair pair = new ToroGenModelBOM.DNetMSRGPair('test', 'test', 'test', '001', 100, 100);
      	ToroGenModelBOM.OptionGroup og1 = new ToroGenModelBOM.OptionGroup('test1', new List<ToroGenModelBOM.DNetMSRGPair> {pair}, new Set<String>{'test'});
      	ToroGenModelBOM.OptionGroup og2 = new ToroGenModelBOM.OptionGroup('test2', 1,1, new List<ToroGenModelBOM.DNetMSRGPair> {pair}, new Set<String>{'test'});
      	ToroGenModelBOM.OptionGroup og3 = new ToroGenModelBOM.OptionGroup('test3', 1,1, new List<ToroGenModelBOM.DNetMSRGPair> {pair}, new Set<String>{'test1'});
		ToroGenModelBOM.OptionGroup og4 = new ToroGenModelBOM.OptionGroup('test4', 2,2, new List<ToroGenModelBOM.DNetMSRGPair> {pair}, new Set<String>{'test1'});
		ToroGenModelBOM.OptionGroup og5 = new ToroGenModelBOM.OptionGroup('test4', 0,0, new List<ToroGenModelBOM.DNetMSRGPair> {pair}, new Set<String>{'test'});
		List<ToroGenModelBOM.OptionGroup> optionGroupList = new List<ToroGenModelBOM.OptionGroup>{og1,og2,og3,og4,og5};
		optionGroupList.sort();
	}
	
	@isTest static void test_sort() {
		
		ToroGenModelBOM.StockOrder so2 = new ToroGenModelBOM.StockOrder('2', '2', '2', 100, 
     		100, 2, 100, '2', '2', 'Finished Good', true);
     	ToroGenModelBOM.StockOrder so3 = new ToroGenModelBOM.StockOrder('3', '3', '3', 100, 
     		100, 3, 100, '3', '3', 'Finished Good', true);
     	ToroGenModelBOM.StockOrder so1 = new ToroGenModelBOM.StockOrder('1', '1', '1', 100, 
     		100, 1, 100, '1', '1', 'Finished Good', true);
     	ToroGenModelBOM.StockOrder so4 = new ToroGenModelBOM.StockOrder('4', '4', '4', 100, 
     		100, 4, 100, '4', '4', 'Finished Good', true);
     	ToroGenModelBOM.StockOrder so5 = new ToroGenModelBOM.StockOrder('5', '5', '5', 100, 
     		100, 5, 100, '5', '5', 'Finished Good', true);	
     	ToroGenModelBOM.StockOrder so6 = new ToroGenModelBOM.StockOrder('5', '', '5', 100, 
     		100, 5, 100, '', '5', 'Finished Good', true);
		List<ToroGenModelBOM.StockOrder> optionGroupList = new List<ToroGenModelBOM.StockOrder>{so2,so1,so3,so4,so5,so6};
		optionGroupList.sort();
	}
	
}