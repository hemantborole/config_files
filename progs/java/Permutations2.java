import java.util.ArrayList;
import java.util.List;

public class Permutations2 {
  public List<String> Permutation(String s) {
    List<String> res = new ArrayList<>();
    int len = s.length();
    if (len == 0) return res;
    char[] ch = s.toCharArray();
    res.add(""+ch[0]);
    int count = res.size();
    for (int i=1; i<len; i++) {
      res.add(""+ch[i]);
      for (int j=0; j<count; j++) {
        if( res.get(i) != ch[i] ) {
          String cur = res.get(i) + ch[i];
          res.add(cur);
        }
      }
      count = res.size();
    }
    return res;
  }
  public static void main(String a[]) {
    System.out.println( ( (new Permutations2()).Permutation("abc") ).toString() );
  }
}
