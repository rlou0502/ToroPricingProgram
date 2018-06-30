public with sharing class ToroTriggerRunOnce {
	private static boolean qiExtension = true;
    public static boolean runQiExtensionRunOnce(){
        if(qiExtension){
            qiExtension=false;
            return true;
        } else {
            return qiExtension;
        }
    } 
    private static boolean qisExtension = true;
    public static boolean runQisExtensionRunOnce(){
        if(qisExtension){
            qisExtension=false;
            return true;
        } else {
            return qisExtension;
        }
    } 
    
    private static boolean quoteItemRunOnce = true;
    public static boolean runQuoteItemRunOnce(){
        if(quoteItemRunOnce){
            quoteItemRunOnce=false;
            return true;
        } else {
            return quoteItemRunOnce;
        }
    } 
    private static boolean quoteItemSublineRunOnce = true;
    public static boolean runQuoteItemSublineRunOnce(){
        if(quoteItemSublineRunOnce){
            quoteItemSublineRunOnce=false;
            return true;
        } else {
            return quoteItemSublineRunOnce;
        }
    } 
    
    private static boolean inCloing = false;
    public static void setInCloning(boolean flag){
    	inCloing = flag;	    
    } 
    public static boolean getInCloning() {
    	return inCloing;
    }    
}