import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

public class Combinations {
	private static void comb1(String s) {
		comb1("",s);
	}
	private static void comb1(String prefix, String s) {
		if (s.length() > 0) {
			System.out.println(prefix + s.charAt(0));
			comb1(prefix + s.charAt(0), s.substring(1));
			comb1(prefix,               s.substring(1));
		}
	} 

	private static void comb2(String s[]) {
		comb2("",s);
	}
	private static void comb2(String prefix, String s[]) {
		if (s.length > 0) {
			if( prefix.length() > 0 )
				System.out.println(prefix + s[0]);
			comb2(prefix + s[0], Arrays.copyOfRange(s, 1, s.length) );
			comb2(prefix, Arrays.copyOfRange(s, 1, s.length) );
		}
	} 


	private static Set<String> subSet(Set<String> source, int from) {
		Set<String> set = new HashSet<>();
		int i = 0;
		for( String element : source ) {
			if( i++ >= from ) {
				set.add(element);
			}
		}
		return set;
	}

	private static String first(Set<String> s) {
		Iterator<String> itr = s.iterator();
		return itr.next();
	}

	private static void comb3(Set<String> s) {
		comb3("",s);
	}
	private static void comb3(String prefix, Set<String> s) {
		if (s.size() > 0) {
			if( prefix.length() > 0 )
				System.out.println(prefix + first(s));
			comb3(prefix + first(s), subSet(s, 1) );
			comb3(prefix, subSet(s, 1) );
		}
	} 

	public static void main(String a[]) {
		Set<String> s = new HashSet<String>(Arrays.asList(a));
		Combinations.comb3(s);
	}
}
