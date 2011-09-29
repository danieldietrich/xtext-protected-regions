package net.danieldietrich.xtext.generator.protectedregions;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IRegionOracle {

  /**
   * Checks whether a given String is the start of a marked region.
   * Caution: Comment start and end Strings are not taken into account.
   * 
   * @param comment A String to check
   * @return true, if comment is a marked region start, false otherwise
   */
  boolean isMarkedRegionStart(String comment);
  
  /**
   * Checks whether a given String is the end of a marked region.
   * Caution: Comment start and end Strings are not taken into account.
   * 
   * @param comment A String to check
   * @return true, if comment is a marked region end, false otherwise
   */
  boolean isMarkedRegionEnd(String comment);
  
  /**
   * The id of a marked region start String.
   * 
   * @param markedRegionStart Guaranteed to be a marked region start.
   * @return The id of the marked region.
   */
  String getId(String markedRegionStart);
  
  /**
   * Returns whether a switchable marked region is enabled or not.
   * 
   * @param markedRegionStart Guaranteed to be a marked region start.
   * @return true, if the marked region is enabled, false otherwise
   */
  boolean isEnabled(String markedRegionStart);
  
}
