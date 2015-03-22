import java.util.regex.*;

public class AlnumSymbols {
  private static final Pattern asciiOnly = Pattern.compile("[^\\p{Alnum}']");
  private static Matcher ascii = asciiOnly.matcher("");
  public static void main(String a[]) {
    System.out.println(ascii.reset(a[0]).replaceAll(""));
  }
}
