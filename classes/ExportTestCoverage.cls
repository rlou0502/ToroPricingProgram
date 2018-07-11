public class ExportTestCoverage{
    private Set<String> cpqClasses = new Set<String> {
		'CMnQuoteUtil',
        'CMnQuoteUtilTest',
        'CMnWAPluginFormatNumberQuote',
        'FieldSetMember',
        'FieldSetMemberTest',
        'KMnQuoteLifeCycleAbandoned',
        'KMnQuoteLifeCycleClosedLost',
        'KMnQuoteLifeCycleSelectPriceProgram',
        'PP_UpdateExtensionTest',
        'PP_CanadianCurrencyChange',
		'PP_CreateQIExtension',
		'PP_CreateQISLExtension',
		'PP_PricingProgramDelete',
		'PP_QIExtensionCreated',
		'PP_QISLExtensionCreated',
		'PP_QuoteCloningDone',
		'PP_QuoteItemDelete',
		'PP_QuoteItemSublineDelete',
		'PP_Stratgy4Update',
		'PP_Stratgy5Update',
		'PP_UpdateQIExtension',
		'PP_UpdateQISLExtension',
		'PP_UpdateStrategy1',
        'QuoteItem',
        'QuoteItemTest',
        'ToroBaseAwardAccessoryHelper',
        'ToroBaseWithValueDollarHelper',
        'ToroBaseWithValueDollarHelperTest',
        'ToroCacheManager',
        'ToroCascadingDeleteTest',
        'ToroChartABPricingProgramHelper',
        'ToroChartABPricingProgramHelperTest',
        'ToroContractChartPPHelper',
        'ToroContractChartPPHelperTest',
        'ToroContractPriceListPPHelper',
        'ToroContractPriceListPPHelperTest',
        'ToroContractQuantityPPHelper',
        'ToroContractQuantityPPHelperTest',
        'ToroCustomExceptionData',
        'ToroDefaultPricingProgramHelper',
        'ToroExportToExcelMultipleSheets',
        'ToroFirstTeePricingProgramHelper',
        'ToroGSAPricingProgramHelper',
        'ToroGenModelBOM',
        'ToroInfoBoxResultSet',
        'ToroKemperSportsPricingProgramHelper',
        'ToroKemperSportsPricingProgramHelperTest',
        'ToroLargePackagePricingProgramHelper',
        'ToroLargePackagePricingProgramHelperTest',
        'ToroNTController',
        'ToroNTControllerTest',
        'ToroNTData',
        'ToroNTDataTest',
        'ToroNationAccountNAFPPHelper',
        'ToroNationAccountNAFPPHelperTest',
        'ToroNationalAccountArmyHelper',
        'ToroNationalAccountArmyHelperTest',
        'ToroNationalAccountGSAPPHelper',
        'ToroNationalAccountGSAPPHelperTest',
        'ToroNationalAccountPricingProgramHTest',
        'ToroNationalAccountPricingProgramHelper',
        'ToroPerformancePartCache',
        'ToroPerformancePartPricingProgramHTest',
        'ToroPerformancePartPricingProgramHelper',
        'ToroPriceProgramFactory',
        'ToroPriceProgramFactoryTest',
        'ToroPricingHook',
        'ToroPricingMethodData',
        'ToroPricingMethodDataTest',
        'ToroPricingMethodHelper',
        'ToroPricingMethodHelperTest',
        'ToroPricingProgram',
        'ToroPricingProgramCache',
        'ToroPricingProgramCacheTest',
        'ToroPricingProgramController',
        'ToroPricingProgramControllerTest',
        'ToroPricingProgramData',
        'ToroPricingProgramDataTest',
        'ToroPricingProgramEligibility',
        'ToroPricingProgramEligibilityTest',
        'ToroPricingProgramHelperCache',
        'ToroPricingProgramInfoBoxController',
        'ToroPricingProgramInfoBoxControllerTest',
        'ToroPricingProgramLineProdSel',
        'ToroPricingProgramLineProdSelTest',
        'ToroPricingProgramProdSel',
        'ToroPricingProgramProdSelTest',
        'ToroPricingProgramTest',
        'ToroPricingProgramUtil',
        'ToroPricingProgramUtilTest',
        'ToroProductEligibilityPlugin',
        'ToroProductEligibilityPluginTest',
        'ToroQIBase',
        'ToroQIBaseTest',
        'ToroQIExtensionCreatedBatch',
        'ToroQISLExtensionCreatedBatch',
        'ToroQuoteCache',
        'ToroQuoteItemEmailController',
        'ToroQuoteItemExtensionHandler',
        'ToroSObjectResultSet',
        'ToroSecondaryPricingProgram',
        'ToroSelectOption',
        'ToroSelectPriceProgramController',
        'ToroSouthernDemoPricingProgramHelper',
        'ToroSouthernDemoPricingProgramHelperTest',
        'ToroSouthernDemoSecondaryPricingProgram',
        'ToroStateContractPricingProgramHTest',
        'ToroStateContractPricingProgramHelper',
        'ToroStateContractQtyModelHelper',
        'ToroStateContractQtyModelHelperTest',
        'ToroSupportPlusController',
        'ToroSupportPlusControllerTest',
        'ToroSupportPlusData',
        'ToroSupportPlusDataTest',
        'ToroSupportPlusHelper',
        'ToroSupportPlusHelperTest',
        'ToroSupportPlusItem',
        'ToroSupportPlusItemTest',
        'ToroTestData',
        'ToroTriggerRunOnce',
        'Toro_UpdateData',
        'ToroBaseAwardAccessoryHelperTest',
        'ToroCacheManagerTest',
        'ToroExportToExcelMultipleSheetsTest',
        'ToroStateContractModelQtyHelper' };
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