public class StringArrayTest
{

public static String[] generateStringArray(Integer count)
{
  String[] arryofStrings = new List<String>();
  
  for(Integer i = 0; i < count; i++ )
  {
      arryofStrings.add('Test '+i);
  }
  
  return arryofStrings;
 
}


}