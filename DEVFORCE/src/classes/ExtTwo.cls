public without Sharing class ExtTwo {
    public ExtTwo(ApexPages.StandardController acon) { }
    public void getFoo() {        
        List<Account> acc = new List<Account>();
        acc = [Select Id from Account Where Rating != 'cold'
                AND multiselect__c Excludes ('bala')];
        system.debug('acc');
        for(Account accnt : acc) {
            for(Contact cont : [Select Id from Contact ]) {
                update cont;
            }
            update acc;
        }
        List<Account> accList = new List<Account>();
        accList = Database.query('Select Id from Account Where  Rating != \'cold\'');
        
        
         system.debug('acc');
    }
    
}