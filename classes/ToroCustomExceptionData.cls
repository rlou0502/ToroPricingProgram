public with sharing class ToroCustomExceptionData {
	public String stackTrace;
    public String message;

    public ToroCustomExceptionData(String stackTrace, String message) {
        this.stackTrace = stackTrace;
        this.message = message;
    }    
}