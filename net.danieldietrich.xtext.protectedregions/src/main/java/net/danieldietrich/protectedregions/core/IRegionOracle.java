package net.danieldietrich.protectedregions.core;

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
   * Returns whether a marked region is enabled or not.<br>
   * <strong>Notes:</strong>
   * <ul>
   *   <li>Non switchable implementations are always returning true.</li>
   *   <li>The semantics of enabled marked regions varies.<br>
   *       To common use cases are {@link RegionUtil#fillIn(IDocument, IDocument)}
   *       and {@link RegionUtil#merge(IDocument, IDocument)}.
   *   </li>
   * </ul>
   * 
   * @param markedRegionStart Guaranteed to be a marked region start.
   * @return true, if the marked region is enabled, false otherwise
   */
  boolean isEnabled(String markedRegionStart);
  
}
