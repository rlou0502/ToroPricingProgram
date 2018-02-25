public without sharing class ToroSelectPriceProgramController {
	private ToroPricingProgram helper;
	public Id quoteId {get; set;}
	public Id quoteItemId {get; set; }
	public List<ProductInfo> productInfoList { get; set; }
	public List<Revvy__MnQuote__c> quotes { get; set; }
	public List<Revvy__MnQuoteItem__c> quoteItems { get; set; }
	public List<Schema.FieldSetMember> getQuoteItemSublineFields() {
		return helper.getQuoteItemSublineFields();
	}
	public List<Schema.FieldSetMember> getQuoteItemFields() {
		return helper.getQuoteItemFields();
	}
	public List<Schema.FieldSetMember> getQuoteFields() {
		return helper.getQuoteFields();
	}
	
	public List<Schema.FieldSetMember> getQuoteItemSummaryFields() {
		return helper.getQuoteItemSummaryFields();
	}
	
	public boolean getQuoteLevelMSQPDNetEditable() {
		return helper.getQuoteLevelMSQPDNetEditable();
	}
	public Map<String, Set<Id>> sku2QuoteItems { get; set; }
	public Map<String, boolean> quoteFieldsUpdatable { get; set; }
	public Map<String, boolean> quoteItemFieldsUpdatable { get; set; }
	public Map<String, boolean> quoteItemSublineFieldsUpdatable { get; set; }
	public List<QuoteItem> quoteItemWrapperList {get;set;}
	public List<SelectOption> pricingProgramOptions {get;set;}
	public List<SelectOption> priceMethodOptions {get;set;}
	public List<QuoteItem.PricingProgramSelector> pricingProgramSelectors { get; set;}
	public String pricingMethodLabel { get; set; }
	public Map<String, String> pricingProgramTypes { get; set; }
	public static final String Const_PM_Percent_Of_DNET = '% of DNET';
	public static final String Const_PM_Percent_Off_MSRP = '% off MSRP';
	public String selectedPricingProgram { get; set; }
	public String selectedPricingMethod { get; set; }
	public String prcingProgramType { get; set; }
	public boolean isPricingEditable { get; set; }
    public boolean bdisplayPerformancePart {get { return getDisplayPerformancePart();} set;}
    public void init() {
    	PushTopic pushTopic = new PushTopic();
		pushTopic.Name = 'SetupFee'; 
		pushTopic.Query =   'Select Id from revvy__MnQuoteItem__c where revvy__catelog_node__r.revvy__Id__c=\'S00001\' and revvy__quote__c = \'' + quoteId + '\'' ;
		pushTopic.ApiVersion = 39.0;
		pushTopic.NotifyForOperationCreate = true;
		pushTopic.NotifyForOperationUpdate = false;
		pushTopic.NotifyForOperationUndelete = false;
		pushTopic.NotifyForOperationDelete = false;
		pushTopic.NotifyForFields = 'Referenced';
		insert pushTopic;
    }
	public ToroSelectPriceProgramController() {
		isPricingEditable = false;
		sku2QuoteItems = new Map<String, Set<Id>>();
		productInfoList = new List<ProductInfo> ();
		quoteId = ApexPages.currentPage().getParameters().get('id');
		system.debug('quoteId='+quoteId);
		revvy__MnQuote__c currentQuote = [select Id, Pricing_Program_Name__c, Price_Method__c from revvy__MnQuote__c where Id=:quoteId];
		selectedPricingProgram = currentQuote.Pricing_Program_Name__c;
		selectedPricingMethod = currentQuote.Price_Method__c;
		system.debug('+++++++++++++selectedPricingProgram=' + selectedPricingProgram);
		if(String.isBlank(selectedPricingProgram)) {
			selectedPricingProgram = 'Please select a Pricing Program';	
		}
		if(String.isBlank(selectedPricingMethod)) {
			selectedPricingMethod = '% off MSRP';	
		}
		
		system.debug('+++++++++++++selectedPricingProgram=' + selectedPricingProgram);	
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);
		decimal Award_of_DN = 0;
		decimal Off_MSRP = 0;
		system.debug('+++++++++++++selectedPricingProgram=' + selectedPricingProgram);
		

		pricingProgramSelectors = new List<QuoteItem.PricingProgramSelector>{new QuoteItem.PricingProgramSelector(null, selectedPricingProgram, selectedPricingMethod, Off_MSRP, Award_of_DN, null)};
		List<Rebate_Header__c> pricingPrograms = [select name, Pricing_Program_Type__c, stateprovince__c from Rebate_Header__c  where name = :selectedPricingProgram]; 
		if(pricingPrograms.size() > 0) {
			if(pricingPrograms[0].Pricing_Program_Type__c == 'State Contract')	{
				priceMethodOptions = new List<SelectOption> { new SelectOption('% off MSRP','% off MSRP')};	
			} else {
				priceMethodOptions = new List<SelectOption> { new SelectOption('% of DNET','% of DNET'), new SelectOption('% off MSRP','% off MSRP')};
			}
		}
	}
    
    public void updatePerformanceParts() {
    		
    	String setPerformancePart = Apexpages.currentPage().getParameters().get('setPerformancePart');
    	boolean bSetPerformancePart = Boolean.valueOf(setPerformancePart);
    	prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
		helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
		helper.initialize(quoteId);
		helper.performancePartFlag = bSetPerformancePart;
        helper.quote.Performance_Part__c = bSetPerformancePart;
		system.debug('++++++++++++++++performancePartFlag=' + helper.performancePartFlag);
		system.debug('+++++++++++++++++quoteItemWrapperList=' + quoteItemWrapperList);
		system.debug('+++++++++++++++++quoteId=' + quoteId);
		system.debug('+++++++++++++++++selectedPricingProgram=' + selectedPricingProgram);
		system.debug('+++++++++++++++++selectedPricingMethod=' + selectedPricingMethod);
		List<Revvy__MnQuoteItem__c> qis = helper.calculateRebateAndMargin(quoteId, selectedPricingProgram, selectedPricingMethod, quoteItemWrapperList);
    	//performancePartFlag
		bdisplayPerformancePart = getDisplayPerformancePart();
		//helper.initialize(quoteId);
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);		
		
		/*
		System.debug('>>> updatePerformanceParts qis='+qis);
		
		List<Revvy__MnQuoteItem__c> qislist = [Select Id, REVVY__Unit_Price__c, Performance_Parts_Product__c, revvy__freezepricing__c 
		                                      , (Select Id, REVVY__Unit_Price__c, Performance_Part__c, revvy__freezepricing__c From REVVY__QuoteItemSubLine__r )
		                                   From Revvy__MnQuoteItem__c
		                                  Where Id = :quoteId 
		                                   ];
		                                 
		for(Revvy__MnQuoteItem__c qi:qislist) {
			System.debug('>>> updatePerformanceParts PP qi.REVVY__Unit_Price__c='+qi.REVVY__Unit_Price__c + ' - qi.Performance_Parts_Product__c='+ qi.Performance_Parts_Product__c + ' - qi.revvy__freezepricing__c='+qi.revvy__freezepricing__c);
			if(qi.REVVY__QuoteItemSubLine__r!=null) {
			for(REVVY__MnQuoteItemSubline__c qisl:qi.REVVY__QuoteItemSubLine__r) {
				
				System.debug('>>> updatePerformanceParts PP qisl.REVVY__Unit_Price__c='+qisl.REVVY__Unit_Price__c + ' - qisl.Performance_Parts_Product__c='+ qisl.Performance_Part__c + ' - qisl.revvy__freezepricing__c='+qi.revvy__freezepricing__c);
				
			}
			}

			
		}		
		*/
		
		
    }    
	public void updateQuote() {
		Long perfStart = System.limits.getCpuTime();
		system.debug('+++++++++++++++++quoteItemWrapperList=' + quoteItemWrapperList);
		system.debug('+++++++++++++++++quoteId=' + quoteId);
		system.debug('+++++++++++++++++selectedPricingProgram=' + selectedPricingProgram);
		system.debug('+++++++++++++++++selectedPricingMethod=' + selectedPricingMethod);
		prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
		helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
		helper.initialize(quoteId);
		long calBase = System.limits.getCpuTime();
		
		List<Revvy__MnQuoteItem__c> qis = helper.calculateRebateAndMargin(quoteId, selectedPricingProgram, selectedPricingMethod, quoteItemWrapperList);
		system.debug('perf-------calculateRebateAndMargin 1 ------------ = ' + (System.limits.getCpuTime() - calBase));
		/*
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		for(QuoteItem qItem : quoteItemWrapperList) {
			updatedQuoteItems.add(qItem.qi);
			REVVY__MnQuoteItem__c qi = qItem.qi;
			List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
			system.debug('----------------------' + qi);
			//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
			for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
				updatedQuoteItemSublines.add(qis);
				system.debug('--++--++--++='  + qis.percent_off_msrp__c + ' off DN=' + qis.percent_of_dnet__c);	
			}	
		}
		*/
		//update updatedQuoteItems;
		//update updatedQuoteItemSublines;
		system.debug('perf-------updateQuote 1 ------------ = ' + (System.limits.getCpuTime() - perfStart));
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);
		system.debug('perf------total time for updating quote------------ = ' + (System.limits.getCpuTime() - perfStart));
	}
	public void updateQuoteItem() {
		system.debug('quoteItem id = ' + quoteItemId);
		QuoteItem item = null;	
		for(QuoteItem qItem : quoteItemWrapperList) {
			//updatedQuoteItems.add(qItem.qi);
			REVVY__MnQuoteItem__c qi = qItem.qi;
			if(quoteItemId == qi.Id) {
				item = qItem;
				system.debug('quoteItem off_MSRP = ' + item.qi.off_msrp__c);
				break;	
			}
		}
		//if(item != null) {
			system.debug('+++++++++++++++++selectedPricingProgram=' + selectedPricingProgram);
			system.debug('+++++++++++++++++selectedPricingMethod=' + selectedPricingMethod);
			prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
			helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
			helper.initializeQuoteHeader(quoteId);
			helper.calculateRebateAndMargin(quoteId, selectedPricingProgram, selectedPricingMethod, quoteItemWrapperList);
			loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);
		//}
	}
	public void loadQuoteInformation(String pricingProgram, String pricingMethod) { 
		prcingProgramType = null;
		list<Rebate_Header__c> pricingProgramHeaders = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:pricingProgram];
		for(Rebate_Header__c  pp : pricingProgramHeaders) {
			prcingProgramType = pp.Pricing_Program_Type__c;	
		}
		helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
		helper.initialize(quoteId);
		quotes = new List<Revvy__MnQuote__c> {helper.quote};
		quoteItems = helper.quoteItems;
		List<Rebate_Header__c> pricingPrograms = [select name, Pricing_Program_Type__c, Minimum_Threshold__c, stateprovince__c from Rebate_Header__c order by name asc ];
        pricingProgramTypes = new Map<String, String>();
        for(Rebate_Header__c pp : pricingPrograms) {
        	pricingProgramTypes.put(pp.name, pp.Pricing_Program_Type__c);
        }
        //if('Large package'.equalsIgnoreCase(priceProgramType)) {
		quoteFieldsUpdatable = helper.getQuoteFieldsUpdatable();
		quoteItemFieldsUpdatable = helper.getQuoteItemFieldsUpdatable();
		quoteItemSublineFieldsUpdatable = helper.getQuoteItemSublineFieldsUpdatable(pricingMethod);
		String qtAccountStateCode = helper.quote.revvy__account__r.billingstatecode;
		quoteItemWrapperList = new List<QuoteItem>();
		Map<String, ProductInfo> productInfoMap = new Map<String, ProductInfo>();
		for(REVVY__MnQuoteItem__c qi : quoteItems) {
			if(String.isBlank(qi.Description__c)) {
				qi.Description__c=qi.Revvy__Product_Name_F__c;		
			}
            QuoteItem q = new QuoteItem();
            q.qi=qi; 
            if(qi.REVVY__QuoteItemSubLine__r!=null && qi.REVVY__QuoteItemSubLine__r.size()>0) {
                q.qislList=qi.REVVY__QuoteItemSubLine__r;
                for(REVVY__MnQuoteItemSubLine__c qis : qi.REVVY__QuoteItemSubLine__r) {
                	if(String.isBlank(qis.Description__c)) {
						qis.Description__c=qis.REVVY__Catalog_Node__r.Name;		
					}
                }
            }
            q.ppSelectors = new List<QuoteItem.PricingProgramSelector>{ new QuoteItem.PricingProgramSelector(qi.Id, qi.Pricing_Program__c, qi.Select_a_Price_Method__c
            	, qi.Off_MSRP__c, qi.Award_of_DN__c, qi.Selected_Off_MSRP__c) };
            	
            system.debug('&&&&&&&&&&&&&&&&&&&&&&&' + q.ppSelectors);
            quoteItemWrapperList.add(q);
            
            if(!sku2QuoteItems.containsKey(qi.Revvy__Product_Id_F__c)) {
            	sku2QuoteItems.put(qi.Revvy__Product_Id_F__c, new Set<Id>());
            }
            sku2QuoteItems.get(qi.Revvy__Product_Id_F__c).add(qi.Id);
            productInfoMap.put(qi.Revvy__Product_Id_F__c, new ProductInfo(qi.Revvy__Product_Name_F__c, qi.Revvy__Product_Id_F__c));
        }
        productInfoList = productInfoMap.values();
        pricingProgramOptions = new List<SelectOption>();
        priceMethodOptions = new List<SelectOption> { new SelectOption('% of DNET','% of DNET'), new SelectOption('% off MSRP','% off MSRP')};
        
        //eligibility checking here
        pricingProgramOptions.add(new SelectOption('Please select a Pricing Program', 'Please select a Pricing Program'));
        for(Rebate_Header__c pp : pricingPrograms) {
        	ToroPricingProgram eligibleHelper = ToroPriceProgramFactory.createPricingProgram(pp.Pricing_Program_Type__c);
        	if((eligibleHelper != null) && eligibleHelper.isEligible(pp, helper.quote, helper.quoteItems)) {
	        	pricingProgramOptions.add(new SelectOption(pp.name, pp.name));	
	        	
	        }
        }
        pricingMethodLabel = selectedPricingMethod == '% of DNET' ? 'Award % of DN' : '% Off MSRP';
        system.debug('pricingProgramTypes=' + pricingProgramTypes);	
	}
	
	public PageReference switchDNetMsrf() {
		system.debug('&&&&&&&&&&&&&&&&&&&& selectedPricingMethod = ' + selectedPricingMethod);
		pricingMethodLabel = selectedPricingMethod == '% of DNET' ? 'Award % of DN' : '% Off MSRP';	
		return null;
	}
	public PageReference returnToQuote() {
		PageReference newPage = new PageReference('https://toro--cpqdev.cs91.my.salesforce.com/'+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}
	
	public PageReference addSupportPlus() {
		PageReference newPage = new PageReference('https://toro--cpqdev.cs91.my.salesforce.com/apex/ToroSupportPlus?id='+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}
	
	public PageReference submitSupportPlus() {
		system.debug('+++++++++++++++++quoteItemWrapperList=' + quoteItemWrapperList);
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItem__c> insertQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		List<REVVY__MnQuoteItemSubline__c> insertQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		for(QuoteItem qItem : quoteItemWrapperList) {
			REVVY__MnQuoteItem__c qi = qItem.qi;
			decimal supportPlusQty = qi.Support_Plus_Quantity__c == null ? 0 : qi.Support_Plus_Quantity__c;
			if(supportPlusQty != 0) {
				decimal diff = qi.revvy__Quantity__c - qi.Support_Plus_Quantity__c ; 
				if(diff != 0) {
					REVVY__MnQuoteItem__c clonedQi = qi.clone(false, true, false, false); //keep Id and deep-clone	
					qi.revvy__Quantity__c = diff;
					clonedQi.revvy__Quantity__c = qi.Support_Plus_Quantity__c;
					qi.Support_Plus_Quantity__c=0;
					clonedQi.Support_Plus_Quantity__c=0;
					clonedQi.revvy__Unit_price__c = 0;
					clonedQi.revvy__price__c=0;
					qi.Support_Plus_Item__c = true;
					clonedQi.Support_Plus_Item__c=true;
					system.debug('------- new quote item Id=' + clonedQi.Id + ' quote Id = ' + clonedQi.Revvy__Quote__c);
					updatedQuoteItems.add(qi);
					insertQuoteItems.add(clonedQi);
				} else {
					qi.revvy__Quantity__c=0;
					qi.Support_Plus_Item__c = true;
					qi.Misc_Style__c='NoCharge';
					updatedQuoteItems.add(qi); 
				}
			}
			system.debug('--------------qi product =' + qi.revvy__Product_Name_F__c + ' qty =' + qi.revvy__Quantity__c + ' Support_Plus_Quantity__c =' + qi.Support_Plus_Quantity__c);
			List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
			system.debug('----------------------' + qi);
			if(qiSub!=null && qiSub.size()>0) {
				//system.debug('product name=' + qi.revvy__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
				for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
					system.debug('--------------qis product =' + qis.revvy__Catalog_Node__r.name + ' qty =' + qis.revvy__Quantity__c + ' Support_Plus_Quantity__c =' + qis.Support_Plus_Quantity__c);	
					decimal supportPlusQty2 = qis.Support_Plus_Quantity__c == null ? 0 : qis.Support_Plus_Quantity__c;
					if(supportPlusQty2 != 0) {
						decimal diff = qis.revvy__Quantity__c - qis.Support_Plus_Quantity__c ; 
						if(diff != 0) {
							REVVY__MnQuoteItemSubline__c clonedQis = qis.clone(false, true, false, false); //keep Id and deep-clone	
							qis.revvy__Quantity__c = diff;
							clonedQis.revvy__Quantity__c = qis.Support_Plus_Quantity__c;
							qis.Support_Plus_Quantity__c=0;
							qis.Apply_Support_Plus__c=true;
							clonedQis.Support_Plus_Quantity__c=0;
							clonedQis.revvy__Unit_price__c = 0;
							clonedQis.revvy__price__c=0;
							clonedQis.Apply_Support_Plus__c=true;
							clonedQis.Misc_Style__c='NoCharge';
							updatedQuoteItemSublines.add(qis);
							insertQuoteItemSublines.add(clonedQis);
						} else {
							qis.revvy__Quantity__c = 0;
							qis.Apply_Support_Plus__c=true;
							qis.Misc_Style__c='NoCharge';
							updatedQuoteItemSublines.add(qis);
						}
						//system.debug('------- new quote item subline Id=' + clonedQis.Id + ' quote item Id = ' + clonedQis.Revvy__QuoteItem__c);
					}
					else{
						qis.Apply_Support_Plus__c=false;	
					}
				}
			}
		}
		
		if(updatedQuoteItems.size() > 0) {
			update updatedQuoteItems;	
		}
		if(insertQuoteItems.size() > 0) {
			insert insertQuoteItems;	
		}
		if(updatedQuoteItemSublines.size() > 0) {
			update updatedQuoteItemSublines;	
		}
		if(insertQuoteItemSublines.size() > 0) {
			insert insertQuoteItemSublines;	
		}
		
		PageReference newPage = new PageReference('/apex/ToroSelectPriceProgram?id='+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}
	
	public PageReference returnToPricingPage() {
		PageReference newPage = new PageReference('/apex/ToroSelectPriceProgram?id='+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}
	
	public PageReference manageProducts() {
		PageReference newPage = new PageReference('https://toro--cpqdev--revvy.cs91.visual.force.com/apex/REVVY__PMnUIShell#mnquote/detail/'+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}
	private void switchPricingProgramAndNMethod() {
		selectedPricingProgram = Apexpages.currentPage().getParameters().get('priceProgram');
		selectedPricingMethod = Apexpages.currentPage().getParameters().get('priceMethod');	
		system.debug('-----switchPricingMethod------ selectedPricingMethod =' + selectedPricingMethod);
		system.debug('-----switchPricingMethod------ quoteId =' + quoteId);
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		try{
			prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
			List<REVVY__MnQuoteItem__c> quoteItemList = [select id, REVVY__Price__c, REVVY__SuggestedPrice__c, (select id,REVVY__Price__c, REVVY__SuggestedPrice__c from REVVY__QuoteItemSubLine__r) from REVVY__MnQuoteItem__c where Revvy__Quote__c = :quoteId];
			for(REVVY__MnQuoteItem__c qi : quoteItemList) {
				qi.Pricing_Program__c = selectedPricingProgram;
				qi.Select_a_Price_Method__c = selectedPricingMethod;
				//qi.Award_of_DN__c = 0;
				qi.Rebate_as_a_of_DN__c = 0;
				if('Large package'.equalsIgnoreCase(prcingProgramType)) {
					qi.Award_of_DN__c = 0;
					qi.Off_MSRP__c = 0;	
					if(!qi.Performance_Parts_Product__c) {
						if('% of DNET'.equalsIgnoreCase(selectedPricingMethod)) {
							qi.Award_Price__c = qi.Revvy__SuggestedPrice__c;	
						} else if('% off MSRP'.equalsIgnoreCase(selectedPricingMethod) ) {
							qi.Award_Price__c = qi.Revvy__Price__c;
						}
					}	
				}
				//qi.Off_MSRP__c = 0;	
				/*
				if(!qi.Performance_Parts_Product__c) {
					if('% of DNET'.equalsIgnoreCase(selectedPricingMethod)) {
						qi.Award_Price__c = qi.Revvy__SuggestedPrice__c;	
					} else if('% of MSRP'.equalsIgnoreCase(selectedPricingMethod) ) {
						qi.Award_Price__c = qi.Revvy__Price__c;
					}
				}
				*/
				updatedQuoteItems.add(qi);			
				for(revvy__MnQuoteItemSubline__c s : qi.REVVY__QuoteItemSubLine__r) {
					if('Large package'.equalsIgnoreCase(prcingProgramType)) {
						s.Percent_of_DNet__c = 0;
						s.Percent_Off_MSRP__c = 0;	
						if(!s.Performance_Part__c) {
							if('% of DNET'.equalsIgnoreCase(selectedPricingMethod)) {
								s.Award_Price__c = s.Revvy__SuggestedPrice__c;	
							} else if('% off MSRP'.equalsIgnoreCase(selectedPricingMethod) ) {
								s.Award_Price__c = s.Revvy__Price__c;
							}
						}
					}
					//s.Percent_of_DNet__c = 0;
					//s.Percent_Off_MSRP__c = 0;
					//s.Award_Price__c = 0;
					/*
					if(!s.Performance_Part__c) {
						if('% of DNET'.equalsIgnoreCase(selectedPricingMethod)) {
							s.Award_Price__c = s.Revvy__SuggestedPrice__c;	
						} else if('% of MSRP'.equalsIgnoreCase(selectedPricingMethod) ) {
							s.Award_Price__c = s.Revvy__Price__c;
						}
					}
					*/
					updatedQuoteItemSublines.add(s);			
				}	
			}
		} catch (Exception e) {
			
		}
		
		if(updatedQuoteItems.size() > 0) {
			update updatedQuoteItems;	
		}
		if(updatedQuoteItemSublines.size() > 0) {
			update updatedQuoteItemSublines;	
		}
		Revvy__MnQuote__c updateQuote = new Revvy__MnQuote__c(Id=quoteId, Price_Method__c =selectedPricingMethod, 
				Pricing_Program_Name__c=selectedPricingProgram, Pricing_Program_Type__c = prcingProgramType);
		update updateQuote;
		
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);	
	}
	public void switchPricingMethod() {
		switchPricingProgramAndNMethod();	
	}
	public void switchPricingProgram() {
		switchPricingProgramAndNMethod();
		/*
		selectedPricingProgram = Apexpages.currentPage().getParameters().get('priceProgram');
		selectedPricingMethod = Apexpages.currentPage().getParameters().get('priceMethod');
		system.debug('----------- selectedPricingProgram =' + selectedPricingProgram);
		system.debug('----------- selectedPricingMethod =' + selectedPricingMethod);
		prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
		system.debug('----------- prcingProgramType =' + prcingProgramType);
		helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
		system.debug('----------- quoteId =' + quoteId);
		Revvy__MnQuote__c updateQuote = new Revvy__MnQuote__c(Id=quoteId, Pricing_Program_Name__c =selectedPricingProgram, Pricing_Program_Type__c =  prcingProgramType);
		update updateQuote;
		helper.initialize(quoteId);	
		List<REVVY__MnQuoteItem__c> quoteItemList = [select id from REVVY__MnQuoteItem__c where Revvy__Quote__c = :quoteId];
		for(REVVY__MnQuoteItem__c qi : quoteItemList) {
			qi.Pricing_Program__c = selectedPricingProgram;
			qi.Select_a_Price_Method__c = selectedPricingMethod;
		}
		update quoteItemList;
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);
		
		
		pricingProgramSelectors = new List<QuoteItem.PricingProgramSelector>{new QuoteItem.PricingProgramSelector(null,selectedPricingProgram, selectedPricingMethod, null, null,null)};
		*/
		bdisplayPerformancePart = getDisplayPerformancePart();
	}
	public void updateStateContractQuote() {
		system.debug('updateStateContractQuote');
		selectedPricingProgram = Apexpages.currentPage().getParameters().get('priceProgram');
		selectedPricingMethod = Apexpages.currentPage().getParameters().get('priceMethod');
		system.debug('+++++++++updateStateContractQuote selectedPricingProgram='+selectedPricingProgram);
		decimal Award_of_DN = null;
		decimal Off_MSRP = null;
		prcingProgramType = [select Id, Pricing_Program_Type__c from Rebate_Header__c where name=:selectedPricingProgram limit 1].Pricing_Program_Type__c;
		Revvy__MnQuote__c updateQuote = new Revvy__MnQuote__c(Id=quoteId, Pricing_Program_Name__c =selectedPricingProgram, Pricing_Program_Type__c =  prcingProgramType);
		update updateQuote;
		helper = ToroPriceProgramFactory.createPricingProgram(prcingProgramType);
		helper.initialize(quoteId);
		List<Revvy__MnQuoteItem__c> qis = helper.calculateRebateAndMargin(quoteId, selectedPricingProgram, selectedPricingMethod, quoteItemWrapperList);
		for(Revvy__MnQuoteItem__c qi : helper.quoteItems) {
			String pricingProgram = qi.Select_Price_Program_Type__c;
			String pricingMethod = qi.Select_a_Price_Method__c;
			/*
			if(Const_PM_Percent_Of_DNET.equalsIgnoreCase(pricingMethod)) {
				if(Award_of_DN == null) {
					Award_of_DN = qi.Award_of_DN__c;
				} else if(Award_of_DN != qi.Award_of_DN__c) {
					Award_of_DN = null;
					break;
				}
				
			} else if(Const_PM_Percent_Off_MSRP.equalsIgnoreCase(pricingMethod)) {
				if(Off_MSRP == null) {
					Off_MSRP = qi.Off_MSRP__c;
				} else if(Off_MSRP != qi.Off_MSRP__c) {
					Off_MSRP = null;
					break;
				}
			}	
			*/
		}
		List<REVVY__MnQuoteItem__c> quoteItemList = [select id from REVVY__MnQuoteItem__c where Revvy__Quote__c = :quoteId];
		for(REVVY__MnQuoteItem__c qi : quoteItemList) {
			qi.Pricing_Program__c = selectedPricingProgram;	
		}
		update quoteItemList;
		loadQuoteInformation(selectedPricingProgram, selectedPricingMethod);
		priceMethodOptions = new List<SelectOption> { new SelectOption('% off MSRP','% off MSRP')};
		pricingProgramSelectors = new List<QuoteItem.PricingProgramSelector>{new QuoteItem.PricingProgramSelector(null,selectedPricingProgram, selectedPricingMethod, null, null,null)};
		
		
	}
	public Id currentQuoteItem {get; set; }
	public void updateStateContractQuoteItem() {
		system.debug('updateStateContractQuoteItem');
		Id sfdcId = Apexpages.currentPage().getParameters().get('sfdc_id');
		currentQuoteItem = sfdcId;
		string priceMethod = Apexpages.currentPage().getParameters().get('priceMethod');
		decimal newVal = null;
		decimal originalVal = null;
		try {
			newVal = decimal.valueOf(Apexpages.currentPage().getParameters().get('newVal'));
		} catch ( Exception e) {}
		try {
			originalVal = decimal.valueOf(Apexpages.currentPage().getParameters().get('originalVal'));
		} catch (Exception e) {}
		system.debug('updateStateContractQuoteItem -- newVal=' + newVal);
		system.debug('updateStateContractQuoteItem -- originalVal=' + originalVal);
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		if(newVal != null && originalVal != null) {
			REVVY__MnQuoteItem__c qi = [select id, REVVY__Price__c, (select Id from REVVY__QuoteItemSubLine__r) from REVVY__MnQuoteItem__c where id = :sfdcId];
			decimal basePrice = qi.REVVY__Price__c;
			qi.Off_MSRP__c = newVal;
			qi.Award_Price__c = basePrice * (100-qi.Off_MSRP__c)/100;
			system.debug('updateStateContractQuoteItem -- qi=' + qi);
			for(Revvy__MnQuoteItemSubline__c qis : qi.REVVY__QuoteItemSubLine__r ) {
				qis.Percent_of_DNet__c = qi.Award_of_DN__c;
				qis.Percent_Off_MSRP__c = qi.Off_MSRP__c;	
				updatedQuoteItemSublines.add(qis);
			}
			update updatedQuoteItemSublines;
			update qi;
			loadQuoteInformation(selectedPricingProgram, priceMethod);
			priceMethodOptions = new List<SelectOption> { new SelectOption('% off MSRP','% off MSRP')};
			pricingProgramSelectors = new List<QuoteItem.PricingProgramSelector>{new QuoteItem.PricingProgramSelector(null, selectedPricingProgram, priceMethod, null, null,null)};
				
		}
	}
    public class ProductInfo {
    	public String sku {get; set; }
    	public String name {get; set; }
    	public ProductInfo(String name, String sku) {
    		this.name = name;
    		this.sku = sku;	
    	}
    }
    public class QuoteItemList {
        transient public List<QuoteItem> qiList { get; set; }
    }
    
    public boolean getDisplayPerformancePart() {
        boolean bdisplayPerformancePart = false;
        System.debug('>>> display selectedPricingProgram='+ selectedPricingProgram);
        if(!String.isEmpty(selectedPricingProgram)) {
            for(Rebate_Header__c rh:[Select Id, Name, Pricing_Program_Type__c From Rebate_Header__c
                                     Where Name = :selectedPricingProgram
                                       And Pricing_Program_Type__c  NOT IN ('State Contract','National Account')
                                    ]) {
            	bdisplayPerformancePart = true;                             
            }
        }
        return bdisplayPerformancePart;
    }
}