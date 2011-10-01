package net.danieldietrich.protectedregions.core;

import java.io.IOException;
import java.io.InputStream;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IRegionParser {

  /**
   * Add multiline comment.
   * 
   * @param start Start String of comment
   * @param end End String of comment
   */
  void addComment(String start, String end);
  
  /**
   * Add nestable multiline comment.
   * 
   * @param start
   * @param end
   */
  void addNestableComment(String start, String end);

  /**
   * Add singleline comment. A singleline comment ends with the
   * end of a line, namely newline '\n', '\r\n', '\r' or EOF.
   * 
   * @param start Start String of comment
   */
  void addComment(String start);
  
  /**
   * The parser asks the IRegionOracle if comments
   * are valid marked region starts/ends.
   * 
   * @param oracle A specific IRegionOracle
   */
  void setOracle(IRegionOracle oracle);
  
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
}