global class ToroNTController {
	public Id quoteId { get; private set; }

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	public ToroNTController() {
		quoteId = ApexPages.currentPage().getParameters().get('Id');
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static ToroNTData retrieveNTData(Id quoteId) {
		return new ToroNTData(quoteId);
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@AuraEnabled
	public static ToroQIBase addNonToroItem(Id quoteId, String productId, Decimal msrpPrice, Decimal dnetPrice, Decimal awardPrice, Decimal quantity, String description) {
		List<REVVY__MnPriceListLine__c> pricelistLines = [
			SELECT
				Id
				, REVVY__Product__r.REVVY__Id__c
				, REVVY__Product__r.Name
				, REVVY__Product__r.Non_Toro_Product__c
				, REVVY__SuggestedPrice__c
			FROM
				REVVY__MnPriceListLine__c
			WHERE
				// REVVY__Product__r.REVVY__Type__c IN ('Product', 'Bundle')
				REVVY__Product__r.REVVY__Effective_Start_Date__c <= TODAY
				AND REVVY__Product__r.REVVY__Effective_End_Date__c >= TODAY
				AND REVVY__Product__r.REVVY__Status__c = 'Active'
				AND REVVY__PriceList__r.Name = 'Commercial'
				AND REVVY__Product__r.REVVY__Id__c = :productId
				AND REVVY__Product__r.Non_Toro_Product__c = true
			ORDER BY
				REVVY__Product__r.Name asc
		];

		if (pricelistLines.isEmpty()) return null;

		ToroQIBase result = new ToroQIBase(
			pricelistLines[0].REVVY__Product__r
			, pricelistLines[0]
			, msrpPrice
			, awardPrice
			, quantity
			, description
		);
        result.dnetPrice = dnetPrice;

		System.debug('\n\n@@result: ' + result + '\n\n');
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
	public static Boolean saveChanges(REVVY__MnQuote__c quote, String quoteItemsJSON) {
		System.debug('\n\n@@ToroNTController:saveChanges\n\n -' + quote);
		Savepoint sp = Database.setSavepoint();
		try {
			final ToroNTData existingData = new ToroNTData(quote.Id);
			final Map<Id,ToroQIBase> eqiwMap = new Map<Id,ToroQIBase>();
			for (ToroQIBase eqiw : existingData.qiWrappers) {
				eqiwMap.put(eqiw.sfid, eqiw);
			}

			List<ToroQIBase> qiws = (List<ToroQIBase>) JSON.deserializeStrict(quoteItemsJSON, List<ToroQIBase>.class);
			System.debug('\n\n@@qiWrappers: ' + qiws + '\n\n');

			// figure out which are new and which ones need to be updated
			final List<REVVY__MnQuoteItem__c> quoteItemsToInsert = new List<REVVY__MnQuoteItem__c>();
			final List<REVVY__MnQuoteItem__c> quoteITemsToUpdate = new List<REVVY__MnQuoteItem__c>();

			for (ToroQIBase qiw : qiws) {
				if (qiw.sfid != null) {
					// update it
					ToroQIBase existingQIW = eqiwMap.get(qiw.sfid);
					// TODO: update quantity and add to quoteItemsToInsert
					REVVY__MnQuoteItem__c qiToUpdate = new REVVY__MnQuoteItem__c(
						Id = qiw.sfid
						, REVVY__Quantity__c = qiw.quantity
						, Award_Price__c = qiw.awardPrice
						, Description__c = qiw.description
						, REVVY__SuggestedPrice__c  = qiw.dnetPrice
					);

					quoteITemsToUpdate.add(qiToUpdate);
				}

				else {
					// create it
					REVVY__MnQuoteItem__c qiToInsert = new REVVY__MnQuoteItem__c(
						  REVVY__Quantity__c        = qiw.quantity
						, REVVY__Id__c              = ToroSupportPlusHelper.generateQiExtId()
						, REVVY__Quote__c           = quote.Id
						, REVVY__PricelistLine__c   = qiw.pricelistLineId
						, REVVY__Catalog_Node__c    = qiw.catalogNodeId
						, REVVY__Price__c           = qiw.msrpPrice
						, Award_Price__c            = qiw.awardPrice
						, Description__c            = qiw.description
						, REVVY__SuggestedPrice__c  = qiw.dnetPrice // DNet not applicable here
					);

					quoteItemsToInsert.add(qiToInsert);
				}
			}

			insert quoteItemsToInsert;
			System.debug('\n\n@@quoteItemsToInsert: ' + quoteItemsToInsert + '\n\n');

			// ============================================================================
			// fix Quote_Item_Extension__c for new Support Plus Quote Items
			// ============================================================================
			Map<Id,REVVY__MnQuoteItem__c> insertedQiMap = new Map<Id,REVVY__MnQuoteItem__c>(quoteItemsToInsert);
			List<REVVY__MnStrategy4__c> qiExtObjs = [
				SELECT
					Id, External_Id__c, Description__c, Exc_Rbt__c
				FROM
					REVVY__MnStrategy4__c
				WHERE
					External_Id__c IN :insertedQiMap.keySet()
			];
			System.debug('\n\n@@qiExtObjs: ' + qiExtObjs + '\n\n');

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

			quoteItemsToUpdate.addAll(insertedQuoteItems);
			update quoteItemsToUpdate;

			for (REVVY__MnStrategy4__c qiExtObj : qiExtObjs) {
				qiExtObj.Exc_Rbt__c = true;
			}

			update qiExtObjs;
			
			ToroSupportPlusHelper.saveSequenceGen();
		}

		catch (Exception e) {
			System.debug('\n\n@@Exception Occurred: ' + e + '\n\n');
			Database.rollback(sp);
			throw e;
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
}