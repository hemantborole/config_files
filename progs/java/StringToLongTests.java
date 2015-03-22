/*
 * Synopsis:   test cases for stringtoLong
 *
 * testNull - Tests for null string, expect exception (choice of design)
 * testPattern - Tests that the input adheres -?[0-9]+[Ll] pattern (allowed long literal)
 * testLeadingZeros - Tests zeros in beginning should be stripped,
 *                    for both positive and negative numbers
 * testDataType - ensures returned value is long, not integer.
 *
 * Compile as
 * javac -cp ~/.m2/repository/junit/junit/4.8.1/junit-4.8.1.jar:. StringToLongTests.java
 *
 * Execute like so
 * java -cp ~/.m2/repository/junit/junit/4.8.1/junit-4.8.1.jar:. org.junit.runner.JUnitCore StringToLongTests
*/

import static org.junit.Assert.*;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.junit.Test;
import org.junit.Rule;
import org.junit.rules.ExpectedException;

public class StringToLongTests {

  // All test cases first
  private static final StringToLong TEST_INSTANCE = new StringToLong(); // Only for junit tests;

  // Treat null as a invalid argument, (we could alternatively just return null)
  @Test (expected = IllegalArgumentException.class)
  public void testNull() {
    TEST_INSTANCE.stringToLong(null);
  }

  @Test (expected = NumberFormatException.class)
  public void testPattern() {
    TEST_INSTANCE.stringToLong("-123a");
  }

  @Test
  public void testLeadingZeros() {
    assertEquals( (Long)TEST_INSTANCE.stringToLong("0"), (Long)(0L));
    assertEquals( (Long)TEST_INSTANCE.stringToLong("00123"), (Long)(123L));
    assertEquals( (Long)TEST_INSTANCE.stringToLong("+00123"), (Long)(123L));
    assertEquals( (Long)TEST_INSTANCE.stringToLong("-00123"), (Long)(-123L));
  }

  @Test
  public void testMax() {
    assertEquals( TEST_INSTANCE.stringToLong("611686018427387904"),
                    (Long)611686018427387904l);
  }

  @Rule
  public ExpectedException exceptions = ExpectedException.none();
  @Test
  public void testType() {
    exceptions.expect( AssertionError.class);
    exceptions.expectMessage( "expected: java.lang.Long<123> but was: java.lang.Integer<123>");

    assertEquals( (Long)TEST_INSTANCE.stringToLong("00123"), (Integer)(123));
  }

}
