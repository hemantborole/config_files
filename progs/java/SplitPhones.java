import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class SplitPhones  {
  public static void main(String a[]) {
    SplitPhones sp = new SplitPhones();
    sp.split("phones^4012949429|AMA,4012745844");
  }

  public List<String> split(String p) {
    List<String> phones = new ArrayList<String>();
    Pattern phonePattern = Pattern.compile("(\\d+)");
    Matcher pMatch = phonePattern.matcher(p);
    while(pMatch.find())  {
      phones.add(pMatch.group(0));
    }    
    return phones;
  }
}
