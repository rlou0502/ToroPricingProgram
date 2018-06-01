public with sharing class ToroGenModelBOM {
	static Set<String> tractionUnits = new Set<String>();
	static map<String, Id> modelNameIdMap = new map<String, Id>();
	static Map<String, String> modelHierarchyCode = new Map<String, String>();
	public ToroGenModelBOM() {
		
	}
	static {
		List<REVVY__MnCatalogNode__c> configurableProducts = [Select REVVY__Model__c,  name, REVVY__Id__c From REVVY__MnCatalogNode__c  where REVVY__Model__c != null];
		for(REVVY__MnCatalogNode__c p : configurableProducts) {
			tractionUnits.add(p.REVVY__Id__c);	
		}	
		for(REVVY__MnConfigEngineModel__c mdl : [SELECT Name, REVVY__VerNum__c, (Select Name, Hierarchy_Code__c, Toro_Product_Type__c From REVVY__Products__r) 
				FROM REVVY__MnConfigEngineModel__c where REVVY__User_id__c = null and REVVY__Status__c = 'In Production' and REVVY__IsSolution__c <> true order by REVVY__VerNum__c asc ]) {
			if(!mdl.name.endsWith('(INTL)') && !mdl.name.containsIgnoreCase('test')) {
				modelNameIdMap.put(mdl.name, mdl.Id);
				//modelNameSet.add(mdl.name);
				
			}			
		}
		for(REVVY__MnConfigEngineModel__c mdl : [Select Id, name, REVVY__Product_IDs__c, (Select Name, Hierarchy_Code__c, Toro_Product_Type__c, 
													REVVY__Id__c From REVVY__Products__r) from REVVY__MnConfigEngineModel__c 
													where id in :modelNameIdMap.values()]) {
			if(mdl.REVVY__Products__r != null && mdl.REVVY__Products__r.size() > 0) {
				modelHierarchyCode.put(mdl.name, mdl.REVVY__Products__r[0].Hierarchy_Code__c);	
			}
		}
	}
	public static GenModelBOMResult genBOM() {
		List<String> modelNames = new List<String> ();
		Set<String> modelNameSet = new Set<String> ();
		
		list<Id> modelIds = modelNameIdMap.values();
		system.debug('modelIds---' + modelIds);
		map<String, double> modelOGOrder = new map<String, double>();
		for(REVVY__MnConfigEngineOGUISectionJunction__c junction : [SELECT REVVY__Option_Group_Id__c, 
							REVVY__Config_Engine_UI_Section__r.REVVY__Config_Engine_UI_Layout__r.revvy__Model__c, 
							REVVY__Option_Group_Id__r.revvy__Id__c, REVVY__Config_Engine_UI_Section__r.REVVY__Config_Engine_UI_Layout__r.revvy__Model__r.name ,
							REVVY__OG_Section_Order__c FROM REVVY__MnConfigEngineOGUISectionJunction__c 
							where REVVY__Config_Engine_UI_Section__r.REVVY__Config_Engine_UI_Layout__r.revvy__Model__c in :modelIds
							order by  REVVY__Config_Engine_UI_Section__r.REVVY__Config_Engine_UI_Layout__r.revvy__Model__c, 
							REVVY__Option_Group_Id__c, REVVY__OG_Section_Order__c]) {
			modelOGOrder.put(junction.REVVY__Config_Engine_UI_Section__r.REVVY__Config_Engine_UI_Layout__r.revvy__Model__c+'_' + junction.REVVY__Option_Group_Id__c,
				junction.REVVY__OG_Section_Order__c);	
		}
		
		system.debug('modelOGOrder---' + modelOGOrder);
		Map<String, REVVY__MnPriceListLine__c> prodCode2Price = new Map<String, REVVY__MnPriceListLine__c>();
		List<REVVY__MnPriceListLine__c> plis = [SELECT REVVY__Product_Id__c, REVVY__ListedPrice__c, REVVY__SuggestedPrice__c FROM REVVY__MnPriceListLine__c where revvy__pricelist__r.name = 'Commercial'];
		for(REVVY__MnPriceListLine__c pli : plis) {
			prodCode2Price.put(pli.REVVY__Product_Id__c, pli);	
		}

		List<REVVY__MnConfigEngineOption__c> options = [Select REVVY__Option_Group__r.revvy__Id__c, REVVY__OptId__c, REVVY__Option_Group__r.Name, REVVY__Option_Group__r.Full_OG_Name__c,REVVY__Label__c, REVVY__Option_Group__c,
											 REVVY__Catalog_Node__r.revvy__Id__c, REVVY__Catalog_Node__r.name, REVVY__Catalog_Node__r.Toro_Product_Type__c, REVVY__Catalog_Node__r.Hierarchy_Code__c, Id, name From REVVY__MnConfigEngineOption__c 
											 where REVVY__Option_Group__c in 
											(select REVVY__OptionGroup_Id__c from REVVY__MnConfigEngineModelOptionGroupJunction__c where 
											REVVY__Model_Id__c in :modelNameIdMap.values()) and REVVY__Excluded__c = false ];
		Map<Id, Map<Id, DNetMSRGPair>>	OGOptionMap = new Map<Id, Map<Id, DNetMSRGPair>>();							
		for(REVVY__MnConfigEngineOption__c option : options) {
			if(!OGOptionMap.containsKey(option.REVVY__Option_Group__c))	{
				OGOptionMap.put(option.REVVY__Option_Group__c, new Map<Id, DNetMSRGPair>());	
			}
			REVVY__MnPriceListLine__c pli = prodCode2Price.get(option.REVVY__Catalog_Node__r.revvy__Id__c);
			if(pli == null) {
				pli = prodCode2Price.get(option.REVVY__OptId__c);	
			}
			decimal dNetPrice = null;
			if(pli != null && (!option.REVVY__OptId__c.startsWith('TPP') || !option.REVVY__Catalog_Node__r.revvy__Id__c.startsWith('TPP'))) {
				if (Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
					dNetPrice = pli.REVVY__SuggestedPrice__c;	
				}
				if(option.REVVY__Catalog_Node__r != null) {
					OGOptionMap.get(option.REVVY__Option_Group__c).put(option.Id, new DNetMSRGPair(option.name, option.REVVY__Catalog_Node__r.revvy__Id__c, option.REVVY__Catalog_Node__r.Toro_Product_Type__c, option.REVVY__Catalog_Node__r.Hierarchy_Code__c, pli.REVVY__ListedPrice__c, dNetPrice));
				} else {
					OGOptionMap.get(option.REVVY__Option_Group__c).put(option.Id, new DNetMSRGPair(option.name, option.REVVY__OptId__c, null, null, pli.REVVY__ListedPrice__c, dNetPrice));
				}
			}
		}

		Map<Id, String> optiongroupNameMap = new Map<Id, String>();
		for(REVVY__MnConfigEngineOGUISectionJunction__c OGUI : [SELECT Name, REVVY__Option_Group_Id__c FROM REVVY__MnConfigEngineOGUISectionJunction__c]) {
			optiongroupNameMap.put(OGUI.REVVY__Option_Group_Id__c, OGUI.Name);	
		}
		Map<String, Model> models = new Map<String, Model>();

		Map<Id, Map<Id, Map<Id, DNetMSRGPair>>> modelOGOptionPriceMap = new Map<Id, Map<Id, Map<Id, DNetMSRGPair>>>();
		list<REVVY__MnConfigEngineModelOptionGroupJunction__c> modelOGs = [select REVVY__Model_Id__c, REVVY__Model_Id__r.Name, REVVY__OptionGroup_Id__c, REVVY__OptionGroup_Id__r.Name, REVVY__OptionGroup_Id__r.Full_OG_Name__c from REVVY__MnConfigEngineModelOptionGroupJunction__c
																			where REVVY__Model_Id__c in :modelNameIdMap.values()];
		for(REVVY__MnConfigEngineModelOptionGroupJunction__c mog : modelOGs) {
			if(!modelOGOptionPriceMap.containsKey(mog.REVVY__Model_Id__c)) {
				modelOGOptionPriceMap.put(mog.REVVY__Model_Id__c, new Map<Id, Map<Id, DNetMSRGPair>>());
				models.put(mog.REVVY__Model_Id__r.name, new Model(mog.REVVY__Model_Id__r.name, modelHierarchyCode.get(mog.REVVY__Model_Id__r.name)));	
			}
			
			if(OGOptionMap.containsKey(mog.REVVY__OptionGroup_Id__c)) {
				modelOGOptionPriceMap.get(mog.REVVY__Model_Id__c).put(mog.REVVY__OptionGroup_Id__c, OGOptionMap.get(mog.REVVY__OptionGroup_Id__c));
				Map<Id, DNetMSRGPair> optionGroups  = OGOptionMap.get(mog.REVVY__OptionGroup_Id__c);
				if(OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values() != null && OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values().size() != 0) {
					//system.debug('----------------' + mog.REVVY__Model_Id__c+'_'+mog.REVVY__OptionGroup_Id__c);
					double seq = modelOGOrder.get(mog.REVVY__Model_Id__c+'_'+mog.REVVY__OptionGroup_Id__c) != null ? modelOGOrder.get(mog.REVVY__Model_Id__c+'_'+mog.REVVY__OptionGroup_Id__c) : 0;
					models.get(mog.REVVY__Model_Id__r.name).optionGroups.add(new OptionGroup(string.isNotBlank(optiongroupNameMap.get(mog.REVVY__OptionGroup_Id__c)) ? optiongroupNameMap.get(mog.REVVY__OptionGroup_Id__c) : mog.REVVY__OptionGroup_Id__r.Name  , 
																		seq,
																		OGOptionMap.get(mog.REVVY__OptionGroup_Id__c).values(), tractionUnits));
				}
			}

		}	
		for(Model m : models.values()) {
			m.optionGroups.sort();
		}
		GenModelBOMResult result = new GenModelBOMResult();
		result.BOMs = models.values();
		result.BOMs.sort();
		return result;
	}
	
	public class OptionGroup implements Comparable {
		public string optionGroupName { get; set;}
		public List<DNetMSRGPair> options { get; set; }
		public boolean hasTractionUnit {get; set; }
		public double sequence {get; set;}
		public Set<String> tractionUnits { get;set; }
		OptionGroup(string ogName, double sequence, List<DNetMSRGPair> options, Set<String> tractionUnits) {
			this.optionGroupName = ogName;
			this.options = options;
			this.sequence = sequence;
			this.tractionUnits = tractionUnits;
			hasTractionUnit=false;
			for(DNetMSRGPair p : options) {
				if(this.tractionUnits.contains(p.sku))	 {
					
					hasTractionUnit = true;	 
					break;
				}
			}
		}
		OptionGroup(string ogName, List<DNetMSRGPair> options, Set<String> tractionUnits) {
			this.optionGroupName = ogName;
			this.options = options;
			hasTractionUnit=false;
			this.tractionUnits = tractionUnits;
			for(DNetMSRGPair p : options) {
				if(this.tractionUnits.contains(p.sku))	 {
					
					hasTractionUnit = true;	 
					break;
				}
			}
		}
		public Integer compareTo(Object compareTo) {
	        OptionGroup compareToEmp = (OptionGroup)compareTo;
	        if (compareToEmp.hasTractionUnit && this.hasTractionUnit ) {
	        	return(Integer) (compareToEmp.sequence -sequence); 
	        } else if (compareToEmp.hasTractionUnit) {
	        	return 1;
	        } else {
	        	return -1;
	        }     
	    }
	}
	public class Model implements Comparable {
		public string modelName { get; set; }
		public List<OptionGroup> optionGroups { get; set; } 
		public String modelSortCode { get; set;}
		Model(string name, String modelSortCode) {
			optionGroups = new List<OptionGroup>();
			modelName = name;
			this.modelSortCode = modelSortCode;
     		if(this.modelSortCode == null) {
     			this.modelSortCode='';
     		}
		}
		
		public Integer compareTo(Object compareTo) {
	        Model compareToEmp = (Model)compareTo;
	        if ((string.isBlank(modelSortCode) && string.isBlank(compareToEmp.modelSortCode)) || (modelSortCode.compareTo(compareToEmp.modelSortCode) == 0)) {
	        	return modelName.compareTo(compareToEmp.modelName);
	        } else if(string.isBlank(modelSortCode) || string.isBlank(compareToEmp.modelSortCode)) {
	        	return -1;		
	        } else {
	        	return modelSortCode.compareTo(compareToEmp.modelSortCode);
	        }
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
    	
		Map<String, Set<String>> prodModelMap = new Map<String, Set<String>>();
		for(REVVY__MnConfigEngineModel__c model : [Select Id, name, REVVY__Product_IDs__c, (Select Name, Hierarchy_Code__c, Toro_Product_Type__c, REVVY__Id__c From REVVY__Products__r) from REVVY__MnConfigEngineModel__c where id in :modelNameIdMap.values()]) {
			if(String.isNotBlank(model.REVVY__Product_IDs__c)) {
				system.debug(model.REVVY__Product_IDs__c);
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.removeStart('[');
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.removeEnd(']');
				model.REVVY__Product_IDs__c=model.REVVY__Product_IDs__c.remove('"');
				List<String> pIds = model.REVVY__Product_IDs__c.split(',');
				for(String s : pIds) {
					if(!prodModelMap.containsKey(s)) {
						prodModelMap.put(s, new Set<String>());	
					}
					prodModelMap.get(s).add(model.name);
				}
			}	
			if(model.REVVY__Products__r != null && model.REVVY__Products__r.size() > 0) {
				for(REVVY__MnCatalogNode__c p : model.REVVY__Products__r) {
					if(!prodModelMap.containsKey(p.REVVY__Id__c)) {
						prodModelMap.put(p.REVVY__Id__c, new Set<String>());	
					}
					prodModelMap.get(p.REVVY__Id__c).add(model.name);	
				}
			}
		}
		
		//system.debug('size='+ prodModelMap.size());
		//for(String key : prodModelMap.keySet()) {
		//	system.debug(key + ' -- ' + String.join(prodModelMap.get(key), ','));	
		//}
		
    	list<list<ToroGenModelBOM.StockOrder>> stockOrderLists = new list<list<ToroGenModelBOM.StockOrder>>();
		
		List<REVVY__MnPriceListLine__c> plis = [SELECT REVVY__Product_Id__c,  REVVY__Product_Name__c, REVVY__Product__r.Hierarchy_Code__c, 
				REVVY__Product__r.Toro_Product_Type__c, REVVY__ListedPrice__c, REVVY__SuggestedPrice__c FROM REVVY__MnPriceListLine__c 
				where revvy__pricelist__r.name = 'Commercial' and REVVY__Product__r.Exclude_from_CPL__c = false 
					and REVVY__Product__r.Toro_Product_Type__c in ('Finished Good') 
					and (REVVY__Start_Date__c < Today AND REVVY__End_Date__c > Today) and  (NOT REVVY__Product__r.REVVY__Id__c like 'L%')  ];
		
		Integer count=0;
		//Integer remainder = math.mod(12, 2);
		
		list<ToroGenModelBOM.StockOrder> solist = new list<ToroGenModelBOM.StockOrder>();
		for(REVVY__MnPriceListLine__c pli : plis) {
			if (!Schema.sObjectType.REVVY__MnPriceListLine__c.fields.REVVY__SuggestedPrice__c.isAccessible()) {
					pli.REVVY__SuggestedPrice__c=null;	
			}
			
			system.debug('SKU =' + pli.REVVY__Product_Id__c + ' dnet =' + pli.REVVY__SuggestedPrice__c);
			if(!prodModelMap.containsKey(pli.REVVY__Product_Id__c)) {
				system.debug('--------no models found----');
				solist.add(new ToroGenModelBOM.StockOrder(pli.REVVY__Product_Id__c, '',
					pli.REVVY__Product_Name__c.escapeXml(), pli.REVVY__SuggestedPrice__c, pli.REVVY__ListedPrice__c, 0, 0, null,null,null,false));	
			} else {
				for(string key : prodModelMap.get(pli.REVVY__Product_Id__c))	{
					solist.add(new ToroGenModelBOM.StockOrder(pli.REVVY__Product_Id__c, key,
						pli.REVVY__Product_Name__c.escapeXml(), pli.REVVY__SuggestedPrice__c, pli.REVVY__ListedPrice__c, 0, 0,
						modelHierarchyCode.get(key), pli.REVVY__Product__r.Hierarchy_Code__c, pli.REVVY__Product__r.Toro_Product_Type__c, tractionUnits.contains(pli.REVVY__Product_Id__c)));	
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
    	private Map<String, Integer> productTypeSortCodeMap = new Map<String, Integer>{'Finished Good'=>3, 'Semi-Finished Good'=>2, 'Non-Stock Material'=>1};
     	public StockOrder(String modelNumber, String productTab, String description, decimal distributorNet, 
     		decimal suggestedRetail, double stockOrder, decimal totalDollors, String modelSortCode, String productSortCode, String productType, boolean isTractionUnit) {
     		this.modelNumber =modelNumber;
     		//this.productTab =  modelSortCode + '-'+productTab;
     		//this.description = productSortCode + '-'+productType + '-' +description;
     		this.productTab =  productTab;
     		this.description = description;
     		this.distributorNet = distributorNet;
     		this.suggestedRetail = suggestedRetail;
     		this.stockOrder = stockOrder;
     		this.totalDollors = totalDollors;
     		this.modelSortCode = modelSortCode;
     		this.isTractionUnit = isTractionUnit;
     		if(this.modelSortCode == null) {
     			this.modelSortCode='';
     		}
     		this.productSortCode = productSortCode;
     		if(this.productSortCode == null) {
     			this.productSortCode='';
     		}
     		if(String.isNotBlank(productType) && productTypeSortCodeMap.containsKey(productType)) {
     			 productTypeSortCode = productTypeSortCodeMap.get(productType);
     		} else {
     			this.productTypeSortCode = 0;
     		}	
     		//if(this.isTractionUnit) {
     		//	this.modelNumber += 'traction ';	
     		//}
     	}
     	
    	public String modelNumber { get; set; }
    	public String productTab { get; set; } 
    	public String description { get; set; } 
    	public decimal distributorNet { get; set; } 
    	public decimal suggestedRetail { get; set; } 
    	public double stockOrder { get; set; }
    	public decimal totalDollors { get; set; }
    	public String modelSortCode {get; set;}
    	public String productSortCode {get; set;}
    	public boolean isTractionUnit {get; set;}
    	private Integer productTypeSortCode;
    	public Integer compareTo(Object compareTo) {
	        StockOrder compareToEmp = (StockOrder)compareTo;
	        if(string.isBlank(modelSortCode + productTab)) {
	        	if (string.isBlank(compareToEmp.modelSortCode + compareToEmp.productTab)) { 
	                return 0;
	            } else {  
	                return 1;
	            }	
	        } else {
	        	if(string.isBlank(compareToEmp.modelSortCode + compareToEmp.productTab)) {
	        		return -1;	
	        	}
		        if (string.isBlank(modelSortCode)) {
		            if (string.isBlank(compareToEmp.modelSortCode)) { 
		                return 0;
		            } else {  
		                return 1;
		            }
		        } else { 
		            if (string.isBlank(compareToEmp.modelSortCode))
		            {
		                return -1;
		            } else {
		            	if(modelSortCode.compareTo(compareToEmp.modelSortCode) == 0) {
		            		if(productTab.compareTo(compareToEmp.productTab) == 0) {
		            			if(productTypeSortCode == compareToEmp.productTypeSortCode) {
		            				if(compareToEmp.isTractionUnit == this.isTractionUnit) {
		            					return productSortCode.compareTo(compareToEmp.productSortCode);	
		            				} else if(compareToEmp.isTractionUnit) {
			            				return 1;			
		            				} else {
		            					return -1;
		            				}
			            		} else {
			            			return compareToEmp.productTypeSortCode-productTypeSortCode;
			            		}		
		            		} else {
		            			return productTab.compareTo(compareToEmp.productTab);
		            		}        		
		            	} else {
		            		return modelSortCode.compareTo(compareToEmp.modelSortCode);
		            	}
		            }
		        }
	    	}
	    }
    }
   
	 
	public class DNetMSRGPair {
		DNetMSRGPair(String n, String sku, String productType, String hierarchyCode, decimal msrp, decimal dNet)	{
			this.dNet = dNet;
			this.msrp = msrp;
			this.optionName = n;
			this.sku = sku;
			this.productType = productType;
			this.hierarchyCode = hierarchyCode;
		}
		public decimal dNet { get; set;}
		public decimal msrp {get; set;}
		public String optionName { get; set; }
		public String sku { get; set; }
		public String productType { get; set;}
		public String hierarchyCode { get; set;}
		
	}
}