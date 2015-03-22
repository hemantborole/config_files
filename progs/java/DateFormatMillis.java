import java.text.SimpleDateFormat; 
import java.util.Date;

public class DateFormatMillis {
  public static void main(String a[]) {
    SimpleDateFormat s = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    long millis = Long.parseLong(a[0]);
    String t = s.format(new Date(millis)).toString();
    System.out.println("Date :" + t);
  }
}
