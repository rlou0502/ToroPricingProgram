global class ToroProductEligibilityPlugin implements revvy.IMnProductEligibilityPlugin {
	public ToroProductEligibilityPlugin() {
		
	}
	/*********************************************************************************************
    * @description Indicate that plugin wants to fully override product exclusion logic
    * @return Boolean
    **********************************************************************************************/
    public Boolean isFullOverride(){
        return true;
    }
    public revvy.CMnProductEligibilityResultParams getProductEligibility(Map<String,Object> inputParams) {
          Map<String,Set<ID>> prodEligMap = getEligibleProdsAndCategory(inputParams);
          revvy.CMnProductEligibilityResultParams resultParams = new revvy.CMnProductEligibilityResultParams();
          resultParams.prodEligMap = prodEligMap;
          resultParams.considerInclusions = inputParams.get('considerInclusions') != null ? (boolean) inputParams.get('considerInclusions') : false;
          return resultParams;
    }
    /*********************************************************************************************
    * @description Give opportunity to the plugin to make changes to the product and category exclusion list.
    * @param Map<String,Object> inputParams
    * @return Map<String,Set<ID>>
    **********************************************************************************************/    
    public Map<String,Set<ID>> getEligibleProdsAndCategory(Map<String,Object> inputParams){
    	ID quoteId = inputParams.get('objectId') != null ? (ID) inputParams.get('objectId') : null;
        Id configItemOrSolId = inputParams.get('configItemOrSolId') != null ? (Id) inputParams.get('configItemOrSolId') : null;
        system.debug('configItemOrSolId---' + configItemOrSolId);
        system.debug('++++++++++++++ quote id =' + quoteId);
        Revvy__MnQuote__c qt = [select id, REVVY__Account__c, REVVY__Price_Date__c, REVVY__Channel__c,
        						REVVY__PriceCountry__c, REVVY__Segment__c, REVVY__Currency__c from Revvy__MnQuote__c where id = :quoteId];
        Id accountId = qt.REVVY__Account__c;
        Date priceDate = qt.REVVY__Price_Date__c;
        String qtChannel = qt.REVVY__Channel__c;
        String qtCountry = qt.REVVY__PriceCountry__c;
        String qtSegment = qt.REVVY__Segment__c;
        String qtCurrency = qt.REVVY__Currency__c;
        //system.debug('price date = ' + priceDate);
        //system.debug('qtChannel = ' + qtChannel);
        //system.debug('qtCountry = ' + qtCountry);
        //system.debug('qtSegment = ' + qtSegment);
        //system.debug('qtCurrency = ' + qtCurrency);
        List<revvy__MnPriceListLine__c> plis = [SELECT Id, revvy__ListedPrice__c,revvy__PricingTier__c ,revvy__CostPrice__c,revvy__PriceList__r.name,
                            revvy__FloorPrice__c,revvy__SuggestedPrice__c,revvy__PriceList__r.revvy__Priority__c, revvy__product__c, revvy__product__r.revvy__Id__c, revvy__product__r.name,
                            revvy__PriceList__r.revvy__Account__c, revvy__PriceList__r.revvy__Contract__c FROM revvy__MnPriceListLine__c  
                            WHERE revvy__product__r.revvy__type__c IN ('Product', 'Bundle') AND 
                            revvy__product__r.revvy__effective_start_date__c <= TODAY AND 
                            revvy__product__r.revvy__effective_end_date__c >= TODAY AND 
                            revvy__product__r.revvy__status__c = 'Active' AND
                            revvy__start_date__c <= :priceDate AND revvy__end_date__c >= :priceDate AND
                            revvy__PriceList__c IN (SELECT Id FROM revvy__MnPriceList__c WHERE  
                            revvy__Status__c='Active' AND  revvy__start_date__c <= :priceDate AND 
                            revvy__end_date__c >= :priceDate AND (revvy__Account__c= :accountId OR  
                            (revvy__PriceType__c='Price List' AND revvy__Channel__c = :qtChannel AND 
                            revvy__Country__c = :qtCountry )) AND revvy__segment__c = :qtSegment   )];
        Set<Id> prodIds = new Set<Id>();
        for(revvy__MnPriceListLine__c pli : plis) {
        	//system.debug('price list =' + pli.revvy__PriceList__r.name + ' product = ' + pli.revvy__product__r.revvy__Id__c + ' product id=' + pli.revvy__product__r.name);
        	prodIds.add(pli.revvy__product__c);	
        }
        Map<String,Set<ID>> prodElig = new Map<String,Set<ID>>();
        Set<ID> OOBprodExclusion = (Set<ID>) inputParams.get('ExProductIds');
      	Set<ID> OOBcategoryExclusion = (Set<ID>) inputParams.get('ExCategoryIds');
      	Set<ID> OOBprodInclusion = (Set<ID>) inputParams.get('InProductIds');
      	Set<ID> OOBcategoryInclusion = (Set<ID>) inputParams.get('InCategoryIds');
      	OOBprodInclusion.addAll(prodIds);
        for(REVVY__MnCatalogNode__c p : [select id FROM REVVY__MnCatalogNode__c where REVVY__Type__c='Solution']) {
        	OOBprodInclusion.add(p.Id);   
        }
        
        for(Revvy__MnCatalogNode__c c : [select Id from Revvy__MnCatalogNode__c where Revvy__Id__c in ('GM','RM','TPP','WKM','Ally','WGTXGas','RM5010','WGTXGas1','GM32802D')]) {
        	OOBcategoryInclusion.add(c.Id);	
        }
        for(Revvy__MnCatalogNode__c p : [select Id from Revvy__MnCatalogNode__c where Revvy__Id__c in ('30344')]) {
        	OOBprodInclusion.add(p.Id);	
        }
        /*
      	OOBcategoryInclusion.add('a2A2F0000004YSI'); //GM
      	OOBcategoryInclusion.add('a2A2F0000004YSw'); //RM
      	OOBcategoryInclusion.add('a2A2F0000004fiq'); //TPP
      	OOBcategoryInclusion.add('a2A2F0000004hFM'); //WKM
      	//OOBcategoryInclusion.add('a2A2F0000004cDo'); //Ally
      	
      	OOBcategoryInclusion.add('a2A2F0000004cDoUAI'); //Ally
      	OOBcategoryInclusion.add('a2A2F0000004cCRUAY'); //WGTXGas
      	OOBcategoryInclusion.add('a2A2F00000056gcUAA'); //RM5010
      	OOBcategoryInclusion.add('a2A2F0000004SR9UAM'); //30344
      	
      	OOBcategoryInclusion.add('a2A2F0000005S3JUAU'); //WGTXGas1
      	OOBcategoryInclusion.add('a2A2F0000005S34UAE'); //GM32802D
        */
      	
      	prodElig.put('ExProductIds', OOBprodExclusion );
      	prodElig.put('ExCategoryIds', OOBcategoryExclusion );
      	prodElig.put('InProductIds', OOBprodInclusion );
      	prodElig.put('InCategoryIds', OOBcategoryInclusion );

    	return prodElig;
    }
}