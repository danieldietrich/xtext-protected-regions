package net.danieldietrich.xtext.generator.protectedregions;

/**
 * An IDocument holds IRegions, which are either protected or non-protected regions.
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
   * Get protected region by id.
   * 
   * @param id
   * @return null, if no protected region with corresponding id is present in the current IDocument.
   */
  IRegion getProtectedRegion(String id);
  
  /**
   * Get the contents of the document, namely the text of all IRegions.
   * 
   * @return
   */
  String getContents();
  
  /**
   * There are to kinds of IRegions: text inside and outside of protected regions,
   * where a protected region has an ID.<br>
   * The ID of a protected region is guaranteed to be not null and unique for the
   * current IDocument. The ID of a non-protected region is always null.
   */
  static interface IRegion {
    boolean isProtectedRegion();
    String getId();
    String getText();
  }
}
