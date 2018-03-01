public class ToroLargePackagePricingProgramHelper extends ToroPricingProgram {
	
	public override List<Schema.FieldSetMember> getQuoteFields() {
		system.debug('ToroLargePackagePricingProgramHelper --- getQuoteFields');
		return SObjectType.Revvy__MnQuote__c.FieldSets.REVVY__Quote_Header_Fields.getFields();
	}

	public override List<Schema.FieldSetMember> getToroQuoteItemFields() {
		List<Schema.FieldSetMember> fsl = SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Cols.getFields();
		return fsl;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemUpdatableFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Large_Package_Quote_Line_Updatable_Cols.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineFields() {
		List<Schema.FieldSetMember> fsl = SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Price_Program_Quote_SubLin.getFields();
		return fsl;
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSublineUpdatableFields() {
		return SObjectType.Toro_QuoteItem_SubLine__c.FieldSets.Large_Package_Quote_SubLine_Updatable_Co.getFields();
	}
	public override List<Schema.FieldSetMember> getToroQuoteItemSummaryFields() {
		return SObjectType.Toro_QuoteItem__c.FieldSets.Price_Program_Quote_Summary.getFields();
	}

	public override List<ToroSelectOption> retrievePricingMethodOptions() {
		List<ToroSelectOption> ret = new List<ToroSelectOption>();
		if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
			ret.add(new ToroSelectOption('% of DNET','% of DNET'));	
		}
		ret.add(new ToroSelectOption('% off MSRP','% off MSRP'));
		ret.add(new ToroSelectOption('Total Award $','Total Award $'));
		ret.add(new ToroSelectOption('Gross Profit %','Gross Profit %'));
		return ret;
	}
	
	public override List<ToroSelectOption> retrieveDemoPricingProgramOptions() {
		List<ToroSelectOption> sels = new List<ToroSelectOption>();
		for(Toro_PricingProgram__c pp : [SELECT Name, PricingProgramStyle__c, ExternalId__c FROM Toro_PricingProgram__c 
									where PricingProgramStyle__c = 'Demo' AND Exclude__c = false order by externalID__c asc]){
			sels.add(new ToroSelectOption(pp.ExternalId__c+ ';' + pp.PricingProgramStyle__c, pp.name));
		}
		return sels;
	}
	public override boolean displayPerformancePart() {
		return true;
	}


	public decimal lookupRebateAsPercentOfDNet(decimal percentOfDNet, List<Toro_PricingProgramLine__c> dNetLineList ) {
		decimal result = 0;
		decimal x3 = percentOfDNet;

		//system.debug('lookupRebateAsPercentOfDNet---x3='+ x3);
		for(integer i =dNetLineList.size()-1; i > 0  ; i--) {
			Toro_PricingProgramLine__c l = dNetLineList[i];
			//system.debug('lookupRebateAsPercentOfDNet---high='+ dNetLineList[i].Award_Price_as_a_Percent_of_DN__c + ' low=' +
			//	dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c);
			if(x3 < dNetLineList[i].Award_Price_as_a_Percent_of_DN__c && x3 > dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c){
				decimal x1=(dNetLineList[i].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal x2=(dNetLineList[i-1].Award_Price_as_a_Percent_of_DN__c)/100;
				decimal y1=(dNetLineList[i].Rebate_as_a_Percent_of_DN__c)/100;
				decimal y2=(dNetLineList[i-1].Rebate_as_a_Percent_of_DN__c)/100;
				x3 = x3/100;
				result = y2 -(((x3-x2)*(y2-y1)));
				break;
			}
		}
		return result;
	}
	public override List<Toro_QuoteItem__c> calculateRebateMarginImpl(Id quoteId, String priceProgram,
															String priceMethod, List<Toro_QuoteItem__c> quoteItemList ){
		
		return quoteItemList;
	}

	

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public override List<Toro_QuoteItem__c> postCalculateRebateMargin(Id quoteId
																		, String priceProgram
																		, String priceMethod
																		, List<Toro_QuoteItem__c> quoteItemList
	) {
		final Toro_PricingProgram__c pricingProgram = [SELECT
															OutCrossThreshold__c
															, MinimumThreshold__c
															, MinimumTractionUnits__c
														FROM
															Toro_PricingProgram__c
														WHERE
															Name = :priceProgram LIMIT 1];

		Revvy__MnQuote__c quote = [SELECT
										Toro_ApprovalReason__c
										, Toro_ApprovalRequired__c
										, Total_Extended_DNet__c
									FROM
										Revvy__MnQuote__c
									WHERE
										Id = :quoteId LIMIT 1];

		Boolean containsOutCross = checkForOutCrossProducts(quoteItemList);
		Integer numberOfTractionUnits = getNumberOfTractionUnits(quoteItemList);

		// quotes that contain outcross items have a separate threshold
		if (containsOutCross && quote.Total_Extended_DNet__c < pricingProgram.OutCrossThreshold__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = 'Total Extended DNet must exceed ' + pricingProgram.OutCrossThreshold__c;
		}

		else if (!containsOutcross && quote.Total_Extended_DNet__c < pricingProgram.MinimumThreshold__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = 'Total Extended DNet must exceed ' + pricingProgram.MinimumThreshold__c;
		}

		else if (numberOfTractionUnits < pricingProgram.MinimumTractionUnits__c) {
			quote.Toro_ApprovalRequired__c = true;
			quote.Toro_ApprovalReason__c = 'Quote must contain at least ' + pricingProgram.MinimumTractionUnits__c + ' traction unit(s).' ;
		}

		if (quote.Toro_ApprovalRequired__c) update quote;

		return 	quoteItemList;
	}

	/**
	 *
	 * returns the number of Traction Units in a quote
	 *
	 * @param  quoteItemList    the list of Toro Quote Items
	 * @return count of traction units
	 */
	public Integer getNumberOfTractionUnits(List<Toro_QuoteItem__c> quoteItemList) {
		// toro product type = 'Finished Good' (catalog node field) Toro_Product_Type__c
		Integer count = 0;
		System.debug('\n\nquoteItemList:\n\n' + quoteItemList + '\n\n');
		for (Toro_QuoteItem__c quoteItem : quoteItemList) {
			if (quoteItem.Product__r.Toro_Product_Type__c == 'Finished Good') {
				count++;
			}
		}
		System.debug('\n\n@@count: ' + count + '\n\n');
		return count;
	}

	/**
	 *
	 * check if the quote items contain an Out-Cross unit
	 *
	 * @param  quoteItemList    the list of Toro Quote Items
	 * @return true/false
	 */
	public Boolean checkForOutCrossProducts(List<Toro_QuoteItem__c> quoteItemList) {
		System.debug('\n\n@@checkForOutCrossProducts quoteItemList: ' + quoteItemList + '\n\n');
		for (Toro_QuoteItem__c quoteItem : quoteItemList) {
			if (quoteItem.Product_Name__c.startsWithIgnorecase('OUTCROSS')) {
				System.debug('\n\n@@contains outcross\n\n');
				return true;
			}
		}

		return false;
	}
}