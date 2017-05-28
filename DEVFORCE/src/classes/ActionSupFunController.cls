Public with sharing class ActionSupFunController
{
    Public string Display_This_String{get;set;}
    Public Integer count{get;set;}
    
    Public ActionSupFunController (){
     Display_This_String = 'value set in constructor';
     count = 0;
    }
    
    Public void actionFunMethod(){
      Display_This_String = 'value set in action function method';
    }
    
    Public void actionSupMethod(){
      Display_This_String = 'value set in action Support method';
    }
    
    public PageReference incrementCounter() {
        count++;
        return null;
    }
}