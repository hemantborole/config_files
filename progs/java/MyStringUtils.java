public class MyStringUtils {
  /* strip leading 0's, ensure negative sign is maintained */
  private String strip( final String longstr) {
    int len = longstr.length();
    int idx = 0;
    boolean isNegative = false;

    StringBuilder buildCleanString = new StringBuilder();

    if( longstr.charAt(0) == '-' ) {
      isNegative = true;
      idx++;
    }

    for( ; idx < len && longstr.charAt(idx) == '0' ; idx++ );

    if( isNegative )
      buildCleanString.append('-');

    if( longstr.charAt(len-1) == 'L' || longstr.charAt(len-1) == 'l') {
      len--;
    }
    buildCleanString.append(longstr.substring(idx,len));

    return buildCleanString.toString();
  }

  public static void main(String a[]) {
    MyStringUtils m = new MyStringUtils();
    System.out.println(m.strip(a[0]));
  }

}
