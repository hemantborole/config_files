package com.sb.carpool.tests;

import com.sb.carpool.core.Carpool;
import com.sb.carpool.core.Driver;
import com.sb.carpool.utils.Utils;
import org.junit.Test;

import static org.junit.Assert.*;

public class TestCarpool {

	public Carpool pool = new Carpool();
  private Utils utils = new Utils();

	@Test
	public void testAddDriver() {
    for( int i = 0; i < 5; i++ ) {
      Driver d = new Driver("d"+i);
      pool.add(d);
      assertEquals( pool.combinations(),
                    utils.combinations(pool.getPoolers()));
    }

    pool.showRoutes();
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("2 => " + pool.nextDriver(2));
    System.out.println("2 => " + pool.nextDriver(2));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("2 => " + pool.nextDriver(2));
    System.out.println("3 => " + pool.nextDriver(3));
    System.out.println("2 => " + pool.nextDriver(2));

	}

}

