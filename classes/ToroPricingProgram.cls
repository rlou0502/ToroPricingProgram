public virtual class ToroPricingProgram {
	public Revvy__MnQuote__c quote { get; set; }
	public List<Revvy__MnStrategy4__c> quoteItems { get; set; }
	public boolean performancePartFlag { get; set { performancePartFlag = value; if(quote != null) {quote.Performance_Part__c=value;}}}
	public decimal setupFeePercentage { get; set; }
	public String pricingMethod { get; set; }
	public Boolean blendedPercentOfDnChanged { get; set; }

	public virtual boolean skipMSRPRangeCheck(){
		return false;
	}

	public boolean getAllowSupportPlusIgnoreDNetAccess(String pricingProgram, Id quoteId) {
		List<Revvy__MnStrategy4__c> qiExtensions;
		if (this.quoteItems == null) {
			qiExtensions = [SELECT Pricing_Program__c FROM Revvy__MnStrategy4__c WHERE Mn_Quote__c = :quoteId];	
		}

		else {
			qiExtensions = this.quoteItems;
		}

		if (String.isBlank(pricingProgram)) return false;
		
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(ppd.externalId);
		Boolean allQuoteItemsAreSecondary = true;
		for (Revvy__MnStrategy4__c qi : qiExtensions) {
			if (String.isNotBlank(qi.Pricing_Program__c)) {
				ToroPricingProgramData qiPPD = new ToroPricingProgramData(qi.pricing_program__c);
				if (ppd.externalId.equalsIgnoreCase(qiPPD.externalId)) {
					allQuoteItemsAreSecondary = false;
					break;
				}
			}
		}

		boolean ret = pp_header.AllowSupportPlus__c && !allQuoteItemsAreSecondary;
		return ret == null ? false : ret;
	}

	public boolean getIsSupportPlusValueDollars(String pricingProgram) {
		System.debug('\n\n@@getIsSupportPlusValueDollars\n\n');
		if (String.isBlank(pricingProgram)) return false;
		ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
		Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(ppd.externalId);
		System.debug('\n\n@@pp_header: ' + pp_header + '\n\n');
		return 'Award Only'.equals(pp_header.Determines_Support_Plus_Allowance__c);
	}
	public boolean chainCall { get; set;}
	public string payloadOfChainCall { get; set; }
	public Map<String,Decimal> performancePartMap {get;set;}
	//public abstract List<Schema.FieldSetMember> getQuoteItemSublineFields();
	//public abstract List<Schema.FieldSetMember> getQuoteItemFields();
	public virtual List<Schema.FieldSetMember> getQuoteFields() {
        system.debug(logginglevel.info, 'ToroPricingProgram.getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.Pricing_Program_Quote_Header_Fields.getFields();
	}
	public virtual List<Schema.FieldSetMember> getQuoteUpdatableFields() {
		Map<String, Schema.SObjectField> fieldMap = SObjectType.Revvy__MnQuote__c.fields.getMap();
		return SObjectType.Revvy__MnQuote__c.FieldSets.Quote_Header_Updatable_Fields.getFields();
	}
/* 	for quote item /subline extensions */
	public virtual List<Schema.FieldSetMember> removeDNetFieldsFromSet(List<Schema.FieldSetMember> sourceFS, List<Schema.FieldSetMember> removeFS)  {
		Set<String> dnetMap = new Set<String>();
		for(Schema.FieldSetMember fs : removeFS) {
			dnetMap.add(fs.fieldPath);
		}
		system.debug('removeDNetFieldsFromSet--' + dnetMap);
		for(integer i = sourceFS.size()-1; i >= 0; i--) {
			Schema.FieldSetMember fs2 = sourceFS[i];

			if(dnetMap.contains(fs2.fieldPath)) {
				system.debug('removeDNetFieldsFromSet--fs2=' + fs2);
				Schema.FieldSetMember fs = sourceFS.remove(i);
				system.debug('removeDNetFieldsFromSet--removed =' + fs);
			}
		}
		return sourceFS;
	}

	public virtual List<Schema.FieldSetMember> getToroQuoteItemDNetFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.DNet_Field_Set.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineDNetFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.DNet_Field_Set.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteDNetFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.DNet_Field_Set.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Quote_Summary.getFields();
		//return SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Revvy__MnStrategy5__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
		//return SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSummaryUpdatableFields() {
		return null;
	}
	public virtual List<ToroSelectOption> retrieveDemoPricingProgramOptions() {
		return new List<ToroSelectOption>();
	}

	public virtual List<FieldSetMember> addUpdatableFieldSetMember(List<Schema.FieldSetMember> fieldSet, List<Schema.FieldSetMember> updatableFieldSet, Map<String, Schema.SObjectField> fieldMap) {
		set<String> updatableFields = new set<String>();
		if(updatableFieldSet != null) {
	    	for(Schema.FieldSetMember s : updatableFieldSet) {
	    		if(fieldMap.get(s.fieldPath).getDescribe().isUpdateable()) {
	    			updatableFields.add(s.fieldPath.toLowerCase());
	    		}
	    	}
		}
		system.debug('updatableFields='+updatableFields);
        List<FieldSetMember> fset = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSet) {
        	FieldSetMember nfsm = new FieldSetMember(f);
        	nfsm.updatable=false;
        	//system.debug('f.fieldPath='+f.fieldPath);
        	if(updatableFields.contains(f.fieldPath.toLowerCase())) {
        		nfsm.updatable=true;
        	}
            fset.add(nfsm);
        }
        return fset;
	}

	public virtual List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}

	public virtual Map<String, Object >retrieveSecondaryPrograms(String pricingProgramExtId) {
		system.debug('pricingProgramExtId = ' + pricingProgramExtId);
		Map<String, Object > result = null;
		Revvy__MnStrategy1__c pricingProgram = ToroCacheManager.getPricingProgram(pricingProgramExtId);
		List<ToroSelectOption> ppSelectOptions = ToroCacheManager.getPricingProgramEligibility(quote.Id);
		Set<String> eligiblePricingProgramSet = new Set<String>();
		for(ToroSelectOption opt : ppSelectOptions) {
			ToroPricingProgramData ppd = new ToroPricingProgramData(opt.value);
			eligiblePricingProgramSet.add(ppd.externalId);
		}
		system.debug('retrieveSecondaryPrograms=' + eligiblePricingProgramSet);
		if(String.isNotBlank(pricingProgram.SecondaryProgram__c)) {
			result = new Map<String, Object >{pricingProgramExtId=>pricingProgram.Name};
			String[] ppParts = pricingProgram.SecondaryProgram__c.split(';');
			List<String> pps=new List<String>();
			for(String s : ppParts) {
				if(eligiblePricingProgramSet.contains(s)) {
					pps.add(s);	
				}	
			}
			Set<String> senondaryPricingProgramSet = new Set<String>();
			List<Revvy__MnStrategy1__c> rebates = [Select Id, Name, ExternalId__c, Parent_Program__r.ExternalId__c
					From Revvy__MnStrategy1__c where Status__c = 'Active' AND Parent_Program__r.ExternalId__c  in :pps and Parent_Program__r.Hide_Children__c = FALSE  order by Sequence__c ];
			for(Revvy__MnStrategy1__c pp : rebates) {
				if(!result.containsKey(pp.Parent_Program__r.ExternalId__c)) {
					result.put(pp.Parent_Program__r.ExternalId__c, new Map<String, String>());
				}
				Map<String, String> ppOptions = (Map<String, String>) result.get(pp.Parent_Program__r.ExternalId__c);
				ppOptions.put(pp.ExternalId__c, pp.Name);
				senondaryPricingProgramSet.add(pp.Parent_Program__r.ExternalId__c);
			}
			for(String k : pps) {
				if(!senondaryPricingProgramSet.contains(k)) {
					Revvy__MnStrategy1__c ppTemp = ToroCacheManager.getPricingProgram(k);
					result.put(k, ppTemp.Name);
				}
			}
		} else {
			List<Revvy__MnStrategy1__c> rebates = [Select Id, ExternalId__c, Name, Parent_Program__r.ExternalId__c
					From Revvy__MnStrategy1__c where Parent_Program__r.ExternalId__c = :pricingProgramExtId and Parent_Program__r.Hide_Children__c = FALSE order by Sequence__c];
			result = new Map<String, Object >();
			if(rebates.size() > 0) {
				result.put(pricingProgramExtId, 'Please Select a Pricing Program');
				for(Revvy__MnStrategy1__c pp : rebates) {
					result.put(pp.ExternalId__c, pp.Name);
				}
			}
		}
		system.debug('retrieveSecondaryPrograms = ' + result);
		return result;
	}

	public virtual boolean displayPerformancePart() {
		return false;
	}
	public virtual boolean displaySetupFee() {
		return false;
	}

	public virtual String displayContractMessage(String pricingProgram) {
		String ret = null;
		if(String.isNotBlank(pricingProgram)) {
			ToroPricingProgramData ppd = new ToroPricingProgramData(pricingProgram);
			Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(ppd.externalId);
			if(pp_header != null) {
				ret = pp_header.Contract_Message__c;
			}
		}
		return ret;
	}
	
	public virtual List<Revvy__MnStrategy4__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		system.debug('ToroPricingProgram preCalculateRebateMargin');
		
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			qi.DrivenByGP__c=false;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					system.debug('ToroPricingProgram qis.Pricing_Program_Product_Type__c=' + qis.Pricing_Program_Product_Type__c);
					if(qis.Pricing_Program_Product_Type__c == 'TPP') {
						system.debug('ToroPricingProgram qis.Quote_Item_Sub_Line__r.TPP_DNet__c=' + qis.Quote_Item_Sub_Line__r.TPP_DNet__c);
						qis.DNet_Price__c = qis.Quote_Item_Sub_Line__r.TPP_DNet__c;	
					}
				}
			}
		}
		return 	quoteItemList;
	}
	public virtual List<Revvy__MnStrategy4__c> preSaveCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){

		System.debug('\n\n@@ToroPricingProgram preSaveCalculateRebateMargin\n\n'); 
		System.debug('\n\n@@quote: ' + quote + '\n\n');
		System.debug('\n\n@@quote: ' + priceProgram );
		
		ToroPricingProgramData ppd = new ToroPricingProgramData(priceProgram);
		System.debug('\n\n@@quote: ' + ppd.externalId );
		Revvy__MnStrategy1__c pp_header = ToroCacheManager.getPricingProgram(ppd.externalId);
		System.debug('\n\n@@pp_header:' + pp_header + '\n\n'); 
		if (pp_header != null && pp_header.AllowSupportPlus__c) { 
			// ToroSupportPlusHelper.updateAllowanceAndDistResp(quote, pp_header); 
			ToroSupportPlusData spData = new ToroSupportPlusData(quoteId, pp_header.ExternalId__c, quoteItemList);
			// spData.initializeSupportPlusQuoteTotals(this.quote.Toro_Total_DNet__c, this.quote.Toro_Award__c); 
			this.quote.Distributor_Responsibility__c       = spData.quote.Distributor_Responsibility__c;
			this.quote.Toro_Support_Plus_Allowance__c      = spData.quote.Toro_Support_Plus_Allowance__c;
			this.quote.Toro_Support_Plus_Allowance_Used__c = spData.quote.Toro_Support_Plus_Allowance_Used__c;
			this.quote.SP_Total_Extended_DNET__c           = spData.quote.SP_Total_Extended_DNET__c;
			this.quote.SP_Adjusted_Toro_Award__c           = spData.quote.SP_Adjusted_Toro_Award__c;
			this.quote.SP_Adjusted_Ext_Award__c            = spData.quote.SP_Adjusted_Ext_Award__c;
			this.quote.SP_Toro_Responsibility__c           = spData.quote.SP_Toro_Responsibility__c;
			this.quote.SP_Ext_Dist_Responsibility__c       = spData.quote.SP_Ext_Dist_Responsibility__c;
			//adjust rebate/gp based on support plus distributor cost
			
			system.debug('preSaveCalculateRebateMargin quote.Toro_Total_Rebate__c = ' + quote.Toro_Total_Rebate__c); 
			Decimal disti_cost 							   = CMnQuoteUtil.defaultDecimal(this.quote.Distributor_Contribution__c);
			system.debug('preSaveCalculateRebateMargin disti_cost = ' + disti_cost);
			quote.Toro_Total_Rebate__c             		   = CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Rebate__c) - disti_cost;
			system.debug('preSaveCalculateRebateMargin quote.Toro_Total_Rebate__c = ' + quote.Toro_Total_Rebate__c); 
			quote.Toro_Total_Quote_Gross_Profit__c         = CMnQuoteUtil.defaultDecimal(quote.Toro_Award__c) - CMnQuoteUtil.defaultDecimal(quote.Toro_Total_DNet__c) + CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Rebate__c);
			if(quote.Toro_Award__c != null && quote.Toro_Award__c != 0) {
				quote.Toro_Total_Quote_Gross_Profit_Percent__c = quote.Toro_Total_Quote_Gross_Profit__c/quote.Toro_Award__c * 100;
			}
			quote.Toro_Total_Quote_Rebate__c = quote.Toro_Total_Rebate__c;
			system.debug('preSaveCalculateRebateMargin quote.Toro_Total_Quote_Gross_Profit__c = ' + quote.Toro_Total_Quote_Gross_Profit__c);
			system.debug('preSaveCalculateRebateMargin quote.Toro_Total_Quote_Gross_Profit_Percent__c = ' + quote.Toro_Total_Quote_Gross_Profit_Percent__c);
		}

		else {
			ToroSupportPlusHelper.clearSupportPlusValuesOnQuote(quote);
		}
		
		
		ToroCacheManager.putQuote(quote);
		
		return 	quoteItemList;
	}
	public virtual List<Revvy__MnStrategy4__c> postCalculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(qi.Product_Id__c.startsWIth('L000')){
				qi.Off_MSRP__c=0;
				qi.PricingMethodValue__c='0';
			}
		}

		return 	quoteItemList;
	}
	public virtual List<Revvy__MnStrategy4__c> postSaveQuoteItemList(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		return 	quoteItemList;
	}
	
	public virtual List<Revvy__MnStrategy4__c> calculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList, boolean save ){
		this.pricingMethod = priceMethod;
		Long perfStart = System.limits.getCpuTime();
		performancePartMap = ToroPerformancePartPricingProgramHelper.retrievePerformancePart();
		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			if(String.isBlank(qi.pricing_Program__c)) {
				qi.pricing_Program__c = priceProgram; 	
			}
			
		}
		//call pre
		system.debug(logginglevel.info, 'calling calculateRebateMarginImpl quoteId =' + quoteId + ' -- priceProgram' + priceProgram);
		system.debug(logginglevel.info, 'calling calculateRebateMarginImpl priceMethod =' + priceMethod + ' -- ' + quoteItemList);
		List<Revvy__MnStrategy4__c> lQuoteItemList = preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		lQuoteItemList = calculateRebateMarginImpl(quoteId, priceProgram, priceMethod, lQuoteItemList);
		lQuoteItemList = postCalculateRebateMarginImpl(quoteId, priceProgram, priceMethod, lQuoteItemList);
		system.debug(logginglevel.info,'calling calculateRebateMarginImpl took ' + (System.limits.getCpuTime()-perfStart));
		lQuoteItemList = calculateExtendedFields(lQuoteItemList);
		quote.Is_Dirty__c = false;
		ToroCacheManager.putQuote(quote);
		lQuoteItemList = preSaveCalculateRebateMargin(quoteId, priceProgram, priceMethod, lQuoteItemList);
		system.debug(logginglevel.info,'calling preSaveCalculateRebateMargin');

		system.debug(logginglevel.info,'calling saveQuoteItemList');


		if(save) {
			lQuoteItemList = saveQuoteItemList(lQuoteItemList);
			lQuoteItemList = postSaveQuoteItemList(quoteId, priceProgram, priceMethod, lQuoteItemList);
			ToroCacheManager.refreshQuote(quote.Id);
		}

		// ToroCacheManager.putQuote(quote);
		system.debug(logginglevel.info,'calling saveQuoteItemList took ' + (System.limits.getCpuTime()-perfStart));
		return lQuoteItemList;
	}

	/*
	public virtual List<Revvy__MnStrategy4__c> updateQuote(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		List<Revvy__MnStrategy4__c> qiList = calculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		return saveQuoteItemList(qiList);
	}
	*/

	//Method calculateRebateMarginImpl is a template method called by calculateRebateMargin
	public virtual List<Revvy__MnStrategy4__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Revvy__MnStrategy4__c> quoteItemList ){
		system.debug('inside base calculateRebateMarginImpl');
		return quoteItemList;
	}
	
	public decimal getDNetPrice(REVVY__MnStrategy5__c qis) {
		decimal lDNetPrice = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);	
		if(qis.Pricing_Program_Product_Type__c != 'Standard' && qis.Pricing_Program_Product_Type__c != 'TPP') {
			lDNetPrice=0;		
		} 
		return lDNetPrice;
	}
	public virtual List<Revvy__MnStrategy4__c> calculateExtendedFields(List<Revvy__MnStrategy4__c> quoteItemList) {
		decimal quoteMSRP=0;
		decimal quoteTotalAward =0;
		decimal quoteTotalToroAward=0;
		decimal quoteTotalDNet =0;
		decimal quoteTotalSetupFee=0;
		decimal quoteToroTotalDNet=0;
		decimal quoteTotalGP=0;
		decimal quoteTotalRebate=0;
		decimal quoteTotalDnetWOTppAllied = 0;
		decimal quoteTPPAppliedDNet = 0;
		decimal quoteToroDNet = 0;
		decimal quoteTPPAppliedMSRP = 0;
		decimal quoteToroMSRP = 0;
        decimal quoteTPPAppliedAward = 0;
		decimal quoteToroAward = 0;
		quote.TPP_Total__c = 0;
		quote.Allied_Non_Toro_Total__c = 0;

		for (Revvy__MnStrategy4__c qi : quoteItemList) {
			//qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qi.Award_of_DN__c/100;
			qi.Toro_Total_Setup_Fees__c = 0;
			decimal qiTotalDNet=0;
			decimal qiTotalMSRP=0;
			decimal qiTotalAward=0;
			decimal qiTPPAppliedDNet = 0;
			decimal qiToroDNet = 0;
			decimal qiTPPAppliedMSRP = 0;
			decimal qiToroMSRP = 0;
        	decimal qiTPPAppliedAward = 0;
			decimal qiToroAward = 0;
			qi.Total_Award__c =0;
			qi.Total_Toro_Award__c=0;
			qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			qi.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c);
			qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c);
			qi.Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_DNet_Price__c);
			qi.Extended_MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_MSRP_Price__c);
			qi.Rebate_as_a_of_DN__c = CMnQuoteUtil.defaultDecimal(qi.Rebate_as_a_of_DN__c);
			qi.Total_Toro_MSRP__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_MSRP__c);
			qi.Total_Toro_DNET__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_DNET__c);
			qi.Total_DNET__c=CMnQuoteUtil.defaultDecimal(qi.Total_DNET__c);
			qi.Total_Toro_Award__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_Award__c);
			qi.Total_Toro_DNET__c=CMnQuoteUtil.defaultDecimal(qi.Total_Toro_DNET__c);
			qi.Toro_Total_Rebate__c=CMnQuoteUtil.defaultDecimal(qi.Toro_Total_Rebate__c);
			
			qi.TPP_Quoteitem_Total__c = 0;
			system.debug('check total award for each qi -- 1 qi.award price= ' + qi.award_price__c + ' driven by gp=' + qi.DrivenByGP__c);

			//Non Toro Indra
            if(!String.isEmpty(qi.Product_Id__c) && qi.Product_Id__c.startsWith('L0')) {
                //qi.Award_Price__c = 0;
                qi.Rebate_as_a_of_DN__c = 0;
            }

			if(!qi.Exclude_from_Rebate_F__c || (qi.Exclude_from_Rebate_F__c && (qi.Pricing_Program_Product_Type__c == 'Standard' ||  qi.Pricing_Program_Product_Type__c == 'TPP'))) {
				qiToroDNet = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
				qiToroMSRP = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiToroAward = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiToroAward;
				qi.Extended_DNet_Price__c = qiToroDNet;
				qi.Extended_MSRP_Price__c = qiToroMSRP;
				if(qi.Exclude_from_Rebate_F__c) {
					qi.Rebate_as_a_of_DN__c = 0;	
				}
			} else {				
				qiTPPAppliedDNet = qi.DNet_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedMSRP = qi.MSRP_Price__c * qi.Adjusted_Quantity__c;
				qiTPPAppliedAward = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Extended_Award_Price__c = qiTPPAppliedAward;
				qi.Extended_DNet_Price__c = qiTPPAppliedDNet;
				qi.Extended_MSRP_Price__c = qiTPPAppliedMSRP;
			}


			qiTotalDNet = qiToroDNet + qiTPPAppliedDNet;
			qiTotalMSRP = qiToroMSRP + qiTPPAppliedMSRP;
			qiTotalAward = qiToroAward + qiTPPAppliedAward;

			//Non Toro Indra
            //if(!String.isEmpty(qi.Product_Id__c) && qi.Product_Id__c.startsWith('L0')) {
            //    qiTotalAward = 0;
			//	qi.Total_Award__c = 0;
            //} else {
			//	qi.Total_Award__c = qiTotalAward;
            //}

			qi.Total_MSRP__c = qiTotalMSRP;
			qi.Total_Toro_MSRP__c = qi.Total_MSRP__c;
			qi.Total_DNET__c = qiTotalDNET ;
			qi.Total_Toro_DNET__c = qi.Total_DNET__c ;
			qi.Total_Award__c = qiTotalAward ;
			qi.Total_Toro_Award__c = qi.Total_Award__c;

			qi.Toro_Fee_Amount__c = CMnQuoteUtil.defaultDecimal(qi.Extended_Award_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Fee_Percentage__c)/100;
			//todo: uncomment following line
			qi.Extended_Award_Price__c += qi.Toro_Fee_Amount__c;
			decimal extFeeAmount = qi.Toro_Fee_Amount__c;
			qi.Toro_Rebate__c = qi.Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;

			decimal extRebate = CMnQuoteUtil.defaultDecimal(qi.Toro_Rebate__c);
			if(!qi.DrivenByGP__c || qi.Unit_Award_Overridden__c) {
				qi.Toro_Gross_Profit_Value__c = qi.Extended_Award_Price__c - qi.Extended_DNet_Price__c + qi.Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100;
				if(qi.Extended_Award_Price__c != null && qi.Extended_Award_Price__c != 0) {
					qi.Toro_Gross_Profit_Percent__c = qi.Toro_Gross_Profit_Value__c/qi.Extended_Award_Price__c*100;
				} else {
					qi.Toro_Gross_Profit_Percent__c = null;
				}
			} else {
				qi.Toro_Gross_Profit_Value__c = qi.Extended_Award_Price__c * CMnQuoteUtil.defaultDecimal(qi.Toro_Gross_Profit_Percent__c)/100;
			}
			//Non Toro Indra
            if(!String.isEmpty(qi.Product_Id__c) && qi.Product_Id__c.startsWith('L0')) {
                //qi.Total_Award__c = 0;
            	//qi.Total_Toro_Award__c=0;
            	qi.Off_MSRP__c = 0;
                //qi.Award_Price__c =0;
                qi.Toro_Gross_Profit_Percent__c =0;
                qi.Award_of_DN__c = 0;
                qi.Rebate_as_a_of_DN__c = 0;

                qi.Total_Toro_Award__c=0;
            }
			decimal qisRollupTPPAppliedDNet = 0;
			decimal qisRollupToroDNet = 0;
			decimal qisRollupTPPAppliedMSRP = 0;
			decimal qisRollupToroMSRP = 0;
        	decimal qisRollupTPPAppliedAward = 0;
			decimal qisRollupToroAward = 0;
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				qisRollupTPPAppliedDNet = 0;
				qisRollupToroDNet = 0;
				qisRollupTPPAppliedMSRP = 0;
				qisRollupToroMSRP = 0;
	        	qisRollupTPPAppliedAward = 0;
				qisRollupToroAward = 0;	
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//final Decimal extQty = CMnQuoteUtil.defaultDecimal(qi.Quantity__c) * CMnQuoteUtil.defaultDecimal(qis.Quantity__c);
					final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
					qis.Toro_Extended_Qty__c = extQty;
					qis.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c);
					qis.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c);
					qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					qis.TPP_DNet__c = CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c);
					qis.Rebate_as_of_DNet__c = CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c);
					system.debug('check total award for each qi -- 1 qis.Award_Price__c= ' + qis.Award_Price__c);
					if(!qis.Exclude_from_Rebate_F__c || (qis.Exclude_from_Rebate_F__c && (qis.Pricing_Program_Product_Type__c == 'Standard' ||  qis.Pricing_Program_Product_Type__c == 'TPP')))  {						
						qisRollupToroDNet += qis.DNet_Price__c * extQty;
						qisRollupToroMSRP += qis.MSRP_Price__c * extQty;
						qisRollupToroAward += qis.Award_Price__c * extQty;													
						qis.Extended_MSRP_Price__c = qis.MSRP_Price__c * extQty;
						qis.Extended_DNet_Price__c = qis.DNet_Price__c * extQty;
						qis.Extended_Award_Price__c = qis.Award_Price__c * extQty;	
						if(qis.Exclude_from_Rebate_F__c) {
							qis.Rebate_as_of_DNet__c = 0;	
						}						
					} else {
						//use TPP_DNet here
						decimal lDNetPrice = getDNetPrice(qis);
						qisRollupTPPAppliedDNet += lDNetPrice * extQty;
						qisRollupTPPAppliedMSRP += qis.MSRP_Price__c * extQty;
						qisRollupTPPAppliedAward += qis.Award_Price__c * extQty;							
						qis.Extended_MSRP_Price__c = qis.MSRP_Price__c * extQty;
						qis.Extended_Award_Price__c = qis.Award_Price__c * extQty;
						qis.Extended_DNet_Price__c = lDNetPrice * extQty;
						qis.Rebate_as_of_DNet__c = 0;
					}

					qis.Toro_Subline_Rebate__c = qis.Extended_DNet_Price__c * qis.Rebate_as_of_DNet__c/100;
					//if(!qis.Exclude_from_Rebate_F__c || (qis.Exclude_from_Rebate_F__c && qis.Pricing_Program_Product_Type__c == 'Standard')) {	
					if(!qi.DrivenByGP__c || qis.Unit_Award_Overridden__c) {
						qis.Gross_Profit_Value__c = qis.Extended_Award_Price__c - qis.Extended_DNet_Price__c + (qis.Extended_DNet_Price__c * qis.Rebate_as_of_DNet__c/100);
						if(qis.Extended_Award_Price__c != 0) {
							qis.Gross_Profit_Percent__c = qis.Gross_Profit_Value__c/qis.Extended_Award_Price__c*100;
						} else {
							qis.Gross_Profit_Percent__c = null;
						}
					} else {
						if(qis.Extended_Award_Price__c != null && qis.Extended_Award_Price__c != 0) {
							qis.Gross_Profit_Value__c = CMnQuoteUtil.defaultDecimal(qis.Gross_Profit_Percent__c)/100*CMnQuoteUtil.defaultDecimal(qis.Extended_Award_Price__c);
						}
					}
					
					extRebate = extRebate + CMnQuoteUtil.defaultDecimal(qis.Toro_Subline_Rebate__c);
					//qis.Toro_Extended_Award_Price__c = subExtAward;
					
					//uncomment following line
					
					if(!qis.Exclude_from_Rebate_F__c || (qis.Exclude_from_Rebate_F__c && (qis.Pricing_Program_Product_Type__c == 'Standard' ||  qis.Pricing_Program_Product_Type__c == 'TPP')))  {
						qis.Toro_Fee_Amount__c = qis.Extended_Award_Price__c * CMnQuoteUtil.defaultDecimal(qis.Fee_Percentage__c)/100;
						qis.Extended_Award_Price__c += qis.Toro_Fee_Amount__c;
						extFeeAmount += qis.Toro_Fee_Amount__c;
					}
						system.debug(logginglevel.info,'====% off msrp =' +qis.Percent_Off_MSRP__c  + ' qis.Off_MSRP__c=' + qis.PricingMethodValue__c);
						//qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * qis.Percent_of_DNet__c/100;
					//} 
					
					
					system.debug('check total award for each qi -- 1 qi.Total_Toro_Award__c= ' + qi.Total_Toro_Award__c + ' qiTPPAppliedAward='+qiTPPAppliedAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);
					qi.Total_MSRP__c = qiTotalMSRP + qisRollupToroMSRP+ qisRollupTPPAppliedMSRP;
					qi.Total_Toro_MSRP__c = qi.Total_MSRP__c - qisRollupTPPAppliedMSRP - qiTPPAppliedMSRP;
					qi.Total_DNET__c = qiTotalDNET + qisRollupToroDNET+ qisRollupTPPAppliedDNET;
					qi.Total_Toro_DNET__c = qi.Total_DNET__c - qisRollupTPPAppliedDNET - qiTPPAppliedDNET;
					if(qis.Product_Id__c.startsWith('TPP')) {
						qi.TPP_Quoteitem_Total__c += qis.Award_Price__c * qis.Adjusted_Quantity__c;
					}
				}
			}
			if(isNonToroProduct(qi)) {
				qi.Total_Award__c = qi.Award_Price__c * qi.Adjusted_Quantity__c;
				qi.Total_Toro_Award__c = 0;
			} else {
				qi.Total_Award__c = qiTotalAward + qisRollupToroAward+ qisRollupTPPAppliedAward + extFeeAmount;
				system.debug('check total award for each qi -- 1 qi.Total_Award__c= ' + qi.Total_Award__c + ' qiTotalAward='+qiTotalAward+' qisRollupToroAward='+qisRollupToroAward + ' qisRollupTPPAppliedAward='+qisRollupTPPAppliedAward);
				qi.Total_Toro_Award__c = qi.Total_Award__c - qisRollupTPPAppliedAward - qiTPPAppliedAward;
			}
			
			qi.Toro_Total_Setup_Fees__c = extFeeAmount;
			qi.Toro_Total_Rebate__c = extRebate;
			//qi.Toro_Total_Extended_Award_Price__c = extAward;
			//qi.Toro_Total_Extended_MSRP_Price__c = extMSRP;
			//qi.Toro_Total_Extended_DNet_Price__c = extDnet;
			if( qi.Total_Toro_MSRP__c != 0 && qi.Off_MSRP__c != null) {
				system.debug('check total award for each qi -- 2 qi.Total_Toro_Award__c= ' + qi.Total_Toro_Award__c + ' qi.Total_Toro_MSRP__c='+qi.Total_Toro_MSRP__c);
				qi.Blended_MSRP__c = 100 - (qi.Total_Toro_Award__c/qi.Total_Toro_MSRP__c)*100;
			}
			if(qi.Total_Toro_DNET__c != 0 && qi.Award_of_DN__c != null) {
				qi.Toro_Blend_Of_DN__c = qi.Total_Toro_Award__c/qi.Total_Toro_DNET__c*100;
				qi.Blended_Rebate__c = qi.Toro_Total_Rebate__c/qi.Total_Toro_DNET__c*100;
			}

			qi.Total_Gross_Profit_Value__c = qi.Total_Toro_Award__c - qi.Total_Toro_DNET__c + qi.Toro_Total_Rebate__c;
			if(qi.Total_Toro_Award__c != 0) {
				qi.Blended_GP__c = qi.Total_Gross_Profit_Value__c/qi.Total_Toro_Award__c*100;
			}
			if(isNonToroProduct(qi)) {
				quote.Allied_Non_Toro_Total__c += qi.Award_Price__c * qi.Adjusted_Quantity__c;
			}
			quote.TPP_Total__c += qi.TPP_Quoteitem_Total__c;
			//system.debug('checking MSRP ext qi.Toro_Total_Extended_MSRP_Price__c=' + qi.Toro_Total_Extended_MSRP_Price__c);
			system.debug('check total award for each qi -- 1 quoteTotalAward= ' + quoteTotalAward + ' quoteTotalToroAward='+quoteTotalToroAward);
            System.debug('>>> L03_Trade qi.Product_Id__c='+ qi.Product_Id__c);
            if('L03_Trade'.equalsIgnoreCase(qi.Product_Id__c)) {
	            quoteTotalAward       		-= qi.Total_Award__c;
            } else {
	            quoteTotalAward       		+= qi.Total_Award__c;
            }
/*
            if(qi.Product_Id__c != null
            && !qi.Product_Id__c.contains('_Allied')
            && !qi.Product_Id__c.contains('_Service')
            && !qi.Product_Id__c.contains('_Trade')) {
				quoteToroTotalDNet          += qi.Total_Toro_DNET__c;
				quoteMSRP					+= qi.Total_Toro_MSRP__c;
            }
*/
            if(!isNonToroProduct(qi) && !isNewSPLine(qi)) {
				quoteToroTotalDNet          += qi.Total_Toro_DNET__c;
				quoteMSRP					+= qi.Total_Toro_MSRP__c;
				quoteTotalToroAward       	+= qi.Total_Toro_Award__c;
				quoteTotalDNet              += qi.Total_DNET__c;
				quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			}
			/*
			if(!isNonToroProduct(qi)) {
				quoteTotalToroAward       	+= qi.Total_Toro_Award__c;
				quoteTotalDNet              += qi.Total_DNET__c;
				quoteTotalGP 				+= qi.Total_Gross_Profit_Value__c;
			}
			*/
			
			quoteTotalRebate       		+= qi.Toro_Total_Rebate__c;
			quoteTotalDnetWOTppAllied   += qi.Total_Toro_Award__c;
			quoteTotalSetupFee          += qi.Toro_Total_Setup_Fees__c;
			system.debug('check total award for each qi --qi.Total_Award__c= ' + qi.Total_Award__c + ' qi.Total_Toro_Award__c='+qi.Total_Toro_Award__c);
			system.debug('check total award for each qi --qi.Original_Award_Price__c= ' + qi.Original_Award_Price__c );
			system.debug('check total award for each qi --quoteTotalAward= ' + quoteTotalAward + ' quoteTotalToroAward='+quoteTotalToroAward);
			if(qi.Original_Award_Price__c == null) {
				qi.Original_Award_Price__c = qi.Total_Toro_Award__c;
			}
			if(qi.Total_Toro_MSRP__c != null && qi.Selected_Off_MSRP__c != null) {
				qi.Original_Award_Price__c  = qi.Total_Toro_MSRP__c*(1-qi.Selected_Off_MSRP__c/100);
			}
			system.debug('check total award for each qi --qi.Original_Award_Price__c= ' + qi.Original_Award_Price__c );
		}
		quote.Ext_MSRP__c                      = quoteMSRP;
		quote.Toro_Rollup_Award_Price__c       = quoteTotalToroAward;
		quote.Toro_Rollup_DNET__c              = quoteTotalDNet;
		quote.Toro_Rollup_Setup_Fees__c        = quoteTotalSetupFee;
		quote.Toro_Total_DNet__c               = quoteToroTotalDNet;
		quote.Toro_Total_Quote_Gross_Profit__c = quoteTotalGP;
		quote.Toro_Total_Quote_Rebate__c       = quoteTotalRebate;
		quote.Toro_Total_Rebate__c             = quoteTotalRebate;
		quote.Toro_Rollup_DNetWOTPPAllied__c   = quoteTotalDnetWOTppAllied;
		quote.Toro_Award__c = quoteTotalToroAward;
        quote.Total_Award__c = quoteTotalAward;

		Decimal originalBlendedPercentOfDN = quote.Toro_Blended_Percent_of_DN__c;
		if(quote.Toro_Total_DNET__c != null && quote.Toro_Total_DNET__c != 0) {
			quote.Toro_Blended_Percent_of_DN__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Award__c) / quote.Toro_Total_DNET__c*100;
		}

		if (originalBlendedPercentOfDN == quote.Toro_Blended_Percent_of_DN__c) {
			this.blendedPercentOfDnChanged = false;
		}

		else {
			this.blendedPercentOfDnChanged = true;
		}

		quote.Toro_Blended_Percent_of_DN__c=CMnQuoteUtil.defaultDecimal(quote.Toro_Blended_Percent_of_DN__c).setScale(2);
		if(quote.Toro_Rollup_Award_Price__c != null && quote.Toro_Rollup_Award_Price__c != 0) {
			quote.Toro_Total_Quote_Gross_Profit_Percent__c = CMnQuoteUtil.defaultDecimal(quote.Toro_Total_Quote_Gross_Profit__c) / quote.Toro_Rollup_Award_Price__c *100;
		}

		System.debug('\n\n@@quote: ' + quote + '\n\n');
		
		return quoteItemList;
	}

	// initializes the quote item and quote item subline calculated fields to 0
	private void initializeExtendedFieldsToZero(List<Revvy__MnStrategy4__c> quoteItemList) {
		system.debug('initializeExtendedFieldsToZero quoteItemList =' + quoteItemList);

	}

	//Method saveQuoteItemList is a template method called by calculateRebateMargin
	public virtual List<Revvy__MnStrategy4__c> saveQuoteItemList(List<Revvy__MnStrategy4__c> quoteItemList ){

		system.debug(logginglevel.info,'inside base saveQuoteItemList');
		//saveToroQuoteItemList(quoteItemList);

		List<Revvy__MnStrategy4__c> updateQuoteItems = new List<Revvy__MnStrategy4__c>();
		List<Revvy__MnStrategy5__c> updateQuoteItemSublines = new List<Revvy__MnStrategy5__c>();

		for(Revvy__MnStrategy4__c qi : quoteItemList) {
			updateQuoteItems.add(qi);
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Revvy__MnStrategy5__c qiSubline : qi.Toro_Quote_Item_Sub_Lines__r) {
					updateQuoteItemSublines.add(qiSubline);
				}
			}
		}

		if(updateQuoteItems.size() > 0) {
			//database.update(updateQuoteItems, false);
			update updateQuoteItems;
		}
		if(updateQuoteItemSublines.size() > 0) {
			update updateQuoteItemSublines;
		}
		update quote;

		return quoteItemList;
	}

	public ToroPricingProgram() {
		performancePartFlag = false;
		quoteFieldMap = Schema.SObjectType.Revvy__MnQuote__c.fields.getMap();
		quoteItemFieldMap = Schema.SObjectType.Revvy__MnQuoteItem__c.fields.getMap();
		quoteItemSublineFieldMap = Schema.SObjectType.Revvy__MnQuoteItemSubline__c.fields.getMap();
	}

	public virtual void initializeQuoteHeader(Id quoteId) {
		system.debug(logginglevel.info, 'initializeQuoteHeader -- quoteId-------'+quoteId);
		quote = ToroCacheManager.getQuote(quoteId);
		system.debug(logginglevel.info, 'initializeQuoteHeader quoteId-------'+quote);
		this.quote.REVVY__NeedsApproval__c = false;
		this.quote.Toro_ApprovalReason__c = '';
		//system.debug(logginglevel.info, 'initializeQuoteHeader quote-------'+quote);
		//String quoteQuery = 'select ' + getQuoteFieldAPINameQuery('Setup_Fee__c, Toro_Support_Plus_Allowance__c, Blended_Percent_of_DN__c, Support_Plus_Rebate__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c,Blended_Percent_of_DN__c') + ' from Revvy__MnQuote__c where id=:quoteId';
		//quote = Database.query(quoteQuery);

	}
	public virtual void initialize(Id quoteId) {
		initializeQuoteHeader(quoteId);
		initializeQuoteItems(quoteId);
		system.debug('quote items =' + quoteItems);
	}

	public virtual void initializeQuoteItems(Id quoteId) {
		String quoteLineQuery = 'Select ' + getToroQuoteItemFieldAPINamesQuery('Product__r.Support_Plus_TU__c,Original_MSRP_Price__c,Pricing_Program_Product_Type__c,Support_Plus_From_Add_New_F__c,Has_Support_Plus__c,PricingMethodValue__c,Pricing_Program_Overridden__c, DrivenByGP__c,Adjusted_Quantity__c, OnlyExistedInCPL__c,Original_Award_Price__c,Off_MSRP_Overridden__c, Product__r.Toro_Product_Type__c,Traction_Unit__c, Off_MSRP__c,Award_Price__c,Rebate_as_a_of_DN__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, MSRP_Price__c, Original_off_MSRP__c, Oroginal_of_DNet__c,Unit_Award_Overridden__c, QuoteItem__r.REVVY__Catalog_Node__r.revvy__id__c, QuoteItem__r.REVVY__Catalog_Node__r.name, Product__r.Hierarchy_Code__c,QuoteItem__r.REVVY__SuggestedPrice__c , DNet_Price__c,QuoteItem__r.REVVY__Price__c,Off_MSRP__c, Selected_Off_MSRP__c, Pricing_Program__c, Select_a_Price_Method__c, Award_of_DN__c, Standard_Price__c');
		quoteLineQuery += ', (Select ' + getToroQuoteItemSublineFieldAPINamesQuery('Quote_Item_Sub_Line__r.TPP_DNet__c,Original_MSRP_Price__c,Pricing_Program_Product_Type__c,Adjusted_Quantity__c, Original_off_MSRP__c,OnlyExistedInCPL__c, PricingMethodValue__c, Award_Price__c, Rebate_as_of_DNet__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, Exclude_from_Rebate_F__c,Unit_Award_Overridden__c, Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c,DNet_Price_2__c, DNet_Price__c ,Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name, Standard_Price__c, Quote_Item_Sub_Line__r.REVVY__Price__c, Quote_Item_Sub_Line__r.REVVY__SuggestedPrice__c,  Percent_Off_MSRP__c, Percent_of_DNet__c,Quantity__c');
		quoteLineQuery += ' from Toro_Quote_Item_Sub_Lines__r order by Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name) from  Revvy__MnStrategy4__c where Mn_Quote__c = :quoteId Order by createdDate asc';
		System.debug('88888888888888888888=' + quoteLineQuery);
		quoteItems = Database.query(quoteLineQuery);
	}
	
	public virtual List<Revvy__MnStrategy4__c> setDefaultFields(List<Revvy__MnStrategy4__c> quoteItemList){
		return quoteItemList;
	}
	
	public virtual boolean getQuoteLevelMSQPDNetEditable() {
		return true;
	}

	public virtual boolean isNonToroProduct(Revvy__MnStrategy4__c qi) {
		boolean ret = false;
		String productId = qi.Product_Id__c;
		if(productId.startsWith('L')) {
			ret = true;
		}
		return ret;
	}
    public virtual boolean isNewSPLine(Revvy__MnStrategy4__c qi) {
		boolean ret = false;
		return qi.Support_Plus_From_Add_New_F__c;
	}
	public virtual boolean isNonToroProduct(Revvy__MnStrategy5__c qis) {
		boolean ret = false;
		String productId = qis.Product_Id__c;
		if(productId.startsWith('L')) {
			ret = true;
		}
		return ret;
	}
	
	public virtual boolean excludedFromMSRP(Revvy__MnStrategy4__c qi) {
		boolean ret = false;

		if(qi.Performance_Parts_Product__c) {
			ret=true;
		}

		return ret;
	}

	public virtual boolean excludedFromMSRP(Revvy__MnStrategy5__c qi) {
		boolean ret = false;
		String productId = string.isNotBlank(qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c) ? qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c : qi.Quote_Item_Sub_Line__r.Product_ID_F__c;
		//if(productId.startsWith('TPP')  || productId.startsWith('L0') || productId.startsWith('L1') || qi.Performance_Part__c) {
		if((qi.Exclude_from_Rebate_F__c && qi.Pricing_Program_Product_Type__c != 'Standard' && qi.Pricing_Program_Product_Type__c != 'TPP') || qi.Performance_Part__c) {
			ret = true;
		}
		return ret;
	}

	private String CombineSelectClauses(List<String> fieldListFromFS, String extraFields ) {
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '').toLowerCase();
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldListFromFS);
		return String.join(new List<String>(nameSet), ',');
	}

	@TestVisible protected virtual List<String> getQuoteFieldAPINames() {
		List<String> fieldNames = new List<String>();
		system.debug(logginglevel.info, 'getQuoteFields =' + getQuoteFields());
		for(Schema.FieldSetMember fs : getQuoteFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}

	@TestVisible protected virtual String getQuoteFieldAPINameQuery(String extraFields) {
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}

	@TestVisible protected virtual String getToroQuoteFieldAPINameQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}

	protected virtual String getToroQuoteItemFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		
		for(Schema.FieldSetMember fs : SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Traction_Unit_Info.getFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		for(Schema.FieldSetMember fs : SObjectType.Revvy__MnStrategy4__c.FieldSets.Price_Program_Line_Info_Cols.getFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		
		return CombineSelectClauses(fieldNames, extraFields);
	}

	protected virtual String getToroQuoteItemSublineFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemSublineFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		
		for(Schema.FieldSetMember fs : SObjectType.Revvy__MnStrategy5__c.FieldSets.Price_Program_Subline_Info_Cols.getFields()) {
			fieldNames.add(fs.getFieldPath().toLowerCase());
		}
		
		return CombineSelectClauses(fieldNames, extraFields);
	}

	@TestVisible protected virtual void loadDesignatedPriceList(String pricingProgramExtId) {
		Revvy__MnStrategy1__c pp =  ToroCacheManager.getPricingProgram(pricingProgramExtId);

	}

	protected Map<String, Schema.SObjectField> quoteFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemSublineFieldMap { get; set; }

	public virtual List<Revvy__MnStrategy4__c> loadMSRPPriceFromPricelist(String priceProgram, List<Revvy__MnStrategy4__c> quoteItemList ){
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('ToroContractPriceListPPHelper--' +  rebates);
		List<Id> priceListIds = new List<Id>();
		Date targetDate = null;
		String[] copyFromFields = null;
		boolean copyFromMSRP=false;
		boolean copyFromDNET=false;
		decimal multiplier = 1;
		for(Revvy__MnStrategy1__c pp : rebates) {
			if(pp.UseDesignatedPriceList__c && pp.Previous_Price_Date__c != null && string.isNotBlank(pp.Copy_From_Price_Field__c)) {
				priceListIds.add(pp.OverriddenPriceList__c);
				targetDate = pp.Previous_Price_Date__c;
				copyFromFields = pp.Copy_From_Price_Field__c.split(';');
				for(String s : copyFromFields) {
					if(s == 'MSRP') {
						copyFromMSRP=true;
					} else if(s == 'DNET') {
						copyFromDNET=true;
					}
				}
				system.debug('state of FL pp.Copy_From_Price_Field__c=' + pp.Copy_From_Price_Field__c);
				if(pp.Previous_MSRP_Multiplier__c != null) {
					multiplier = pp.Previous_MSRP_Multiplier__c;
				}
			}
		}
		List<Id> productIdList = new List<Id>();
		for(REVVY__MnStrategy4__c qi : quoteItemList) {
			productIdList.add(qi.Product__c);	
		}
		system.debug('state of FL copyFromMSRP=' + copyFromMSRP);
		system.debug('state of FL copyFromDNET=' + copyFromDNET);
		system.debug('targetDate=' + targetDate);
		if(targetDate != null) {
			Map<String, revvy__MnPriceListLine__c> prodPriceListLineMap = new Map<String, revvy__MnPriceListLine__c>();
			List<REVVY__MnPriceListLine__c> plis = [SELECT Id, REVVY__ListedPrice__c,REVVY__SuggestedPrice__c,
					REVVY__product__c,REVVY__Product_Id__c,REVVY__Start_Date__c,REVVY__End_Date__c,
					REVVY__Product__r.REVVY__Id__c, REVVY__PriceField1__c, REVVY__PriceField2__c, REVVY__PriceField3__c
					FROM REVVY__MnPriceListLine__c  WHERE REVVY__Price_List_ID__c = 'Commercial'  
								and REVVY__product__c in :productIdList
								and (REVVY__Start_Date__c <= :targetDate AND REVVY__End_Date__c > :targetDate)];
			for(REVVY__MnPriceListLine__c ppl : plis) {
				//system.debug('ToroContractPriceListPPHelper--product Id='+ppl.REVVY__Product_Id__c + ' start date=' + ppl.REVVY__Start_Date__c + ' end date = ' + ppl.REVVY__End_Date__c + ' msrp=' + ppl.REVVY__ListedPrice__c + ' dnet=' + ppl.REVVY__SuggestedPrice__c);
				prodPriceListLineMap.put(ppl.REVVY__product__r.REVVY__Id__c, ppl);
			}

			for(REVVY__MnStrategy4__c qi : quoteItemList) {
				if(CMnQuoteUtil.isNonToroProduct(qi)) {
	                continue;
	            }
			
				if(prodPriceListLineMap.containsKey(qi.Product_Id__c)) {
					REVVY__MnPriceListLine__c ppl = prodPriceListLineMap.get(qi.Product_Id__c);
					if(copyFromMSRP) {
						system.debug('state of FL copyFromMSRP=' + copyFromMSRP);
						qi.MSRP_Price__c = ppl.REVVY__ListedPrice__c;
					}
					if(copyFromDNET) {
						system.debug('state of FL copyFromDNET=' + copyFromDNET);
						qi.DNet_Price__c = ppl.REVVY__SuggestedPrice__c;
					}
					//system.debug('ToroContractPriceListPPHelper--product Id='+qi.Product_Id__c + ' msrp = ' + qi.MSRP_Price__c + ' dnet =' + qi.DNet_Price__c);
					qi.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) * multiplier;
				}
				
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(prodPriceListLineMap.containsKey(qis.Product_Id__c)) {
							revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qis.Product_Id__c);
							if(copyFromMSRP) {
								system.debug('state of FL copyFromMSRP=' + copyFromMSRP);
								qis.MSRP_Price__c = ppl.REVVY__ListedPrice__c;
							}
							if(copyFromDNET) {
								system.debug('state of FL copyFromDNET=' + copyFromDNET);
								qis.DNet_Price__c = ppl.REVVY__SuggestedPrice__c;
							}
							//system.debug('QIS ToroContractPriceListPPHelper--product Id='+qis.Product_Id__c + ' msrp = ' + qis.MSRP_Price__c + ' dnet =' + qis.DNet_Price__c);
							qis.MSRP_Price__c = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * multiplier;
						}
						
					}
				}

			}
		}
		return 	quoteItemList;
	}
	public virtual List<Revvy__MnStrategy4__c> loadPricesFromPricelist(String priceProgram, List<Revvy__MnStrategy4__c> quoteItemList ){
		Id defaultPriceList = CMnQuoteUtil.getDefaultPriceList();
		List<Revvy__MnStrategy1__c> rebates = new List<Revvy__MnStrategy1__c>{ToroCacheManager.getPricingProgram(priceProgram)};
		system.debug('loadPricesFromPricelist--pricing program =' +  rebates);
		List<Id> priceListIds = new List<Id>();
		Date targetDate = null;
		String[] copyFromFields = null;
		boolean copyFromMSRP=false;
		boolean copyFromDNET=false;
		boolean copyFromDisti=false;
		boolean usePriceList = false;
		for(Revvy__MnStrategy1__c pp : rebates) {
			if(pp.UseDesignatedPriceList__c && (pp.Previous_Price_Date__c != null || pp.OverriddenPriceList__c != null) && string.isNotBlank(pp.Copy_From_Price_Field__c)) {
				usePriceList = true;
				if(pp.OverriddenPriceList__c != null) {
					priceListIds.add(pp.OverriddenPriceList__c);
				}
				if(pp.Previous_Price_Date__c != null) {
					targetDate = pp.Previous_Price_Date__c;
				}
				copyFromFields = pp.Copy_From_Price_Field__c.split(';');
				for(String s : copyFromFields) {
					if(s == 'MSRP') {
						copyFromMSRP=true;
					} else if(s == 'DNET') {
						copyFromDNET=true;
					} else if( s == 'Disti Award') {
						copyFromDisti=true;
					}
				}
				//system.debug('state of FL pp.Copy_From_Price_Field__c=' + pp.Copy_From_Price_Field__c);
			}
		}
		if(usePriceList) {
			if(priceListIds.size() == 0) {
				priceListIds.add(defaultPriceList);	
			}
			if(targetDate == null) {
				targetDate = Date.Today();	
			}
		}
		//system.debug('pricing program copyFromMSRP=' + copyFromMSRP);
		//system.debug('pricing program copyFromDNET=' + copyFromDNET);
		//system.debug('pricing program copyFromDisti=' + copyFromDisti);
		system.debug('pricing program usePriceList=' + usePriceList);
		system.debug('pricing program targetDate=' + targetDate);
		//system.debug('pricing program priceListIds=' + priceListIds);
		if(usePriceList) {
			Map<String, revvy__MnPriceListLine__c> prodPriceListLineMap = new Map<String, revvy__MnPriceListLine__c>();
			List<REVVY__MnPriceListLine__c> plis = [SELECT Id, REVVY__ListedPrice__c,REVVY__SuggestedPrice__c, REVVY__FloorPrice__c,
					REVVY__product__c,REVVY__Product_Id__c,REVVY__Start_Date__c,REVVY__End_Date__c,
					REVVY__Product__r.REVVY__Id__c, REVVY__PriceField1__c, REVVY__PriceField2__c, REVVY__PriceField3__c
					FROM REVVY__MnPriceListLine__c  WHERE REVVY__PriceList__c in :priceListIds  and (REVVY__Start_Date__c <= :targetDate AND REVVY__End_Date__c > :targetDate)];

			for(REVVY__MnPriceListLine__c ppl : plis) {
				//system.debug('ToroContractPriceListPPHelper--product Id='+ppl.REVVY__Product_Id__c + ' start date=' + ppl.REVVY__Start_Date__c + ' end date = ' + ppl.REVVY__End_Date__c + ' msrp=' + ppl.REVVY__ListedPrice__c + ' dnet=' + ppl.REVVY__SuggestedPrice__c + ' disti=' + ppl.REVVY__FloorPrice__c);
				prodPriceListLineMap.put(ppl.REVVY__product__r.REVVY__Id__c, ppl);
			}

			if(usePriceList) {
				for(REVVY__MnStrategy4__c qi : quoteItemList) {
					if(CMnQuoteUtil.isNonToroProduct(qi)) {	
		                continue;
		            }
					
					if(prodPriceListLineMap.containsKey(qi.Product_Id__c)) {
						REVVY__MnPriceListLine__c ppl = prodPriceListLineMap.get(qi.Product_Id__c);
						if(copyFromMSRP) {
							//system.debug('state of FL copyFromMSRP=' + copyFromMSRP);
							qi.MSRP_Price__c = ppl.REVVY__ListedPrice__c;
						} else if(copyFromDisti) {
							//system.debug('state of FL copyFromDisti=' + copyFromDisti);
							qi.MSRP_Price__c = ppl.REVVY__FloorPrice__c;
						}
						if(copyFromDNET) {
							system.debug('state of FL copyFromDNET=' + copyFromDNET);
							qi.DNet_Price__c = ppl.REVVY__SuggestedPrice__c;
						}
						
						system.debug('ToroContractPriceListPPHelper--product Id='+qi.Product_Id__c + ' msrp = ' + qi.MSRP_Price__c + ' dnet =' + qi.DNet_Price__c);
					}
					if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
						for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
							if(prodPriceListLineMap.containsKey(qis.Product_Id__c)) {
								revvy__MnPriceListLine__c ppl = prodPriceListLineMap.get(qis.Product_Id__c);
								if(copyFromMSRP) {
									//system.debug('state of FL copyFromMSRP=' + copyFromMSRP);
									qis.MSRP_Price__c = ppl.REVVY__ListedPrice__c;
								} else if(copyFromDisti) {
									//system.debug('state of FL copyFromDisti=' + copyFromDisti);
									qis.MSRP_Price__c = ppl.REVVY__FloorPrice__c;
								} 
								if(copyFromDNET) {
									//system.debug('state of FL copyFromDNET=' + copyFromDNET);
									if(qis.Pricing_Program_Product_Type__c == 'TPP') {
										qis.DNet_Price__c = qis.Quote_Item_Sub_Line__r.TPP_DNet__c;	
									} else {
										qis.DNet_Price__c = ppl.REVVY__SuggestedPrice__c;
									}
								}
								//system.debug('QIS ToroContractPriceListPPHelper--product Id='+qis.Product_Id__c + ' msrp = ' + qis.MSRP_Price__c + ' dnet =' + qis.DNet_Price__c);
							}
						}
					}
	
				}
			}
		} else {
			//reset MSRP price
			for(REVVY__MnStrategy4__c qi : quoteItemList) {
				if(qi.Original_MSRP_Price__c != null) {
					qi.MSRP_Price__c = qi.Original_MSRP_Price__c;
				}
				if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for(Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						if(qis.Original_MSRP_Price__c != null) {
							qis.MSRP_Price__c = qis.Original_MSRP_Price__c;
						}	
					}	
				}
			}
			
		}
		return 	quoteItemList;
	}
	public decimal calcDistributedTractionUnitAwardPrice(Revvy__MnStrategy4__c qi) {	
		if(!CMnQuoteUtil.isNonToroProduct(qi)) {
			decimal qiExtMSRP = CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
			system.debug(logginglevel.info, 'distributeTotalAwordDollors qi qiExtMSRP  =' + qiExtMSRP);
			qi.Extended_MSRP_Price__c = qi.MSRP_Price__c * CMnQuoteUtil.defaultDecimal(qi.Adjusted_Quantity__c);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!qis.Exclude_from_Rebate_F__c || (qis.Exclude_from_Rebate_F__c && (qis.Pricing_Program_Product_Type__c == 'Standard' ||  qis.Pricing_Program_Product_Type__c == 'TPP') )) {
						//final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
						final Decimal extQty = CMnQuoteUtil.defaultDecimal(qis.Adjusted_Quantity__c);
						qis.Toro_Extended_Qty__c = extQty;
						decimal qisExtMSRP = CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * extQty;
						system.debug(logginglevel.info, 'distributeTotalAwordDollors qis qisExtMSRP  =' + qisExtMSRP);
						qiExtMSRP += qisExtMSRP;
						system.debug(logginglevel.info, 'distributeTotalAwordDollors qi qiExtMSRP  =' + qiExtMSRP);
					}	
				}	
			}
			if(qiExtMSRP != null && qiExtMSRP != 0 && qi.Adjusted_Quantity__c != null && qi.Adjusted_Quantity__c != 0) {
				qi.Award_Price__c = qi.Total_Toro_Award__c * (qi.Extended_MSRP_Price__c /qiExtMSRP)/qi.Adjusted_Quantity__c; //.setScale(2,roundingMode.HALF_UP);
			}
		}
		return qi.Award_Price__c;	
	} 
}