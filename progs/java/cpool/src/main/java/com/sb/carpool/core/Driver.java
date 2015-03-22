package com.sb.carpool.core;

public class Driver {
	private String name;

	public Driver(String name) {
		this.name = name;
	}

	public String get() {
		return name;
	}

  public String toString() {
    return this.name;
  }
}
