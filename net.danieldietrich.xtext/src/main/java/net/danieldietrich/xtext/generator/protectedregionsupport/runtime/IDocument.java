package net.danieldietrich.xtext.generator.protectedregionsupport.runtime;

/**
 * An IDocument holds IParts, which are either protected or non-protected regions.
 * 
 * @see DefaultWritableDocument
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IDocument {

  /**
   * An IDocument consists of zero or more IParts.
   */
  Iterable<IPart> getParts();
  
  /**
   * Get protected region by id.
   * 
   * @param id
   * @return null, if no protected region with corresponding id is present in the current IDocument.
   */
  IPart getProtectedRegion(String id);
  
  /**
   * Get the contents of the document, namely the text of all IParts.
   * 
   * @return
   */
  String getContents();
  
  /**
   * There are to kinds of IParts: text inside and outside of protected regions,
   * where a protected region has an ID.<br>
   * The ID of a protected region is guaranteed to be not null and unique for the
   * current IDocument. The ID of a non-protected region is always null.
   */
  static interface IPart {
    boolean isProtectedRegion();
    String getId();
    String getText();
  }
}
