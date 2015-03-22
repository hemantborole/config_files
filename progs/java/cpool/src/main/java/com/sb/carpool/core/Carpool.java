package com.sb.carpool.core;

import android.os.Parcel;
import android.os.Parcelable;
import com.sb.carpool.utils.Utils;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;

/*
 * Carpool, Driver
 * routes = combinations
 * map
 * 
 */
public class Carpool implements Parcelable {
	private Set<Driver> poolers;
	private Set<Route> routes;
	private Utils utils;

	public Carpool() {
		poolers = new HashSet<>();
		routes = new LinkedHashSet<>();
		utils = new Utils();
	}

  //Interface methods
	public void add(Driver d) {
		if( d != null )
			poolers.add(d);
    generateRoutes();
	}

	public Set<Route> showRoutes() {
    int i=0;
		for( Route r: routes) {
			System.out.println("Route " + (++i) + ": " + r);
		}
		return routes;
	}

  public Driver nextDriver(int route) {
    Route r = pickRoute(route);
    if( null == r ) return null;
    return r.getNextDriver();
  }


  // Internal utility methods
  public Set<Driver> getPoolers() {
    return poolers;
  }

  private Route pickRoute(int i) {
    if( i < 1 || i > routes.size() ) return null;
    return (Route)utils.get(routes, i-1);
  }

	public int combinations() {
		return routes.size();
	}

	private void generateRoutes() {
		routes.clear();
		generateRoutes((Set)null,poolers);
	}

	private void generateRoutes(Set<Driver> prefix, Set<Driver> s) {
    Driver first = (Driver)utils.getFirst(s);
    if( s.size() > 0 ) {
      if( prefix != null ) {
        if( prefix.size() > 0 ) {
          Route r = new Route(utils.merge(prefix,first));
          routes.add(r);
        }
      } else {
        prefix = new HashSet<Driver>();
      }
      Set<Driver> tmp = utils.merge(prefix, first);
      generateRoutes(tmp, (Set<Driver>)utils.subSet(s,1) );
      generateRoutes(prefix, (Set<Driver>)utils.subSet(s,1) );
    }
	}

  @Override
  public int describeContents() {
    return 0;
  }

  @Override
  public void writeToParcel(Parcel dest, int flags) {
  }
}

