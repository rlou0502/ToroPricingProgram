global class CMnWAPluginFormatNumberQuoteItem implements REVVY.CMnWAPlugin {

    private static String NAME = 'Format Number for Quote Item';
    
    public REVVY.CMnPluginInfo getInfo() {
        REVVY.CMnPluginInfo pi = new REVVY.CMnPluginInfo();
        pi.name = NAME;
        pi.objectName = 'MnQuoteItem__c';
        //pi.objectName = '';

        pi.fieldNames = new List<String>();
        return pi;
    }

    public Map<String, Map<String, String>> execute(Map<String, Map<String, String>> data) {

        System.debug('>>> MnQuoteItem__c execute');
        List<String> args = new String[]{'0','number','###,###,##0.00'};
        
        for (String key : data.keySet()) {
            Map<String, String> fields = data.get(key);
            for (String k : fields.keySet()) {
                String d = fields.get(k);
                if (d != null) {
                    String value = '';
                    try {
                    	
					/*
Total_Award__c 
TPP_Total__c 
Set_Up_Total__c 
Freight_Delivery__c 
Allied_Non_Toro_Total__c 
State_Sales_Tax__c
Grand_Total__c
Trade_In_Total__c
Misc__c					
					
					*/
                    	
                        if('Total_Award__c'.equalsIgnoreCase(k)
                        || 'TPP_Total__c'.equalsIgnoreCase(k)
                        || 'Set_Up_Total__c'.equalsIgnoreCase(k)
                        || 'Freight_Delivery__c'.equalsIgnoreCase(k)
                        || 'Allied_Non_Toro_Total__c'.equalsIgnoreCase(k)
                        || 'State_Sales_Tax__c'.equalsIgnoreCase(k)
                        || 'Grand_Total__c'.equalsIgnoreCase(k)
                        || 'Trade_In_Total__c'.equalsIgnoreCase(k)
                        || 'Misc__c'.equalsIgnoreCase(k)
                        
                        ) {
                        
                        	/*
                            // Read decimal number
                            Decimal dc = Decimal.valueOf(d);
                            // Scale and round upto 2 digits
                            Decimal scaledDecimal = dc.setScale(2);
                            system.debug('@@@@ scaledDecimal : '+scaledDecimal);                                                                            
                            // prepend currency symbol
                            String sd = string.valueOf(scaledDecimal);
                            system.debug('@@@@ sd : '+sd);                                                                            
                            String strFormattedCurrency = String.format(scaledDecimal.format(), args);
	                        if(sd.contains('.00')) {
                                 strFormattedCurrency = strFormattedCurrency + '.00';
                             } 

                            // Your currency to be printed is ready
                            system.debug('@@@@ strFormattedCurrency : '+strFormattedCurrency);                                                                            
                            value = strFormattedCurrency;          
                            */
                            value = currency(d);             
                            System.debug('>>> value =' + value);
                            
                        } else 
                    	
                        if(d.isNumeric()){
                            System.debug('This is Numeric');
                           Integer intValue=Integer.valueOf(d);
                            value=String.valueOf(intValue);     
                        }else{ 
                            System.debug('This is Not Numeric');
                            Decimal dc=Decimal.valueOf(d);
                            value=dc.format(); 
                            System.debug('The Value is :'+value);
                        }
                        
                    } catch (Exception ex) {
                        System.debug('There is an exception ');

                        continue;
                    } 
                    fields.put(k, value);
                }
            }
        }
        return data;
    }

	public String currency(String input){
	    if(input == null){return '0.00';}
	    if(input.indexOf('.') == -1){input = input+'.00';}
	    if(input.length() == 5){return input+'0';}
	    String newValue = input.substring(input.indexOf('.'));
	    newValue = String.valueOf(Decimal.valueOf(newValue).setScale(2));
	    newValue = newValue.substring(newValue.indexOf('.'));
	    input = input.substring(0,input.indexOf('.'));
	    Integer sz = input.length();
	    Integer n=0;
	    for(Integer i = sz - 1;i > -1;i--){
	        if(n!= 0 && math.mod(n,3) == 0)
	            newValue = input.substring(i,i+1)+','+newValue;
	        else
	            newValue = input.substring(i,i+1)+newValue;
	        n++; 
	    }
	    return newValue;
	}    
}