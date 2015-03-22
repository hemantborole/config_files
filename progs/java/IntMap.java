import java.util.HashMap;
import java.util.Map;

public class IntMap {
  public static Map<String,Integer> intMap;
  public IntMap() {
      intMap = new HashMap<String,Integer>();
      intMap.put("le",new Integer(170000));
  }
  public static void main(String a[]) {
    new IntMap();
    if( IntMap.intMap.get("le") > 150000000 )
      System.out.println("Get threshold:" + IntMap.intMap.get("le"));
    else
      System.out.println("1.Get threshold:" + IntMap.intMap.get("le"));
  }
}
