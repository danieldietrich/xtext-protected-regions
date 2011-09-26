package net.danieldietrich.xtext.generator.protectedregions;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IProtectedRegionOracle {

  /**
   * Checks whether a given String is the start of a protected region.
   * Caution: Comment start and end Strings are not taken into account.
   * 
   * @param s A String to check
   * @return true, if s is a protected region start, false otherwise
   */
  boolean isProtectedRegionStart(String s);
  
  /**
   * Checks whether a given String is the end of a protected region.
   * Caution: Comment start and end Strings are not taken into account.
   * 
   * @param s A String to check
   * @return true, if s is a protected region end, false otherwise
   */
  boolean isProtectedRegionEnd(String s);
  
  /**
   * The id of a protected region start String.
   * 
   * @param protectedRegionStart Guaranteed to be a protected region start.
   * @return The id of the protected region.
   */
  String getId(String protectedRegionStart);
  
}
