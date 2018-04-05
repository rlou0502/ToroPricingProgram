global class ToroSupportPlusController {
	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static ToroSupportPlusData retrieveSupportPlusData(Id quoteId) {
		
		Revvy__MnQuote__c tmpQ = [select Toro_Total_DNet__c from Revvy__MnQuote__c where id = :quoteId];
        List<Support_Plus_Plan__c> plans = [select Total_DNet_Low__c, Total_DNet_High__c, Maximum_Support__c from Support_Plus_Plan__c order by Total_DNet_Low__c];
        for(Support_Plus_Plan__c sp : plans) {
        	if((tmpQ.Toro_Total_DNet__c >= sp.Total_DNet_Low__c) && (tmpQ.Toro_Total_DNet__c < sp.Total_DNet_High__c)) {
        		tmpQ.Toro_Support_Plus_Allowance__c = sp.Maximum_Support__c;
        		break;
        	}
        }
        //update quote;
        update tmpQ;
        
		ToroSupportPlusData ret = new ToroSupportPlusData();
		REVVY__MnQuote__c spQuote = [
			SELECT
				Id
				, Name
				, Toro_Support_Plus_Allowance__c
				, Toro_Blended_Percent_of_DN__c
				, Support_Plus_Rebate__c
				, SP_Ext_Dist_Responsibility__c
				, SP_Total_Extended_DNET__c
			FROM
				REVVY__MnQuote__c
			WHERE
				Id = :quoteId
		];
		spQuote.Support_Plus_Rebate__c = CMnQuoteUtil.defaultDecimal(spQuote.Support_Plus_Rebate__c);
    	spQuote.SP_Ext_Dist_Responsibility__c = CMnQuoteUtil.defaultDecimal(spQuote.SP_Ext_Dist_Responsibility__c);
    	spQuote.SP_Total_Extended_DNET__c = CMnQuoteUtil.defaultDecimal(spQuote.SP_Total_Extended_DNET__c);

    	List<Support_Plus_Contribution__c> contributions = [
			SELECT
				Award_Price_Low__c
				, Award_Price_High__c
				, Toro_Contribution__c
				, Distributor_Contribution__c
			FROM
				Support_Plus_Contribution__c];

    	for (Support_Plus_Contribution__c con : contributions) {
    		if (
				spQuote.Toro_Blended_Percent_of_DN__c >= con.Award_Price_Low__c
				&& spQuote.Toro_Blended_Percent_of_DN__c < con.Award_Price_High__c
			) {
        		spQuote.Distributor_Responsibility__c = con.Distributor_Contribution__c;
        		ret.Distributor_Responsibility        = spQuote.Distributor_Responsibility__c;
        		break;
        	}
    	}

    	ret.quote = spQuote;

		List<REVVY__MnQuoteItem__c> quoteItems = [
			SELECT
				REVVY__Product_Name_F__c
				, REVVY__Product_ID_F__c
				, REVVY__Quantity__c
				, Support_Plus_Quantity__c
				, Description__c
				, Distributor_Responsibility__c
				, REVVY__SuggestedPrice__c
				, (SELECT
						REVVY__Quantity__c
						, Support_Plus_Quantity__c
						, REVVY__Catalog_Node__r.Name
						, Product_ID2__c
						, Description__c
						, Distributor_Responsibility__c
						, REVVY__SuggestedPrice__c
					FROM
						REVVY__QuoteItemSubLine__r
					ORDER BY
						REVVY__Catalog_Node__r.Name)
			FROM
				REVVY__MnQuoteItem__c
			WHERE
				REVVY__Quote__c = :quoteId
		];

		final List<QuoteItem> quoteItemWrapperList = new List<QuoteItem>();
		for (REVVY__MnQuoteItem__c quoteItem : quoteItems) {
            quoteItemWrapperList.add(new QuoteItem(quoteItem));
        }

        ret.quoteItemList = quoteItemWrapperList;
		return ret;
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
    @AuraEnabled
    public static List<REVVY__MnPriceListLine__c> getProductCodesAura(String searchTerm) {
        String term = '%' + searchTerm + '%';
        List<REVVY__MnPriceListLine__c> pricelistLines = [
			SELECT Id
				, REVVY__Product__r.REVVY__Id__c
				, REVVY__Product__r.Name
				, REVVY__Product__c
				, REVVY__SuggestedPrice__c
			FROM
				REVVY__MnPriceListLine__c
            WHERE
				REVVY__Product__r.REVVY__Type__c IN ('Product', 'Bundle')
				AND REVVY__Product__r.REVVY__Effective_Start_Date__c <= TODAY
				AND REVVY__Product__r.REVVY__Effective_End_Date__c >= TODAY
				AND REVVY__Product__r.REVVY__Status__c = 'Active'
				AND REVVY__PriceList__r.Name = 'Commercial'
				AND (REVVY__Product__r.REVVY__Id__c LIKE :term
					OR REVVY__Product__r.Name LIKE :term)];

        return pricelistLines;
    }



	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static void submitSupportPlus(REVVY__MnQuoteItem__c quote, List<QuoteItem> quoteItems) {
		List<REVVY__MnQuoteItem__c>        quoteItemsToUpdate = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItem__c>        quoteItemsToInsert = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> sublinesToUpdate   = new List<REVVY__MnQuoteItemSubline__c>();
		List<REVVY__MnQuoteItemSubline__c> sublinesToInsert   = new List<REVVY__MnQuoteItemSubline__c>();

		REVVY__MnSequenceGen__c sequence = [
			SELECT
				REVVY__CurrentValue__c
			FROM
				REVVY__MnSequenceGen__c
			WHERE
				REVVY__ObjectName__c = 'MnQuoteItem__c' LIMIT 1
		];

		for (QuoteItem qItem : quoteItems) {
			REVVY__MnQuoteItem__c qi = qItem.qi;
			Decimal supportPlusQty = qi.Support_Plus_Quantity__c == null ? 0 : qi.Support_Plus_Quantity__c;
			if (supportPlusQty != 0) {
				Decimal diff = qi.REVVY__Quantity__c - qi.Support_Plus_Quantity__c;
				if (diff != 0) {
					REVVY__MnQuoteItem__c clonedQi = qi.clone(false, true, false, false); //keep Id and deep-clone
					qi.REVVY__Quantity__c = diff;
					qi.Support_Plus_Item__c = true;

					REVVY__MnQuoteItem__c newQuote = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c       = supportPlusQty
						, REVVY__Price__c          = 0
						, REVVY__Unit_Price__c     = 0
						, REVVY__Quote__c          = quote.Id
						, REVVY__Id__c             = ++sequence.REVVY__CurrentValue__c
						, REVVY__PricelistLine__c  = qi.REVVY__PricelistLine__c
						, REVVY__Catalog_Node__c   = qi.REVVY__Catalog_Node__c
						, REVVY__SuggestedPrice__c = 0
						, Description__c           = qi.Description__c
						, Support_Plus_Quantity__c = qi.Support_Plus_Quantity__c
						, Support_Plus_Item__c     = true
						, Misc_Style__c            = 'NoCharge'
					);

					quoteItemsToUpdate.add(qi);
					quoteItemsToInsert.add(newQuote);
				}

				else {
					qi.REVVY__Quantity__c   = 0.000001;
					qi.Support_Plus_Item__c = true;
					qi.Misc_Style__c        = 'NoCharge';
					quoteItemsToUpdate.add(qi);
				}
			}

			List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;

			if (qiSub != null && qiSub.size() > 0) {
				for (REVVY__MnQuoteItemSubline__c qis : qiSub) {
					Decimal supportPlusQty2 = qis.Support_Plus_Quantity__c == null ? 0 : qis.Support_Plus_Quantity__c;
					if (supportPlusQty2 != 0) {
						Decimal diff = qis.REVVY__Quantity__c - qis.Support_Plus_Quantity__c ;
						if (diff != 0) {
							REVVY__MnQuoteItemSubline__c clonedQis = qis.clone(false, true, false, false); // keep Id and deep-clone

							qis.REVVY__Quantity__c             = diff;
							clonedQis.REVVY__Quantity__c       = qis.Support_Plus_Quantity__c;
							qis.Apply_Support_Plus__c          = true;
							clonedQis.Support_Plus_Quantity__c = 0;
							clonedQis.REVVY__Unit_price__c     = 0;
							clonedQis.REVVY__price__c          = 0;
							clonedQis.Apply_Support_Plus__c    = true;
							clonedQis.Misc_Style__c            = 'NoCharge';

							sublinesToUpdate.add(qis);
							sublinesToInsert.add(clonedQis);
						}

						else {
							qis.REVVY__Quantity__c    = 0.000000001;
							qis.Apply_Support_Plus__c = true;
							qis.Misc_Style__c         = 'NoCharge';
							sublinesToUpdate.add(qis);
						}
					}

					else {
						qis.Apply_Support_Plus__c = false;
					}
				}
			}
		}

        List<REVVY__MnQuoteItem__c> qitems = new List<REVVY__MnQuoteItem__c>();
		sequence.REVVY__CurrentValue__c++;
		update sequence;

		if (qitems.size() > 0) {
			insert qitems;
		}

		if (!quoteItemsToUpdate.isEmpty()) {
			update quoteItemsToUpdate;
		}

		if (!quoteItemsToInsert.isEmpty()) {
			insert quoteItemsToInsert;
		}

		if (!sublinesToUpdate.isEmpty()) {
			update sublinesToUpdate;
		}

		if (!sublinesToInsert.isEmpty()) {
			insert sublinesToInsert;
		}

		// update quote;
	}


/*
    public void init() {

    	quote = [
			SELECT
				Id
				, Toro_Support_Plus_Allowance__c
				, Blended_Percent_of_DN__c
				, Support_Plus_Rebate__c
				, SP_Ext_Dist_Responsibility__c
				, SP_Total_Extended_DNET__c
			FROM
				REVVY__MnQuote__c
			WHERE
				Id = :quoteId
		];

    	if (quote.Support_Plus_Rebate__c == null) {
    		quote.Support_Plus_Rebate__c=0;
    	}

    	if (quote.SP_Ext_Dist_Responsibility__c == null) {
    		quote.SP_Ext_Dist_Responsibility__c=0;
    	}

    	if (quote.SP_Total_Extended_DNET__c == null) {
    		quote.SP_Total_Extended_DNET__c=0;
    	}

    	List<Support_Plus_Contribution__c> contributions = [select Award_Price_Low__c, Award_Price_High__c, Toro_Contribution__c, Distributor_Contribution__c from Support_Plus_Contribution__c];

    	for (Support_Plus_Contribution__c con : contributions) {
    		system.debug('=======================q.Blended_Percent_of_DN__c='+ quote.Blended_Percent_of_DN__c + ' low=' + con.Award_Price_Low__c + ' high='  + con.Award_Price_High__c);
    		if((quote.Blended_Percent_of_DN__c >= con.Award_Price_Low__c) && (quote.Blended_Percent_of_DN__c < con.Award_Price_High__c)) {
        		system.debug('=======================con.Distributor_Contribution__c=' + con.Distributor_Contribution__c);
        		quote.Distributor_Responsibility__c = con.Distributor_Contribution__c;
        		Distributor_Responsibility = quote.Distributor_Responsibility__c;
        		system.debug('=======================Distributor_Responsibility=' + Distributor_Responsibility);
        		break;
        	}
    	}

    	update quote;
    	loadQuoteInformation();

    }
	*/

	/*
	public void loadQuoteInformation() {
		helper = new ToroLargePackagePricingProgramHelper();
		helper.initialize(quoteId);
		helper.quote.Agree_to_Support_Plus_T_C__c = false;
		quote                                     = helper.quote;
		quotes                                    = new List<REVVY__MnQuote__c> {helper.quote};
		quoteItems                                = helper.quoteItems;

        //if('Large package'.equalsIgnoreCase(priceProgramType)) {
		quoteItemWrapperList = new List<QuoteItem>();
		for(REVVY__MnQuoteItem__c qi : quoteItems) {
			//if(qi.Support_Plus_Quantity__c == null) {
				qi.Support_Plus_Quantity__c=0;
			//}
			if(String.isBlank(qi.Description__c)) {
				qi.Description__c=qi.REVVY__Product_Name_F__c;
			}
            QuoteItem q = new QuoteItem();
            q.qi=qi;
            if(qi.REVVY__QuoteItemSubLine__r!=null && qi.REVVY__QuoteItemSubLine__r.size()>0) {
                q.qislList=qi.REVVY__QuoteItemSubLine__r;
                for(REVVY__MnQuoteItemSubLine__c qis : qi.REVVY__QuoteItemSubLine__r) {
                	if(String.isBlank(qis.Description__c)) {
						qis.Description__c=qis.REVVY__Catalog_Node__r.Name;
					}
					//if(qis.Support_Plus_Quantity__c == null) {
						qis.Support_Plus_Quantity__c=0;
					//}
                }
            }

            quoteItemWrapperList.add(q);
        }
        supportPlusList = new List<Support_Plus_Holder__c>{new Support_Plus_Holder__c(Distributor_Responsibility__c = Distributor_Responsibility)};
	}
	*/



	private transient ToroPricingProgram helper;


	public Id quoteId 									{ get; set; }
	public String searchTerm 							{ get; set; }
    public String selectedProductCode 					{ get; set; }

	public Decimal Distributor_Responsibility 			{ get; set; }
	public transient Id quoteItemId 					{ get; set; }
	public transient List<REVVY__MnQuote__c> quotes 	{ get; set; }
	public REVVY__MnQuote__c quote 						{ get; set; }
	public List<REVVY__MnQuoteItem__c> quoteItems 		{ get; set; }
	public List<QuoteItem> quoteItemWrapperList 		{ get; set; }


	public ToroSupportPlusController() {
		quoteId = ApexPages.currentPage().getParameters().get('id'); 
	}


	public PageReference returnToQuote() {
		PageReference newPage = new PageReference('https://toro--cpqdev.cs91.my.salesforce.com/'+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}


	public PageReference submitSupportPlus() {
		system.debug('+++++++++++++++++quoteItemWrapperList=' + quoteItemWrapperList);
		List<REVVY__MnQuoteItem__c> updatedQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItem__c> insertQuoteItems = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItemSubline__c> updatedQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		List<REVVY__MnQuoteItemSubline__c> insertQuoteItemSublines = new List<REVVY__MnQuoteItemSubline__c>();
		REVVY__MnSequenceGen__c sequence = [SELECT REVVY__CurrentValue__c FROM REVVY__MnSequenceGen__c WHERE REVVY__ObjectName__c='MnQuoteItem__c' limit 1];
		for(QuoteItem qItem : quoteItemWrapperList) {
			REVVY__MnQuoteItem__c qi = qItem.qi;
			decimal supportPlusQty = qi.Support_Plus_Quantity__c == null ? 0 : qi.Support_Plus_Quantity__c;
			if(supportPlusQty != 0) {
				decimal diff = qi.REVVY__Quantity__c - qi.Support_Plus_Quantity__c ;
				if(diff != 0) {
					REVVY__MnQuoteItem__c clonedQi = qi.clone(false, true, false, false); //keep Id and deep-clone
					qi.REVVY__Quantity__c = diff;
					qi.Support_Plus_Item__c = true;

					REVVY__MnQuoteItem__c newQuote = new REVVY__MnQuoteItem__c(REVVY__quantity__c=supportPlusQty,
						REVVY__price__c = 0,
						REVVY__Unit_price__c = 0,
						REVVY__quote__c=quoteId, REVVY__Id__c=++sequence.REVVY__currentvalue__c,
						REVVY__pricelistline__c=qi.REVVY__pricelistline__c, REVVY__CATALOG_NODE__C = qi.REVVY__CATALOG_NODE__C,
						description__c= qi.description__c, REVVY__suggestedprice__c = 0,
						Support_Plus_Quantity__c=qi.Support_Plus_Quantity__c,
						Support_Plus_Item__c = true,
						Misc_Style__c='NoCharge'
						);

					/*
					clonedQi.REVVY__Quantity__c = qi.Support_Plus_Quantity__c;
					clonedQi.Support_Plus_Quantity__c=0;
					clonedQi.REVVY__Unit_price__c = 0;
					//clonedQi.REVVY__price__c=0;
					clonedQi.REVVY__Id__c=++sequence.REVVY__currentvalue__c;

					clonedQi.Support_Plus_Item__c=true;
					system.debug('------- new quote item Id=' + clonedQi.Id + ' quote Id = ' + clonedQi.REVVY__Quote__c);
					*/
					updatedQuoteItems.add(qi);
					insertQuoteItems.add(newQuote);
				} else {
					qi.REVVY__Quantity__c=0.000001;
					qi.Support_Plus_Item__c = true;
					qi.Misc_Style__c='NoCharge';
					updatedQuoteItems.add(qi);
				}
			}
			system.debug('--------------qi product =' + qi.REVVY__Product_Name_F__c + ' qty =' + qi.REVVY__Quantity__c + ' Support_Plus_Quantity__c =' + qi.Support_Plus_Quantity__c);
			List<REVVY__MnQuoteItemSubLine__c> qiSub = qItem.qislList;
			system.debug('----------------------' + qi);
			if(qiSub!=null && qiSub.size()>0) {
				//system.debug('product name=' + qi.REVVY__Product_name_f__c + ' Percent off MSRP=' + qi.Off_MSRP__c + ' off DN=' + qi.Award_of_DN__c);
				for(REVVY__MnQuoteItemSubline__c qis : qiSub) {
					system.debug('--------------qis product =' + qis.REVVY__Catalog_Node__r.name + ' qty =' + qis.REVVY__Quantity__c + ' Support_Plus_Quantity__c =' + qis.Support_Plus_Quantity__c);
					decimal supportPlusQty2 = qis.Support_Plus_Quantity__c == null ? 0 : qis.Support_Plus_Quantity__c;
					if(supportPlusQty2 != 0) {
						decimal diff = qis.REVVY__Quantity__c - qis.Support_Plus_Quantity__c ;
						if(diff != 0) {
							REVVY__MnQuoteItemSubline__c clonedQis = qis.clone(false, true, false, false); //keep Id and deep-clone
							qis.REVVY__Quantity__c = diff;
							clonedQis.REVVY__Quantity__c = qis.Support_Plus_Quantity__c;
							qis.Apply_Support_Plus__c=true;
							clonedQis.Support_Plus_Quantity__c=0;
							clonedQis.REVVY__Unit_price__c = 0;
							clonedQis.REVVY__price__c=0;
							clonedQis.Apply_Support_Plus__c=true;
							clonedQis.Misc_Style__c='NoCharge';
							updatedQuoteItemSublines.add(qis);
							insertQuoteItemSublines.add(clonedQis);
						} else {
							qis.REVVY__Quantity__c = 0.000000001;
							qis.Apply_Support_Plus__c=true;
							qis.Misc_Style__c='NoCharge';
							updatedQuoteItemSublines.add(qis);
						}
						//system.debug('------- new quote item subline Id=' + clonedQis.Id + ' quote item Id = ' + clonedQis.REVVY__QuoteItem__c);
					}
					else{
						qis.Apply_Support_Plus__c=false;
					}
				}
			}
		}



        List<REVVY__MnQuoteItem__c> qitems = new List<REVVY__MnQuoteItem__c>();
		/*
		for(Support_Plus_Holder__c sp : supportPlusList) {
			if(sp.Support_Plus_Quantity__c != null && sp.Support_Plus_Quantity__c>0) {
				Id prodId = sp.Product__c;
				String description = sp.Description__c;
				decimal esponsibility = sp.Distributor_Responsibility__c;
				decimal dnet = sp.DNet__c;
				qitems.add(new REVVY__MnQuoteItem__c(REVVY__quantity__c=sp.Support_Plus_Quantity__c,
					REVVY__price__c = 0,
					REVVY__quote__c=quoteId, REVVY__Id__c=++sequence.REVVY__currentvalue__c,
					REVVY__pricelistline__c=sp.pricelistline__c, REVVY__CATALOG_NODE__C = prodId,
					description__c= description, REVVY__suggestedprice__c = 0,
					Support_Plus_Quantity__c=sp.Support_Plus_Quantity__c,
					Support_Plus_Item__c = true,
					Misc_Style__c='NoCharge'
					));
			}
		}
		*/
		sequence.REVVY__currentvalue__c++;
		update sequence;
		if(qitems.size() > 0) {
			insert qitems;
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
		update quote;
		PageReference newPage = new PageReference('/apex/ToroSelectPriceProgram?id='+quoteId);
		newPage.setRedirect(true);
		return newPage;
	}

	public PageReference returnToPricingPage() {
		PageReference newPage = new PageReference('/apex/ToroSelectPriceProgram');
		newPage.getParameters().put('id', quoteId);
		newPage.setRedirect(true);
		return newPage;
	}


    public class QuoteItemList {
        public List<QuoteItem> qiList { get; set; }
    }

    global class ProductPricingInfo {
    	public decimal dnet {get; set; }
    	public String productName { get; set; }
    	public Id pricelistLine { get; set; }
    }
    @RemoteAction
    global static ToroSupportPlusController.ProductPricingInfo getDNetPrice(Id productId) {
    	ToroSupportPlusController.ProductPricingInfo ret = null;
    	List<REVVY__MnPriceListLine__c> priceListLines = [Select r.REVVY__SuggestedPrice__c, r.REVVY__Product_Name__c, r.REVVY__Product_Id__c,
    			r.REVVY__Price_List_ID__c, r.REVVY__PriceList__c From REVVY__MnPriceListLine__c r
    			where REVVY__Price_List_ID__c = 'Commercial' and REVVY__Product__c = :productId];
    	for(REVVY__MnPriceListLine__c pli : priceListLines) {
    		ret = new ToroSupportPlusController.ProductPricingInfo();
    		ret.dnet = pli.REVVY__SuggestedPrice__c;
    		ret.productName = pli.REVVY__Product_Name__c;
    		ret.pricelistLine = pli.id;
    	}
    	return ret;
    }
    @RemoteAction
    global static List<REVVY__MnPriceListLine__c> getProductCodes(String searchTerm) {
        System.debug('searchTerm: '+searchTerm );
        String term = '%'+searchTerm+'%';
        List<REVVY__MnPriceListLine__c> plis = [SELECT Id, REVVY__Product__r.REVVY__Id__c, REVVY__Product__r.Name, REVVY__product__c, REVVY__suggestedPrice__c FROM REVVY__MnPriceListLine__c
                            WHERE REVVY__Product__r.REVVY__Type__c IN ('Product', 'Bundle') AND
                            REVVY__Product__r.REVVY__Effective_Start_Date__c <= TODAY AND
                            REVVY__Product__r.REVVY__Effective_End_Date__c >= TODAY AND
                            REVVY__Product__r.REVVY__Status__c = 'Active' AND
                            REVVY__PriceList__r.name = 'Commercial' AND REVVY__Product__r.REVVY__Id__c like :term];

        return plis;
    }
}