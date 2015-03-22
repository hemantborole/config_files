import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;

public class CountChars {
  public static int countChar(String str, int c) {
    int counter=0;
    for( int i=0; i< str.length() ; i++) {
      if( str.charAt(i) == c ) {
        counter++;
      }
    }
    return counter;
  }
  public static void main(String ...a) {
    //System.out.println(CountChars.countChar("hello world",'o'));
    System.out.println(new CountChars().countChar2("hello world",'x'));
    //new CountChars().testString("hello");
  }

  public long countChar2(String str, int c) {
    char[] ch = str.toCharArray();
    List<Character> list = new ArrayList<>();
    for( int i = 0; i< str.length(); i++) {
        list.add(ch[i]);
    }
    return list.stream().filter(i-> i == c  ).count();
  }

  public void testString(String str) {
    char [] ch = str.toCharArray();
    for( int i=0; i< str.length(); i++) {
      System.out.println( ch[i]);
    }
  }

}
