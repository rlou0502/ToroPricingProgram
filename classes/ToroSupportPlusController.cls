global class ToroSupportPlusController {
	public Id quoteId { get; private set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroSupportPlusController() {
		quoteId = ApexPages.currentPage().getParameters().get('id');
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static ToroSupportPlusData retrieveSupportPlusData(Id quoteId) {
		return ToroSupportPlusData.createToroSupportPlusData(quoteId);
	}


	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
    @AuraEnabled
    public static List<REVVY__MnPriceListLine__c> fetchSearchResults(String searchTerm) {
        final String term = '%' + searchTerm + '%';
		List<REVVY__MnPriceListLine__c> pricelistLines = [
			SELECT
				REVVY__Product__c
				, REVVY__Product__r.REVVY__Id__c
				, REVVY__Product__r.Name
				, REVVY__Product__r.REVVY__Description__c
				, REVVY__SuggestedPrice__c
			FROM
				REVVY__MnPriceListLine__c
			WHERE
				REVVY__Product__r.REVVY__Type__c IN ('Product', 'Bundle')
				AND REVVY__Product__r.REVVY__Effective_Start_Date__c <= TODAY
				AND REVVY__Product__r.REVVY__Effective_End_Date__c >= TODAY
				AND REVVY__Product__r.REVVY__Status__c = 'Active'
				AND REVVY__PriceList__r.Name = 'Commercial'
				AND REVVY__Product__r.REVVY__Id__c LIKE :term
			ORDER BY
				REVVY__Product__r.Name asc
		];

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
	public static Boolean deleteQuoteItem(Id quoteItemId) {
		Boolean wasSuccessful = true;
		try {
			REVVY__MnQuoteItem__c quoteItemToDelete = [
				SELECT
					Id
				FROM
					REVVY__MnQuoteItem__c
				WHERE
					Id = :quoteItemId
				LIMIT 1
			];

			if (quoteItemToDelete != null) {
				delete quoteItemToDelete;
			}
		}

		catch (Exception e) {
			wasSuccessful = false;
		}

		return wasSuccessful;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static ToroSupportPlusItem addSupportPlustItem(Id quoteId, String productId, Decimal dnetPrice, Decimal spQuantity, Decimal distributorResponsibility) {
		List<REVVY__MnPriceListLine__c> pricelistLines = [
			SELECT
				REVVY__Product__r.REVVY__Id__c
				, REVVY__Product__r.Name
			FROM
				REVVY__MnPriceListLine__c
			WHERE
				REVVY__Product__r.REVVY__Type__c IN ('Product', 'Bundle')
				AND REVVY__Product__r.REVVY__Effective_Start_Date__c <= TODAY
				AND REVVY__Product__r.REVVY__Effective_End_Date__c >= TODAY
				AND REVVY__Product__r.REVVY__Status__c = 'Active'
				AND REVVY__PriceList__r.Name = 'Commercial'
				AND REVVY__Product__r.REVVY__Id__c = :productId
			ORDER BY
				REVVY__Product__r.Name asc
		];

		if (pricelistLines.isEmpty()) return null;

		ToroSupportPlusItem result = new ToroSupportPlusItem(
			priceListLines[0].REVVY__Product__r
			, dnetPrice
			, spQuantity
		);

		return result;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static Boolean splitAndSaveItems(REVVY__MnQuote__c quote
											, String quoteItemsJSON
											, String supportPlusItemsJSON
	) {
		Savepoint sp = Database.setSavepoint();
		try {
			// update the quote header values
			updateQuote(quote);

			// build copy of Support Plus Data currently in database
			final ToroSupportPlusData currentSupportPlusDataWrapper = ToroSupportPlusData.createToroSupportPlusData(quote.Id);



			// ============================================================================
			// HANDLE MAIN QUOTE ITEMS
			// ============================================================================
			final List<REVVY__MnQuoteItem__c> quoteItemsToInsert = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnStrategy4__c> quoteItemExtensionsToUpdate = new List<REVVY__MnStrategy4__c>();

			// find the quote items that have changed
			final Map<Id,ToroSupportPlusItem> mainQuoteItemWrapperMap = ToroSupportPlusItem.buildQuoteItemIdToWrapperMap((List<ToroSupportPlusItem>)JSON.deserializeStrict(quoteItemsJSON,List<ToroSupportPlusItem>.class));
			final Map<Id,ToroSupportPlusItem> currentQuoteItemWrapperMap = ToroSupportPlusItem.buildQuoteItemIdToWrapperMap(currentSupportPlusDataWrapper.quoteItems);
			final List<ToroSupportPlusItem> changedQuoteItemWrappers = new List<ToroSupportPlusItem>();
			for (Id quoteItemId : currentQuoteItemWrapperMap.keySet()) {
				ToroSupportPlusItem currentWrapper = currentQuoteItemWrapperMap.get(quoteItemId);
				ToroSupportPlusItem newWrapper = mainQuoteItemWrapperMap.get(quoteItemId);
				if (currentWrapper.spQuantity != newWrapper.spQuantity) {
					changedQuoteItemWrappers.add(newWrapper);
					System.debug('\n\n@@quoteItem: ' + newWrapper.productId + ' ' + currentWrapper.spQuantity + ' to ' + newWrapper.spQuantity + '\n\n');
				}
			}
			System.debug('\n\n@@changedQuoteItemWrappers: ' + changedQuoteItemWrappers + '\n\n');

			for (ToroSupportPlusItem wrapper : changedQuoteItemWrappers) {
				// we still need to determine if an existing support plus item exists for the main quote item
				// if it does, then we only need to update the extension object. if it does not exist,
				// then we need to create the quote item object, then update the extension object
				Decimal quantity = wrapper.quantity;
				Decimal updatedSpQuantity = wrapper.spQuantity;
				if (wrapper.hasExistingSupportPlusItem()) {
					System.debug('\n\n@@wrapper.hasExistingSupportPlusItem(): ' + wrapper.hasExistingSupportPlusItem() + '\n\n');
					REVVY__MnStrategy4__c quoteItemExtensionToUpdate = new REVVY__MnStrategy4__c(
                        external_ID__c = wrapper.sfid
						, Adjusted_Quantity__c = quantity - updatedSpQuantity
					);

					REVVY__MnStrategy4__c supportPlusExtensionToUpdate = new REVVY__MnStrategy4__c(
						external_Id__c = wrapper.SupportPlusItemId
						, Adjusted_Quantity__c = updatedSpQuantity
					);
					Map<String, decimal> extIdQtyMap = new Map<String, decimal>{wrapper.sfid=>(quantity - updatedSpQuantity), wrapper.SupportPlusItemId=>updatedSpQuantity};

					List<REVVY__MnStrategy4__c> spQuoteItems = [select id, external_Id__c from REVVY__MnStrategy4__c where external_Id__c in :extIdQtyMap.keyset()];
					for(REVVY__MnStrategy4__c qi : spQuoteItems) {
						qi.Adjusted_Quantity__c = extIdQtyMap.get(qi.external_Id__c);
					}
					System.debug('\n\n@@before quoteItemExtensionsToUpdate : ' + quoteItemExtensionsToUpdate + '\n\n');

					quoteItemExtensionsToUpdate.addAll(spQuoteItems);
					System.debug('\n\n@@after quoteItemExtensionsToUpdate: ' + quoteItemExtensionsToUpdate + '\n\n');
				}

				else {
					REVVY__MnQuoteItem__c supportPlusQuoteItemToInsert = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c            = updatedSpQuantity
						, REVVY__Id__c                  = ToroSupportPlusHelper.generateExternalId()
						, Is_Support_Plus_Item_Only__c  = false
						, REVVY__Quote__c               = quote.Id
						, REVVY__PricelistLine__c       = wrapper.pricelistLineId
						, REVVY__Catalog_Node__c        = wrapper.catalogNodeId
						, REVVY__Price__c               = 0
						, REVVY__SuggestedPrice__c      = 0
						, Description__c                = wrapper.description
						, Misc_Style__c                 = 'NoCharge'
						, Support_Plus_Original_Item__c = wrapper.sfid
					);

					List<REVVY__MnStrategy4__c> spQuoteItems = [select id, external_Id__c from REVVY__MnStrategy4__c where external_Id__c = :wrapper.sfid];
					for(REVVY__MnStrategy4__c qi : spQuoteItems) {
						qi.Adjusted_Quantity__c = quantity - updatedSpQuantity;
					}

					quoteItemsToInsert.add(supportPlusQuoteItemToInsert);
					quoteItemExtensionsToUpdate.addAll(spQuoteItems);
				}
			}


			// ============================================================================
			// HANDLE MAIN QUOTE ITEM SUBLINES
			// ============================================================================



			// ============================================================================
			// HANDLE SUPPORT PLUS ONLY ITEMS
			// ============================================================================

			/*
			// find the support plus items that have changed
			final Map<Id,ToroSupportPlusItem> newSupportPlusItemWrapperMap = ToroSupportPlusItem.buildIdToSupportPlusItemMap(
				(List<ToroSupportPlusItem>)JSON.deserializeStrict(supportPlusItemsJSON,List<ToroSupportPlusItem>.class)
			);
			final Map<Id,ToroSupportPlusItem> currentSupportPlusOnlyItemWrapperMap =  ToroSupportPlusItem.buildIdToSupportPlusItemMap(originalSupportPlusData.supportPlusOnlyItems);
			final List<ToroSupportPlusItem> newSupportPlusWrappersToInsert = new List<ToroSupportPlusItem>();
			final List<ToroSupportPlusItem> changedSupportPlusWrappers = new List<ToroSupportPlusItem>();

			// iterate the updated wrappers passed from the support plus application
			// these are support plus only items
			for (Id itemId : newSupportPlusItemWrapperMap.keySet()) {
				ToroSupportPlusItem newWrapper = newSupportPlusItemWrapperMap.get(itemId);
				if (!currentSupportPlusOnlyItemWrapperMap.containsKey(itemId)) {
					newSupportPlusWrappersToInsert.add(newWrapper);
					System.debug('\n\n@@' + newWrapper.productId + ' (new) ' + newWrapper.spQuantity + '\n\n');
				}

				else {
					// support plus item already exists, so we only need to update them.
					ToroSupportPlusItem originalWrapper = currentSupportPlusOnlyItemWrapperMap.get(itemId);
					if (originalWrapper.spQuantity != newWrapper.spQuantity) {
						changedSupportPlusWrappers.add(newWrapper);
						System.debug('\n\n@@' + newWrapper.productId + ' ' + originalWrapper.spQuantity + ' to ' + newWrapper.spQuantity + '\n\n');
					}
				}
			}

			System.debug('\n\n@@newSupportPlusWrappersToInsert: ' + newSupportPlusWrappersToInsert + '\n\n');
			System.debug('\n\n@@changedSupportPlusWrappers: ' + changedSupportPlusWrappers + '\n\n');



			// ============================================================================
			// handle support plus only items

			// these are support plus only items that need to be created
			for (ToroSupportPlusItem wrapper : newSupportPlusWrappersToInsert) {
					REVVY__MnQuoteItem__c supportPlusQuoteItemToInsert = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c            = 1
						, REVVY__Id__c                  = ToroSupportPlusHelper.generateExternalId()
						, Is_Support_Plus_Item_Only__c  = true
						, REVVY__Quote__c               = quote.Id
						, REVVY__PricelistLine__c       = wrapper.pricelistLineId
						, REVVY__Catalog_Node__c        = wrapper.catalogNodeId
						, REVVY__Price__c               = 0
						, REVVY__SuggestedPrice__c      = 0
						, Description__c                = wrapper.description
						, Misc_Style__c                 = 'NoCharge'
						, Support_Plus_Original_Item__c = null
					);

					REVVY__MnStrategy4__c quoteItemExtensionToUpdate = new REVVY__MnStrategy4__c(
						Id = wrapper.extensionObjId
						, Adjusted_Quantity__c = wrapper.spQuantity
						, Support_Plus_Item__c = true
					);

					quoteItemsToInsert.add(supportPlusQuoteItemToInsert);
					quoteItemExtensionsToUpdate.add(quoteItemExtensionToUpdate);
			}

			// these are support plus only items that have changed
			for (ToroSupportPlusItem wrapper : changedSupportPlusWrappers) {
				// we still need to determine if an existing support plus item exists for the main quote item
				REVVY__MnStrategy4__c quoteItemExtensionToUpdate = new REVVY__MnStrategy4__c(
					Id = wrapper.extensionObjId
					, Adjusted_Quantity__c = wrapper.spQuantity
					, Support_Plus_Item__c = true
				);
				quoteItemExtensionsToUpdate.add(quoteItemExtensionToUpdate);
			}
			*/
			System.debug('\n\n@@quoteItemsToInsert: ' + quoteItemsToInsert + '\n\n');
			System.debug('\n\n@@quoteItemExtensionsToUpdate: ' + quoteItemExtensionsToUpdate + '\n\n');
			insert quoteItemsToInsert;
			update quoteItemExtensionsToUpdate;

			/*
			List<String> strat4ExtIds = new List<String>();
			for (REVVY__MnStrategy4__c obj : quoteItemExtensionsToUpdate) {
				strat4Extids.add(obj.external_Id__c);
			}

			List<REVVY__MnStrategy4__c> strat4List = [
				SELECT
					DNet_Price__c
					, Adjusted_Quantity__c
					, external_Id__c
				FROM
					REVVY__MnStrategy4__c
				WHERE external_Id__c IN :strat4ExtIds];

			System.debug('\n\n@@strat4List: ' + strat4List + '\n\n');
			*/
		}

		catch (Exception e) {
			Database.rollback(sp);
			return false;
		}

		return true;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	private static void updateQuote(REVVY__MnQuote__c quote) {
		// ============================================================================
		// first, update quote with selected distributor responsibility
		System.debug('\n\n@@quote: ' + quote + '\n\n');
		//update quote;

		REVVY__MnQuote__c quoteObjToUpdate = [
			SELECT
				Distributor_Responsibility__c
				, Toro_Support_Plus_Allowance__c
				, SP_Toro_Responsibility__c
				, SP_Ext_Dist_Responsibility__c
				, SP_Total_Extended_DNET__c
			FROM
				REVVY__MnQuote__c
			WHERE
				Id = :quote.Id
		];
		quoteObjToUpdate.Distributor_Responsibility__c = quote.Distributor_Responsibility__c;
		quoteObjToUpdate.Toro_Support_Plus_Allowance__c = quote.Toro_Support_Plus_Allowance__c;
		quoteObjToUpdate.SP_Toro_Responsibility__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Toro_Responsibility__c);
		quoteObjToUpdate.SP_Ext_Dist_Responsibility__c = CMnQuoteUtil.defaultDecimal(quote.SP_Ext_Dist_Responsibility__c);
		quoteObjToUpdate.SP_Total_Extended_DNET__c     = CMnQuoteUtil.defaultDecimal(quote.SP_Total_Extended_DNET__c);
		update quoteObjToUpdate;
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static Boolean splitAndSaveItemsOld(REVVY__MnQuote__c quote
							, String quoteItemsJSON
							, String supportPlusItemsJSON
	) {/*
		System.debug('\n\n@@@ToroSupportPlusController.splitAndSave\n\n');
		List<REVVY__MnQuoteItem__c> quoteItemsToUpdate       = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItem__c> supportPlusItemsToInsert = new List<REVVY__MnQuoteItem__c>();
		List<REVVY__MnQuoteItem__c> supportPlusItemsToDelete = new List<REVVY__MnQuoteItem__c>();
		List<ToroSupportPlusItem> quoteItemWrappers = (List<ToroSupportPlusItem>)JSON.deserializeStrict(quoteItemsJSON,List<ToroSupportPlusItem>.class);
		List<ToroSupportPlusItem> supportPlusItemWrappers = (List<ToroSupportPlusItem>)JSON.deserializeStrict(supportPlusItemsJSON,List<ToroSupportPlusItem>.class);

		System.debug('\n\n@@quoteItemWrappers: ' + quoteItemWrappers + '\n\n');
		System.debug('\n\n@@supportPlusItemWrappers: ' + supportPlusItemWrappers + '\n\n');

		Savepoint sp = Database.setSavepoint();
		try {

			// ============================================================================
			// HANDLE THE QUOTE
			// ============================================================================
			REVVY__MnQuote__c quoteObjToUpdate = [
				SELECT
					Id
				FROM
					REVVY__MnQuote__c
				WHERE
					Id = :quote.Id
			];

			quoteObjToUpdate.Distributor_Responsibility__c = quote.Distributor_Responsibility__c;
			update quoteObjToUpdate;


			// ============================================================================
			// HANDLE QUOTE ITEMS
			// ============================================================================
			List<REVVY__MnQUoteItem__c> quoteItemObjs = ToroSupportPlusData.getQuoteItems(quote.Id);
			// get quote items and support plus items
			final Map<Id,REVVY__MnQuoteItem__c> originalQuoteItemMap = new Map<Id,REVVY__MnQuoteItem__c>();
			final Map<Id,REVVY__MnQuoteItem__c> quoteItemIdToSupportPlusItemMap = new Map<Id,REVVY__MnQuoteItem__c>();
			final Map<Id,REVVY__MnQuoteItem__c> existingSupportPlusOnlyItemMap = new Map<Id,REVVY__MnQuoteItem__c>();
			// check if quote items have an existing support plus item
			for (REVVY__MnQUoteItem__c quoteItemObj  : quoteItemObjs) {
				if (quoteItemObj.Is_Support_Plus_Item_Only__c) {
					existingSupportPlusOnlyItemMap.put(quoteItemObj.Id, quoteItemObj);
				}
				else if (quoteItemObj.Support_Plus_Original_Item__c == null) {
					originalQuoteItemMap.put(quoteItemObj.Id, quoteItemObj);
				}

				else {
					quoteItemIdToSupportPlusItemMap.put(quoteItemObj.Support_Plus_Original_Item__c, quoteItemObj);
				}
			}

			System.debug('\n\n@@existingSupportPlusOnlyItemMap: ' + existingSupportPlusOnlyItemMap + '\n\n');
			System.debug('\n\n@@originalQuoteItemMap: ' + originalQuoteItemMap + '\n\n');
			System.debug('\n\n@@quoteItemIdToSupportPlusItemMap: ' + quoteItemIdToSupportPlusItemMap + '\n\n');

			// iterate the wrappers and build lists for quote item insert/update/delete
			for (ToroSupportPlusItem quoteItemWrapper : quoteItemWrappers) {
				final Decimal quantity   = quoteItemWrapper.quantity;
				final Decimal spQuantity = quoteItemWrapper.spQuantity;

				REVVY__MnQuoteItem__c originalQuoteItemObj = originalQuoteItemMap.get(quoteItemWrapper.sfid);

				// skip if no change
				if (quoteItemIdToSupportPlusItemMap.containsKey(originalQuoteItemObj.Id)) {
					Decimal originalQuantity = originalQuoteItemObj.REVVY__Quantity__c;
					Decimal originalSpQuantity = quoteItemIdToSupportPlusItemMap.get(originalQuoteItemObj.Id).REVVY__Quantity__c;
					if (quantity == originalQuantity && spQuantity == originalSpQuantity) {
						continue;
					}
				}

				else {
					Decimal originalQuantity = originalQuoteItemObj.REVVY__Quantity__c;
					if (quantity == originalQuantity && spQuantity == 0) {
						continue;
					}
				}

				// handle the quote item
				if (spQuantity == 0) {
					if (quoteItemIdToSupportPlusItemMap.containsKey(quoteItemWrapper.sfid)) {
						originalQuoteItemObj.Support_Plus_Original_Item__c = null;
						REVVY__MnQuoteItem__c supportPlusItemObj = quoteItemIdToSupportPlusItemMap.get(quoteItemWrapper.sfid);
						supportPlusItemsToDelete.add(supportPlusItemObj);
					}
					originalQuoteItemObj.REVVY__Quantity__c = quantity;
					quoteItemsToUpdate.add(originalQuoteItemObj);
				}

				else if (spQuantity > 0 && spQuantity < quantity) {
					originalQuoteItemObj.REVVY__Quantity__c = quantity - spQuantity;
					quoteItemsToUpdate.add(originalQuoteItemObj);

					if (quoteItemIdToSupportPlusItemMap.containsKey(quoteItemWrapper.sfid)) {
						REVVY__MnQuoteItem__c supportPlusItemObj = quoteItemIdToSupportPlusItemMap.get(quoteItemWrapper.sfid);
						supportPlusItemObj.REVVY__Quantity__c = spQuantity;
						quoteItemsToUpdate.add(supportPlusItemObj);
					}

					else {
						REVVY__MnQuoteItem__c newSupportPlusItemObj = new REVVY__MnQuoteItem__c(
							REVVY__Quantity__c           = spQuantity
							, REVVY__Id__c                 = generateRevvyId()
							, Is_Support_Plus_Item_Only__c = false
							, REVVY__Quote__c              = quote.Id
							, REVVY__PricelistLine__c      = originalQuoteItemObj.REVVY__PricelistLine__c
							, REVVY__Catalog_Node__c       = originalQuoteItemObj.REVVY__Catalog_Node__c
							, REVVY__Price__c              = 0
							, REVVY__SuggestedPrice__c     = 0
							, Description__c               = originalQuoteItemObj.Description__c
							, Misc_Style__c                = 'NoCharge'
							, Support_Plus_Original_Item__c = originalQuoteItemObj.Id
						);

						supportPlusItemsToInsert.add(newSupportPlusItemObj);
					}
				}

				else if (spQuantity == quantity) {
					originalQuoteItemObj.REVVY__Quantity__c = quantity;
					originalQuoteItemObj.Support_Plus_Original_Price__c = originalQuoteItemObj.REVVY__SuggestedPrice__c;
					originalQuoteItemObj.REVVY__SuggestedPrice__c = 0.0;
					quoteItemsToUpdate.add(originalQuoteItemObj);

					if (quoteItemIdToSupportPlusItemMap.containsKey(quoteItemWrapper.sfid)) {
						REVVY__MnQuoteItem__c supportPlusItemObj = quoteItemIdToSupportPlusItemMap.get(quoteItemWrapper.sfid);
						supportPlusItemObj.REVVY__Quantity__c = spQuantity;
						quoteItemsToUpdate.add(supportPlusItemObj);
					}

					else {
						REVVY__MnQuoteItem__c newSupportPlusItemObj = new REVVY__MnQuoteItem__c(
							  REVVY__Quantity__c           = spQuantity
							, REVVY__Id__c                 = generateRevvyId()
							, Is_Support_Plus_Item_Only__c = false
							, REVVY__Quote__c              = quote.Id
							, REVVY__PricelistLine__c      = originalQuoteItemObj.REVVY__PricelistLine__c
							, REVVY__Catalog_Node__c       = originalQuoteItemObj.REVVY__Catalog_Node__c
							, REVVY__SuggestedPrice__c     = 0
							, Description__c               = originalQuoteItemObj.Description__c
							, Misc_Style__c                = 'NoCharge'
							, Support_Plus_Original_Item__c = originalQuoteItemObj.Id
						);

						supportPlusItemsToInsert.add(newSupportPlusItemObj);
					}
				}
			}

			// handle the sublines
			List<REVVY__MnQuoteItemSubLine__c> sublinesToUpdate            = new List<REVVY__MnQuoteItemSubLine__c>();
			List<REVVY__MnQuoteItemSubLine__c> supportPlusSublinesToInsert = new List<REVVY__MnQuoteItemSubLine__c>();
			List<REVVY__MnQuoteItemSubLine__c> supportPlusSublinesToDelete = new List<REVVY__MnQuoteItemSubLine__c>();
			final Map<Id, REVVY__MnQuoteItemSubLine__c> originalSublineMap            = new Map<Id, REVVY__MnQuoteItemSubLine__c>();
			final Map<Id, REVVY__MnQuoteItemSubline__c> sublineIdToSupportPlusItemMap = new Map<Id, REVVY__MnQuoteItemSubLine__c>();
			// check if sublines have an existing support plus item
			for (REVVY__MnQuoteItem__c quoteItemObj : quoteItemObjs) {
				for (REVVY__MnQuoteItemSubLine__c sublineObj : quoteItemObj.REVVY__QuoteItemSubLine__r) {
					if (sublineObj.Support_Plus_Original_Item__c == null) {
						originalSublineMap.put(sublineObj.Id, sublineObj);
					}

					else {
						sublineIdToSupportPlusItemMap.put(sublineObj.Support_Plus_Original_Item__c, sublineObj);
					}
				}
			}

			// iterate subline wrappers and build lists for subline insert/update/delete
			for (ToroSupportPlusItem quoteItemWrapper : quoteItemWrappers) {
				for (ToroSupportPlusItem sublineWrapper : quoteItemWrapper.sublines) {
					final Decimal quantity = sublineWrapper.quantity;
					final Decimal spQuantity = sublineWrapper.spQuantity;

					// handle the subline
					REVVY__MnQuoteItemSubline__c originalSublineObj = originalSublineMap.get(sublineWrapper.sfid);

					// skip if no change
					if (originalSublineObj == null) {
						continue;
					}
					else if (sublineIdToSupportPlusItemMap.containsKey(originalSublineObj.Id)) {
						Decimal originalQuantity = originalSublineObj.REVVY__Quantity__c;
						Decimal originalSpQuantity = sublineIdToSupportPlusItemMap.get(originalSublineObj.Id).REVVY__Quantity__c;
						if (quantity == originalQuantity && spQuantity == originalSpQuantity) {
							continue;
						}
					}

					else {
						Decimal originalQuantity = originalSublineObj.REVVY__Quantity__c;
						if (quantity == originalQuantity && spQuantity == 0) {
							continue;
						}
					}

					// handle changes
					if (spQuantity == 0) {
						if (sublineIdToSupportPlusItemMap.containsKey(sublineWrapper.sfid)) {
							originalSublineObj.Support_Plus_Original_Item__c = null;
							REVVY__MnQuoteItemSubLine__c supportPlusItemObj = sublineIdToSupportPlusItemMap.get(sublineWrapper.sfid);
							supportPlusSublinesToDelete.add(supportPlusItemObj);
						}
						originalSublineObj.REVVY__Quantity__c = quantity;
						sublinesToUpdate.add(originalSublineObj);
					}


					else if (spQuantity > 0 && spQuantity < quantity) {
						originalSublineObj.REVVY__Quantity__c = quantity - spQuantity;
						sublinesToUpdate.add(originalSublineObj);

						if (sublineIdToSupportPlusItemMap.containsKey(sublineWrapper.sfid)) {
							REVVY__MnQuoteItemSubLine__c supportPlusItemObj = sublineIdToSupportPlusItemMap.get(sublineWrapper.sfid);
							supportPlusItemObj.REVVY__Quantity__c = spQuantity;
							sublinesToUpdate.add(supportPlusItemObj);
						}

						else {
							REVVY__MnQuoteItemSubLine__c newSupportPlusItemObj = new REVVY__MnQuoteItemSubLine__c(
								  REVVY__Quantity__c            = spQuantity
								, REVVY__Id__c                  = generateRevvyId()
								, REVVY__QuoteItem__c           = quoteItemWrapper.sfid
								, REVVY__PricelistLine__c       = originalSublineObj.REVVY__PricelistLine__c
								, REVVY__Catalog_Node__c        = originalSublineObj.REVVY__Catalog_Node__c
								, REVVY__Price__c               = 0
								, REVVY__SuggestedPrice__c      = 0
								, Description__c                = originalSublineObj.Description__c
								, Misc_Style__c                 = 'NoCharge'
								, Support_Plus_Original_Item__c = originalSublineObj.Id
							);

							supportPlusSublinesToInsert.add(newSupportPlusItemObj);
						}
					}

					else if (spQuantity == quantity) {
						originalSublineObj.REVVY__Quantity__c = quantity;
						originalSublineObj.Support_Plus_Original_Price__c = originalSublineObj.REVVY__SuggestedPrice__c;
						originalSublineObj.REVVY__SuggestedPrice__c = 0.0;
						sublinesToUpdate.add(originalSublineObj);

						if (sublineIdToSupportPlusItemMap.containsKey(sublineWrapper.sfid)) {
							REVVY__MnQuoteItemSubline__c supportPlusItemObj = sublineIdToSupportPlusItemMap.get(sublineWrapper.sfid);
							supportPlusItemObj.REVVY__Quantity__c = spQuantity;
							sublinesToUpdate.add(supportPlusItemObj);
						}

						else {
							REVVY__MnQuoteItemSubLine__c newSupportPlusItemObj = new REVVY__MnQuoteItemSubLine__c(
								  REVVY__Quantity__c            = spQuantity
								, REVVY__Id__c                  = generateRevvyId()
								, REVVY__QuoteItem__c           = quoteItemWrapper.sfid
								, REVVY__PricelistLine__c       = originalSublineObj.REVVY__PricelistLine__c
								, REVVY__Catalog_Node__c        = originalSublineObj.REVVY__Catalog_Node__c
								, REVVY__Price__c               = 0
								, REVVY__SuggestedPrice__c      = 0
								, Description__c                = originalSublineObj.Description__c
								, Misc_Style__c                 = 'NoCharge'
								, Support_Plus_Original_Item__c = originalSublineObj.Id
							);

							supportPlusSublinesToInsert.add(newSupportPlusItemObj);
						}
					}
				}
			}

			// handle add new support plus items
			Map<Decimal,REVVY__MnQuoteItem__c> addNewSupportPlusExtIdItemMap = new Map<Decimal,REVVY__MnQuoteItem__c>();
			for (ToroSupportPlusItem newItemWrapper : supportPlusItemWrappers) {
				// existingSupportPlusOnlyItemMap
				if (newItemWrapper.sfid == null) {
					System.debug('\n\n@@add new:: ' + newItemWrapper + '\n\n');
					REVVY__MnQuoteItem__c newSupportPlusItemObj = new REVVY__MnQuoteItem__c(
						REVVY__Quantity__c           = newItemWrapper.spQuantity
						, REVVY__Id__c                 = generateRevvyId()
						, Is_Support_Plus_Item_Only__c = true
						, REVVY__Quote__c              = quote.Id
						// , REVVY__PricelistLine__c      = newItemWrapper.supportPlusNewPricelistId
						// , REVVY__Catalog_Node__c       = newItemWrapper.supportPlusNewCatalogNodeId
						, REVVY__SuggestedPrice__c     = newItemWrapper.dnetPrice
						, Description__c               = newItemWrapper.description
						, Misc_Style__c                = 'NoCharge'
						, Support_Plus_Original_Item__c = null
					);
					supportPlusItemsToInsert.add(newSupportPlusItemObj);
					addNewSupportPlusExtIdItemMap.put(newSupportPlusItemObj.REVVY__Id__c, newSupportPlusItemObj);
					System.debug('\n\n@@newSupportPlusItemObj: ' + newSupportPlusItemObj + '\n\n');
				}

				else {
					REVVY__MnQuoteItem__c existingNewItem = existingSupportPlusOnlyItemMap.get(newItemWrapper.sfid);
					if (newItemWrapper.quantity == 0) {
						supportPlusItemsToDelete.add(existingNewItem);
					}

					else if (existingNewItem.REVVY__Quantity__c != newItemWrapper.quantity) {
						existingNewItem.REVVY__Quantity__c = newItemWrapper.quantity;
						quoteItemsToUpdate.add(existingNewItem);
					}
				}
			}

			System.debug('\n\n@@quoteItemsToUpdate: ' + quoteItemsToUpdate + '\n\n');
			System.debug('\n\n@@supportPlusItemsToInsert: ' + supportPlusItemsToInsert + '\n\n');
			System.debug('\n\n@@supportPlusItemsToDelete: ' + supportPlusItemsToDelete + '\n\n');

			System.debug('\n\n@@sublinesToUpdate: ' + sublinesToUpdate + '\n\n');
			System.debug('\n\n@@supportPlusSublinesToInsert: ' + supportPlusSublinesToInsert + '\n\n');
			System.debug('\n\n@@supportPlusSublinesToDelete: ' + supportPlusSublinesToDelete + '\n\n');

			// quote items
			List<REVVY__MnQuoteItem__c> quoteItemsToUpsert = new List<REVVY__MnQuoteItem__c>();
			quoteItemsToUpsert.addAll(quoteItemsToUpdate);
			quoteItemsToUpsert.addAll(supportPlusItemsToInsert);
			upsert quoteItemsToUpsert;
			delete supportPlusItemsToDelete;

			// we need to update the suggested price on the newly added support plus items again.
			// it seems that when the quote item is inserted, the suggested price is populated using the
			// price list.
			if (!addNewSupportPlusExtIdItemMap.isEmpty()) {
				List<REVVY__MnQuoteItem__c> newSupportPlusOnlyItems = [
					SELECT
						REVVY__Id__c
						, REVVY__SuggestedPrice__c
					FROM
						REVVY__MnQuoteItem__c
					WHERE
						REVVY__Id__c IN :addNewSupportPlusExtIdItemMap.keySet()
				];

				for (REVVY__MnQuoteItem__c newSupportPlusOnlyItem : newSupportPlusOnlyItems) {
					Decimal suggestedPrice = addNewSupportPlusExtIdItemMap.get(newSupportPlusOnlyItem.REVVY__Id__c).REVVY__SuggestedPrice__c;
					newSupportPlusOnlyItem.REVVY__SuggestedPrice__c = suggestedPrice;
				}
				update newSupportPlusOnlyItems;
			}

			// sublines
			List<REVVY__MnQuoteItemSubline__c> sublinesToUpsert = new List<REVVY__MnQuoteItemSubLine__c>();
			sublinesToUpsert.addAll(sublinesToUpdate);
			sublinesToUpsert.addAll(supportPlusSublinesToInsert);
			upsert sublinesToUpsert;
			delete supportPlusSublinesToDelete;

			// sequence gen
			if (sequenceGen != null) {
				update sequenceGen;
			}
		}

		catch (Exception e) {
			Database.rollback(sp);
			return false;

		}
		*/
		return true;
	}
}