public class ToroPricingProgramController {
	public static final String defaultPricingMethod='% off MSRP';
	public static final String constCachedQuoteId = 'quoteId';
	public static final String constCachedSetupFee = 'setupFee';
    public Id quoteId {get; set;}
    public boolean readOnly {get; set;} 
    public ToroPricingProgramController() {
    	readOnly = false;
    	try{
    		readOnly = boolean.valueOf(ApexPages.currentPage().getParameters().get('readOnly'));	
    	} catch(Exception e) {    		
    	}
    	quoteId = ApexPages.currentPage().getParameters().get('id');
    	//if(!Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).contains(ToroPricingProgramController.constCachedQuoteId)){
    		Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).put(ToroPricingProgramController.constCachedQuoteId, quoteId);
    	//}
    }

    @AuraEnabled
    public static void svc_clearDirtyQuoteItem(Id quoteId) {
    	System.debug('>>> svc_clearDirtyQuoteItem 111 quoteId='+quoteId);
    	delete [Select Id From REVVY__MnQuoteItem__c where REVVY__Quote__c =:quoteId and Dirty__c = true];
    	System.debug('>>> svc_clearDirtyQuoteItem 222 quoteId='+quoteId);
    }


    @AuraEnabled
    public static ToroSObjectResultSet svc_getPricingMethodOptions(Id quoteId, String pricingProgram) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	rs.selectedPricingProgram = pricingProgram;
    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    	List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
		rs.pricingMethodOptions = options;
		if(options.size() == 1) {
			rs.selectedPricingMethod = options[0].value;
		} else {
			rs.selectedPricingMethod = '% off MSRP';
		}
		system.debug('svc_getPricingMethodOptions pricingProgram=' + pricingProgram);

		rs.allowSupportPlus = pp.getAllowSupportPlus(pricingProgram);
		system.debug('rs.allowSupportPlus=' + rs.allowSupportPlus);
		rs.displayPerformancePart = pp.displayPerformancePart();
		rs.displaySetupFee=pp.displaySetupFee();
		rs.contractMessage = pp.displayContractMessage(pricingProgram);
    	return rs;
    }

	
    @AuraEnabled
    public static ToroSObjectResultSet svc_updateQuoteData2(Map<String, Object> values, String quoteItemsDataJSON, String qiSublinesDataJSON, boolean save) {
    	system.debug('***************** svc_updateQuoteData2' );
    	//Id quoteId, Id qiId, String pricingProgram,
    	//String pricingMethod, decimal setupFeePercent, boolean performancePart,
		System.debug('values: ' + values); 
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	if(values == null) {
    		rs.result=false;
    		return rs;
    	}
    	try{
	    	String pricingMethod = (String) values.get('pricingMethod');
	    	String pricingProgram = (String) values.get('pricingProgram');
	    	rs.selectedPricingMethod = pricingMethod;
	    	rs.selectedPricingProgram = pricingProgram;
	    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
	    	Id quoteId = (Id) values.get('quoteId');
	    	Id qiId = (Id) values.get('qiId');
	    	decimal setupFeePercent = null;
	    	if(values.get('setupFeePercent') != null) {
	    		setupFeePercent = (Decimal)values.get('setupFeePercent');
	    	}
	    	boolean performancePart = false;
	    	if(values.get('performancePart') != null) {
	    		performancePart = (Boolean)values.get('performancePart');
	    	}
	    	boolean setupFeeOverride = false;
	    	if(values.get('setupFeeOverride') != null) {
	    		setupFeeOverride = (Boolean)values.get('setupFeeOverride');
	    	}
	    	ToroPricingProgramData ppd = new ToroPricingProgramData(rs.selectedPricingProgram);
	    	rs.currentQuoteItem = qiId;
			ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
			system.debug('ppd =' + ppd); 
			Revvy__MnStrategy1__c pricingProgramData = ToroCacheManager.getPricingProgram(ppd.externalId);
			
			pp.performancePartFlag = performancePart != null ? performancePart : false;
			pp.setupFeePercentage = setupFeePercent;
			System.debug('pricingProgram=' +pricingProgram);
			System.debug('pricingMethod=' +pricingMethod);
			System.debug('quoteItemsDataJSON=' +quoteItemsDataJSON);
			System.debug('qiSublinesDataJSON=' +qiSublinesDataJSON);
			system.debug('values=' + values);
			Map<String, object> quoteItemsData = (Map<String, object>) JSON.deserializeUntyped(quoteItemsDataJSON);
			for(String key : quoteItemsData.keyset()) {
				Map<String, Object>	data1 = (Map<String, Object>) quoteItemsData.get(key);
				system.debug('key =' + key + ' obj =' + data1);
				for(String key2 : data1.keyset()) {
					String	data2 = (String) data1.get(key2);
					system.debug('key2 =' + key2 + ' obj =' + data2);
				}
			}
			Map<String, object> qiSublinesData = (Map<String, object>) JSON.deserializeUntyped(qiSublinesDataJSON);
	
			system.debug('quoteItemsData=' + quoteItemsData);
			system.debug('qiSublinesData=' + qiSublinesData);
			system.debug('setPricingMethodValueRemote pp=' + pp);
			List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
			rs.pricingMethodOptions = options;
			system.debug('setPricingMethodValueRemote options=' + options);
			//if there is only one pricing method + "Please select" item, auto apply it
			pp.initialize(quoteId);
			pp.quote.Pricing_Program_Name__c=pricingProgram;
			pp.quote.Pricing_Program__c=pricingProgramData.Name;
			pp.quote.Setup_Fee_Overridden__c=setupFeeOverride;
			if(pricingProgramData != null) {
				pp.quote.Contract_Number__c = pricingProgramData.Contract_Number__c;
				pp.quote.Pricing_Program_Type__c = pricingProgramData.PricingProgramType__c;
			}
			
			pp.quote.Price_Method__c=pricingMethod;
			
			if(pp.displaySetupFee()) {
    			system.debug('setupfee--displaySetupFee -- ' + pp.quote.Setup_Fee__c);
    			pp.quote.Setup_Fee__c = setupFeePercent;
    			if(pp.quote.Setup_Fee__c == null) {
    				Revvy__MnStrategy1__c program = ToroCacheManager.getPricingProgram(ppd.externalId);	
    				pp.quote.Setup_Fee__c = program.Setup_Fee__c;
    				system.debug('setupfee--displaySetupFee --program.Setup_Fee__c ' + program.Setup_Fee__c);
    				system.debug('setupfee--displaySetupFee --quote= ' + pp.quote.Setup_Fee__c);
    			}
    		}
	    		
			//pp.quote.Setup_Fee__c = setupFeePercent;
			pp.quote.Performance_Part__c=performancePart;
			
			for(Revvy__MnStrategy4__c qi : pp.quoteItems) {
				//if(pp.performancePartFlag && qi.Performance_Parts_Product__c) {
				//	qi.FreezeLine__c = true;
				//}
				system.debug(logginglevel.info,'checkpoint 4 qi.Award_of_DN__c =' + qi.Award_of_DN__c + ' sku =' + qi.Product_Name__c);
				qi.Select_a_Price_Method__c = pricingMethod;
				Map<String, Object> qiUpdateData = 	(Map<String, Object>) quoteItemsData.get(qi.Id);
				system.debug(logginglevel.info, 'qiUpdateData =' + qiUpdateData);
				if(qiUpdateData != null) {
					for(String key : qiUpdateData.keyset()) {
						system.debug(logginglevel.info, 'key =' + key);
						String strVal = (String)qiUpdateData.get(key);
						system.debug(logginglevel.info, '1 strVal =' + strVal);
						//qi.PricingMethodValue__c=null;
						system.debug(logginglevel.info, '2 strVal =' + strVal);
						if('PricingMethodValue__c'.equalsIgnoreCase(key)){
							system.debug(logginglevel.info, '3 key =' + key);
							qi.PricingMethodValue__c = strVal;
							system.debug(logginglevel.info, '3 pricingMethod =' + pricingMethod);
							if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
				    			qi.Award_of_DN__c = string.isNotBlank(strVal) ? Double.valueOf(strVal) : null;
				    			system.debug(logginglevel.info, '3 % of DNET =' + qi.Award_of_DN__c);
				    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
				    			qi.Off_MSRP__c =  string.isNotBlank(strVal) ? Double.valueOf(strVal) : null;
				    			system.debug(logginglevel.info, '3 qi.Off_MSRP__c =' + qi.Off_MSRP__c);
				    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
				    			qi.Toro_Gross_Profit_Percent__c =  string.isNotBlank(strVal) ? Double.valueOf(strVal) : null;
				    		} else if ('Total Award $'.equalsIgnoreCase(pricingMethod)) {
				    			//qi.Award_Price__c = string.isNotBlank(strVal) ? decimal.valueOf(strVal) : null;
				    			qi.Total_Toro_Award__c = string.isNotBlank(strVal) ? decimal.valueOf(strVal) : null;
				    		}
						} else if('Award_Price__c'.equalsIgnoreCase(key)){
							system.debug('---------------Award_Price__c =' + strVal);
	
							qi.Award_Price__c = string.isNotBlank(strVal) ? decimal.valueOf(strVal) : null;
	
						} else if('Unit_Award_Overridden__c'.equalsIgnoreCase(key)){
							qi.Unit_Award_Overridden__c=false;
							system.debug('---------------Unit_Award_Overridden__c =' + strVal);
							qi.Unit_Award_Overridden__c = string.isNotBlank(strVal) ? boolean.valueOf(strVal) : false;
	
						} else if('Off_MSRP_Overridden__c'.equalsIgnoreCase(key)){
							qi.Off_MSRP_Overridden__c = string.isNotBlank(strVal) ? boolean.valueOf(strVal) : false;
	
						} else if('Pricing_Program__c'.equalsIgnoreCase(key)) {
							system.debug('Pricing_Program__c = ' + key + ' value =' + strVal);
							qi.Pricing_Program__c = strVal;
						} else if('Pricing_Program_Overridden__c'.equalsIgnoreCase(key)) {
							qi.Pricing_Program_Overridden__c = string.isNotBlank(strVal) ? boolean.valueOf(strVal) : false;
						}
	
					}
	
				}
				if(!performancePart) {
					qi.Performance_Parts_Product__c = false;
				}
				system.debug('display qi=' + qi.PricingMethodValue__c );
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						//if(pp.performancePartFlag && qis.Performance_part__c) {
						//	qis.FreezeLine__c = true;
						//}
						//qis.PricingMethodValue__c=null;
						Map<String, Object>  qisUpdateData = (Map<String, Object>) qiSublinesData.get(qis.id);
						if(qisUpdateData != null) {
							for(String key : qisUpdateData.keyset()) {
								String strVal = (String)qisUpdateData.get(key);
								if(string.isNotBlank(strVal)) {
									if('PricingMethodValue__c'.equalsIgnoreCase(key)){
										qis.PricingMethodValue__c = strVal;
										if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
							    			qis.Percent_of_DNet__c = Double.valueOf(strVal);
							    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
							    			qis.Percent_Off_MSRP__c = Double.valueOf(strVal);
							    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
							    			qis.Gross_Profit_Percent__c = Double.valueOf(strVal);
							    		} else if ('Total Award $'.equalsIgnoreCase(pricingMethod)) {
							    			qis.Award_Price__c = decimal.valueOf(strVal);
							    		}
									} else if('Award_Price__c'.equalsIgnoreCase(key)){
										qis.Award_Price__c = decimal.valueOf(strVal);
									} else if('Unit_Award_Overridden__c'.equalsIgnoreCase(key)){
										qis.Unit_Award_Overridden__c = boolean.valueOf(strVal);
									}
								}
							}
						}
						system.debug('display qis=' + qis.PricingMethodValue__c );
						if(!performancePart) {
							qis.Performance_Part__c = false;
						}
					}
	    		}
			}
	
			
			rs = retrieveFieldSets(rs, pp, pricingMethod, pricingProgram);
			system.debug(logginglevel.info, 'entering---calculateRebateMargin');
	    	pp.quoteItems = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, save);
	    	system.debug(logginglevel.info, 'pricingMethod =' + pricingMethod);
	    	if ('Total Award $'.equalsIgnoreCase(pricingMethod)) {
	    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
	    			qi.PricingMethodValue__c = String.valueOf(qi.Total_Toro_Award__c);	
	    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.PricingMethodValue__c = String.valueOf(qis.Award_Price__c);	
						}
	    			}
					
				}
	    	}
	    	if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
	    			qi.PricingMethodValue__c = String.valueOf(qi.Toro_Gross_Profit_Percent__c);	
	    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.PricingMethodValue__c = String.valueOf(qis.Gross_Profit_Percent__c);	
						}
	    			}
					
				}
	    	}
	    	if ('% of DNET'.equalsIgnoreCase(pricingMethod)) {
	    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
	    			qi.PricingMethodValue__c = String.valueOf(qi.Award_of_DN__c);	
	    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.PricingMethodValue__c = String.valueOf(qis.Percent_of_DNet__c);	
						}
	    			}
					
				}
	    	}
	    	if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
	    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
	    			qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);	
	    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);	
						}
	    			}
					
				}
	    	}
	    	system.debug(logginglevel.info, 'exiting---calculateRebateMargin');
	    	//pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
	    	/*
	    	for(Revvy__MnStrategy4__c qi : pp.quoteItems) {
	    		system.debug('display qi=' + qi.PricingMethodValue__c );
	    		for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
	    			system.debug('display qis=' + qis.PricingMethodValue__c );
	    		}
	    	}
	    	*/
	    	for(FieldSetMember fs : rs.fieldSetMembers) {
	    		if(fs.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			fs.label = rs.selectedPricingMethod;
	    		}
	    	}
	    	for(FieldSetMember fss : rs.fieldSetSubMembers) {
	    		if(fss.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			fss.label = rs.selectedPricingMethod;
	    		}
	    	}
	    	ToroCacheManager.putQuote(pp.quote);
	    	
	    	rs.quote = pp.quote;
	    	system.debug('setupfee--pp.setupFeePercentage=' + pp.setupFeePercentage);
	    	system.debug('setupfee--setupFeePercent=' + setupFeePercent);
	    	system.debug('setupfee--pp.quote.Setup_Fee__c=' + pp.quote.Setup_Fee__c);
	    	system.debug('setupfee--rs.quote.Setup_Fee__c=' + rs.quote.get('Setup_Fee__c')); 
	    	rs.values =  pp.quoteItems;
	    	rs.chainCall = pp.chainCall;
	    	rs.payload = pp.payloadOfChainCall;
	    	rs.displaySetupFee=pp.displaySetupFee();
	    	rs.allowSupportPlus = pp.getAllowSupportPlus(pricingProgram);
	    	List<String> spKeys = new List<String>();
	    	system.debug(logginglevel.info, 'ppd.externalId---calculateRebateMargin' + ppd.externalId);
			if(String.isNotBlank(ppd.externalId)) {
		    	Map<String, Object > secondaryPrograms = pp.retrieveSecondaryPrograms(ppd.externalId);
		    	for(String key : secondaryPrograms.keyset()) {
		    		spKeys.add(key);
		    	}
		
		    	if(spKeys.size() > 0) {
		    		rs.secondaryPrograms = secondaryPrograms;
		    		rs.secondaryProgramKeys = spKeys;
		    	}
			}
		
    	} catch (Exception e) {
    		System.debug(logginglevel.error, e);
    		System.debug(logginglevel.error, e.getStackTraceString());
    		ToroCustomExceptionData data = new ToroCustomExceptionData(e.getStackTraceString(), e.getMessage());
    		throw new AuraHandledException(JSON.serialize(data));
    	}
    	return rs;
    }

    @AuraEnabled
    public static ToroSObjectResultSet svc_setPricingMethodValue(Id quoteId, Id qiId, String pricingProgram, String pricingMethod, string value) {
    	system.debug('***************** svc_setPricingMethodValue' );
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	rs.selectedPricingMethod = pricingMethod;
    	rs.selectedPricingProgram = pricingProgram;
    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	rs.currentQuoteItem = qiId;
		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
		system.debug('setPricingMethodValueRemote pp=' + pp);
		List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
		rs.pricingMethodOptions = options;
		system.debug('setPricingMethodValueRemote options=' + options);
		//if there is only one pricing method + "Please select" item, auto apply it
		pp.initialize(quoteId);
		rs = retrieveFieldSets(rs, pp, pricingMethod, pricingProgram);
		
    	List<Revvy__MnStrategy4__c> qis = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, false);
    	pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
    	for(FieldSetMember fs : rs.fieldSetMembers) {
    		if(fs.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			fs.label = rs.selectedPricingMethod;
    		}
    	}
    	for(FieldSetMember fss : rs.fieldSetSubMembers) {
    		if(fss.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			fss.label = rs.selectedPricingMethod;
    		}
    	}
    	rs.values =  pp.quoteItems;
    	rs.displaySetupFee=pp.displaySetupFee();
    	return rs;
    }

	@AuraEnabled
    public static ToroSObjectResultSet setTotalAwardDollarPMRemote(Id quoteId, String pricingProgram, String pricingMethod, decimal awardPrice, boolean performancePart) {
    	system.debug('--------------calling setTotalAwardDollarPMRemote');
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	try {
	    	rs.result=false;
	    	rs.selectedPricingMethod = pricingMethod;
	    	rs.selectedPricingProgram = pricingProgram;
	    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
	    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
	    	if(string.isNotBlank(pricingProgram)) {
	    		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
	    		pp.initialize(quoteId);
	    		pp.performancePartFlag = performancePart != null ? performancePart : false;
	    		pp.quoteItems = ToroPricingMethodHelper.distributeTotalAwardDollors(pp.quoteItems, awardPrice);
	    		rs = retrieveFieldSets(rs, pp, pricingMethod, pricingProgram);
				//system.debug(logginglevel.info, 'entering---calculateRebateMargin');
		    	pp.quoteItems = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, false);
	
		    	pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
		    	for(FieldSetMember fs : rs.fieldSetMembers) {
		    		if(fs.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
		    			fs.label = rs.selectedPricingMethod;
		    		}
		    	}
		    	for(FieldSetMember fss : rs.fieldSetSubMembers) {
		    		if(fss.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
		    			fss.label = rs.selectedPricingMethod;
		    		}
		    	}
		    	pp.quote.Total_Award_Dollars__c = awardPrice;
		    	ToroCacheManager.putQuote(pp.quote);
		    	rs.quote = pp.quote;
		    	rs.values =  pp.quoteItems;
		    	rs.chainCall = pp.chainCall;
		    	rs.payload = pp.payloadOfChainCall;
		    	rs.displaySetupFee=pp.displaySetupFee();
		    	rs.result=true;
	    	}
    	} catch (Exception e) {
    		System.debug(logginglevel.error, e);
    		ToroCustomExceptionData data = new ToroCustomExceptionData(e.getStackTraceString(), e.getMessage());
    		throw new AuraHandledException(JSON.serialize(data));	
    	}
    	return rs;
    }

    @AuraEnabled
    public static ToroSObjectResultSet setGPPercentRemote(Id quoteId, String pricingProgram, String pricingMethod, decimal gpPercent, boolean performancePart) {
    	system.debug('--------------calling setGPPercentRemote');
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	try {
	    	rs.result=false;
	    	rs.selectedPricingMethod = pricingMethod;
	    	rs.selectedPricingProgram = pricingProgram;
	    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
	    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
	    	if(string.isNotBlank(pricingProgram)) {
	    		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
	    		pp.initialize(quoteId);
	    		pp.performancePartFlag = performancePart != null ? performancePart : false;
	    		for (Revvy__MnStrategy4__c qi : pp.quoteItems) {
	    			qi.Toro_Gross_Profit_Percent__c = gpPercent;
	    			qi.PricingMethodValue__c = String.valueOf(gpPercent);
					if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							qis.Gross_Profit_Percent__c = gpPercent;
							qis.PricingMethodValue__c = String.valueOf(gpPercent);
						}
					}
				}
	
	    		rs = retrieveFieldSets(rs, pp, pricingMethod, pricingProgram);
				system.debug(logginglevel.info, 'entering---calculateRebateMargin');
		    	pp.quoteItems = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, false);
	
		    	//pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
		    	for(FieldSetMember fs : rs.fieldSetMembers) {
		    		if(fs.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
		    			fs.label = rs.selectedPricingMethod;
		    		}
		    	}
		    	for(FieldSetMember fss : rs.fieldSetSubMembers) {
		    		if(fss.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
		    			fss.label = rs.selectedPricingMethod;
		    		}
		    	}
		    	pp.quote.Gross_Profit_Percent__c = gpPercent;
		    	ToroCacheManager.putQuote(pp.quote);
		    	rs.quote = pp.quote;
		    	rs.values =  pp.quoteItems;
		    	rs.chainCall = pp.chainCall;
		    	rs.payload = pp.payloadOfChainCall;
		    	rs.displaySetupFee=pp.displaySetupFee();
		    	rs.result=true;
	    	}
    	} catch (Exception e) {
    		System.debug(logginglevel.error, e);
    		ToroCustomExceptionData data = new ToroCustomExceptionData(e.getStackTraceString(), e.getMessage());
    		throw new AuraHandledException(JSON.serialize(data));	
    	}
    	return rs;
    }

    @AuraEnabled
    public static ToroSObjectResultSet savePricingProgramMethodRemote(Id quoteId, String pricingProgram, String pricingMethod, decimal setupFeePercent, boolean performancePart) {
    	system.debug('--------------calling savePricingProgramMethodRemote');
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	update new revvy__MnQuote__c(Id=quoteId, Pricing_Program_Name__c=pricingProgram, Price_Method__c=pricingMethod, Setup_Fee__c=setupFeePercent, Performance_Part__c=performancePart);
    	return rs;
    }

    @AuraEnabled
    public static ToroSObjectResultSet setPricingProgramMethodRemote(Id objId, String pricingProgram, String pricingMethod) {
    	system.debug('***************** setPricingProgramMethodRemote' );
    	system.debug('pricingProgram pricingProgram=' + pricingProgram);
    	Long perfStart2 = System.limits.getCpuTime();
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	rs.selectedPricingProgram = pricingProgram;
    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
    	rs.selectedPricingMethod = pricingMethod;
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);

    	//if(string.isNotBlank(pricingProgram)) {
    		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    		system.debug('pricingProgram pp=' + pp);
    		List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
    		rs.pricingMethodOptions = options;
    		system.debug('setPricingProgramToDB options=' + options);
    		//if there is only one pricing method + "Please select" item, auto apply it
    		pp.initialize(objId);
    		rs = retrieveFieldSets(rs, pp, pricingMethod, pricingProgram);
			
    		if(options.size() ==1) {
    			//pp.calculateRebateMargin();
    			ToroSelectOption so = options[0];
    			system.debug('setPricingProgramToDB calling calculateRebateMargin');
    			//update new Revvy__MnQuote__c(Id = objId, Pricing_Program_Name__c=pricingProgram, Pricing_Program_Type__c=pricingProgram, Price_Method__c=so.value);
    			pp.quote.Pricing_Program_Name__c=pricingProgram;
	    		pp.quote.Pricing_Program_Type__c=pricingProgram;
	    		pp.quote.Price_Method__c=so.value;
	    		if(pp.displaySetupFee()) {
	    			system.debug('displaySetupFee -- ' + pp.quote.Setup_Fee__c);
	    			if(pp.quote.Setup_Fee__c == null) {
	    				Revvy__MnStrategy1__c program = ToroCacheManager.getPricingProgram(ppd.externalId);	
	    				pp.quote.Setup_Fee__c = program.Setup_Fee__c;
	    				system.debug('displaySetupFee --program.Setup_Fee__c ' + program.Setup_Fee__c);
	    				system.debug('displaySetupFee --quote= ' + pp.quote.Setup_Fee__c);
	    			}
	    		}
	    		ToroCacheManager.putQuote(pp.quote);
    			for(Revvy__MnStrategy4__c qi : pp.quoteItems) {
    				qi.Pricing_Program__c = pricingProgram;
    				qi.Select_a_Price_Method__c = rs.selectedPricingMethod;
    				qi.Off_MSRP__c=0;
    				qi.Award_of_DN__c=0;
    				qi.Rebate_as_a_of_DN__c=0;
    				qi.Unit_Award_Overridden__c = false;
    				if(!qi.Unit_Award_Overridden__c) {
    					qi.Award_Price__c=0;
    				}
    				qi.PricingMethodValue__c=null;
    				qi.Performance_Parts_Product__c = false;
    				qi.pricing_program__c = pricingProgram;
    				if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
	    				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
	    					qis.Percent_Off_MSRP__c=0;
	    					qis.Percent_of_DNet__c=0;
	    					qis.Rebate_as_of_DNet__c=0;
	    					qis.Unit_Award_Overridden__c=false;
	    					if(!qis.Unit_Award_Overridden__c) {
	    						qis.Award_Price__c=0;
	    					}
	    					qis.PricingMethodValue__c=null;
	    					//qis.Unit_Award_Overridden__c=false;
	    					qis.Performance_Part__c = false;
	    				}
    				}

    			}
    			//List<Revvy__MnStrategy4__c> qis = pp.calculateRebateMargin(objId, ppd.externalId, so.value, pp.quoteItems,false);
    			rs.selectedPricingMethod = so.value;
    			//rs.nextAction = 'calculation';
    			return ToroPricingProgramCOntroller.getQuoteItemFields(pricingProgram, so.value, objId);
    		} else {
    			pp.quote.Pricing_Program_Name__c=pricingProgram;
	    		pp.quote.Pricing_Program_Type__c=pricingProgram;
	    		
	    		ToroCacheManager.putQuote(pp.quote);
    			//update new Revvy__MnQuote__c(Id = objId, Pricing_Program_Name__c=pricingProgram, Pricing_Program_Type__c=pricingProgram,Price_Method__c=options[0].value);
    			system.debug('pricingMethod = ' + pricingMethod);
    			rs.selectedPricingMethod = string.isNotBlank(pricingMethod) ? pricingMethod : defaultPricingMethod;
    			system.debug('rs.selectedPricingMethod = ' + rs.selectedPricingMethod);
    			list<Revvy__MnStrategy4__c> items = pp.quoteItems;
    			for(Revvy__MnStrategy4__c qi : items) {
    				qi.Pricing_Program__c = pricingProgram;
    				qi.Select_a_Price_Method__c = rs.selectedPricingMethod;
    				qi.Off_MSRP__c=0;
    				qi.Award_of_DN__c=0;
    				qi.Rebate_as_a_of_DN__c=0;
    				qi.Unit_Award_Overridden__c = false;
    				if(!qi.Unit_Award_Overridden__c) {
    					qi.Award_Price__c=0;
    				}
    				qi.PricingMethodValue__c=null;
    				qi.Performance_Parts_Product__c = false;
    				qi.pricing_program__c = pricingProgram;
    				if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
	    				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
	    					qis.Percent_Off_MSRP__c=0;
	    					qis.Percent_of_DNet__c=0;
	    					qis.Rebate_as_of_DNet__c=0;
	    					qis.Unit_Award_Overridden__c=false;
	    					if(!qis.Unit_Award_Overridden__c) {
	    						qis.Award_Price__c=0;
	    					}
	    					qis.PricingMethodValue__c=null;
	    					//qis.Unit_Award_Overridden__c=false;
	    					qis.Performance_Part__c = false;
	    				}
    				}
    			}
    			/*
    			if(sublines.size() > 0) {
    				update sublines;
    			}
    			if(items.size() > 0) {
    				update items;
    			}
    			*/
    		}

    		pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
    		rs.values =  pp.quoteItems;
    		rs.displaySetupFee=pp.displaySetupFee();
    		rs.displayPerformancePart = pp.displayPerformancePart();
    		for(FieldSetMember fs : rs.fieldSetMembers) {
	    		if(fs.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			fs.label = rs.selectedPricingMethod;
	    		}
	    	}
	    	for(FieldSetMember fss : rs.fieldSetSubMembers) {
	    		if(fss.fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			fss.label = rs.selectedPricingMethod;
	    		}
	    	}
	    	List<String> spKeys = new List<String>();
			if(String.isNotBlank(ppd.externalId)) {
		    	Map<String, Object > secondaryPrograms = pp.retrieveSecondaryPrograms(ppd.externalId);
		    	for(String key : secondaryPrograms.keyset()) {
		    		spKeys.add(key);
		    	}
	
		    	if(spKeys.size() > 0) {
		    		rs.secondaryPrograms = secondaryPrograms;
		    		rs.secondaryProgramKeys = spKeys;
		    	}
			}
    	//}
	
		rs.quote = pp.quote;
		system.debug('displaySetupFee --rs.quote= ' + rs.quote);
    	return rs;
    }
    
	@AuraEnabled
    public static ToroSObjectResultSet getQuoteHeaderFields(String pricingProgram, ID objId) {
    	system.debug(logginglevel.info, 'getQuoteHeaderFields=' + pricingProgram + ' objId=' + objId);
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;

    	Id quoteId = objId;

    	//load quote from DB
    	Revvy__MnQuote__c q = ToroCacheManager.refreshQuote(quoteId);
    	//if(Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).contains(ToroPricingProgramController.constCachedQuoteId)) {
    	//	quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);
    	//}
    	system.debug('quote q=' + q);
    	system.debug(logginglevel.info, 'pricingProgram=' + pricingProgram);
    	rs.pricingProgramOptions = ToroCacheManager.getPricingProgramEligibility(quoteId);
    	 	
    	if(String.isBlank(pricingProgram)) {
	    	pricingProgram = q.Pricing_Program_Name__c;
    	}
    	
    	if(String.isBlank(pricingProgram)) {
    		for(ToroSelectOption opt : rs.pricingProgramOptions) {
    			if(opt.defaultSelected) {
    				pricingProgram = opt.value;
    				break;	
    			}	
    		}	
    	}
    	
    	system.debug(logginglevel.info, 'pricingProgram=' + pricingProgram);
    	rs.selectedPricingProgram = pricingProgram;
    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);

    	system.debug(logginglevel.info,'pricingProgram=' + pricingProgram);
    	system.debug(logginglevel.info,'pricingProgram ppd=' + ppd);
    	ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    	rs.allowSupportPlus = pp.getAllowSupportPlus(pricingProgram);
		rs.contractMessage = pp.displayContractMessage(pricingProgram);
    	system.debug(logginglevel.info,'pricingProgram pp=' + pp);
    	List<Schema.FieldSetMember> fieldSet = pp.getQuoteFields();
    	if(!Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
    		List<Schema.FieldSetMember> dNetfieldSet = pp.getToroQuoteDNetFields();
    		fieldSet = pp.removeDNetFieldsFromSet(fieldSet, dNetfieldSet);
    	}

    	List<Schema.FieldSetMember> updatableFieldSet = pp.getQuoteUpdatableFields();
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	pp.initialize(quoteId);
    	system.debug(logginglevel.info,'pricingProgram setup fee=' + pp.quote.Setup_Fee__c);
    	if(pp.displaySetupFee() && pp.quote.Setup_Fee__c == null) {
    		List<Revvy__MnStrategy1__c> pps = [SELECT Id, Name, Setup_Fee__c FROM Revvy__MnStrategy1__c where externalID__c = :ppd.externalId];
    		for(Revvy__MnStrategy1__c ppi : pps) {
    			pp.quote.Setup_Fee__c = ppi.Setup_Fee__c;
    			system.debug(logginglevel.info,'pricingProgram setup fee=' + pp.quote.Setup_Fee__c);
    		}
    	}

    	ToroCacheManager.putQuote(pp.quote);
    		
		//create the ootb to extension relationship
    	list<Id> quoteItemIds = new list<Id>();
    	list<Id> sublineIds = new list<Id>();
    	for(Revvy__MnStrategy4__c qi : pp.quoteItems) {
    		quoteItemIds.add(qi.Id);
    		if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					sublineIds.add(qis.Id);
				}
    		}
		}
		if(quoteItemIds.size() > 0) {
			ToroQIExtensionCreatedBatch b = new ToroQIExtensionCreatedBatch(quoteItemIds);
			Database.executeBatch(b);
		}
		if(sublineIds.size() > 0) {
			ToroQISLExtensionCreatedBatch b = new ToroQISLExtensionCreatedBatch(sublineIds);
			Database.executeBatch(b);
		}
		pp.quote = q;
    	rs.values =  new List<SObject> {pp.quote};
    	rs.pricingMethodOptions = pp.retrievePricingMethodOptions();
    	if(rs.pricingMethodOptions.size() == 1) {
    		rs.selectedPricingMethod = rs.pricingMethodOptions[0].value;
    	} else {
    		rs.selectedPricingMethod = q.Price_Method__c;
    	}			
    	rs.displayPerformancePart = pp.displayPerformancePart();
    	rs.displaySetupFee=pp.displaySetupFee();
    	
    	system.debug(logginglevel.info, ' to be deleted -- rs.selectedPricingProgram=' + rs.selectedPricingProgram);
    	
    	system.debug(logginglevel.info,'pricingProgram setup fee pp=' + pp);
    	system.debug(logginglevel.info,'pricingProgram setup fee pp=' + pp.displaySetupFee()); 
    	return rs;
    }

    private static ToroSObjectResultSet retrieveFieldSets(ToroSObjectResultSet rs, ToroPricingProgram pp, String pricingMethod, String pricingProgram) {
    	List<Schema.FieldSetMember> fieldSet = pp.getToroQuoteItemFields();
    	List<Schema.FieldSetMember> fieldSetSub = pp.getToroQuoteItemSublineFields();
    	List<Schema.FieldSetMember> fieldSetSummary = pp.getToroQuoteItemSummaryFields();
    	if(!Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
    		List<Schema.FieldSetMember> qiDNetFS = pp.getToroQuoteItemDNetFields();
    		List<Schema.FieldSetMember> qiSummaryDNetFS = pp.getToroQuoteItemDNetFields();
    		List<Schema.FieldSetMember> qisDNetFS = pp.getToroQuoteItemSublineDNetFields();
    		fieldSet = pp.removeDNetFieldsFromSet(fieldSet, qiDNetFS);
    		fieldSetSummary = pp.removeDNetFieldsFromSet(fieldSetSummary, qiSummaryDNetFS);
    		fieldSetSub = pp.removeDNetFieldsFromSet(fieldSetSub, qisDNetFS);
    	}

    	system.debug('retrieveFieldSets = ' + fieldSet);
    	system.debug('retrieveFieldSets =  fieldSetSummary=' + fieldSetSummary);
    	List<Schema.FieldSetMember> updatableFieldSet = pp.getToroQuoteItemUpdatableFields();
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	List<Schema.FieldSetMember> updatableFieldSetSub = pp.getToroQuoteItemSublineUpdatableFields();
    	rs.fieldSetSubMembers = pp.addUpdatableFieldSetMember(fieldSetSub, updatableFieldSetSub);
    	List<Schema.FieldSetMember> updatableFieldSetSummary = pp.getToroQuoteItemSummaryUpdatableFields();
    	rs.fieldSetSummaryMembers = pp.addUpdatableFieldSetMember(fieldSetSummary, updatableFieldSetSummary);
    	rs.demoPricingProgramOptions = pp.retrieveDemoPricingProgramOptions();

    	for ( Integer i = rs.fieldSetMembers.size() - 1; i >= 0; --i ) {
    		if(rs.fieldSetMembers.get(i).fieldPath.startsWithIgnoreCase('PlaceHolder')) {
    			rs.fieldSetMembers.get(i).label = '';
    		}
			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			rs.fieldSetMembers.get(i).label = pricingMethod;
    		}
    		if(string.isNotBlank(pricingMethod)) {
				if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
					if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_of_DN__c')) {
						rs.fieldSetMembers.remove(i);
					}
	    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Off_MSRP__c')) {
						rs.fieldSetMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Toro_Gross_Profit_Percent__c')) {
						rs.fieldSetMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetMembers.remove(i);
					}
	    		}
    		}
		}
		for ( Integer i = rs.fieldSetSummaryMembers.size() - 1; i >= 0; --i ) {
			if(rs.fieldSetSummaryMembers.get(i).fieldPath.startsWithIgnoreCase('PlaceHolder')) {
    			rs.fieldSetSummaryMembers.get(i).label = '';
    		}
			if(rs.fieldSetSummaryMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			rs.fieldSetSummaryMembers.get(i).label = pricingMethod;
    		}
    		if(string.isNotBlank(pricingMethod)) {
				if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
					if(rs.fieldSetSummaryMembers.get(i).fieldPath.equalsIgnoreCase('Award_of_DN__c')) {
						rs.fieldSetSummaryMembers.remove(i);
					}
	    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSummaryMembers.get(i).fieldPath.equalsIgnoreCase('Off_MSRP__c')) {
						rs.fieldSetSummaryMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSummaryMembers.get(i).fieldPath.equalsIgnoreCase('Toro_Gross_Profit_Percent__c')) {
						rs.fieldSetSummaryMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSummaryMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetSummaryMembers.remove(i);
					}
	    		}
    		}
		}
		system.debug('***************** 1   fieldset size =' + rs.fieldSetSubMembers.size());
		system.debug('***************** 1   pm' + pricingMethod);
		for ( Integer i = rs.fieldSetSubMembers.size() - 1; i >= 0; --i ) {
			if(rs.fieldSetSubMembers.get(i).fieldPath.startsWithIgnoreCase('PlaceHolder')) {
    			rs.fieldSetSubMembers.get(i).label = '';
    		}
			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			rs.fieldSetSubMembers.get(i).label = pricingMethod;
    		}
    		if(string.isNotBlank(pricingMethod)) {
				if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
					if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_of_DNet__c')) {
						rs.fieldSetSubMembers.remove(i);
					}
	    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_Off_MSRP__c')) {
						rs.fieldSetSubMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Gross_Profit_Percent__c')) {
						rs.fieldSetSubMembers.remove(i);
					}
	    		} else if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetSubMembers.remove(i);
					}
	    		}
    		}
		}
		system.debug('***************** 2 fieldset size =' + rs.fieldSetSubMembers.size());

		//if ('% off MSRP'.equalsIgnoreCase(pricingMethod))
		
		if(string.isNotBlank(pricingProgram)){
			ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
			system.debug('***************** pricing program  =' + ppd.externalId);
			Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(ppd.externalId);
			if((pp_header != null) && 'State Contract'.equalsIgnoreCase(pp_header.PricingProgramType__c) && '% off MSRP'.equalsIgnoreCase(pricingMethod) && !pp.skipMSRPRangeCheck()) {
				rs.listenMSRPChange = true;
			}
		}
		
		return rs;
    }
    @AuraEnabled
    public static ToroSObjectResultSet getQuoteItemFields(String pricingProgram, String pricingMethod, ID objId) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	system.debug(logginglevel.info, '***************** getQuoteItemFields pricingProgram=' +  pricingProgram);
    	Id quoteId = objId;
    	if(quoteId == null) {
    		quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);
    	}
    	Revvy__MnQuote__c q = ToroCacheManager.getQuote(quoteId);
    	if(String.isBlank(pricingProgram)) {
    		pricingProgram = q.Pricing_Program_Name__c;	
    	}
    	
    	if(String.isBlank(pricingProgram)) {
    		rs.pricingProgramOptions = ToroCacheManager.getPricingProgramEligibility(quoteId);
    		for(ToroSelectOption opt : rs.pricingProgramOptions) {
    			if(opt.defaultSelected) {
    				pricingProgram = opt.value;
    				break;	
    			}	
    		}	
    	}
    	
    	if(String.isBlank(pricingMethod)) {
    		pricingMethod = q.Price_Method__c;	
    	}
    	system.debug(logginglevel.info, '***************** getQuoteItemFields pricingMethod=' +  pricingMethod);
    	//if(Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).contains(ToroPricingProgramController.constCachedQuoteId)) {
    	//	quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);
    	//}
    	ToroPricingProgram pp = new ToroDefaultPricingProgramHelper();
    	if(string.isNotBlank(pricingProgram)) {
    		//pricingProgram = [select Pricing_Program_Name__c from Revvy__MnQuote__c where id = :objId].Pricing_Program_Name__c;
    		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
	    	rs.selectedPricingProgram = pricingProgram;
	    	pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
	    	//rs.secondaryPrograms = pp.retrieveSecondaryPrograms(ppd.externalId);
    	} else {
    		rs.pricingProgramOptions = ToroCacheManager.getPricingProgramEligibility(objId); 
    		for(ToroSelectOption opt : rs.pricingProgramOptions) {
    			if(opt.defaultSelected) {
    				rs.selectedPricingProgram = opt.value;
    				pricingProgram=rs.selectedPricingProgram;
    				ToroPricingProgramData ppd = new ToroPricingProgramData(rs.selectedPricingProgram);
			    	pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    				List<ToroSelectOption> options2 = pp.retrievePricingMethodOptions();
    				rs.selectedPricingMethod = options2[0].value;
    				break;	
    			}	
    		}		
    	}
    	
    	system.debug(logginglevel.info, 'getQuoteItemFields result=' + rs);
    	pp.initialize(objId);
		List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
		rs.pricingMethodOptions = options;
		if(String.isBlank(pricingMethod)) {
			if(options.size() ==1) {
				pricingMethod = options[0].value;
			}
    			
    	}
    	
    	q = pp.quote;
    	//Performance_Part__c
    	pp.performancePartFlag = pp.quote.Performance_Part__c;
    	//String pm = pricingMethod;
    	String pm = pricingMethod;
    	rs = retrieveFieldSets(rs, pp, pm, pricingProgram);

    	//pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
    	for(Revvy__MnStrategy4__c qi : pp.quoteItems) {
    		if(String.isNotBlank(qi.PricingMethodValue__c)){
    			decimal d = decimal.valueOf(qi.PricingMethodValue__c).setScale(2, roundingMode.HALF_UP);
    			qi.PricingMethodValue__c = String.valueOf(d);
    		}
			if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(String.isNotBlank(qis.PricingMethodValue__c)){
		    			decimal d = decimal.valueOf(qis.PricingMethodValue__c).setScale(2, roundingMode.HALF_UP);
		    			qis.PricingMethodValue__c = String.valueOf(d);
		    			//system.debug('performance part product id=' + qis.product_Id__c + ' performance part =' + qis.performance_part__c);
		    		}
				}
			}
		}
		
		//if(String.IsNotBlank(pricingProgram) && String.IsNotBlank(pricingMethod)) {
			//rs.nextAction = 'calculation';
		//}
		List<String> spKeys = new List<String>();
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		pp.quoteItems = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, false);
		
		if(String.isNotBlank(ppd.externalId)) {
	    	Map<String, Object > secondaryPrograms = pp.retrieveSecondaryPrograms(ppd.externalId);
	    	for(String key : secondaryPrograms.keyset()) {
	    		spKeys.add(key);
	    	}
	
	    	if(spKeys.size() > 0) {
	    		rs.secondaryPrograms = secondaryPrograms;
	    		rs.secondaryProgramKeys = spKeys;
	    	}
		}
		if ('Total Award $'.equalsIgnoreCase(pricingMethod)) {
    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
    			qi.PricingMethodValue__c = String.valueOf(qi.Total_Toro_Award__c);	
    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.PricingMethodValue__c = String.valueOf(qis.Award_Price__c);	
					}
    			}
				
			}
    	}
    	if ('Gross Profit %'.equalsIgnoreCase(pricingMethod)) {
    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
    			qi.PricingMethodValue__c = String.valueOf(qi.Toro_Gross_Profit_Percent__c);	
    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.PricingMethodValue__c = String.valueOf(qis.Gross_Profit_Percent__c);	
					}
    			}
				
			}
    	}
    	if ('% of DNET'.equalsIgnoreCase(pricingMethod)) {
    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
    			qi.PricingMethodValue__c = String.valueOf(qi.Award_of_DN__c);	
    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.PricingMethodValue__c = String.valueOf(qis.Percent_of_DNet__c);	
					}
    			}
				
			}
    	}
    	if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
    		for(Revvy__MnStrategy4__c qi : pp.quoteItems) { 
    			qi.PricingMethodValue__c = String.valueOf(qi.Off_MSRP__c);	
    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.PricingMethodValue__c = String.valueOf(qis.Percent_Off_MSRP__c);	
					}
    			}
				
			}
    	}
    	rs.quote = pp.quote;    	
    	rs.allowSupportPlus = pp.getAllowSupportPlus(pricingProgram);
		rs.displayPerformancePart = pp.displayPerformancePart();
		rs.contractMessage = pp.displayContractMessage(pricingProgram);
		
		rs.selectedPricingMethod = pricingMethod;
    	rs.displaySetupFee=pp.displaySetupFee();
    	rs.values =  pp.quoteItems;
    	system.debug(logginglevel.info, 'getQuoteItemFields result=' + rs);
    	return rs;
    }

    public static List<FieldSetMember> addUpdatableFieldSetMember(List<Schema.FieldSetMember> fieldSet, List<Schema.FieldSetMember> updatableFieldSet) {
		set<String> updatableFields = new set<String>();
		if(updatableFieldSet != null) {
	    	for(Schema.FieldSetMember s : updatableFieldSet) {
	    		updatableFields.add(s.fieldPath.toLowerCase());
	    	}
		}
		system.debug('updatableFields='+updatableFields);
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
        	FieldSetMember nfsm = new FieldSetMember(f);
        	nfsm.updatable=false;
        	system.debug('f.fieldPath='+f.fieldPath);
        	if(updatableFields.contains(f.fieldPath.toLowerCase())) {
        		nfsm.updatable=true;
        	}
            fset.add(nfsm);
        }
        return fset;
	}
}