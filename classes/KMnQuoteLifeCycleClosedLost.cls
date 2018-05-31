/**
 * KMnQuoteLifeCycleClosedList
 *
 * Lifecycle action plugin for Closed Lost
 *
 */
global class KMnQuoteLifeCycleClosedLost extends Revvy.CMnLifeCycleActionScript {
	public static final String KEY_OBJECT_ID = 'objectId';

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	global override Map<String,String> doAction(Map<String,String> values) {
		final Id quoteId = values.get(KEY_OBJECT_ID);

		return backToQuote(quoteId);
	}

	/**
	 *
	 * description
	 *
	 * @param  name    description
	 * @return return_type
	 */
	@TestVisible
	private Map<String,String> backToQuote(Id quoteId) {
		return new Map<String,String> {
			'PageReference' => '/' + quoteId
		};
	}
}