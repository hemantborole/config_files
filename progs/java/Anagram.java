public class Anagram {
  public boolean isAnagram(String s1, String s2) {
    byte[] b1 = new byte[26];
    byte[] b2 = new byte[26];

    char[] c1 = s1.toCharArray();
    char[] c2 = s2.toCharArray();

    for( int i = 0; i < c1.length; i++ ) {
      b1[c1[i] - 'a'] += 1;
    }
    for( int i = 0; i < c2.length; i++ ) {
      b2[c2[i] - 'a'] += 1;
    }

    for( int i = 0; i < 26; i++ ) {
      if( b1[i] != b2[i] )
        return false;
    }

    return true;
  }

  public static void main(String a[]) {
    Anagram ana = new Anagram();
    System.out.println(a[0] + " and " + a[1] + " = Anagram? " + ana.isAnagram(a[0],a[1]));
  }
}
