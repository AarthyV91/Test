public class ApexClassOptimizerController {
    
    Public Map<String,apexWrapperClass> apexClsWrapperMap {get;set;}
    Public Integer totalWithoutSharingCount {get;set;}
    Public Integer totalSeeAllDataCount {get;set;}
    Public Integer totalWhereClauseCount {get;set;}
    Public Integer totalDmlInsLoopCount {get;set;}
    Public Integer totalSoqlInsLoopCount {get;set;}
    Public Integer totalsoqlwithNegCount {get;set;}
    Public Integer totaldebugStatemtCount {get;set;}
    Public  List<PieWedgeData> data {get;set;}
    public Boolean displayPopUp {get;set;}
    Public String selectedtime{get;set;}
    Public List<SelectOption> timeOptionsList{get;set;}
    
    
    public ApexClassOptimizerController() {
        apexClsWrapperMap = new Map<String,apexWrapperClass>();
        totalWithoutSharingCount  = 0;
        totalSeeAllDataCount  = 0;
        totalWhereClauseCount = 0;
        totalDmlInsLoopCount = 0;
        totalSoqlInsLoopCount = 0;
        totalsoqlwithNegCount  = 0;
        totaldebugStatemtCount = 0;
        displayPopUp = true;
        timeOptionsList = new List<SelectOption>();
        selectedtime = '';
        
        timeOptionsList.add(new SelectOption('LAST_YEAR','Last Year'));
        timeOptionsList.add(new SelectOption('LAST_N_YEARS:3','Last 3 Years'));
        timeOptionsList.add(new SelectOption('THIS_MONTH','This Month'));
        timeOptionsList.add(new SelectOption('LAST_MONTH','This Month'));
        timeOptionsList.add(new SelectOption('LAST_WEEK','Last Week'));
        timeOptionsList.add(new SelectOption('YESTERDAY','Yesterday'));
        
        /* data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Total Without Sharing Count', totalWithoutSharingCount));
        data.add(new PieWedgeData('Total See All Data Count', totalSeeAllDataCount));
        data.add(new PieWedgeData('SOQL with Negative Operator', totalsoqlwithNegCount));
        data.add(new PieWedgeData('SOQL without Where Clause', totalWhereClauseCount));
        data.add(new PieWedgeData('SOQL inside LOOPS', totalSoqlInsLoopCount));
        data.add(new PieWedgeData('DML INSIDE LOOP', totalDmlInsLoopCount));
        data.add(new PieWedgeData('DEBUG Statement', totalDebugStatemtCount )); */
     }
    
    public void optimizeTheClass(String selectedtime) {
    
        List<ApexClass> apexClasslist = new List<ApexClass>();
        
        String query = 'SELECT Body,BodyCrc,Id,IsValid,LengthWithoutComments,Name,Status FROM ApexClass';
        
        query += ' Where Status = \'Active\' AND NAME != \'ApexClassOptimizerController\' AND NAME != \'APexClassOptimizerController2\'';
        query += ' AND SystemModstamp = '+selectedtime+' ORDER BY Name';
        system.debug(query+'$$$');
        apexClasslist = Database.query(query);
        
        // QUERY ACTIVE APEX CLASSES
      
       for(ApexClass apexcls : apexClasslist ) {
            
            String ClassBody = '';
            string tString = apexcls.Body.toUpperCase();
            
            Integer withoutSharingCount = 0;
            Integer seeAllDataCount = 0;
            Integer debugStatemtCount = 0;
             
            ClassBody = tString;
            List<String> listOfStr = ClassBody.split(('\\{'));  
            
            if(listOfStr[0].contains('WITHOUT SHARING')){           
                withoutSharingCount = +1;
            }
            if(listOfStr[0].contains('SEEALLDATA')){           
                seeAllDataCount =+ 1;
            }
            Map<string,integer> StartIndexMap = new Map<string,Integer>();
            Map<string,integer> stopIndexMap = new Map<string,integer>();
            List<String> originalClass = new List<String>();
            integer counter = 0;
            integer listSize = 0;
        
            originalClass = classBody.split('\n',-2);       
            
            Boolean selectQuery = false;
            Boolean fromQuery = false;
            Integer selectCount = 0;
            Integer whereClauseCount = 0;
            integer soqlwithNegCount = 0;
            
            for(String s: ClassBody.split('\n',-2)){
                // If the Line contains 'SELECT' and does not contain 'WHERE''
                if(s.contains('SELECT')) {                  
                    if(!s.contains('WHERE ')) {
                        //whereClauseCount = whereClauseCount + 1;
                        selectQuery = true;
                    }
                }
                // If the line contains 'FROM' and does not contain 'WHERE'
                if(!s.contains('WHERE ') && selectQuery && s.contains('FROM ')) {
                    fromQuery = true;
                }
                // If the line contains 'WHERE'
                else if(s.contains('WHERE ') && selectQuery ) {
                    selectQuery = false;
                    fromQuery = false;
                    selectCount = 0 ;
                }
                                
                // If 'SELECT' and 'FROM' is available and 'WHERE' statement is not available
                if(selectQuery && fromQuery && !s.contains('WHERE ')) {
                    if(selectCount >= 1 ) {
                        whereClauseCount = whereClauseCount + 1;    
                        selectQuery = false;
                        fromQuery = false;
                        selectCount = 0 ;
                    }   
                    else {
                        selectCount++;
                    }
                }
                // Map of FOR Loop order and line number
                if(s.contains('FOR(')){
                    counter = counter + 1;
                    StartIndexMap.put(string.valueOf(counter),listSize);                     
                }    
                listSize = listsize + 1;
                
                if(s.contains('SYSTEM.DEBUG')) {
                    debugStatemtCount++;
                }
            }
            
            //List<String> tempList = new List<String>();  
            Map<string,List<String>> GroupMap = new Map<string,List<String>>();
            
            for(string s : startIndexMap.keyset()){
                List<String> tempListString = new List<String>();
                integer i = 0;
                integer OpenBraceCount = 0;
                integer recrussiveFor = 0;
                
                for(string classRec : originalClass){  
                    // If the Apex code inside the for loop
                    if(i >= startIndexMap.get(s)){                    
                       
                        //tempList.add(classRec);
                        tempListString.add(classRec);
                        if(classRec.contains('{')){
                            OpenBraceCount = OpenBraceCount + 1;
                        }
                        if(ClassRec.contains('}')){
                            OpenBraceCount = openBraceCount - 1;
                        } 
                        if(OpenBraceCount == 0){
                            
                            stopIndexMap.put(s,i);           // Map of FOR loop ORDER and FOR loop ending line number                           
                            GroupMap.put(s,tempListString);  // Map of FOR loop and the code inside for loop
                            break;  
                        }                  
                    }
                    i = i+1;   // Line Number of the Apex code                                             
                }
            }
                
            List<string> tobedeleted = new List<string>();
            for(string s: StartIndexMap.Keyset()){  
                integer i = 0; 
                for(string s1 : stopIndexMap.keyset()){   
                    //  IF a Nested FOR LOOP EXISTS, 
                    if(startIndexMap.get(s) < startIndexMap.get(s1) && stopIndexMap.get(s) > startIndexMap.get(s1)){
                            tobedeleted.add(s1);
                    }
                }                             
            }
            
           List<String> FinalDisplayList = new List<String>();
            
            // IGNORE THE NESTED LOOPS
            for(string s: groupMap.keyset()){               
                if(tobedeleted.size() > 0){
                    for(String s1 : tobedeleted){
                        if(s != s1){
                            FinalDisplayList.addall(GroupMap.get(s));
                        }    
                    }
                }else{
                    FinalDisplayList.addall(GroupMap.get(s));    
                }
            }           
            Integer soqlInsLoopCount = 0;
            
            for(string s : FinalDisplayList){
                if(s.contains('SELECT') ){
                    soqlInsLoopCount = soqlInsLoopCount + 1;
                }
               system.debug(soqlInsLoopCount +'FINAL LIST');
            }
            
            // Nested DML Statements will be calculated
            Integer dmlInsLoopCount = 0;
            dmlInsLoopCount = findDmlInsideLoop(classBody);
            
            // SOQL Queries with Negative operators calculated
            soqlwithNegCount = findNegativeOperators(classBody);
            
            apexClsWrapperMap.put(apexcls.Name,new apexWrapperClass(withoutSharingCount,seeAllDataCount,soqlwithNegCount,whereClauseCount,soqlInsLoopCount,dmlInsLoopCount,debugStatemtCount ));
        }
    }
    
    /******** TO FIND THE NEGATIVE OPERATOR IN SOQL QUERY **************/ 
    public Integer findNegativeOperators(String ClassBody) {
        List<String> splitString = new List<String>();
        splitString = classBody.split('\n',-2);
        Boolean openSelectQuery = false;
        Integer soqlwithNegCount = 0;
        Integer lineNo = 1;
        
        for(String s : splitString) {
            String tempStr1 =  s.deleteWhitespace();  
            if(tempStr1.contains('[SELECT')) {
                openSelectQuery = true;
            } 
            if(openSelectQuery && (s.contains('NOT ') || tempStr1.contains('EXCLUDES(')  
                                    || s.contains('!=') )){
                soqlwithNegCount++;
            }
            if(openSelectQuery && s.contains(']')) {
                openSelectQuery = false;
            }           
            if(s.contains('DATABASE.QUERY') || s.contains('DATABASE.COUNTQUERY') || s.contains('GETQUERYLOCATOR')) {
                if(tempStr1.contains('(\'')) {
                    if(s.contains('NOT ') ||  tempStr1.contains('EXCLUDES(') || s.contains('!='))   {
                        soqlwithNegCount++;
                    }
                }   
            }
        }
        return soqlwithNegCount;
    }
    
    
   
    /******** TO FIND THE DML INSIDE FOR LOOPS **************/  
    public Integer findDmlInsideLoop(String classBody)
    {
        Map<Integer,Integer> mapSrtEnd = new Map<Integer,Integer>();
        List<Integer> listOfForStart = new List<Integer>();
        List<Integer> lstDmlIdx = new List<Integer>();        
        Integer lineNumber = 1;
        Integer startIndex=0;
        List<String> splitString = new List<String>();
        splitString = classBody.split('\n',-2);
        
        for(String singleLine: splitString )
        {
            
            if(singleLine.containsIgnoreCase('for(') && singleLine.contains('{'))                        
            {
                listOfForStart.add(lineNumber);
                startIndex++;
            }
            if(singleLine.contains('}'))                        
            {
                
                if(listOfForStart !=NULL && !listOfForStart.isEmpty()) {
                
                    if(startIndex == 0 && listOfForStart.get(startIndex)!=NULL) {
                         mapSrtEnd.put(listOfForStart.get(startIndex),lineNumber);
                    }
                    else {
                        if(listOfForStart.get(startIndex-1)!=NULL) {
                             mapSrtEnd.put(listOfForStart.get(startIndex-1),lineNumber);
                        }
                    }
                    
                }
            } 
            
            if(singleLine.containsIgnoreCase('insert ') || singleLine.containsIgnoreCase('upsert') 
                || singleLine.containsIgnoreCase('update') || singleLine.containsIgnoreCase('delete')
                || singleLine.containsIgnoreCase('undelete'))
            {
                lstDmlIdx.add(lineNumber);
            }
            
            lineNumber = lineNumber+1;
            //startIndex=startIndex+1;           
        }
        Integer dmlInsFor=0;
        for(Integer dmlSrt:lstDmlIdx)
        {
            for(Integer forsrt:mapSrtEnd.keySet())
            {
                if(dmlSrt>forsrt && dmlSrt<mapSrtEnd.get(forsrt))
                {
                    dmlInsFor=dmlInsFor+1;                
                }
            }
        }
        return dmlInsFor;
    }
    
     public List<PieWedgeData> getPieData() {
        List<PieWedgeData> data = new List<PieWedgeData>();
        data.add(new PieWedgeData('Jan', 30));
        data.add(new PieWedgeData('Feb', 15));
        data.add(new PieWedgeData('Mar', 10));
        data.add(new PieWedgeData('Apr', 20));
        data.add(new PieWedgeData('May', 20));
        data.add(new PieWedgeData('Jun', 5));
        return data;
    }
    
    public PageReference submit() {
        displayPopUp  = false;
        
        optimizeTheClass(selectedtime);
        for(String apexClsStr : apexClsWrapperMap.keySet()) {
            //apexWrapperClass apexClsWrapInst = new apexWrapperClass();
            totalWithoutSharingCount += apexClsWrapperMap.get(apexClsStr).withoutSharingCount;
            totalSeeAllDataCount += apexClsWrapperMap.get(apexClsStr).seeAllDataCount;
            totalWhereClauseCount += apexClsWrapperMap.get(apexClsStr).soqlWithoutWhereCount;
            totalDmlInsLoopCount += apexClsWrapperMap.get(apexClsStr).dmlInsLoopCount;
            totalSoqlInsLoopCount += apexClsWrapperMap.get(apexClsStr).soqlInsLoopCount;
            totalsoqlwithNegCount += apexClsWrapperMap.get(apexClsStr).soqlwithNegCount;
            totaldebugStatemtCount += apexClsWrapperMap.get(apexClsStr).debugStatemtCount;
           
            data.add(new PieWedgeData(apexClsStr,apexClsWrapperMap.get(apexClsStr).withoutSharingCount ));
            
        }
        
        apexClsWrapperMap.put('#Total Count',new apexWrapperClass(totalWithoutSharingCount,totalSeeAllDataCount,totalsoqlwithNegCount, totalWhereClauseCount,totalSoqlInsLoopCount,totalDmlInsLoopCount,totalDebugStatemtCount ));
        return null;
    }

    // Wrapper class
    public class PieWedgeData {

        public String name { get; set; }
        public Integer data { get; set; }

        public PieWedgeData(String name, Integer data) {
            this.name = name;
            this.data = data;
        }
    }
    
    
    public class apexWrapperClass {
        
        public Integer withoutSharingCount{get;set;}
        public Integer seeAllDataCount{get;set;}
        public Integer dmlInsLoopCount {get;set;}
        public Integer soqlInsLoopCount {get;set;}
        public Integer soqlWithoutWhereCount{get;set;}
        public Integer soqlwithNegCount{get;set;}
        public Integer debugStatemtCount{get;set;}
        String apexClsName = '';
        
        public apexWrapperClass(Integer withoutSharingCount,Integer seeAllDataCount,Integer soqlwithNegCount, Integer soqlWithoutWhereCount,Integer soqlInsLoopCount, Integer dmlInsLoopCount, Integer debugStatemtCount ) {
            this.withoutSharingCount = withoutSharingCount;
            this.seeAllDataCount = seeAllDataCount;
            this.dmlInsLoopCount = dmlInsLoopCount;
            this.soqlInsLoopCount = soqlInsLoopCount;
            this.soqlWithoutWhereCount = soqlWithoutWhereCount;
            this.soqlwithNegCount = soqlwithNegCount;
            this.debugStatemtCount = debugStatemtCount;
        }
    }
}