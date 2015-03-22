public class Deviation {
  private static final float D = 3;
  public static void main(String a[]) {
    float threshold = 1;
    int c = 1890000;
    int n = 1890090;

    float deviation = Math.abs(c - n ) * 100 / n;
    float d = Float.parseFloat("1");
    if( deviation < D ) {
      System.out.println("Got good deviation:" + deviation);
    } else {
      System.out.println("Got bad deviation:" + deviation);
    }
  }
}
