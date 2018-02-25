public with sharing class TR_GenModelBOM {
	public TR_GenModelBOM() {
		
	}
	public static void genBOM() {
		List<String> modelNames = new List<String> ();
		for(REVVY__MnConfigEngineModel__c mdl : [SELECT Name FROM REVVY__MnConfigEngineModel__c where REVVY__User_id__c = null]) {
			modelNames.add(mdl.name);
		}
		
		Map<String, REVVY__MnPriceListLine__c> prodCode2Price = new Map<String, REVVY__MnPriceListLine__c>();
		List<REVVY__MnPriceListLine__c> plis = [SELECT REVVY__Product_Id__c, REVVY__ListedPrice__c FROM REVVY__MnPriceListLine__c where revvy__pricelist__r.name = 'Commercial'];
		for(REVVY__MnPriceListLine__c pli : plis) {
			prodCode2Price.put(pli.REVVY__Product_Id__c, pli);	
		}

		List<REVVY__MnConfigEngineOption__c> options = [Select REVVY__Option_Group__r.revvy__Id__c, REVVY__Label__c, REVVY__Option_Group__c,
											 REVVY__Catalog_Node__r.revvy__Id__c, Id From REVVY__MnConfigEngineOption__c 
											 where REVVY__Option_Group__c in 
											(select REVVY__OptionGroup_Id__c from REVVY__MnConfigEngineModelOptionGroupJunction__c where 
											REVVY__Model_Id__r.name in :modelNames)];
		Map<Id, Map<Id, DNetMSRGPair>>	OGOptionMap = new Map<Id, Map<Id, DNetMSRGPair>>();							
		for(REVVY__MnConfigEngineOption__c option : options) {
			if(!OGOptionMap.containsKey(option.REVVY__Option_Group__c))	{
				OGOptionMap.put(option.REVVY__Option_Group__c, new Map<Id, DNetMSRGPair>());	
			}
			REVVY__MnPriceListLine__c pli = prodCode2Price.get(option.REVVY__Catalog_Node__r.revvy__Id__c);
			if(pli != null) {
				OGOptionMap.get(option.REVVY__Option_Group__c).put(option.Id, new DNetMSRGPair(pli.REVVY__ListedPrice__c, null));
			}
		}

		Map<Id, Map<Id, Map<Id, DNetMSRGPair>>> modelOGOptionPriceMap = new Map<Id, Map<Id, Map<Id, DNetMSRGPair>>>();
		list<REVVY__MnConfigEngineModelOptionGroupJunction__c> modelOGs = [select REVVY__Model_Id__c, REVVY__OptionGroup_Id__c from REVVY__MnConfigEngineModelOptionGroupJunction__c
																			where REVVY__Model_Id__r.name in :modelNames];
		for(REVVY__MnConfigEngineModelOptionGroupJunction__c mog : modelOGs) {
			if(!modelOGOptionPriceMap.containsKey(mog.REVVY__Model_Id__c)) {
				modelOGOptionPriceMap.put(mog.REVVY__Model_Id__c, new Map<Id, Map<Id, DNetMSRGPair>>());	
			}
			if(OGOptionMap.containsKey(mog.REVVY__OptionGroup_Id__c)) {
				modelOGOptionPriceMap.get(mog.REVVY__Model_Id__c).put(mog.REVVY__OptionGroup_Id__c, OGOptionMap.get(mog.REVVY__OptionGroup_Id__c));
			}

		}																	
		system.debug(modelOGOptionPriceMap);
		List<TR_BOM__c>  boms = new List<TR_BOM__c>();
		for(Id k1 : modelOGOptionPriceMap.keySet()) {
			Map<Id, Map<Id, DNetMSRGPair>> ogs = modelOGOptionPriceMap.get(k1);	
			for(Id k2 : ogs.keySet()) {
				Map<Id, DNetMSRGPair> ops = ogs.get(k2);	
				for(Id k3 : ops.keyset()) {
					DNetMSRGPair opPrice = ops.get(k3);
					boms.add(new TR_BOM__c(Model__c=k1, Option_Group__c=k2, Option__c=k3, dNet__c=opPrice.dNet, MSRP__c=opPrice.msrp));
				}
			}
		}
		insert boms;
	}
	class DNetMSRGPair {
		DNetMSRGPair(decimal dNet, decimal msrp)	{
			this.dNet = dNet;
			this.msrp = msrp;
		}
		decimal dNet { get; set;}
		decimal msrp {get; set;}
	}
}