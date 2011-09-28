package net.danieldietrich.xtext.generator.protectedregions;

import java.io.IOException;
import java.io.InputStream;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface IProtectedRegionParser {

  /**
   * Add multiline comment.
   * 
   * @param start Start String of comment
   * @param end End String of comment
   * @return this
   */
  IProtectedRegionParser addComment(String start, String end);
  
  /**
   * Add nestable multiline comment.
   * 
   * @param start
   * @param end
   * @return
   */
  IProtectedRegionParser addNestableComment(String start, String end);

  /**
   * Add singleline comment. A singleline comment ends with the
   * end of a line, namely newline '\n', '\r\n', '\r' or EOF.
   * 
   * @param start Start String of comment
   * @return this
   */
  IProtectedRegionParser addComment(String start);
  
  /**
   * The parser asks the IProtectedRegionOracle if comments
   * are valid protected region starts/ends.
   * 
   * @param oracle A specific IProtectedRegionOracle
   * @return this
   */
  IProtectedRegionParser setOracle(IProtectedRegionOracle oracle);
  
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
  
}
