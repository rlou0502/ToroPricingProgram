public class ToroPricingProgramController {
	public static final String constCachedQuoteId = 'quoteId';
	public static final String constCachedSetupFee = 'setupFee';
    public Id quoteId {get; set;}
    public ToroPricingProgramController() {
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
    public static ToroSObjectResultSet svc_setupFeeChange(decimal setupFee) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();	
    	rs.result=true;
    	system.debug(logginglevel.info, 'setup fee=' + setupFee);
    	ToroCacheManager.setSetupFee(setupFee);
    	//if(Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName) != null){
    	//	system.debug(logginglevel.info, 'set setup fee to cache=' + setupFee);
    	//	Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).put(ToroPricingProgramController.constCachedSetupFee, setupFee);		
    	//}  	
    	//system.debug(logginglevel.info, 'get it from cache setup fee=' + Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedSetupFee));
    	return rs;
    }
    
    @AuraEnabled
    public static ToroSObjectResultSet svc_performancePartChange(boolean performancePart) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();	
    	rs.result=true;
    	ToroCacheManager.setPerformancePart(performancePart);
    	return rs;
    }
    
    
    @AuraEnabled
    public static ToroSObjectResultSet svc_getPricingMethodOptions(Id quoteId, String pricingProgram) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();	
    	rs.result=true;
    	rs.selectedPricingProgram = pricingProgram;
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    	List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
		rs.pricingMethodOptions = options;
		if(options.size() == 1) {
			rs.selectedPricingMethod = options[0].value;	
		} else {
			rs.selectedPricingMethod = null;
		}
		rs.displayPerformancePart = pp.displayPerformancePart();
		rs.displaySetupFee=pp.displaySetupFee();
    	return rs;
    }
    
    @AuraEnabled
    public static ToroSObjectResultSet svc_updateQuoteData2(Map<String, Object> values, String quoteItemsDataJSON, String qiSublinesDataJSON, boolean save) {
    	system.debug('***************** svc_updateQuoteData2' );
    	//Id quoteId, Id qiId, String pricingProgram, 
    	//String pricingMethod, decimal setupFeePercent, boolean performancePart,   			
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();	
    	rs.result=true;
    	if(values == null) {
    		rs.result=false;
    		return rs;	
    	}
    	String pricingMethod = (String) values.get('pricingMethod');
    	String pricingProgram = (String) values.get('pricingProgram'); 
    	rs.selectedPricingMethod = pricingMethod;
    	rs.selectedPricingProgram = pricingProgram; 
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
    	ToroPricingProgramData ppd = new ToroPricingProgramData(rs.selectedPricingProgram);
    	rs.currentQuoteItem = qiId;
		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
		pp.performancePartFlag = performancePart;
		pp.setupFeePercentage = setupFeePercent;
		System.debug('pricingProgram=' +pricingProgram);
		System.debug('pricingMethod=' +pricingMethod);
		System.debug('quoteItemsDataJSON=' +quoteItemsDataJSON);
		System.debug('qiSublinesDataJSON=' +qiSublinesDataJSON);
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
		
		for(Toro_QuoteItem__c qi : pp.quoteItems) {
			if(pp.performancePartFlag && qi.Performance_Parts_Product__c) {
				qi.FreezeLine__c = true;
			}
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
			    			qi.Award_Price__c = string.isNotBlank(strVal) ? decimal.valueOf(strVal) : null;		
			    		}	
					} else if('Award_Price__c'.equalsIgnoreCase(key)){
						system.debug('---------------Award_Price__c =' + strVal);
						
						qi.Award_Price__c = string.isNotBlank(strVal) ? decimal.valueOf(strVal) : null;	
						
					} else if('Unit_Award_Overridden__c'.equalsIgnoreCase(key)){
						qi.Unit_Award_Overridden__c=false;
						
						qi.Unit_Award_Overridden__c = string.isNotBlank(strVal) ? boolean.valueOf(strVal) : false;
						
					}
					
				} 
			}
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(pp.performancePartFlag && qis.Performance_part__c) {
						qis.FreezeLine__c = true;
					}
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
				}
    		}
		}
		
		rs = retrieveFieldSets(rs, pp, pricingMethod);
		system.debug(logginglevel.info, 'entering---calculateRebateMargin');
    	pp.quoteItems = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, save);
    	
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
    	
    	rs.values =  pp.quoteItems;
    	rs.chainCall = pp.chainCall;
    	rs.payload = pp.payloadOfChainCall;
    	rs.displaySetupFee=pp.displaySetupFee();
    	return rs;	
    }
  
    @AuraEnabled
    public static ToroSObjectResultSet svc_setPricingMethodValue(Id quoteId, Id qiId, String pricingProgram, String pricingMethod, string value) {
    	system.debug('***************** svc_setPricingMethodValue' );
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();	
    	rs.result=true;
    	rs.selectedPricingMethod = pricingMethod;
    	rs.selectedPricingProgram = pricingProgram; 
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	rs.currentQuoteItem = qiId;
		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
		system.debug('setPricingMethodValueRemote pp=' + pp);	
		List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
		rs.pricingMethodOptions = options;
		system.debug('setPricingMethodValueRemote options=' + options);	
		//if there is only one pricing method + "Please select" item, auto apply it
		pp.initialize(quoteId);
		rs = retrieveFieldSets(rs, pp, pricingMethod);
		/*
    	List<Schema.FieldSetMember> fieldSet = pp.getToroQuoteItemFields();
    	List<Schema.FieldSetMember> updatableFieldSet = pp.getToroQuoteItemUpdatableFields(); 
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	List<Schema.FieldSetMember> fieldSetSub = pp.getToroQuoteItemSublineFields();
    	List<Schema.FieldSetMember> updatableFieldSetSub = pp.getToroQuoteItemSublineUpdatableFields(); 
    	rs.fieldSetSubMembers = pp.addUpdatableFieldSetMember(fieldSetSub, updatableFieldSetSub);
    	List<Schema.FieldSetMember> fieldSetSummary = pp.getToroQuoteItemSummaryFields();
    	rs.fieldSetSummaryMembers = pp.addUpdatableFieldSetMember(fieldSetSummary, null);
    	*/
    	for(Toro_QuoteItem__c qi : pp.quoteItems) {
    		if(qiId == qi.id) {
	    		qi.PricingMethodValue__c = value;
	    		if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
	    			qi.Award_of_DN__c = Double.valueOf(value);
	    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
	    			qi.Off_MSRP__c = Double.valueOf(value);
	    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pricingMethod)) {
	    			qi.Toro_Gross_Profit_Percent__c = Double.valueOf(value);
	    		} else if ('Total Award Price'.equalsIgnoreCase(pricingMethod)) {
	    			qi.Award_Price__c = decimal.valueOf(value);		
	    		}
	    		if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.PricingMethodValue__c = value;
						if('% of DNET'.equalsIgnoreCase(pricingMethod)) {
			    			qis.Percent_of_DNet__c = Double.valueOf(value);
			    		} else if ('% off MSRP'.equalsIgnoreCase(pricingMethod)) {
			    			qis.Percent_Off_MSRP__c = Double.valueOf(value);
			    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pricingMethod)) {
			    			qis.Gross_Profit_Percent__c = Double.valueOf(value);
			    		} else if ('Total Award Price'.equalsIgnoreCase(pricingMethod)) {
			    			qis.Award_Price__c = decimal.valueOf(value);		
			    		}
					}
	    		}
    		}
    	}
    	List<Toro_QuoteItem__c> qis = pp.calculateRebateMargin(quoteId, ppd.externalId, pricingMethod, pp.quoteItems, false);
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
    public static map<String, decimal> setTotalAwardDollarPMRemote(Id quoteId, String pricingProgram, String pricingMethod, decimal awardPrice) {
    	system.debug('--------------calling setTotalAwardDollarPMRemote');
    	map<String, decimal> retData = new map<String, decimal>();
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	if(string.isNotBlank(pricingProgram)) {
    		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);	
    		pp.initialize(quoteId);
    		list<Toro_QuoteItem__c> items = ToroPricingMethodUtil.distributeTotalAwordDollors(ppd.externalId, pp.quoteItems, awardPrice);
    		for(Toro_QuoteItem__c qi : items) {
    			retData.put(qi.Id, qi.Award_Price__c);
    			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						retData.put(qis.Id, qis.Award_Price__c);	
					}
    			}	
    		}
    	}
    	
    	return retData;
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
    	rs.selectedPricingMethod = pricingMethod;
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	
    	if(string.isNotBlank(pricingProgram)) {
    		ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    		system.debug('pricingProgram pp=' + pp);	
    		List<ToroSelectOption> options = pp.retrievePricingMethodOptions();
    		rs.pricingMethodOptions = options;
    		system.debug('setPricingProgramToDB options=' + options);	
    		//if there is only one pricing method + "Please select" item, auto apply it
    		pp.initialize(objId);
    		rs = retrieveFieldSets(rs, pp, pricingMethod);
    		
	    	List<Schema.FieldSetMember> fieldSet = pp.getToroQuoteItemFields();
	    	List<Schema.FieldSetMember> updatableFieldSet = pp.getToroQuoteItemUpdatableFields(); 
	    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
	    	List<Schema.FieldSetMember> fieldSetSub = pp.getToroQuoteItemSublineFields();
	    	List<Schema.FieldSetMember> updatableFieldSetSub = pp.getToroQuoteItemSublineUpdatableFields(); 
	    	rs.fieldSetSubMembers = pp.addUpdatableFieldSetMember(fieldSetSub, updatableFieldSetSub);
	    	List<Schema.FieldSetMember> fieldSetSummary = pp.getToroQuoteItemSummaryFields();
	    	rs.fieldSetSummaryMembers = pp.addUpdatableFieldSetMember(fieldSetSummary, null);
    		String pm = pricingMethod;
    		for ( Integer i = rs.fieldSetMembers.size() - 1; i >= 0; --i ) {
				if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			rs.fieldSetMembers.get(i).label = pm;	
	    		}
	    		if(string.isNotBlank(pm)) {
					if('% of DNET'.equalsIgnoreCase(pm)) {
						if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_of_DN__c')) {
							rs.fieldSetMembers.remove(i);	
						}
		    		} else if ('% off MSRP'.equalsIgnoreCase(pm)) {
		    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Off_MSRP__c')) {
							rs.fieldSetMembers.remove(i);	
						}
		    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pm)) {
		    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Toro_Gross_Profit_Percent__c')) {
							rs.fieldSetMembers.remove(i);	
						}
		    		} else if ('Total Award Price'.equalsIgnoreCase(pm)) {	
		    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
							rs.fieldSetMembers.remove(i);	
						}	
		    		}	
	    		}
			}
		
			system.debug('***************** 1   fieldset size =' + rs.fieldSetSubMembers.size());
			system.debug('***************** 1   pm' + pm);
			for ( Integer i = rs.fieldSetSubMembers.size() - 1; i >= 0; --i ) {
				if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
	    			rs.fieldSetSubMembers.get(i).label = pm;	
	    		}
	    		if(string.isNotBlank(pm)) {
					if('% of DNET'.equalsIgnoreCase(pm)) {
						if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_of_DNet__c')) {
							rs.fieldSetSubMembers.remove(i);	
						}
		    		} else if ('% off MSRP'.equalsIgnoreCase(pm)) {
		    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_Off_MSRP__c')) {
							rs.fieldSetSubMembers.remove(i);	
						}
		    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pm)) {
		    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Gross_Profit_Percent__c')) {
							rs.fieldSetSubMembers.remove(i);	
						}
		    		} else if ('Total Award Price'.equalsIgnoreCase(pm)) {	
		    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
							rs.fieldSetSubMembers.remove(i);	
						}	
		    		}	
	    		}
			}
			system.debug('***************** 2   fieldset size =' + rs.fieldSetSubMembers.size());

    		if(options.size() ==1) {
    			//pp.calculateRebateMargin();	
    			ToroSelectOption so = options[0];
    			system.debug('setPricingProgramToDB calling calculateRebateMargin'); 
    			update new Revvy__MnQuote__c(Id = objId, Pricing_Program_Name__c=pricingProgram, Pricing_Program_Type__c=pricingProgram, Price_Method__c=so.value);
    			for(Toro_QuoteItem__c qi : pp.quoteItems) {
    				qi.Pricing_Program__c = pricingProgram;
    				qi.Select_a_Price_Method__c = rs.selectedPricingMethod;
    				qi.Off_MSRP__c=0;
    				qi.Award_of_DN__c=0;
    				qi.Rebate_as_a_of_DN__c=0;
    				qi.Award_Price__c=0;
    				qi.PricingMethodValue__c=null;
    				if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
	    				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
	    					qis.Percent_Off_MSRP__c=0;
	    					qis.Percent_of_DNet__c=0;
	    					qis.Rebate_as_of_DNet__c=0;
	    					qis.Award_Price__c=0;
	    					qis.PricingMethodValue__c=null;	
	    				}
    				}				
    			}
    			List<Toro_QuoteItem__c> qis = pp.calculateRebateMargin(objId, ppd.externalId, so.value, pp.quoteItems,false);
    			rs.selectedPricingMethod = so.value;
    		} else {
    			//update new Revvy__MnQuote__c(Id = objId, Pricing_Program_Name__c=pricingProgram, Pricing_Program_Type__c=pricingProgram,Price_Method__c=options[0].value);
    			rs.selectedPricingMethod = string.isNotBlank(pricingMethod) ? pricingMethod : '';
    			list<Toro_QuoteItem__c> items = pp.quoteItems;
    			for(Toro_QuoteItem__c qi : items) {
    				qi.Pricing_Program__c = pricingProgram;
    				qi.Select_a_Price_Method__c = rs.selectedPricingMethod;
    				qi.Off_MSRP__c=0;
    				qi.Award_of_DN__c=0;
    				qi.Rebate_as_a_of_DN__c=0;
    				qi.Award_Price__c=0;
    				qi.PricingMethodValue__c=null;
    				if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
	    				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
	    					qis.Percent_Off_MSRP__c=0;
	    					qis.Percent_of_DNet__c=0;
	    					qis.Rebate_as_of_DNet__c=0;
	    					qis.Award_Price__c=0;
	    					qis.PricingMethodValue__c=null;	
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
    	}
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
    	
    	return rs;
    }
    public static void resetPricingProgramAndMethod() {
    	
    }
	@AuraEnabled
    public static ToroSObjectResultSet getQuoteHeaderFields(String pricingProgram, ID objId) {
    	system.debug(logginglevel.info, 'getQuoteHeaderFields=' + pricingProgram + ' objId=' + objId);
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	
    	Id quoteId = objId;
    	if(quoteId == null) {
    		quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);		
    	}
    	//if(Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).contains(ToroPricingProgramController.constCachedQuoteId)) {
    	//	quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);	
    	//}
    	system.debug(logginglevel.info, 'pricingProgram=' + pricingProgram);
    	if(String.isBlank(pricingProgram)) {
	    	Revvy__MnQuote__c q = [SELECT Id, Pricing_Program_Type__c, Pricing_Program_Name__c, Price_Method__c FROM REVVY__MnQuote__c where id = :quoteId ];
	    	pricingProgram = q.Pricing_Program_Name__c;
    	}
    	rs.selectedPricingProgram = pricingProgram; 
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	system.debug(logginglevel.info,'pricingProgram=' + pricingProgram);
    	ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    	system.debug(logginglevel.info,'pricingProgram pp=' + pp);
    	List<Schema.FieldSetMember> fieldSet = pp.getQuoteFields();
    	List<Schema.FieldSetMember> updatableFieldSet = pp.getQuoteUpdatableFields(); 
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	pp.initializeQuoteHeader(objId);
    	if(pp.displaySetupFee() && pp.quote.Setup_Fee__c == null) {
    		List<Toro_PricingProgram__c> pps = [SELECT Id, Name, Setup_Fee__c FROM Toro_PricingProgram__c where externalID__c = :ppd.externalId];	
    		for(Toro_PricingProgram__c ppi : pps) { 
    			pp.quote.Setup_Fee__c = ppi.Setup_Fee__c;
    			ToroCacheManager.setSetupFee(ppi.Setup_Fee__c);
    		}
    	}
    	rs.values =  new List<SObject> {pp.quote};
    	rs.pricingProgramOptions = ToroPricingProgramEligibility.retrievePricingProgramOptions(quoteId);
    	rs.pricingMethodOptions = pp.retrievePricingMethodOptions();
    	rs.displayPerformancePart = pp.displayPerformancePart();
    	rs.displaySetupFee=pp.displaySetupFee();
    	return rs;
    }  
    
    private static ToroSObjectResultSet retrieveFieldSets(ToroSObjectResultSet rs, ToroPricingProgram pp, String pricingMethod) {
    	List<Schema.FieldSetMember> fieldSet = pp.getToroQuoteItemFields();
    	List<Schema.FieldSetMember> updatableFieldSet = pp.getToroQuoteItemUpdatableFields(); 
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	List<Schema.FieldSetMember> fieldSetSub = pp.getToroQuoteItemSublineFields();
    	List<Schema.FieldSetMember> updatableFieldSetSub = pp.getToroQuoteItemSublineUpdatableFields(); 
    	rs.fieldSetSubMembers = pp.addUpdatableFieldSetMember(fieldSetSub, updatableFieldSetSub);
    	List<Schema.FieldSetMember> fieldSetSummary = pp.getToroQuoteItemSummaryFields();
    	rs.fieldSetSummaryMembers = pp.addUpdatableFieldSetMember(fieldSetSummary, null);
    	rs.demoPricingProgramOptions = pp.retrieveDemoPricingProgramOptions();
    	
    	for ( Integer i = rs.fieldSetMembers.size() - 1; i >= 0; --i ) {
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
	    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Toro_Gross_Profit_Percent__c')) {
						rs.fieldSetMembers.remove(i);	
					}
	    		} else if ('Total Award Price'.equalsIgnoreCase(pricingMethod)) {	
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetMembers.remove(i);	
					}	
	    		}	
    		}
		}
		system.debug('***************** 1   fieldset size =' + rs.fieldSetSubMembers.size());
		system.debug('***************** 1   pm' + pricingMethod);
		for ( Integer i = rs.fieldSetSubMembers.size() - 1; i >= 0; --i ) {
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
	    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pricingMethod)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Gross_Profit_Percent__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}
	    		} else if ('Total Award Price'.equalsIgnoreCase(pricingMethod)) {	
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}	
	    		}	
    		}
		}
		system.debug('***************** 2 fieldset size =' + rs.fieldSetSubMembers.size());		
		
		return rs;
    }
    @AuraEnabled
    public static ToroSObjectResultSet getQuoteItemFields(String pricingProgram, String pricingMethod, ID objId) {
    	ToroSObjectResultSet rs = new ToroSObjectResultSet();
    	rs.result=true;
    	system.debug('***************** getQuoteItemFields' );  	
    	Id quoteId = objId;
    	if(quoteId == null) {
    		quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);		
    	}
    	//if(Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).contains(ToroPricingProgramController.constCachedQuoteId)) {
    	//	quoteId = (Id) Cache.Session.getPartition(ToroPriceProgramFactory.constPartitionName).get(ToroPricingProgramController.constCachedQuoteId);	
    	//}
    	
    	if(string.isBlank(pricingProgram)) {
    		pricingProgram = [select Pricing_Program_Name__c from Revvy__MnQuote__c where id = :objId].Pricing_Program_Name__c;
    	}
    	
    	ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
    	rs.selectedPricingProgram = pricingProgram; 
    	ToroPricingProgram pp = ToroPriceProgramFactory.getPricingProgramHelper(ppd.subType);
    	pp.initialize(objId);
    	Revvy__MnQuote__c q = pp.quote;
    	//String pm = pricingMethod;
    	String pm = q.Price_Method__c;
    	rs = retrieveFieldSets(rs, pp, pm);
/*    	
    	//pp.pricingMethod = pricingMethod;
    	List<Schema.FieldSetMember> fieldSet = pp.getToroQuoteItemFields();
    	List<Schema.FieldSetMember> updatableFieldSet = pp.getToroQuoteItemUpdatableFields(); 
    	rs.fieldSetMembers = pp.addUpdatableFieldSetMember(fieldSet, updatableFieldSet);
    	List<Schema.FieldSetMember> fieldSetSub = pp.getToroQuoteItemSublineFields();
    	List<Schema.FieldSetMember> updatableFieldSetSub = pp.getToroQuoteItemSublineUpdatableFields(); 
    	rs.fieldSetSubMembers = pp.addUpdatableFieldSetMember(fieldSetSub, updatableFieldSetSub);
    	List<Schema.FieldSetMember> fieldSetSummary = pp.getToroQuoteItemSummaryFields();
    	rs.fieldSetSummaryMembers = pp.addUpdatableFieldSetMember(fieldSetSummary, null);
    	
		for ( Integer i = rs.fieldSetMembers.size() - 1; i >= 0; --i ) {
			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			rs.fieldSetMembers.get(i).label = pm;	
    		}
    		if(string.isNotBlank(pm)) {
				if('% of DNET'.equalsIgnoreCase(pm)) {
					if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_of_DN__c')) {
						rs.fieldSetMembers.remove(i);	
					}
	    		} else if ('% off MSRP'.equalsIgnoreCase(pm)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Off_MSRP__c')) {
						rs.fieldSetMembers.remove(i);	
					}
	    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pm)) {
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Toro_Gross_Profit_Percent__c')) {
						rs.fieldSetMembers.remove(i);	
					}
	    		} else if ('Total Award Price'.equalsIgnoreCase(pm)) {	
	    			if(rs.fieldSetMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetMembers.remove(i);	
					}	
	    		}	
    		}
		}
		
		system.debug('***************** 1   fieldset size =' + rs.fieldSetSubMembers.size());
		system.debug('***************** 1   pm' + pm);
		for ( Integer i = rs.fieldSetSubMembers.size() - 1; i >= 0; --i ) {
			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('PricingMethodValue__c')) {
    			rs.fieldSetSubMembers.get(i).label = pm;	
    		}
    		if(string.isNotBlank(pm)) {
				if('% of DNET'.equalsIgnoreCase(pm)) {
					if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_of_DNet__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}
	    		} else if ('% off MSRP'.equalsIgnoreCase(pm)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Percent_Off_MSRP__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}
	    		} else if ('% of Gross Profit Margin'.equalsIgnoreCase(pm)) {
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Gross_Profit_Percent__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}
	    		} else if ('Total Award Price'.equalsIgnoreCase(pm)) {	
	    			if(rs.fieldSetSubMembers.get(i).fieldPath.equalsIgnoreCase('Award_Price__c')) {
						rs.fieldSetSubMembers.remove(i);	
					}	
	    		}	
    		}
		}
		system.debug('***************** 2 fieldset size =' + rs.fieldSetSubMembers.size());
*/
    	pp.quoteItems = pp.calculateExtendedFields(pp.quoteItems);
    	for(Toro_QuoteItem__c qi : pp.quoteItems) {
    		if(String.isNotBlank(qi.PricingMethodValue__c)){
    			decimal d = decimal.valueOf(qi.PricingMethodValue__c).setScale(2, roundingMode.HALF_UP);
    			qi.PricingMethodValue__c = String.valueOf(d);	
    		}
			if( qi.Toro_Quote_Item_Sub_Lines__r != null) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(String.isNotBlank(qis.PricingMethodValue__c)){
		    			decimal d = decimal.valueOf(qis.PricingMethodValue__c).setScale(2, roundingMode.HALF_UP);
		    			qis.PricingMethodValue__c = String.valueOf(d);	
		    		}
				}
			}				
		}
    			
    	rs.displaySetupFee=pp.displaySetupFee();
    	rs.values =  pp.quoteItems;
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