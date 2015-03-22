package com.sb.carpool.core;

import java.util.HashSet;
import java.util.Set;

import com.sb.carpool.utils.Utils;

/* Each combination of Drivers is a route */

public class Route {

	private Set<Driver> drivers;
	private String key;
  private Driver currentDriver;

  private int next ;
  private Utils utils = new Utils();

	public Route(Set<Driver> poolers) {
    if( null == drivers ) {
      drivers = new HashSet<>();
    }
    if ( null == this.key ) {
      this.key = new String();
    }
		for( Driver driver : poolers ) {
      if( null != driver ) {
			  this.drivers.add(driver);
			  this.key += driver.get();
      }
		}
	}

  public Driver getNextDriver() {
    return (Driver)utils.get(drivers, (next++)%drivers.size());
  }

	public String toString() {
		return key;
	}
}

