public with sharing class ContactExt {
    private Credit_Exposure__c credExposure {get;set;}
    public String credExpoJson {get;set;}
    public ContactExt(ApexPages.StandardController controller) {
        credExposure = (Credit_Exposure__c) controller.getRecord();
        credExpoJson = JSON.serializePretty(credExposure);
    }
    
    public void save()
    {
        credExposure = (Credit_Exposure__c)JSON.deserialize(credExpoJson, Credit_Exposure__c.class);
        upsert credExposure;
    }
    
    // fetch values of Line Of Business
    @RemoteAction 
    public static  List<SelectOption> getLOB()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Credit_Exposure__c.Line_Of_Business__c.getDescribe();
        List<Schema.PicklistEntry> picklstEntry = fieldResult.getPicklistValues();       
        for( Schema.PicklistEntry ple : picklstEntry) {  
            options.add(new SelectOption(ple.getValue(),ple.getLabel()));
        }  
         return options;     
    } // end
}