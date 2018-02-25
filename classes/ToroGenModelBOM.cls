public with sharing class ToroGenModelBOM {
	public ToroGenModelBOM() {
		
	}
	
	public static GenModelBOMResult genBOM() {
		List<String> modelNames = new List<String> ();
		Set<String> modelNameSet = new Set<String> ();
		map<String, Id> modelNameIdMap = new map<String, Id>();
		for(REVVY__MnConfigEngineModel__c mdl : [SELECT Name, REVVY__VerNum__c FROM REVVY__MnConfigEngineModel__c where REVVY__User_id__c = null and REVVY__Status__c = 'In Production' order by REVVY__VerNum__c asc ]) {
			if(!mdl.name.endsWith('(INTL)')) {
				modelNameIdMap.put(mdl.name, mdl.Id);
				//modelNameSet.add(mdl.name);
			}
		}
		Map<String, REVVY__MnPriceListLine__c> prodCode2Price = new Map<String, REVVY__MnPriceListLine__c>();
		List<REVVY__MnPriceListLine__c> plis = [SELECT REVVY__Product_Id__c, REVVY__ListedPrice__c, REVVY__SuggestedPrice__c FROM REVVY__MnPriceListLine__c where revvy__pricelist__r.name = 'Commercial'];
		for(REVVY__MnPriceListLine__c pli : plis) {
			prodCode2Price.put(pli.REVVY__Product_Id__c, pli);	
		}

		List<REVVY__MnConfigEngineOption__c> options = [Select REVVY__Option_Group__r.revvy__Id__c, REVVY__Option_Group__r.Name, REVVY__Label__c, REVVY__Option_Group__c,
											 REVVY__Catalog_Node__r.revvy__Id__c, REVVY__Catalog_Node__r.name, Id, name From REVVY__MnConfigEngineOption__c 
											 where REVVY__Option_Group__c in 
											(select REVVY__OptionGroup_Id__c from REVVY__MnConfigEngineModelOptionGroupJunction__c where 
											REVVY__Model_Id__c in :modelNameIdMap.values()) and REVVY__Excluded__c = false];
		Map<Id, Map<Id, DNetMSRGPair>>	OGOptionMap = new Map<Id, Map<Id, DNetMSRGPair>>();							
		for(REVVY__MnConfigEngineOption__c option : options) {
			if(!OGOptionMap.containsKey(option.REVVY__Option_Group__c))	{
				OGOptionMap.put(option.REVVY__Option_Group__c, new Map<Id, DNetMSRGPair>());	
			}
			REVVY__MnPriceListLine__c pli = prodCode2Price.get(option.REVVY__Catalog_Node__r.revvy__Id__c);
			decimal dNetPrice = null;
			if(pli != null) {
				if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
					dNetPrice = pli.REVVY__SuggestedPrice__c;	
				}
				OGOptionMap.get(option.REVVY__Option_Group__c).put(option.Id, new DNetMSRGPair(option.name, option.REVVY__Catalog_Node__r.revvy__Id__c, pli.REVVY__ListedPrice__c, dNetPrice));
			}
		}

		Map<String, Model> models = new Map<String, Model>();

		Map<Id, Map<Id, Map<Id, DNetMSRGPair>>> modelOGOptionPriceMap = new Map<Id, Map<Id, Map<Id, DNetMSRGPair>>>();
		list<REVVY__MnConfigEngineModelOptionGroupJunction__c> modelOGs = [select REVVY__Model_Id__c, REVVY__Model_Id__r.Name, REVVY__OptionGroup_Id__c, REVVY__OptionGroup_Id__r.Name from REVVY__MnConfigEngineModelOptionGroupJunction__c
																			where REVVY__Model_Id__c in :modelNameIdMap.values()];
		for(REVVY__MnConfigEngineModelOptionGroupJunction__c mog : modelOGs) {
			if(!modelOGOptionPriceMap.containsKey(mog.REVVY__Model_Id__c)) {
				modelOGOptionPriceMap.put(mog.REVVY__Model_Id__c, new Map<Id, Map<Id, DNetMSRGPair>>());
				models.put(mog.REVVY__Model_Id__r.name, new Model(mog.REVVY__Model_Id__r.name));	
			}
			
			if(OGOptionMap.containsKey(mog.REVVY__OptionGroup_Id__c)) {
				modelOGOptionPriceMap.get(mog.REVVY__Model_Id__c).put(mog.REVVY__OptionGroup_Id__c, OGOptionMap.get(mog.REVVY__OptionGroup_Id__c));
				Map<Id, DNetMSRGPair> optionGroups  = OGOptionMap.get(mog.REVVY__OptionGroup_Id__c);
				if(OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values() != null && OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values().size() != 0) {
					models.get(mog.REVVY__Model_Id__r.name).optionGroups.add(new OptionGroup(mog.REVVY__OptionGroup_Id__r.Name, OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values()));
				}
			}

		}	
		for(Model m : models.values()) {
			m.optionGroups.sort();
		}
		GenModelBOMResult result = new GenModelBOMResult();
		result.BOMs = models.values();
		return result;
	}
	
	public class OptionGroup implements Comparable {
		public string optionGroupName { get; set;}
		public List<DNetMSRGPair> options { get; set; }
		OptionGroup(string ogName, List<DNetMSRGPair> options) {
			this.optionGroupName = ogName;
			this.options = options;
		}
		public Integer compareTo(Object compareTo) {
	        OptionGroup compareToEmp = (OptionGroup)compareTo;
	        if (compareToEmp.optionGroupName.containsIgnoreCase('Traction Units')) {
	        	 return 1; 
	        } else {
	        	return 0;
	        }     
	    }
	}
	public class Model {
		public string modelName { get; set; }
		public List<OptionGroup> optionGroups { get; set; } 
		Model(string name) {
			optionGroups = new List<OptionGroup>();
			modelName = name;
		}
	}
    
    public class GenModelBOMResult {
    	public List<Model> BOMs { get; set; }
    	public List<ProductModelView>  prodModels { get; set; } 
    }

    public class ProductModelView {
    	public String modelName { get; set;}
    	public String productTab { get; set;}
    	public String description { get; set; }
    	public decimal msrp { get; set; }
    	public decimal dnet { get; set; }
    	public integer stockOrder { get; set; }
    	public decimal totalValue { get; set; }
    	public ProductModelView() {
    		modelName=null;
    		productTab=null;
    		description=null;
    		msrp=0.0;
    		dnet=0.0;
    		stockOrder=0;
    		totalValue=0.0;	
    	}
    	public ProductModelView(String modelName, String productTab, String description, decimal msrp, decimal dnet, integer stockOrder, decimal totalValue) {
    		this.modelName=modelName;
    		this.productTab=productTab;
    		this.description=description;
    		this.msrp=msrp;
    		this.dnet=dnet;
    		this.stockOrder=stockOrder;
    		this.totalValue=totalValue;	
    	}

    }
    public static list<list<ToroGenModelBOM.StockOrder>> getStockOrder() {
    	map<String, Id> modelNameIdMap = new map<String, Id>();
		for(REVVY__MnConfigEngineModel__c mdl : [SELECT Name, REVVY__Product_IDs__c, REVVY__VerNum__c FROM REVVY__MnConfigEngineModel__c where REVVY__User_id__c = null and REVVY__Status__c = 'In Production' order by REVVY__VerNum__c asc ]) {
			if(!mdl.name.endsWith('(INTL)') && !mdl.name.contains('test')) {
				modelNameIdMap.put(mdl.name, mdl.Id);
				//modelNameSet.add(mdl.name);
			}
		}
		
		Map<String, List<String>> prodModelMap = new Map<String, List<String>>();
		for(REVVY__MnConfigEngineModel__c model : [Select Id, name, REVVY__Product_IDs__c from REVVY__MnConfigEngineModel__c where id in :modelNameIdMap.values()]) {
			if(String.isNotBlank(model.REVVY__Product_IDs__c)) {
				system.debug(model.REVVY__Product_IDs__c);
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.removeStart('[');
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.removeEnd(']');
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.remove('"');
				List<String> pIds = model.REVVY__Product_IDs__c.split(',');
				for(String s : pIds) {
					if(!prodModelMap.containsKey(s)) {
						prodModelMap.put(s, new List<String>());	
					}
					prodModelMap.get(s).add(model.name);
				}
			}	
		}
		
		system.debug('size='+ prodModelMap.size());
		for(String key : prodModelMap.keySet()) {
			system.debug(key + ' -- ' + String.join(prodModelMap.get(key), ','));	
		}
		
    	list<list<ToroGenModelBOM.StockOrder>> stockOrderLists = new list<list<ToroGenModelBOM.StockOrder>>();
		
		List<REVVY__MnPriceListLine__c> plis = [SELECT REVVY__Product_Id__c,  REVVY__Product_Name__c, REVVY__ListedPrice__c, REVVY__SuggestedPrice__c FROM REVVY__MnPriceListLine__c where revvy__pricelist__r.name = 'Commercial'];
		
		Integer count=0;
		//Integer remainder = math.mod(12, 2);
		
		list<ToroGenModelBOM.StockOrder> solist = new list<ToroGenModelBOM.StockOrder>();
		for(REVVY__MnPriceListLine__c pli : plis) {
			if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
					pli.REVVY__SuggestedPrice__c=null;	
			}
			
			system.debug('SKU =' + pli.REVVY__Product_Id__c);
			if(!prodModelMap.containsKey(pli.REVVY__Product_Id__c)) {
				system.debug('--------no models found----');
				solist.add(new ToroGenModelBOM.StockOrder(pli.REVVY__Product_Id__c, '',
					pli.REVVY__Product_Name__c.escapeXml(), pli.REVVY__SuggestedPrice__c, pli.REVVY__ListedPrice__c, 0, 0));	
			} else {
				for(string key : prodModelMap.get(pli.REVVY__Product_Id__c))	{
					solist.add(new ToroGenModelBOM.StockOrder(pli.REVVY__Product_Id__c, key,
						pli.REVVY__Product_Name__c.escapeXml(), pli.REVVY__SuggestedPrice__c, pli.REVVY__ListedPrice__c, 0, 0));	
				}	
			}	
		}
		solist.sort();
		list<ToroGenModelBOM.StockOrder> sol = null;
		for(ToroGenModelBOM.StockOrder pli : solist) {
			Integer remainder = math.mod(count, 900);
			
			if(remainder==0) {
				system.debug('remainder===11---' + remainder);
				sol = new list<ToroGenModelBOM.StockOrder>();
				stockOrderLists.add(sol);	
			}
			sol.add(pli);
			count++;
		}
		system.debug('------'+ stockOrderLists.size());	
		return stockOrderLists;
	}
    public class StockOrder implements Comparable {
     	public StockOrder(String modelNumber, String productTab, String description, decimal distributorNet, 
     		decimal suggestedRetail, double stockOrder, decimal totalDollors) {
     		this.modelNumber = modelNumber;
     		this.productTab = productTab;
     		this.description = description;
     		this.distributorNet = distributorNet;
     		this.suggestedRetail = suggestedRetail;
     		this.stockOrder = stockOrder;
     		this.totalDollors = totalDollors;	
     	}
    	public String modelNumber { get; set; }
    	public String productTab { get; set; } 
    	public String description { get; set; } 
    	public decimal distributorNet { get; set; } 
    	public decimal suggestedRetail { get; set; } 
    	public double stockOrder { get; set; }
    	public decimal totalDollors { get; set; }
    	public Integer compareTo(Object compareTo) {
	        StockOrder compareToEmp = (StockOrder)compareTo;
	        return compareToEmp.productTab.compareTo(productTab);
	    }
    }
   
	 
	public class DNetMSRGPair {
		DNetMSRGPair(String n, String sku, decimal msrp, decimal dNet)	{
			this.dNet = dNet;
			this.msrp = msrp;
			this.optionName = n;
			this.sku = sku;
		}
		public decimal dNet { get; set;}
		public decimal msrp {get; set;}
		public String optionName { get; set; }
		public String sku { get; set; }
	}
}