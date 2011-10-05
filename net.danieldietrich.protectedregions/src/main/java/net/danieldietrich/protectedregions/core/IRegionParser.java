package net.danieldietrich.protectedregions.core;

import java.io.IOException;
import java.io.InputStream;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IRegionParser {

  /**
   * @see #parse(CharSequence)
   * 
   * @param in InputStream to parse
   * @return IDocument result document containing the regions
   * @throws IOException If an error occurs reading the InputStream
   */
  IDocument parse(InputStream in) throws IOException;
  
  /**
   * Parses an InputStream and returns an IDocument, consisting of
   * IRegions.
   * 
   * @param in CharSequence to parse
   * @return IDocument result document containing the regions
   * @throws IOException If an error occurs reading the InputStream
   */
  IDocument parse(CharSequence in);
  
  /**
   * States if this parser parses <em>inverse</em> protected regions.
   * 
   * @return true, if this parser parses <em>inverse</em> protected regions, false otherwise.
   */
  boolean isInverse();
  
  /**
   * Returns ICommentTypes of this parser.
   * 
   * @return
   */
  Iterable<ICommentType> getCommentTypes();
  
  /**
   * Returns ICDataTypes of this parser.
   * @return
   */
  Iterable<ICDataType> getCDataTypes();
  
  /**
   * Denotes comment types (multiline, singleline, nestable).
   */
  static interface ICommentType {
    boolean isMultiline();
    boolean isNestable();
    String getStart();
    /** always null, if singleline comment */
    String getEnd();
  }
  
  /**
   * Denotes character data types (like String literals or Xml's CDATA section).
   */
  static interface ICDataType {
    String getStart();
    String getEnd();
    boolean isEscapable();
    String getEscapeString();
  }
}
