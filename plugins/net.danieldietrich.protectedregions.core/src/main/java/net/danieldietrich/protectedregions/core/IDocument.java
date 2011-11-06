package net.danieldietrich.protectedregions.core;

/**
 * An IDocument holds IRegions, which are either marked (with an ID) or not marked.
 * 
 * @see DefaultWritableDocument
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IDocument {
  
  /**
   * An IDocument consists of zero or more IRegions.
   */
  Iterable<IRegion> getRegions();
  
  /**
   * Get marked region by id.
   * 
   * @param id
   * @return null, if no marked region with corresponding id is present in the current IDocument.
   */
  IRegion getMarkedRegion(String id);
  
  /**
   * Get the contents of the document, namely the text of all IRegions.
   * 
   * @return
   */
  String getContents();
  
  /**
   * There are to kinds of IRegions: marked and not marked regions,
   * where a marked region has an ID.<br>
   * Regarding the 'fill-in' scenario, a marked region contains generated code.<br>
   * Regarding the 'protected regions' scenario, a marked region contains protected code.<br>
   * <br>
   * The ID of a marked region is guaranteed to be not null and unique for the
   * current IDocument. The ID of a not marked region is always null.<br>
   * <br>
   * Marked regions are enabled or disabled.<br>
   * Regarding the 'fill-in' scenario, enabled marked regions will <em>not</em> be preserved (i.e. the region will be generated).<br>
   * Regarding the 'protected regions' scenario, enabled marked regions will be preserved (i.e. the previous version merged in).
   */
  static interface IRegion {
    boolean isMarkedRegion();
    boolean isEnabled();
    String getId();
    String getText();
  }
}
