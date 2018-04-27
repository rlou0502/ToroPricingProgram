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
		return new ToroSupportPlusData(quoteId);
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
	public static ToroSupportPlusItem addSupportPlustItem(Id quoteId, String productId, Decimal dnetPrice, Decimal spQuantity) {
		List<REVVY__MnPriceListLine__c> pricelistLines = [
			SELECT
				Id
				, REVVY__Product__r.REVVY__Id__c
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
			, priceListLines[0]
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
		System.debug('\n\n@@splitAndSaveItems start\n\n');
		Savepoint sp = Database.setSavepoint();
		try {
			// UPDATE QUOTE
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
			System.debug('\n\n@@quoteObjToUpdate: ' + quoteObjToUpdate + '\n\n');

			// EXISTING QUOTE ITEM DATA
			final ToroSupportPlusData existingSpData = new ToroSupportPlusData(quote.Id);
			final Map<Id,ToroSupportPlusItem> existingQiWrapperMap = ToroSupportPlusHelper.buildQuoteItemWrapperMap(existingSpData.qiWrappers);
			System.debug('\n\n@@existingQiWrapperMap: ' + existingQiWrapperMap + '\n\n');

			// NEW DATA FROM SUPPORT PLUS
			final Map<Id,ToroSupportPlusItem> qiWrapperMap = ToroSupportPlusHelper.buildQuoteItemWrapperMap((List<ToroSupportPlusItem>)JSON.deserializeStrict(quoteItemsJSON,List<ToroSupportPlusItem>.class));
			System.debug('\n\n@@qiWrapperMap: ' + qiWrapperMap + '\n\n');

			// ============================================================================
			// HANDLE MAIN QUOTE ITEMS
			// ============================================================================

			// first, find CHANGED quote items
			final List<ToroSupportPlusItem> changedQiWrappers = new List<ToroSupportPlusItem>();
			for (Id qiId : existingQiWrapperMap.keySet()) {
				ToroSupportPlusItem existingWrapper = existingQiWrapperMap.get(qiId);
				ToroSupportPlusItem qiWrapper = qiWrapperMap.get(qiId);
				if (existingWrapper.spQuantity != qiWrapper.spQuantity) {
					changedQiWrappers.add(qiWrapper);
					System.debug('\n\n@@changed quote item: ' + qiWrapper.productId + ' ' + existingWrapper.spQuantity + ' to ' + qiWrapper.spQuantity + '\n\n');
				}
			}
			System.debug('\n\n@@changedQiWrappers: ' + changedQiWrappers + '\n\n');

			// next, find which ones are new, and which ones need to be updated
			final List<REVVY__MnQuoteItem__c> quoteItemsToInsert = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnQuoteItem__c> quoteItemsToDelete = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnStrategy4__c> quoteItemExtensionsToUpdate = new List<REVVY__MnStrategy4__c>();

			for (ToroSupportPlusItem wrapper : changedQiWrappers) {
				final Decimal quantity = wrapper.quantity;
				final Decimal updatedSpQuantity = wrapper.spQuantity;

				// new support plus item needs to be created
				// existing quote item needs to be updated
				if (wrapper.qiSpObj == null) {
					REVVY__MnQuoteItem__c spItemToInsert = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c            = updatedSpQuantity
						, REVVY__Id__c                  = ToroSupportPlusHelper.generateExternalId()
						, Support_Plus_From_Add_New__c  = false
						, REVVY__Quote__c               = quote.Id
						, REVVY__PricelistLine__c       = wrapper.qiObj.REVVY__PricelistLine__c
						, REVVY__Catalog_Node__c        = wrapper.qiObj.REVVY__Catalog_Node__c
						, REVVY__Price__c               = 0
						, REVVY__SuggestedPrice__c      = 0
						, Description__c                = wrapper.description
						, Misc_Style__c                 = 'NoCharge'
						, Support_Plus_Original_Item__c = wrapper.sfid
					);
					quoteItemsToInsert.add(spItemToInsert);
					System.debug('\n\n@@spItemToInsert: ' + spItemToInsert + '\n\n');


					List<REVVY__MnStrategy4__c> spExtObjs = [
						SELECT
							Id
							, External_Id__c
							, Adjusted_Quantity__c
						FROM
							REVVY__MnStrategy4__c
						WHERE
							External_Id__c = :wrapper.sfid
					];

					for(REVVY__MnStrategy4__c spExtObj : spExtObjs) {
						spExtObj.Adjusted_Quantity__c = quantity - updatedSpQuantity;
					}
					quoteItemExtensionsToUpdate.addAll(spExtObjs);


					// wrapper.qiExtObj.Adjusted_Quantity__c = quantity - updatedSpQuantity;
					// quoteItemExtensionsToUpdate.add(wrapper.qiExtObj);
					System.debug('\n\n@@wrapper.qiExtObj to update: ' + wrapper.qiExtObj + '\n\n');
				}

				else {
					if (wrapper.spQuantity == 0) {
						quoteItemsToDelete.add(wrapper.qiSpObj);

						wrapper.qiExtObj.Adjusted_Quantity__c = wrapper.qiExtObj.Adjusted_Quantity__c + wrapper.qiSpExtObj.Adjusted_Quantity__c;
						quoteItemExtensionsToUpdate.add(wrapper.qiExtObj);
					}

					else {
						/*
						REVVY__MnStrategy4__c quoteItemExtensionToUpdate = new REVVY__MnStrategy4__c(
							External_ID__c = wrapper.sfid
							, Adjusted_Quantity__c = quantity - updatedSpQuantity
						);
						REVVY__MnStrategy4__c supportPlusExtensionToUpdate = new REVVY__MnStrategy4__c(
							external_Id__c = wrapper.qiSpObj.Id
							, Adjusted_Quantity__c = updatedSpQuantity
						);
						*/

						Map<String,Decimal> extIdQtyMap = new Map<String,Decimal>{
							wrapper.sfid => (quantity - updatedSpQuantity)
							, wrapper.qiSpObj.Id => updatedSpQuantity
						};

						List<REVVY__MnStrategy4__c> qiExtObjs = [
							SELECT
								Id
								, External_Id__c
								, Adjusted_Quantity__c
							FROM
								REVVY__MnStrategy4__c
							WHERE
								External_Id__c IN :extIdQtyMap.keyset()
						];

						for(REVVY__MnStrategy4__c qi : qiExtObjs) {
							qi.Adjusted_Quantity__c = extIdQtyMap.get(qi.External_Id__c);
						}
						System.debug('\n\n@@before quoteItemExtensionsToUpdate : ' + quoteItemExtensionsToUpdate + '\n\n');

						quoteItemExtensionsToUpdate.addAll(qiExtObjs);
						System.debug('\n\n@@after quoteItemExtensionsToUpdate: ' + quoteItemExtensionsToUpdate + '\n\n');
					}
				}
			}


			// ============================================================================
			// HANDLE SUBLINES
			// ============================================================================
			final List<REVVY__MnQuoteItemSubline__c> sublinesToInsert = new List<REVVY__MnQuoteItemSubline__c>();
			final List<REVVY__MnQuoteItemSubline__c> sublinesToDelete = new List<REVVY__MnQuoteItemSubline__c>();
			final List<REVVY__MnStrategy5__c> sublineExtensionsToUpdate = new List<REVVY__MnStrategy5__c>();


			for (Id quoteItemId : existingQiWrapperMap.keySet()) {
				final List<ToroSupportPlusItem> changedSublineWrappers = new List<ToroSupportPlusItem>();
				ToroSupportPlusItem existingWrapper = existingQiWrapperMap.get(quoteItemId);
				ToroSupportPlusItem qiWrapper = qiWrapperMap.get(quoteItemId);
				System.debug('\n\n@@existingWrapper.sublines: ' + existingWrapper.sublines + '\n\n');
				System.debug('\n\n@@qiWrapper.sublines: ' + qiWrapper.sublines + '\n\n');

				Map<Id,ToroSupportPlusItem> existingSublineWrapperMap = ToroSupportPlusHelper.buildSublineWrapperMap(existingWrapper.sublines);
				Map<Id,ToroSupportPlusItem> sublineWrapperMap = ToroSupportPlusHelper.buildSublineWrapperMap(qiWrapper.sublines);

				for (Id sublineId : existingSublineWrapperMap.keySet()) {
					ToroSupportPlusItem existingSublineWrapper = existingSublineWrapperMap.get(sublineId);
					ToroSupportPlusItem sublineWrapper = sublineWrapperMap.get(sublineId);
					if (existingSublineWrapper.spQuantity != sublineWrapper.spQuantity) {
						changedSublineWrappers.add(sublineWrapper);
						System.debug('\n\n@@changed subline: ' + sublineWrapper.productId + ' ' + existingSublineWrapper.spQuantity + ' to ' + sublineWrapper.spQuantity + '\n\n');
					}
				}
				System.debug('\n\n@@changedSublineWrappers: ' + changedSublineWrappers + '\n\n');

				for (ToroSupportPlusItem wrapper : changedSublineWrappers) {
					final Decimal quantity = wrapper.quantity;
					final Decimal updatedSpQuantity = wrapper.spQuantity;

					if (wrapper.sublineSpObj == null) {
						REVVY__MnQuoteItemSubline__c spSublineToInsert = new REVVY__MnQuoteItemSubline__c(
							  REVVY__Quantity__c            = updatedSpQuantity
							, REVVY__Id__c                  = null //ToroSupportPlusHelper.generateExternalId()
							, REVVY__QuoteItem__c           = wrapper.qiObj.Id
							, REVVY__PricelistLine__c       = wrapper.sublineObj.REVVY__PricelistLine__c
							, REVVY__Catalog_Node__c        = wrapper.sublineObj.REVVY__Catalog_Node__c
							, REVVY__Price__c               = 0
							, REVVY__SuggestedPrice__c      = 0
							, Description__c                = wrapper.description
							, Misc_Style__c                 = 'NoCharge'
							, Support_Plus_Original_Item__c = wrapper.sublineObj.Id
						);
						sublinesToInsert.add(spSublineToInsert);
						System.debug('\n\n@@spSublineToInsert: ' + spSublineToInsert + '\n\n');

						List<REVVY__MnStrategy5__c> spExtObjs = [
							SELECT
								Id
								, External_Id__c
								, Adjusted_Quantity__c
							FROM
								REVVY__MnStrategy5__c
							WHERE
								External_Id__c = :wrapper.sublineObj.Id
						];

						for (REVVY__MnStrategy5__c spExtObj : spExtObjs) {
							spExtObj.Adjusted_Quantity__c = quantity - updatedSpQuantity;
						}

						System.debug('\n\n@@sublines - spExtObjs: ' + spExtObjs + '\n\n');
						sublineExtensionsToUpdate.addAll(spExtObjs);
						System.debug('\n\n@@sublineExtensionsToUpdate: ' + sublineExtensionsToUpdate + '\n\n');
					}

					else {
						if (wrapper.spQuantity == 0) {
							sublinesToDelete.add(wrapper.sublineSpObj);

							wrapper.sublineExtObj.Adjusted_Quantity__c = wrapper.sublineExtObj.Adjusted_Quantity__c + wrapper.sublineSpExtObj.Adjusted_Quantity__c;
							sublineExtensionsToUpdate.add(wrapper.sublineExtObj);
						}

						else {
							Map<String,Decimal> extIdQtyMap = new Map<String,Decimal>{
								wrapper.sfid => (quantity - updatedSpQuantity)
								, wrapper.sublineSpObj.Id => updatedSpQuantity
							};

							List<REVVY__MnStrategy5__c> sublineExtObjs = [
								SELECT
									Id
									, External_Id__c
									, Adjusted_Quantity__c
								FROM
									REVVY__MnStrategy5__c
								WHERE
									External_Id__c IN :extIdQtyMap.keyset()
							];

							for (REVVY__MnStrategy5__c qi : sublineExtObjs) {
								qi.Adjusted_Quantity__c = extIdQtyMap.get(qi.External_Id__c);
							}
							System.debug('\n\n@@before sublineExtensionsToUpdate : ' + quoteItemExtensionsToUpdate + '\n\n');
							sublineExtensionsToUpdate.addAll(sublineExtObjs);
							System.debug('\n\n@@after sublineExtensionsToUpdate: ' + quoteItemExtensionsToUpdate + '\n\n');
						}
					}
				}
			}

			// ============================================================================
			// HANDLE SUPPORT PLUS ONLY ITEMS
			// ============================================================================

			final List<REVVY__MnQuoteItem__c> addNewItemsToInsert = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnQuoteItem__c> addNewItemsToUpdate = new List<REVVY__MnQuoteItem__c>();

			// EXISTING ADD NEW ITEMS
			final Map<Id,ToroSupportPlusItem> existingAddNewWrapperMap = ToroSupportPlusHelper.buildQuoteItemWrapperMap(existingSpData.addNewWrappers);
			System.debug('\n\n@@existingAddNewWrapperMap: ' + existingAddNewWrapperMap + '\n\n');

			// NEW DATA FROM SUPPORT PLUS
			List<ToroSupportPlusItem> addNewWrappers = (List<ToroSupportPlusItem>)JSON.deserializeStrict(supportPlusItemsJSON,List<ToroSupportPlusItem>.class);
			for (ToroSupportPlusItem addNewWrapper : addNewWrappers) {
				if (addNewWrapper.sfid != null) {
					// update it
					ToroSupportPlusItem existingWrapper = existingAddNewWrapperMap.get(addNewWrapper.sfid);
					if (existingWrapper.spQuantity != addNewWrapper.spQuantity) {
						List<REVVY__MnStrategy4__c> spExtObjs = [
							SELECT
								Id
								, External_Id__c
								, Adjusted_Quantity__c
							FROM
								REVVY__MnStrategy4__c
							WHERE
								External_Id__c = :addNewWrapper.sfid
						];

						for (REVVY__MnStrategy4__c spExtObj : spExtObjs) {
							spExtObj.Adjusted_Quantity__c = addNewWrapper.spQuantity;
						}
						quoteItemExtensionsToUpdate.addAll(spExtObjs);
					}
				}

				else {
					// create it
					REVVY__MnQuoteItem__c spItemToInsert = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c            = addNewWrapper.spQuantity
						, REVVY__Id__c                  = ToroSupportPlusHelper.generateExternalId()
						, Support_Plus_From_Add_New__c  = true
						, REVVY__Quote__c               = quote.Id
						, REVVY__PricelistLine__c       = addNewWrapper.pricelistLineId
						, REVVY__Catalog_Node__c        = addNewWrapper.catalogNodeId
						, REVVY__Price__c               = 0
						, REVVY__SuggestedPrice__c      = 0
						, Support_Plus_Original_Price__c = addNewWrapper.dnetPrice
						, Description__c                = addNewWrapper.description
						, Misc_Style__c                 = 'NoCharge'
						, Support_Plus_Original_Item__c = null
					);

					quoteItemsToInsert.add(spItemToInsert);
				}
			}


			// ============================================================================
			// insert new quote items
			// ============================================================================
			insert quoteItemsToInsert;
			System.debug('\n\n@@quoteItemsToInsert: ' + quoteItemsToInsert + '\n\n');
			System.debug('\n\n@@quoteItemExtensionsToUpdate: ' + quoteItemExtensionsToUpdate + '\n\n');

			// ============================================================================
			// fix Quote_Item_Extension__c for new Support Plus Quote Items
			// ============================================================================
			Map<Id,REVVY__MnQuoteItem__c> insertedQiMap = new Map<Id,REVVY__MnQuoteItem__c>(quoteItemsToInsert);
			List<REVVY__MnStrategy4__c> qiExtObjs = [
				SELECT
					Id, External_Id__c
				FROM
					REVVY__MnStrategy4__c
				WHERE
					External_Id__c IN :insertedQiMap.keySet()
			];

			Map<Id,Id> qiToExtObjIdMap = new Map<Id,Id>();
			for (REVVY__MnStrategy4__c qiExtObj : qiExtObjs) {
				qiToExtObjIdMap.put(qiExtObj.External_Id__c, qiExtObj.Id);
			}

			List<REVVY__MnQuoteItem__c> insertedQuoteItems = [
				SELECT
					Id, Quote_Item_Extension__c
				FROM
					REVVY__MnQuoteItem__c
				WHERE
					Id IN :insertedQiMap.keySet()
			];

			for (REVVY__MnQuoteItem__c insertedQi : insertedQuoteItems) {
				insertedQi.Quote_Item_Extension__c = qiToExtObjIdMap.get(insertedQi.Id);
			}

			update insertedQuoteItems;
			update quoteItemExtensionsToUpdate;
			delete quoteItemsToDelete;

			// ============================================================================
			// insert new sublines
			// ============================================================================

			System.debug('\n\n@@sublinesToInsert: ' + sublinesToInsert + '\n\n');
			insert sublinesToInsert;

			// ============================================================================
			// fix Quote_Subline_Extension__c for new Support Plus Sublines
			// ============================================================================
			Map<Id,REVVY__MnQuoteItemSubLine__c> insertedSublineMap = new Map<Id,REVVY__MnQuoteItemSubLine__c>(sublinesToInsert);
			List<REVVY__MnStrategy5__c> sublineExtObjs = [
				SELECT
					Id,
					External_Id__c
				FROM
					REVVY__MnStrategy5__c
				WHERE
					External_Id__c IN :insertedSublineMap.keySet()
			];

			Map<Id,Id> sublineToExtObjIdMap = new Map<Id,Id>();
			for (REVVY__MnStrategy5__c sublineExtObj : sublineExtObjs) {
				sublineToExtObjIdMap.put(sublineExtObj.External_Id__c, sublineExtObj.Id);
			}

			List<REVVY__MnQuoteItemSubline__c> insertedSublines = [
				SELECT
					Id, Quote_Item_Subline_Extension__c
				FROM
					REVVY__MnQuoteItemSubline__c
				WHERE
					Id IN :insertedSublineMap.keySet()
			];

			for (REVVY__MnQuoteItemSubline__c insertedSubline : insertedSublines) {
				insertedSubline.Quote_Item_Subline_Extension__c = sublineToExtObjIdMap.get(insertedSubline.Id);
			}

			System.debug('\n\n@@insertedSublines: ' + insertedSublines + '\n\n');
			System.debug('\n\n@@sublineExtensionsToUpdate: ' + sublineExtensionsToUpdate + '\n\n');
			System.debug('\n\n@@sublinesToDelete: ' + sublinesToDelete + '\n\n');
			update insertedSublines;
			update sublineExtensionsToUpdate;
			delete sublinesToDelete;

			// Database.rollback(sp);
			ToroSupportPlusHelper.saveSequenceGen();
		}


		catch (Exception e) {
			System.debug('\n\n@@exception occurred: ' + e + '\n\n');
			Database.rollback(sp);
			throw e;
		}

		return true;
	}
}