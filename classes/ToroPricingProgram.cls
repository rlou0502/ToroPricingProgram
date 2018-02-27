public abstract class ToroPricingProgram {
	public Revvy__MnQuote__c quote { get; set; }
	public List<Toro_QuoteItem__c> quoteItems { get; set; }
	public boolean performancePartFlag { get; set; }
	public abstract List<Schema.FieldSetMember> getQuoteItemSublineFields();
	public abstract List<Schema.FieldSetMember> getQuoteItemFields();
	public abstract List<Schema.FieldSetMember> getQuoteFields() ;
	public virtual List<Schema.FieldSetMember> getQuoteItemSublineUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getQuoteItemUpdatableFields() {
		system.debug('--------------------getQuoteItemUpdatableFields --- ToroPricingProgram' + SObjectType.Revvy__MnQuoteItem__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields());
		return null;
	}
	public virtual List<Schema.FieldSetMember> getQuoteUpdatableFields() {
		return SObjectType.Revvy__MnQuote__c.FieldSets.Quote_Header_Updatable_Fields.getFields();
	}
/* 	for quote item /subline extensions */

	public virtual List<Schema.FieldSetMember> getToroQuoteItemFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Line_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Price_Program_Quote_SubLine_Cols.getFields();
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return null;
	}
	public virtual List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	
	public virtual List<FieldSetMember> addUpdatableFieldSetMember(List<Schema.FieldSetMember> fieldSet, List<Schema.FieldSetMember> updatableFieldSet) {
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

	public virtual List<ToroSelectOption> retrievePricingProgramOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();

		List<Toro_PricingProgram__c> pricingPrograms = [select name, PricingProgramType__c, MinimumThreshold__c,
					stateprovince__c from Toro_PricingProgram__c order by name asc ];
		for(Toro_PricingProgram__c pp : pricingPrograms) {
        	//if(isEligible(pp, quote, quoteItems)) {
	        	ret.add(new ToroSelectOption(pp.name, pp.name));
	        //}
        }
		return ret;
	}

	public virtual List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		ret.add(new ToroSelectOption('% of DNET','% of DNET'));
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}


	public virtual boolean displayPerformancePart() {
		return false;
	}
	public virtual boolean displaySetupFee() {
		return false;
	}
	public abstract List<Revvy__MnQuoteItem__c> calculateRebateAndMargin(Id quoteId, String priceProgramExternalId,
															String priceMethod, List<QuoteItem> quoteItemWrapperList );
	public virtual List<Toro_QuoteItem__c> preCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return 	quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> postCalculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		return 	quoteItemList;
	}
	public virtual List<Toro_QuoteItem__c> calculateRebateMargin(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList, boolean save ){
		Long perfStart = System.limits.getCpuTime();
		//call pre
		system.debug(logginglevel.info, 'calling calculateRebateMarginImpl =' + priceProgram + ' -- ' + quoteItemList);
		List<Toro_QuoteItem__c> lQuoteItemList = preCalculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		
		lQuoteItemList = calculateRebateMarginImpl(quoteId, priceProgram, priceMethod, lQuoteItemList);
		system.debug(logginglevel.info,'calling calculateRebateMarginImpl took ' + (System.limits.getCpuTime()-perfStart));

		lQuoteItemList = calculateExtendedFields(lQuoteItemList);
		system.debug(logginglevel.info,'calling calculateExtendedFields took ' + (System.limits.getCpuTime()-perfStart));
		system.debug(logginglevel.info,'calling saveQuoteItemList');
		if(save) {
			lQuoteItemList = saveQuoteItemList(lQuoteItemList);
			lQuoteItemList = postCalculateRebateMargin(quoteId, priceProgram, priceMethod, lQuoteItemList);
		}
		

		system.debug(logginglevel.info,'calling saveQuoteItemList took ' + (System.limits.getCpuTime()-perfStart));
		return lQuoteItemList;
	}
	
	/*
	public virtual List<Toro_QuoteItem__c> updateQuote(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		List<Toro_QuoteItem__c> qiList = calculateRebateMargin(quoteId, priceProgram, priceMethod, quoteItemList);
		return saveQuoteItemList(qiList);
	}
	*/

	//Method calculateRebateMarginImpl is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		system.debug('inside base calculateRebateMarginImpl');
		return quoteItemList;
	}

	//Method calculateExtendedFields is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> calculateExtendedFields(List<Toro_QuoteItem__c> quoteItemList) {
		system.debug(logginglevel.info,'inside base calculateExtendedFields =' + quoteItemList);
		initializeExtendedFieldsToZero(quoteItemList);

		// calculate subline values
		for (Toro_QuoteItem__c qi : quoteItemList) {
			//qi.Award_Price__c = qi.Award_Price__c.setScale(2,roundingMode.HALF_UP);
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					//qis.Award_Price__c = qis.Award_Price__c.setScale(2,roundingMode.HALF_UP);
					//extended qty = qi qty * qis qty
					final Decimal extQty = qi.Quantity__c * qis.Quantity__c;
					// calculate values for the subline
					qis.Toro_Extended_Qty__c              = extQty;
					qis.Toro_Extended_Award_DNet_Price__c = qis.DNet_Price__c * extQty * CMnQuoteUtil.defaultDecimal(qis.Percent_of_DNet__c/100);
					qis.Toro_Extended_Award_MSRP_Price__c = qis.MSRP_Price__c * extQty * (1 - CMnQuoteUtil.defaultDecimal(qis.Percent_Off_MSRP__c/100));
					system.debug(logginglevel.info,'------Percent_of_DNet__c  =' + qis.Percent_of_DNet__c);
					system.debug(logginglevel.info,'------Percent_Off_MSRP__c  =' + qis.Percent_Off_MSRP__c);
					
					//ask lance
					qis.Toro_Extended_Award_Price__c      = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c)  * extQty;
					//do we need this//allied product will always dnet as 0
					qis.Toro_DNet_Price__c                = (qis.TPP_Line_Item__c == true) ? (CMnQuoteUtil.defaultDecimal(qis.TPP_DNet__c) * extQty) : (CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * extQty);
					//???? need clarification // 
					qis.Toro_Extended_MSRP_Price__c       = (qis.Performance_Part__c == true) ? (qis.Quote_Item_Sub_Line__r.REVVY__Unit_Price__c * extQty) : (CMnQuoteUtil.defaultDecimal(qis.MSRP_Price__c) * extQty);

					if (qis.Fee_Percentage__c != null) {
						qis.Toro_Fee_Amount__c = qis.Toro_Extended_Award_Price__c * qis.Fee_Percentage__c/100;
					}

					qis.Toro_Subline_Rebate__c = CMnQuoteUtil.defaultDecimal(qis.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c/100);

					// calculate rollups on the quote item
					qi.Toro_Rollup_Award_DNet_Price__c           += qis.Toro_Extended_Award_DNet_Price__c;
					qi.Toro_Rollup_Award_MSRP_Price__c           += qis.Toro_Extended_Award_MSRP_Price__c;
					qi.Toro_Rollup_Award_Price__c                += CMnQuoteUtil.defaultDecimal(qis.Award_Price__c);
					//????????????
					if(qis.TPP_Line_Item__c) {
						qi.Toro_Rollup_DNet_for_TPP__c               += CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					}
					qi.Toro_Rollup_DNet_Price__c                 += CMnQuoteUtil.defaultDecimal(qis.Toro_DNet_Price__c);
					qi.Toro_Rollup_Extended_Award_Price__c       += qis.Toro_Extended_Award_Price__c;
					qi.Toro_Rollup_MSRP_Price__c                 += qis.Toro_Extended_MSRP_Price__c;
					qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c += 1; // count of sublines

					if (qis.Toro_Fee_Amount__c != null) {
						qi.Toro_Rollup_Setup_Fees_Sub_Line__c += qis.Toro_Fee_Amount__c;
					}

					qi.Toro_Rollup_Subline_Rebate__c             += qis.Toro_Subline_Rebate__c;
					//??do we need this - need more input from nalee, nalee has a better way to do this
					qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c += CMnQuoteUtil.defaultDecimal(qis.Rebate_as_of_DNet__c);
				}
			}
		}

		// calculate quote item values
		for (Toro_QuoteItem__c qi : quoteItemList) {
			final Decimal qty = qi.Quantity__c;
			qi.DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c);
			// calculate values for the quote item
			system.debug('qty=' + qty + 'MSRP_Price__c=' + qi.MSRP_Price__c + ' Award_of_DN__c =' + qi.Award_of_DN__c + 'qi.Toro_Rollup_Award_DNet_Price__c=' + qi.Toro_Rollup_Award_DNet_Price__c);
			if (qi.Award_of_DN__c != null) {
				qi.Toro_Extended_Award_DNet_Price__c = (CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * qty * qi.Award_of_DN__c/100) + qi.Toro_Rollup_Award_DNet_Price__c;
			}

					
			if (qi.Off_MSRP__c != null) {
				system.debug(logginglevel.info,'------qi.Off_MSRP__c  =' +qi.Off_MSRP__c);
				qi.Toro_Extended_Award_MSRP_Price__c = (CMnQuoteUtil.defaultDecimal(qi.MSRP_Price__c) * qty * (1 - qi.Off_MSRP__c/100)) + CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_Award_MSRP_Price__c);
			}
			//todo -- need calculate Toro_Rollup_Partner_Products__c and Toro_Rollup_TPP__c
			//might need Total_Award_Price__c, TPP should be included in calculation
			qi.Toro_Total_Award_price__c = (qi.Select_a_Price_Method__c == '% of DNET')
											? qi.Toro_Extended_Award_DNet_Price__c
											: CMnQuoteUtil.defaultDecimal(qi.Toro_Extended_Award_MSRP_Price__c)
												- (CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_Partner_Products__c) * (1 - CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100))
												- (CMnQuoteUtil.defaultDecimal(qi.Toro_Rollup_TPP__c) * (1 - CMnQuoteUtil.defaultDecimal(qi.Off_MSRP__c)/100));

			if (qi.Award_Price__c != null) {
				qi.Toro_Total_Extended_Award_Price__c = qi.Award_Price__c * qty;
			}
			system.debug(LoggingLevel.INFO,' id='+qi.Product_Id__c+' qty=' + qty + 'qi.DNet_Price__c ' + qi.DNet_Price__c );
			qi.Toro_Extended_DNet_Price__c = CMnQuoteUtil.defaultDecimal(qi.DNet_Price__c) * CMnQuoteUtil.defaultDecimal(qty);

			if (qi.Toro_Extended_DNet_Price__c != 0) {
				qi.Toro_Blend_Of_DN__c = qi.Toro_Total_Extended_Award_Price__c / qi.Toro_Extended_DNet_Price__c * 100;
			}

			qi.Toro_Distributor_Responsibility__c = null; // @TODO
			//total extended dnet
			qi.Toro_Rollup_DNet_for_TPP__c =0;
			qi.Toro_DNet_Price__c      = (qi.DNet_Price__c * qty) + (qi.Toro_Rollup_DNet_Price__c - qi.Toro_Rollup_DNet_for_TPP__c);
			qi.Toro_DNetWOTPPAllied__c = (qi.DNet_Price__c * qty) + (qi.Toro_Rollup_DNet_Price__c - qi.Toro_Rollup_DNet_for_TPP__c);
//unit award price
			if (qi.Award_Price__c != null) {
				qi.Toro_Extended_Award_Price__c = qi.Award_Price__c * qty;
			}
			//?? remove?
			System.debug('+++++ Toro_Extended_MSRP_Price__c qi.MSRP_Price__c='+qi.MSRP_Price__c + ' qty='+qty );
			qi.Toro_Extended_MSRP_Price__c = (qi.Performance_Parts_Product__c == true)
												? qi.Award_Price__c * qty
												: qi.MSRP_Price__c * qty;

			if (qi.Fee_Percentage__c != null) {
				qi.Toro_Fee_Amount__c = qi.Toro_Total_Extended_Award_Price__c * qi.Fee_Percentage__c/100;
			}

			if (qi.Rebate_as_a_of_DN__c != null) {
				system.debug(logginglevel.info, ' qi.Toro_Extended_DNet_Price__c =' + qi.Toro_Extended_DNet_Price__c + ' qi.Rebate_as_a_of_DN__c/100 ' + qi.Rebate_as_a_of_DN__c/100 + ' qi.Toro_Rollup_Subline_Rebate__c ' + qi.Toro_Rollup_Subline_Rebate__c);
				qi.Toro_Total_Rebate__c = (qi.Toro_Extended_DNet_Price__c * qi.Rebate_as_a_of_DN__c/100) + qi.Toro_Rollup_Subline_Rebate__c;
			}

			if (qi.Toro_Total_Rebate__c != null) {
				qi.Toro_Gross_Profit_Value__c = qi.Toro_Total_Award_price__c - qi.DNet_Price__c + qi.Toro_Total_Rebate__c;
			}

			if (qi.Toro_Total_Award_price__c != 0) {
				qi.Toro_Gross_Profit_Percent__c = (qi.Toro_Gross_Profit_Value__c / qi.Toro_Total_Award_price__c) * 100;
			}

			if (qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c != 0) {
				qi.Toro_QuoteItemSubline_Rebate_as_of_Dnet__c = (qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c / qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c)*100;
			}

			qi.Toro_Total_Extended_MSRP_Price__c = qi.Toro_Extended_MSRP_Price__c + qi.Toro_Rollup_MSRP_Price__c;

			if (qi.Toro_Fee_Amount__c != null) {
				qi.Toro_Total_Setup_Fees__c = qi.Toro_Fee_Amount__c + qi.Toro_Rollup_Setup_Fees_Sub_Line__c;
			}

			if (qi.Award_Price__c != null) {
				qi.Toro_Total_Unit_Award__c = qi.Award_Price__c + qi.Toro_Rollup_Award_Price__c;
			}
		}

		//debugCalculatedValues(quoteItemList);

		return quoteItemList;
	}
/*
	private void debugCalculatedValues(List<Toro_QuoteItem__c> quoteItemList) {
		
		String output = '\n\nCHECK CALCULATED VALUES\n\n';
		output += '\n<FIELD_NAME>: <TORO VALUE>, <ORIGINAL VALUE>\n';
		final Set<String> toroQuoteItemFieldNames = new Set<String>();
		for (String fieldName : Schema.getGlobalDescribe().get('REVVY__MnQuoteItem__c').getDescribe().fields.getMap().keySet()) {
			if (fieldName.startsWith('toro_')) {
				toroQuoteItemFieldNames.add(fieldName);
			}
		}
		final Set<String> toroSublineFieldNames = new Set<String>();
		for (String fieldName : Schema.getGlobalDescribe().get('Revvy__MnQuoteItemSubline__c').getDescribe().fields.getMap().keySet()) {
			if (fieldName.startsWith('toro_')) {
				toroSublineFieldNames.add(fieldName);
			}
		}
		for (Toro_QuoteItem__c qi : quoteItemList) {
			output += '\n\nQuote Item: ' + qi.QuoteItem__r.REVVY__Catalog_Node__r.name;
			for (String fieldName : toroQuoteItemFieldNames) {
				final Decimal toroValue = (Decimal) qi.get(fieldName);
				final Decimal originalValue = (Decimal) qi.get(fieldName.removeStart('toro_'));
				output += '\n';
				if (toroValue != originalValue) output += '**';
				output += fieldName + ': ' + toroValue + ', ' + originalValue;
			}

			for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
				output += '\n   Subline Item: ' + qis.QuoteItem__r.REVVY__Catalog_Node__r.name;
				for (String fieldName : toroSublineFieldNames) {
					final Decimal toroValue = (Decimal) qis.get(fieldName);
					final Decimal originalValue = (Decimal) qis.get(fieldName.removeStart('toro_'));
					if (toroValue != originalValue) output += '**';
					output += '   ' + fieldName + ': ' + toroValue + ', ' + originalValue + '\n';
				}

				output += '   REVVY__Quantity__c: ' + qis.get('REVVY__Quantity__c') + '\n';
				output += '   Toro_Extended_Qty__c: ' + qis.get('Toro_Extended_Qty__c') + '\n';
				output += '   DNet_Price_2__c: ' + qis.get('DNet_Price_2__c') + '\n';
				output += '   REVVY__Price__c: ' + qis.get('REVVY__Price__c') + '\n';
				output += '   Award_Price__c: ' + qis.get('Award_Price__c') + '\n';
				output += '   Percent_of_DNet__c: ' + qis.get('Percent_of_DNet__c') + '\n';
				output += '   Percent_Off_MSRP__c: ' + qis.get('Percent_Off_MSRP__c') + '\n';
			}
		}
		System.debug(output);
		
	}
*/
	// initializes the quote item and quote item subline calculated fields to 0
	private void initializeExtendedFieldsToZero(List<Toro_QuoteItem__c> quoteItemList) {
		system.debug('initializeExtendedFieldsToZero quoteItemList =' + quoteItemList);
		if(quoteItemList != null) {
			for (Toro_QuoteItem__c qi : quoteItemList) {
				qi.Toro_Blend_Of_DN__c                        = 0;
				qi.Toro_Extended_DNet_Price__c                = 0;
				qi.Toro_Distributor_Responsibility__c         = 0;
				qi.Toro_DNet_Price__c                         = 0;
				qi.Toro_DNetWOTPPAllied__c                    = 0;
				qi.Toro_Extended_Award_Price__c               = 0;
				qi.Toro_Extended_Award_DNet_Price__c          = 0;
				qi.Toro_Extended_Award_MSRP_Price__c          = 0;
				qi.Toro_Extended_MSRP_Price__c                = 0;
				qi.Toro_Fee_Amount__c                         = 0;
				qi.Toro_Gross_Profit_Value__c                 = 0;
				qi.Toro_Gross_Profit_Percent__c               = 0;
				qi.Toro_QuoteItemSubline_Rebate_as_of_Dnet__c = 0;
				qi.Toro_Rollup_Award_DNet_Price__c            = 0;
				qi.Toro_Rollup_Award_MSRP_Price__c            = 0;
				qi.Toro_Rollup_Award_Price__c                 = 0;
				qi.Toro_Rollup_DNet_for_TPP__c                = 0;
				qi.Toro_Rollup_DNet_Price__c                  = 0;
				qi.Toro_Rollup_Extended_Award_Price__c        = 0;
				qi.Toro_Rollup_MSRP_Price__c                  = 0;
				qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c  = 0;
				qi.Toro_Rollup_Setup_Fees_Sub_Line__c         = 0;
				qi.Toro_Rollup_Subline_Rebate__c              = 0;
				qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c  = 0;
				qi.Toro_Total_Award_price__c                  = 0;
				qi.Toro_Total_Extended_Award_Price__c         = 0;
				qi.Toro_Total_Extended_MSRP_Price__c          = 0;
				qi.Toro_Total_Rebate__c                       = 0;
				qi.Toro_Total_Setup_Fees__c                   = 0;
				qi.Toro_Total_Unit_Award__c                   = 0;
	
				if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
					for (Toro_QuoteItem_SubLine__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
						qis.Toro_Extended_Qty__c                     = 0;
						qis.Toro_Extended_Award_DNet_Price__c        = 0;
						qis.Toro_Extended_Award_MSRP_Price__c        = 0;
						qis.Toro_Extended_Award_Price__c             = 0;
						qis.Toro_DNet_Price__c                       = 0;
						qis.Toro_Extended_MSRP_Price__c              = 0;
						qis.Toro_Fee_Amount__c                       = 0;
						qis.Toro_Subline_Rebate__c                   = 0;
						qi.Toro_Rollup_Award_DNet_Price__c           = 0;
						qi.Toro_Rollup_Award_MSRP_Price__c           = 0;
						qi.Toro_Rollup_Award_Price__c                = 0;
						qi.Toro_Rollup_DNet_for_TPP__c               = 0;
						qi.Toro_Rollup_DNet_Price__c                 = 0;
						qi.Toro_Rollup_Extended_Award_Price__c       = 0;
						qi.Toro_Rollup_MSRP_Price__c                 = 0;
						qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c = 0;
						qi.Toro_Rollup_Setup_Fees_Sub_Line__c        = 0;
						qi.Toro_Rollup_Subline_Rebate__c             = 0;
						qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c = 0;
					}
				}
			}
		}
		
	}
/*
	public void saveToroQuoteItemList(List<Toro_QuoteItem__c> quoteItemList ){
		
		List<Toro_QuoteItem__c> toroQuoteItems = new List<Toro_QuoteItem__c>();
		List<Toro_QuoteItem_SubLine__c> toroSublines = new List<Toro_QuoteItem_SubLine__c>();
		for(Toro_QuoteItem__c qi : quoteItemList) {

			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Toro_QuoteItem_SubLine__cpoiuyd qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					Toro_QuoteItem_SubLine__c toroSubline = new Toro_QuoteItem_SubLine__c(
						External_Id__c = qis.Id,
						DNet_Price_2__c=qis.DNet_Price_2__c,
						Percent_of_DNet__c=qis.Percent_of_DNet__c,
						Percent_Off_MSRP__c=qis.Percent_Off_MSRP__c,
						TPP_Line_Item__c=qis.TPP_Line_Item__c,
						Performance_Part__c=qis.Performance_Part__c,
						Toro_Extended_Qty__c=qis.Toro_Extended_Qty__c,
						Toro_Extended_Award_DNet_Price__c=qis.Toro_Extended_Award_DNet_Price__c,
						Toro_Extended_Award_MSRP_Price__c=qis.Toro_Extended_Award_MSRP_Price__c,
						Toro_Extended_Award_Price__c=qis.Toro_Extended_Award_Price__c,
						Toro_DNet_Price__c=qis.Toro_DNet_Price__c,
						Toro_Extended_MSRP_Price__c=qis.Toro_Extended_MSRP_Price__c,
						Toro_Fee_Amount__c=qis.Toro_Fee_Amount__c,
						Toro_Subline_Rebate__c=qis.Toro_Subline_Rebate__c
					);
					toroSublines.add(toroSubline);
				}
			}
			Toro_QuoteItem__c tqi = new Toro_QuoteItem__c(QuoteItem__c=qi.Id,
				//Product_Name__c=qi.revvy__product_name_f__c, Product_Id__c=qi.revvy__product_Id_f__c,
				MSRP_Price__c=qi.revvy__Price__c, DNet_Price__c=qi.revvy__suggestedPrice__c, External_Id__c = qi.Id,
				Award_of_DN__c=qi.Award_of_DN__c,
				Award_Price__c=qi.Award_Price__c,
				Description__c=qi.Description__c,
				Original_off_MSRP__c=qi.Original_off_MSRP__c,
				Oroginal_of_DNet__c=qi.Oroginal_of_DNet__c,
				Part_Percentage__c=qi.Part_Percentage__c,
				Off_MSRP__c=qi.Off_MSRP__c,
				Performance_Parts_Product__c=qi.Performance_Parts_Product__c,
				Pricing_Program__c=qi.Pricing_Program__c,
				Rebate_as_a_of_DN__c=qi.Rebate_as_a_of_DN__c,
				Select_a_Price_Method__c=qi.Select_a_Price_Method__c,
				Selected_Off_MSRP__c=qi.Selected_Off_MSRP__c,
				Select_Price_Program_Type__c=qi.Select_Price_Program_Type__c,
				//....more here....
				Toro_Rollup_Award_DNet_Price__c=qi.Toro_Rollup_Award_DNet_Price__c,
				Toro_Rollup_Award_MSRP_Price__c=qi.Toro_Rollup_Award_MSRP_Price__c,
				Toro_Rollup_Award_Price__c=qi.Toro_Rollup_Award_Price__c,
				Toro_Rollup_DNet_for_TPP__c=qi.Toro_Rollup_DNet_for_TPP__c,
				Toro_Rollup_DNet_Price__c=qi.Toro_Rollup_DNet_Price__c,
				Toro_Rollup_Extended_Award_Price__c=qi.Toro_Rollup_Extended_Award_Price__c,
				Toro_Rollup_MSRP_Price__c=qi.Toro_Rollup_MSRP_Price__c,
				Toro_Rollup_Num_of_SubLines_for_Rebate__c=qi.Toro_Rollup_Num_of_SubLines_for_Rebate__c,
				Toro_Rollup_Setup_Fees_Sub_Line__c=qi.Toro_Rollup_Setup_Fees_Sub_Line__c,
				Toro_Rollup_Sum_percent_Rebate_of_Dnet__c=qi.Toro_Rollup_Sum_percent_Rebate_of_Dnet__c,
				Toro_Extended_Award_DNet_Price__c=qi.Toro_Extended_Award_DNet_Price__c,
				Toro_Extended_Award_MSRP_Price__c=qi.Toro_Extended_Award_MSRP_Price__c,
				Toro_Total_Award_price__c=qi.Toro_Total_Award_price__c,
				Toro_Total_Extended_Award_Price__c=qi.Toro_Total_Extended_Award_Price__c,
				Toro_Extended_DNet_Price__c=qi.Toro_Extended_DNet_Price__c,
				Toro_Blend_Of_DN__c=qi.Toro_Blend_Of_DN__c,
				Toro_Distributor_Responsibility__c=qi.Toro_Distributor_Responsibility__c,
				Toro_DNet_Price__c=qi.Toro_DNet_Price__c,
				Toro_DNetWOTPPAllied__c=qi.Toro_DNetWOTPPAllied__c,
				Toro_Extended_Award_Price__c=qi.Toro_Extended_Award_Price__c,
				Toro_Extended_MSRP_Price__c=qi.Toro_Extended_MSRP_Price__c,
				Toro_Fee_Amount__c=qi.Toro_Fee_Amount__c,
				Toro_Total_Rebate__c=qi.Toro_Total_Rebate__c,
				Toro_Gross_Profit_Value__c=qi.Toro_Gross_Profit_Value__c,
				Toro_Gross_Profit_Percent__c=qi.Toro_Gross_Profit_Percent__c,
				Toro_QuoteItemSubline_Rebate_as_of_Dnet__c=qi.Toro_QuoteItemSubline_Rebate_as_of_Dnet__c,
				Toro_Total_Extended_MSRP_Price__c=qi.Toro_Total_Extended_MSRP_Price__c,
				Toro_Total_Setup_Fees__c=qi.Toro_Total_Setup_Fees__c,
				Toro_Total_Unit_Award__c=qi.Toro_Total_Unit_Award__c
				);

			toroQuoteItems.add(tqi);
		}
		upsert toroQuoteItems External_Id__c;
		upsert toroSublines External_Id__c;
		
	}
	*/
	//Method saveQuoteItemList is a template method called by calculateRebateMargin
	public virtual List<Toro_QuoteItem__c> saveQuoteItemList(List<Toro_QuoteItem__c> quoteItemList ){
		
		system.debug(logginglevel.info,'inside base saveQuoteItemList');
		//saveToroQuoteItemList(quoteItemList);

		List<Toro_QuoteItem__c> updateQuoteItems = new List<Toro_QuoteItem__c>();
		List<Toro_QuoteItem_SubLine__c> updateQuoteItemSublines = new List<Toro_QuoteItem_SubLine__c>();
				
		for(Toro_QuoteItem__c qi : quoteItemList) {
			updateQuoteItems.add(qi);
			if(qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for(Toro_QuoteItem_SubLine__c qiSubline : qi.Toro_Quote_Item_Sub_Lines__r) {
					updateQuoteItemSublines.add(qiSubline);
				}
			}
		}
		
		if(updateQuoteItems.size() > 0) {
			database.update(updateQuoteItems, false);
		}
		if(updateQuoteItemSublines.size() > 0) {
			update updateQuoteItemSublines;
		}
		
		return quoteItemList;
	}

	public ToroPricingProgram() {
		quoteFieldMap = Schema.SObjectType.Revvy__MnQuote__c.fields.getMap();
		quoteItemFieldMap = Schema.SObjectType.Revvy__MnQuoteItem__c.fields.getMap();
		quoteItemSublineFieldMap = Schema.SObjectType.Revvy__MnQuoteItemSubline__c.fields.getMap();
	}

	public virtual void initializeQuoteHeader(Id quoteId) {
		system.debug(logginglevel.info, 'quoteId-------'+quoteId);
		String quoteQuery = 'select ' + getQuoteFieldAPINameQuery('Setup_Fee__c, Toro_Support_Plus_Allowance__c, Blended_Percent_of_DN__c, Support_Plus_Rebate__c, SP_Ext_Dist_Responsibility__c, SP_Total_Extended_DNET__c,name,REVVY__Account__r.BillingStateCode, Performance_Part__c, Pricing_Program_Name__c, Price_Method__c, Agree_to_Support_Plus_T_C__c,Blended_Percent_of_DN__c') + ' from Revvy__MnQuote__c where id=:quoteId';
		quote = Database.query(quoteQuery);

	}
	public virtual void initialize(Id quoteId) {
		initializeQuoteHeader(quoteId);
		
		String quoteLineQuery = 'Select ' + getToroQuoteItemFieldAPINamesQuery('Off_MSRP__c,Award_Price__c,Rebate_as_a_of_DN__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, MSRP_Price__c, Original_off_MSRP__c, Oroginal_of_DNet__c,Unit_Award_Overridden__c, QuoteItem__r.REVVY__Catalog_Node__r.revvy__id__c, QuoteItem__r.REVVY__Catalog_Node__r.name,Select_Price_Program_Type__c,QuoteItem__r.REVVY__SuggestedPrice__c,Misc_Style__c , DNet_Price__c,QuoteItem__r.REVVY__Price__c,Off_MSRP__c, Selected_Off_MSRP__c, Pricing_Program__c, Select_a_Price_Method__c, Award_of_DN__c, Standard_Price__c');
		quoteLineQuery += ', (Select ' + getToroQuoteItemSublineFieldAPINamesQuery('Award_Price__c, Rebate_as_of_DNet__c,Fee_Percentage__c,Part_Percentage__c,Toro_Product_Tier__c, Exclude_from_Rebate__c,Unit_Award_Overridden__c, Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c,DNet_Price_2__c ,Misc_Style__c, DNet_Price__c ,Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name, Standard_Price__c, Quote_Item_Sub_Line__r.REVVY__Price__c, Quote_Item_Sub_Line__r.REVVY__SuggestedPrice__c, Toro_Quote_Item__r.Select_a_Price_Method__c, Percent_Off_MSRP__c, Percent_of_DNet__c');
		quoteLineQuery += ' from Toro_Quote_Item_Sub_Lines__r order by Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.Name) from  Toro_QuoteItem__c where Mn_Quote__c = :quoteId';
		System.debug('88888888888888888888=' + quoteLineQuery);
		quoteItems = Database.query(quoteLineQuery);
		system.debug('quote items =' + quoteItems);
		//Set<Id> deleteSetupFeeLineItemId = new Set<Id>();
		//for(REVVY__MnQuoteItem__c qi : quoteItems) {
		//	system.debug('**************' + qi.Off_MSRP__c + '&&&&&&' + qi.Award_of_DN__c);
			//if('S00001'.equalsIgnoreCase(qi.REVVY__Product_ID_F__c)) {
			//	deleteSetupFeeLineItemId.add(qi.Id);
			//}
			//Reset Values
			//qi.Off_MSRP__c = 0;
			//qi.Rebate_as_a_of_DN__c = 0;
			//qi.Fee_Percentage__c = 0;
			//qi.Part_Percentage__c = 0;
			//qi.Award_Price__c = 0; //qi.REVVY__SuggestedPrice__c * qi.Award_of_DN__c/100;

			//List<REVVY__MnQuoteItemSubLine__c> qiSub = qi.REVVY__QuoteItemSubLine__r;
			//if(qiSub!=null) {
			//	for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
			//		qis.percent_off_msrp__c =  0;
			//		qis.Fee_Percentage__c = 0;
			//		qis.Part_Percentage__c = 0;
			//		qis.Award_Price__c =0;
			//	}
			//}
		//}
		//delete setup fee line
		//delete [Select Id From REVVY__MnQuoteItem__c where Id in :deleteSetupFeeLineItemId];
	}
	public virtual Revvy__MnQuoteItem__c calculateRebateAndMarginForQuoteItem(String pricingProgram, String priceMethod, Revvy__MnQuoteItem__c quoteItem ) {
		return null;
	}
	public virtual List<SelectOption> getPriceMethodOptions() {
		return new List<SelectOption> {new SelectOption('% off MSRP','% off MSRP'),  new SelectOption('% of DNET','% of DNET') };
	}
	public virtual boolean getQuoteLevelMSQPDNetEditable() {
		return true;
	}
	public virtual boolean isEligible(Toro_PricingProgram__c pp, Revvy__MnQuote__c quote, List<Revvy__MnQuoteItem__c> qiList) {
		return true;
	}
	public virtual List<Schema.FieldSetMember> getQuoteItemSummaryFields() {
		return SObjectType.Revvy__MnQuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}
	public virtual boolean excludedFromMSRP(Toro_QuoteItem__c qi) {
		boolean ret = false;

		if(qi.Performance_Parts_Product__c) {
			ret=true;
		}

		return ret;
	}

	public virtual boolean excludedFromMSRP(Toro_QuoteItem_SubLine__c qi) {
		boolean ret = false;
		String productId = string.isNotBlank(qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c) ? qi.Quote_Item_Sub_Line__r.REVVY__Catalog_Node__r.revvy__id__c : qi.Quote_Item_Sub_Line__r.Product_ID_F__c;
		if(qi.TPP_Line_Item__c || productId.startsWith('L0') || productId.startsWith('L1') || qi.Performance_Part__c) {
			ret = true;
		}
		return ret;
	}

	public virtual Map<String, boolean> getQuoteFieldsUpdatable() {
		Set<String> fs = new Set<String>();
		Map<String, boolean> ret = new Map<String, boolean>();
		for(String s : getQuoteFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		system.debug(fs);
		return ret;
	}

	public virtual Map<String, boolean> getQuoteItemFieldsUpdatable() {
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		return ret;
	}

	public virtual Map<String, boolean> getQuoteItemSublineFieldsUpdatable(string pricingMethod) {
		Map<String, boolean> ret = new Map<String, boolean>();
		Set<String> fs = new Set<String>();
		for(String s : getQuoteItemSublineFieldAPINames()) {
			fs.add(s.toLowerCase());
			ret.put(s.toLowerCase(), false);
		}
		return ret;
	}

	private String CombineSelectClauses(List<String> fieldListFromFS, String extraFields ) {
		String extraFieldWOSpaces = extraFields.replaceAll( '\\s+', '');
		String[] extras = extraFieldWOSpaces.split(',');
		Set<String> nameSet = new Set<String>(extras);
		nameSet.addAll(fieldListFromFS);
		return String.join(new List<String>(nameSet), ',');
	}

	protected virtual List<String> getQuoteFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}

	protected virtual String getQuoteFieldAPINameQuery(String extraFields) {
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}

	protected virtual String getToroQuoteFieldAPINameQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return CombineSelectClauses(getQuoteFieldAPINames(), extraFields);
	}
	
	protected virtual String getToroQuoteItemFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		for(Schema.FieldSetMember fs : getToroQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return CombineSelectClauses(fieldNames, extraFields);
	}
	
	protected virtual String getToroQuoteItemSublineFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getToroQuoteItemSublineFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return CombineSelectClauses(fieldNames, extraFields);
	}
	
	protected virtual List<String> getQuoteItemFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteItemFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}
	

	protected virtual List<String> getQuoteItemSummaryFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteItemSummaryFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}

	protected virtual String getQuoteItemFieldAPINamesQuery(String extraFields) {
		List<String> fieldNames = new List<String>(getQuoteItemFieldAPINames());
		fieldNames.addAll(getQuoteItemSummaryFieldAPINames());
		return CombineSelectClauses(fieldNames, extraFields);
	}

	protected virtual List<String> getQuoteItemSublineFieldAPINames() {
		List<String> fieldNames = new List<String>();
		for(Schema.FieldSetMember fs : getQuoteItemSublineFields()) {
			fieldNames.add(fs.getFieldPath());
		}
		return fieldNames;
	}

	protected virtual String getQuoteItemSublineFieldAPINamesQuery(String extraFields) {
		return CombineSelectClauses(getQuoteItemSublineFieldAPINames(), extraFields);
	}

	protected Map<String, Schema.SObjectField> quoteFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemFieldMap { get; set; }
	protected Map<String, Schema.SObjectField> quoteItemSublineFieldMap { get; set; }
}