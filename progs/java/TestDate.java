import java.util.Calendar;
import java.text.SimpleDateFormat;

public class TestDate {
  public static void main(String args[]){
    String DATE_FORMAT = "yyyyMMddHHmm";
    SimpleDateFormat sdf =
          new SimpleDateFormat(DATE_FORMAT);
    Calendar c1 = Calendar.getInstance(); // today
    System.out.println("Today is " + sdf.format(c1.getTime()));
  }
}

