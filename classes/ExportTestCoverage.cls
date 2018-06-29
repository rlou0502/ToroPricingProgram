public class ExportTestCoverage{
    private Set<String> cpqClasses = new Set<String> {
		'CMnQuoteUtil',
		'CMnWAPluginFormatNumberQuoteItem',
		'CMnWAPluginFormatNumberStrategy4',
		'CMnWAPluginFormatNumberStrategy5',
		'FieldSetMember',
		'KMnQuoteLifeCycleAbandoned',
		'KMnQuoteLifeCycleClosedLost',
		'KMnQuoteLifeCycleSelectPriceProgram',
		'PP_CreateQIExtension',
		'PP_CreateQISLExtension',
		'PP_PricingProgramDelete',
		'PP_QuoteItemDelete',
		'PP_QuoteItemSublineDelete',
		'PP_UpdateQIExtension',
		'PP_UpdateQISLExtension',
		'QuoteItem',
		'ToroBaseWithValueDollarHelper',
		'ToroCacheManager',
		'ToroCacheManagerTest',
		'ToroChartABPricingProgramHelper',
		'ToroChartWithAccessoryDiscount',
		'ToroContractChartPPHelper',
		'ToroContractPriceListPPHelper',
		'ToroContractQuantityPPHelper',
		'ToroCustomExceptionData',
		'ToroDefaultPricingProgramHelper',
		'ToroExportToExcelMultipleSheets',
		'ToroGenModelBOM',
		'ToroGSAPricingProgramHelper',
		'ToroKemperSportsPricingProgramHelper',
		'ToroLargePackagePricingProgramHelper',
		'ToroLargePackageSTIHelper',
		'ToroNationAccountNAFPPHelper',
		'ToroNationalAccountArmyHelper',
		'ToroNationalAccountGSAPPHelper',
		'ToroNationalAccountPricingProgramHelper',
		'ToroNTController',
		'ToroNTData',
		'ToroPerformancePartCache',
		'ToroPerformancePartPricingProgramHelper',
		'ToroPostConfigPricingHook',
		'ToroPriceProgramFactory',
		'ToroPricingHook',
		'ToroPricingMethodData',
		'ToroPricingMethodHelper',
		'ToroPricingProgram',
		'ToroPricingProgramCache',
		'ToroPricingProgramController',
		'ToroPricingProgramData',
		'ToroPricingProgramEligibility',
		'ToroPricingProgramHelperCache',
		'ToroPricingProgramInfoBoxController',
		'ToroPricingProgramLineProdSel',
		'ToroPricingProgramProdSel',
		'ToroPricingProgramUtil',
		'ToroProductEligibilityPlugin',
		'ToroQIBase',
		'ToroQIExtensionCreatedBatch',
		'ToroQISLExtensionCreatedBatch',
		'ToroQuoteCache',
		'ToroSecondaryPricingProgram',
		'ToroSelectOption',
		'ToroSObjectResultSet',
		'ToroSouthernDemoPricingProgramHelper',
		'ToroSouthernDemoSecondaryPricingProgram',
		'ToroStateContractPricingProgramHelper',
		'ToroStateContractQtyModelHelper',
		'ToroSupportPlusController',
		'ToroSupportPlusData',
		'ToroSupportPlusHelper',
		'ToroSupportPlusItem',
		'ToroTestData' };
    public CoverageWrap cw {get;set;}
    public ExportTestCoverage(){
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(URL.getSalesforceBaseURL().toExternalForm()+'/services/data/v33.0/tooling/query/?q=Select+id,ApexClassorTrigger.Name,NumLinesCovered,NumLinesUncovered+from+ApexCodeCoverageAggregate');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200){
            cw  = (CoverageWrap)JSON.deserialize(res.getBody(),CoverageWrap.class);
            system.debug('cw  '+cw  );
            List<Records> rs = new List<Records>();
            for(Records r : cw.records) {
                if(cpqClasses.contains(r.ApexClassOrTrigger.Name)) {
                	rs.add(r);    
                }    
            }
            cw.records = rs;
            cw.records.sort();
        }
    }
    
    public class Attributes {
        public String type;
        public String url;
    }

    public class Records implements Comparable {
        public Attributes attributes;
        public String Id;
        public ApexClassOrTrigger ApexClassOrTrigger {get;set;}
        public Integer NumLinesCovered {get;set;}
        public Integer NumLinesUncovered {get;set;}
        public Integer compareTo(Object compareTo) {
            Records compareToObj = (Records) compareTo;
            return this.ApexClassOrTrigger.Name.compareTo(compareToObj.ApexClassOrTrigger.Name);
        }
    }

    public class ApexClassOrTrigger {
        public Attributes attributes;
        public String Name{get;set;}
    }
    
    public class CoverageWrap{
        public Integer size;
        public Integer totalSize;
        public Boolean done;
        public Object queryLocator;
        public String entityTypeName;
        public List<Records> records{get;set;}
    }
}