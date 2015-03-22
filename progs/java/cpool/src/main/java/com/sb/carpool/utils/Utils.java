package com.sb.carpool.utils;

import com.sb.carpool.core.Driver;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

public class Utils<T> {
	public int combinations(Set<Driver> d) {
		int numDrivers = 0;
		if( null == d || ( numDrivers = d.size() ) == 0 ) return 0;
		return power(2, numDrivers) - numDrivers - 1;
	}

	/* limited power function */
	private int power(int base, int exp) {
		int p = 1;
		for( int i = exp ; i > 0; i-- ) {
			p = p * base;
		}
		return p;
	}

	public T getFirst(Set<T> s) {
    return this.get(s,0);
	}

	public T get(Set<T> s, int n) {
    int i = 0;
    for( T t : s ) {
      if( i++ == n )
        return t;
    }
    return null;
	}

	public Set<T> subSet(Set<T> s, int from) {
		Set<T> copySet = new HashSet<>();
		int i = 0;
		for( T t : s ) {
			if( i++ >= from ) {
				copySet.add(t);
			}
		}
		return copySet;
	}

  public Set<T> merge(Set<T> s1, T tAdd) {
    Set<T> merged = new HashSet<>();
    for( T t : s1 ) {
      merged.add(t);
    }
    merged.add(tAdd);
    return merged;
  }
}
