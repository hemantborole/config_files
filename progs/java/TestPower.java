public class TestPower {
  public static void main(String a[]) {
    System.out.println(String.format("%f", 1.0 * ( 611686018420000000l + (7*power(10,6)) )) );
    System.out.println(String.format("%f", ( 611686018420000000l + 7000000.0 )));
  }

  public static long power(int base, int exp) {
    long product = 1l ;
    for( int i = 0 ; i < exp; i++ ) {
      product = product * base;
    }
    return product;
  }
}
