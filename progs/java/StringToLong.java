/*
 * Synopsis:   Convert a given string to java long
 * Assumption: conversion to base 10 only.
 * Limitation: Since most string functions are build on int, e.g. string.length returns int,
 *             this method can handle strings of length that can be only as long as a value that
 *             a integer can hold.
 * 
 * Compile as
 * javac -cp ~/.m2/repository/junit/junit/4.8.1/junit-4.8.1.jar:. StringToLong.java
 *
 * Execute using attached unit test
*/

import static org.junit.Assert.*;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.junit.Test;
import org.junit.Rule;
import org.junit.rules.ExpectedException;

public class StringToLong {

  // input string normalized pattern
  private static final Pattern NUMERIC_LONG = Pattern.compile("^[-+]?[0-9]*[Ll]?$");

  // default, can be skipped
  public StringToLong() {
  }

  private boolean isNegative = false;

  public Long stringToLong(final String longstr)
      throws IllegalArgumentException{
    
    // this will hold the final long value
    long value = 0l;

    // translate null to illegal argument, avoid catching runtime exceptions;
    if( null == longstr )
      throw new IllegalArgumentException("Null string not allowed");

    String inputString = longstr.trim();

    // string containing non allowed long characters can be considered invalid
    // Alternatively, we could just strip those characters and continue to convert
    // We choose the former
    if( invalidPattern(inputString) )
      throw new NumberFormatException("Found illegal characters in the middle of the string");

    isNegative=false; // initialize, assume positive to being with

    /* normalize string, strip leading 0's, ensure negative sign is maintained */
    inputString = strip(inputString);

    /* Now that we have the "clean" string, we can iterate over and multiply by radix */
    int length = inputString.length();
    int position = length-1;
    for( int i = 0; i < length; i++) {
      int atoi = inputString.charAt(i) - '0'; // Convert to digit
      if( position == 0 )
        value += atoi;
      else
        value += atoi * ( Math.pow(10,position));
      position --;
    }

    return isNegative ? -value : value;
  }

  private boolean invalidPattern(String l_longstr) {
    Matcher m = NUMERIC_LONG.matcher(l_longstr);
    return ( !m.matches() );
  }


  /* strip leading 0's and '-'ve sign */
  private String strip( final String l_longstr) {
    int len = l_longstr.length();
    int idx = 0;

    StringBuilder buildCleanString = new StringBuilder();

    char first = l_longstr.charAt(0);
    if( l_longstr.charAt(0) == '-' ) {
      isNegative = true;
      idx++;
    }
    if( l_longstr.charAt(0) == '+' ) {
      idx++;
    }

    // Do nothing, simply iterate index
    for( ; idx < len && l_longstr.charAt(idx) == '0' ; idx++ );

    if( l_longstr.charAt(len-1) == 'L' || l_longstr.charAt(len-1) == 'l') {
      len--;
    }

    buildCleanString.append(l_longstr.substring(idx,len));

    return buildCleanString.toString();
  }

}
