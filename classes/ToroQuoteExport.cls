public with sharing class ToroQuoteExport {
	public static final Integer socMergeAcross = 4;
	public decimal equipmentTotal { get; set; }
	public decimal tpp { get; set; }
	public decimal tradeIn { get; set; }
	public decimal total { get; set; }
	public REVVY__MnQuote__c quote { get; set; }
	public List<REVVY__MnStrategy4__c> quoteItems { get; set; }
	public Integer getSOCMergeAcross() {
    	Integer val = socMergeAcross;
    	return val;
    }
	public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    public String hostName {
        get {
        	REVVY__MnProperty__c hostName = REVVY__MnProperty__c.getValues('ToroCPQHostName'); 
            String hostNameVal='enter_your_host_name';
            if(hostName != null && String.isNotBlank(hostName.Revvy__Value__c)) {
                hostNameVal = 	hostName.Revvy__Value__c;
            } 
            return hostNameVal;
        }
    }
    public void initialize(Id quoteId){
    	equipmentTotal=0;
		tpp=0;
		tradeIn=0;
		total=0;
		Map<String, decimal> type2SubTotal = new Map<String, decimal>();
		
		quote = [Select Id, Name, REVVY__Id__c, REVVY__Expiration_Date__c, REVVY__Account__r.Name, REVVY__Account__r.BillingAddress, 
					REVVY__Account__r.BillingCountryCode, REVVY__Account__r.BillingStateCode, 
					REVVY__Account__r.BillingCountry, REVVY__Account__r.BillingPostalCode, 
					REVVY__Account__r.BillingState, REVVY__Account__r.BillingCity, REVVY__Account__r.Commercial_Distributor__r.Name,
					REVVY__Account__r.BillingStreet From REVVY__MnQuote__c where id = :quoteId];
		quoteItems = [Select Product_Name__c, Product_Id__c, Extended_Award_Price__c, Award_Price__c, Pricing_Program_Product_Type__c,
							Adjusted_Quantity__c, (Select Award_Price__c, Description__c, Pricing_Program_Product_Type__c,
							Extended_Award_Price__c, Product_Id__c, Product_Name__c , Adjusted_Quantity__c From Toro_Quote_Item_Sub_Lines__r) 
							From REVVY__MnStrategy4__c where Mn_Quote__c = :quoteId];
		System.debug('quoteItems =' + quoteItems);
		for(REVVY__MnStrategy4__c qi : quoteItems) {
			if(!type2SubTotal.containsKey(qi.Pricing_Program_Product_Type__c)) {
				type2SubTotal.put(qi.Pricing_Program_Product_Type__c, 0);		
			}
			qi.Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Award_Price__c).setScale(2,roundingMode.HALF_UP);
			qi.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qi.Extended_Award_Price__c).setScale(2,roundingMode.HALF_UP);
			
			type2SubTotal.put(qi.Pricing_Program_Product_Type__c, type2SubTotal.get(qi.Pricing_Program_Product_Type__c) + qi.Extended_Award_Price__c);
			
			if (qi.Toro_Quote_Item_Sub_Lines__r != null && qi.Toro_Quote_Item_Sub_Lines__r.size() > 0) {
				for (Revvy__MnStrategy5__c qis : qi.Toro_Quote_Item_Sub_Lines__r) {
					if(!type2SubTotal.containsKey(qis.Pricing_Program_Product_Type__c)) {
						type2SubTotal.put(qis.Pricing_Program_Product_Type__c, 0);		
					}
					qis.Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Award_Price__c).setScale(2,roundingMode.HALF_UP);
					qis.Extended_Award_Price__c = CMnQuoteUtil.defaultDecimal(qis.Extended_Award_Price__c).setScale(2,roundingMode.HALF_UP);
					type2SubTotal.put(qis.Pricing_Program_Product_Type__c, type2SubTotal.get(qis.Pricing_Program_Product_Type__c) + qis.Extended_Award_Price__c);
					
				}
			}		
		}
		System.debug('type2SubTotal =' + type2SubTotal);
		if(type2SubTotal.containsKey('Standard')) {
			equipmentTotal = type2SubTotal.get('Standard').setScale(2,roundingMode.HALF_UP);		
		}
		if(type2SubTotal.containsKey('TPP')) {
			tpp = type2SubTotal.get('TPP').setScale(2,roundingMode.HALF_UP);	
			
		}
		if(type2SubTotal.containsKey('Trade Ins')) {
			tradeIn = type2SubTotal.get('Trade Ins').setScale(2,roundingMode.HALF_UP);	
			if(tradeIn > 0)	 {
				tradeIn = -1*tradeIn;	
				type2SubTotal.put('Trade Ins', tradeIn);
			}	
		}
		total = 0;
		for(decimal d : type2SubTotal.values()) {
			total += CMnQuoteUtil.defaultDecimal(d);		
		}
		total = total.setScale(2,roundingMode.HALF_UP);		
    }
	public ToroQuoteExport(ApexPages.StandardController controller){
		SObject recObj = controller.getRecord();
		system.debug('record id=' + recObj.Id);	
		initialize(recObj.Id);
	}
	public ToroQuoteExport(){
		Id quoteId = ApexPages.currentPage().getParameters().get('Id');
		initialize(quoteId);
	}
}