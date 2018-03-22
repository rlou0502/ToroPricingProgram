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
private class ToroPricingProgramControllerTest {
	@testSetup static void setupData() {
		CMnQuoteUtil.setupData();
		
	}
    static testMethod void myUnitTest() {
    	Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
    	List<Revvy__MnStrategy4__c> quoteItems= [select Id from Revvy__MnStrategy4__c];
    	List<Revvy__MnStrategy5__c> quoteItemSublines= [select Id from Revvy__MnStrategy5__c];
        Map<String, Map<String, object>> qiData = new Map<String, Map<String, object>>{
        	quoteItems[0].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Off_MSRP_Overridden__c'=>'false',
        		'Award_Price__c'=>'7206.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},	
        	quoteItems[1].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Off_MSRP_Overridden__c'=>'false',
        		'Award_Price__c'=>'19988.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItems[2].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Off_MSRP_Overridden__c'=>'false',
        		'Award_Price__c'=>'218.0486',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItems[3].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Off_MSRP_Overridden__c'=>'false',
        		'Award_Price__c'=>'900.13',
        		'Unit_Award_Overridden__c'=>'false'     			
        	}
        };
        Map<String, Map<String, object>> qisData = new Map<String, Map<String, object>>{
        	quoteItemSublines[0].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'7206.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},	
        	quoteItemSublines[1].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'19988.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[2].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'218.0486',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[3].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Off_MSRP_Overridden__c'=>'false',
        		'Award_Price__c'=>'900.13',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[4].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'7206.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},	
        	quoteItemSublines[5].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'19988.43',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[6].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'218.0486',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[7].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'900.13',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[8].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'218.0486',
        		'Unit_Award_Overridden__c'=>'false'     			
        	},
        	quoteItemSublines[9].Id=>new Map<String, object>{
        		'PricingMethodValue__c'=>'23',
        		'Award_Price__c'=>'900.13',
        		'Unit_Award_Overridden__c'=>'false'     			
        	}
        };
        String qiDataJson = Json.serialize(qiData);
        String qisDataJson = Json.serialize(qisData);
        Map<String, object> values= new Map<String, object>{
        	'performancePart'=>false,
        	'pricingMethod'=>'% off MSRP',
        	'pricingProgram'=>'MarketSupportChartLargePackage;Large_Package',
        	'quoteId'=>quote.Id,
        	'setupFeePercent'=>0
        };
        ToroPricingProgramController.svc_updateQuoteData2(values, qiDataJson, qisDataJson, false);
        values.put('pricingMethod','% of DNET');
        ToroPricingProgramController.svc_updateQuoteData2(values, qiDataJson, qisDataJson, false);
        values.put('pricingMethod','% of Gross Profit Margin');
        ToroPricingProgramController.svc_updateQuoteData2(values, qiDataJson, qisDataJson, false);
        values.put('pricingMethod','Total Award Price');
        ToroPricingProgramController.svc_updateQuoteData2(values, qiDataJson, qisDataJson, false);
        ToroPricingProgramController.setPricingProgramMethodRemote(quote.Id,'Buyboard;Base','% off MSRP');
    }       
    static testMethod void myUnitTest2() {
    	Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        
        ToroSObjectResultSet rs = ToroPricingProgramController.setTotalAwardDollarPMRemote(quote.Id, 'MarketSupportChartLargePackage;Large_Package', '% off MSRP', 32000, false);
    	ToroPricingProgramController.setGPPercentRemote(quote.Id, 'MarketSupportChartLargePackage;Large_Package', '% off MSRP', 19, false);
    	ToroPricingProgramController.savePricingProgramMethodRemote(quote.Id, 'MarketSupportChartLargePackage;Large_Package', '% off MSRP', 1, false);
    	//savePricingProgramMethodRemote
    	ToroPricingProgramController.setPricingProgramMethodRemote(quote.Id, 'MarketSupportChartLargePackage;Large_Package', '% off MSRP');
    	ToroPricingProgramController.getQuoteHeaderFields('MarketSupportChartLargePackage;Large_Package', quote.Id);
    	ToroPricingProgramController.getQuoteItemFields('MarketSupportChartLargePackage;Large_Package', '% off MSRP', quote.Id);
    	ToroPricingProgramController.addUpdatableFieldSetMember(SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_Quote_Line_Summary_Cols.getFields(),
    		SObjectType.Revvy__MnStrategy4__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields());
    
    }    
    static testMethod void myUnitTest3() {
    	Revvy__MnQuote__c quote = [select Id from Revvy__MnQuote__c limit 1];
        ToroPricingProgramController.svc_clearDirtyQuoteItem(quote.Id);
        ToroPricingProgramController.svc_getPricingMethodOptions(quote.Id, 'MarketSupportChartLargePackage;Large_Package');
        ToroPricingProgramController.svc_setPricingMethodValue(quote.Id, null, 'MarketSupportChartLargePackage;Large_Package', '% off MSRP', '23');
       	ToroPricingProgramController.svc_setPricingMethodValue(quote.Id, null, 'MarketSupportChartLargePackage;Large_Package', '% of DNET', '117');
       	ToroPricingProgramController.svc_setPricingMethodValue(quote.Id, null, 'MarketSupportChartLargePackage;Large_Package', 'Gross Profit %', '18');
       	ToroPricingProgramController.svc_setPricingMethodValue(quote.Id, null, 'MarketSupportChartLargePackage;Large_Package', 'Total Award $', '2300');
       	
    }        
}