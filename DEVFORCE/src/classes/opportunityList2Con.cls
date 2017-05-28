public class opportunityList2Con {
  
 // Refer https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/apex_pages_standardsetcontroller.htm
  
      public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [select name,closedate from Opportunity]));
            }
            return setCon;
        }
        set;
    }
 
    // Initialize setCon and return a list of records
    
    public List<Opportunity> getOpportunities() {
         setCon.setpagesize(10);
         return (List<Opportunity>) setCon.getRecords();
    }
}