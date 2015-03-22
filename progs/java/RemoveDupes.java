public class RemoveDupes {
  public static void main(String ap[]) {
    byte[] bits = new byte[26];
    char [] input = ap[0].toCharArray();

    int idx = 0;
    for( int i = 0; i < input.length; i++ ) {
      char c = input[i];
      if ( bits[c - 'a'] < 1 ) {
        bits[c-'a'] = 1;
        input[idx] = c;
        idx++;
      }
    }
    for( int i = idx ; i < input.length ; i++ ) {
      input[i] = '\0';
    }
    //input[idx] = 0;
    System.out.println(input);
  }
}
