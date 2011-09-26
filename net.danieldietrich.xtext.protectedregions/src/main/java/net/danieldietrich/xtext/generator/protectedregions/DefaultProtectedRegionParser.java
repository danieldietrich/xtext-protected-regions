package net.danieldietrich.xtext.generator.protectedregions;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import net.danieldietrich.xtext.generator.protectedregions.IDocument.IRegion;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class DefaultProtectedRegionParser implements IProtectedRegionParser {

  private Map<String, Flavor> flavors = new HashMap<String, Flavor>();;
  private IProtectedRegionOracle oracle;
  
  @Override
  public DefaultProtectedRegionParser setOracle(IProtectedRegionOracle oracle) {
    this.oracle = oracle;
    return this;
  }
  
  // TODO(@@dd): add sanity checks
  @Override
  public DefaultProtectedRegionParser addComment(String start, String end) {
    Flavor flavor = flavors.get(start);
    if (flavor == null) {
      flavors.put(start, new Flavor(start, end, Flavor.Style.MULTILINE)); 
    } else {
      flavor.addEnd(end, Flavor.Style.MULTILINE);
    }
    return this;
  }
  
  // TODO(@@dd): add sanity checks
  @Override
  public DefaultProtectedRegionParser addComment(String start) {
    Flavor flavor = flavors.get(start);
    if (flavor == null) {
      flavor = new Flavor(start, "\n", Flavor.Style.SINGLELINE);
      flavor.addEnd("\r\n", Flavor.Style.SINGLELINE);
      flavor.addEnd("\r", Flavor.Style.SINGLELINE);
      flavors.put(start, flavor);
    } else {
      flavor.addEnd("\n", Flavor.Style.SINGLELINE);
      flavor.addEnd("\r\n", Flavor.Style.SINGLELINE);
      flavor.addEnd("\r", Flavor.Style.SINGLELINE);
    }
    return this;
  }
  
  @Override
  public IDocument parse(InputStream in) throws IOException {
    
    if (flavors.isEmpty()) {
      throw new IllegalStateException("No comment flavors specified.");
    }
    
    if (oracle == null) {
      throw new IllegalStateException("No IProtectedRegionOracle set.");
    }
    
    DefaultDocument result = new DefaultDocument();
    String input = read(in/*, encoding*/); // TODO(@@dd): support character encodings
    Cursor cursor = new Cursor(); // flyweight
    Comment comment = new Comment(); // flyweight
    
    while (true) {
      
      if (!nextStart(input, cursor, comment)) {
        break; // no more comments found - loop finished
      }
      
      if (!nextEnd(input, cursor, comment)) {
        throw new IllegalStateException("current comment does not end properly: " + input.substring(cursor.offset));
      }

      if (!cursor.protectedRegion && oracle.isProtectedRegionStart(comment.content)) {
        String id = oracle.getId(comment.content);
        cursor.recordProtectedRegionStart(input, result, comment, id);
      } else if (cursor.protectedRegion && oracle.isProtectedRegionEnd(comment.content)) {
        cursor.recordProtectedRegionEnd(input, result, comment);
      }
    }
    
    cursor.recordEndOfDocument(input, result, comment);
    
    return result;
    
  }
  
  /**
   * Find next comment start. Searching all comments (added via #addComment(...))
   * and taking the nearest one.
   * 
   * @param document
   * @param cursor
   * @param comment
   * @return
   */
  private boolean nextStart(String document, Cursor cursor, Comment comment) {
    comment.reset();
    boolean found = false;
    for (Flavor flavor : flavors.values()) {
      int i = document.indexOf(flavor.start, cursor.offset);
      if (i != -1 && i < comment.startIndex) {
        comment.flavor = flavor;
        comment.startIndex = i;
        found = true;
      }
    }
    if (found) {
      cursor.offset = comment.startIndex + comment.flavor.start.length();
    }
    return found;
  }
  
  /**
   * Find next comment end. Searching all valid end comments defined for
   * the current start comment.
   * 
   * @param document
   * @param cursor
   * @param comment
   * @return
   */
  private boolean nextEnd(String document, Cursor cursor, Comment comment) {
    Flavor flavor = comment.flavor;
    boolean found = false;
    for (String end : flavor.endings) {
      int i = document.indexOf(end, cursor.offset);
      if (i != -1 && i < comment.endIndex) {
        comment.endIndex = i + end.length();
        comment.end = end;
        found = true;
      }
    }
    if (found) {
      cursor.offset = comment.endIndex;
      int beginIndex = comment.startIndex+flavor.start.length();
      int endIndex = comment.endIndex-comment.end.length();
      comment.content = document.substring(beginIndex, endIndex);
    } else {
      if (isSinglelineComment(flavor) && noNewLineBeforeEOF(document, cursor)) {
        int beginIndex = comment.startIndex+flavor.start.length();
        comment.content = document.substring(beginIndex);
        cursor.offset = document.length();
        found = true;
      }
    }
    return found;
  }
  
  /**
   * A comment has singleline style if one of its endings has single line style.
   * This behavior doesn't collide with multlines because it is used in the case
   * where the input ends within a comment without a newline. If the comment start
   * has an ending with singleline style (which in the normal case ends with a newline),
   * it is ok to treat the comment as closed.
   * 
   * @param flavor
   * @return
   */
  private boolean isSinglelineComment(Flavor flavor) {
    for (String end : flavor.endings) {
      Flavor.Style style = flavor.end2style.get(end);
      if (style == Flavor.Style.SINGLELINE) {
        return true;
      }
    }
    return false;
  }

  /**
   * Check if end of input/file (EOF) reached.
   * 
   * @param document
   * @param cursor
   * @return
   */
  private boolean noNewLineBeforeEOF(String document, Cursor cursor) {
    return document.indexOf("\\n", cursor.offset) == -1 && document.indexOf("\\r", cursor.offset) == -1;
  }
  
  /**
   * Read the contents of an InputStream and returning the corresponding String.
   * @param in
   * @return
   * @throws IOException
   */
  private String read(InputStream in) throws IOException {
    StringBuilder result = new StringBuilder();
    Reader reader = new InputStreamReader(in);
    char[] cbuf = new char[4096];
    int len;
    while ((len = reader.read(cbuf)) != -1) {
      if (len == cbuf.length) {
        result.append(cbuf);
      } else {
        result.append(Arrays.copyOfRange(cbuf, 0, len));
      }
    }
    return result.toString();
  }
  
  /**
   * A cursor, pointing to the current position within the input.
   */
  private static class Cursor {
    int offset = 0;
    int lastRegionStartOffset = 0;
    boolean protectedRegion = false;
    String currentId = null;
    void recordProtectedRegionStart(String input, DefaultDocument document, Comment comment, String id) {
      String text = input.substring(lastRegionStartOffset, offset);
      document.addRegion(new Region(null, text));
      currentId = id;
      lastRegionStartOffset = offset;
      protectedRegion = true;
    }
    void recordProtectedRegionEnd(String input, DefaultDocument document, Comment comment) {
      String text = input.substring(lastRegionStartOffset, comment.startIndex);
      document.addRegion(new Region(currentId, text));
      currentId = null;
      lastRegionStartOffset = comment.startIndex;
      protectedRegion = false;
    }
    void recordEndOfDocument(String input, DefaultDocument document, Comment comment) {
      String text = input.substring(lastRegionStartOffset);
      document.addRegion(new Region(currentId, text)); // TODO(@@dd): currentId should be null here(!)
      lastRegionStartOffset = input.length(); // don't necessary because never read
    }
  }
  
  /**
   * Stores comment inportmation.
   */
  private static class Comment {
    Flavor flavor;
    int startIndex;
    int endIndex;
    String end;
    String content;
    void reset() {
      flavor = null;
      startIndex = Integer.MAX_VALUE;
      endIndex = Integer.MAX_VALUE;
      end = null;
      content = null;
    }
  }
  
  /**
   * A specific comment flavor.
   */
  private static class Flavor {
    static enum Style {
      MULTILINE, SINGLELINE
    }
    final String start;
    final List<String> endings; // (read-only!) List provides the right order
    final Map<String,Style> end2style; // (read-only!) Map provides the Styles
    Flavor(String start, String end, Style style) {
      this.start = start;
      this.endings = new ArrayList<String>();
      this.end2style = new HashMap<String, Style>();
      addEnd(end, style);
    }
    void addEnd(String end, Style style) {
      endings.add(end);
      end2style.put(end, style);
    }
  }
  
  /**
   * A default implementation of IDocument.IRegion.
   */
  private static class Region implements IRegion {
    
    final String id;
    final String text;
    
    Region(String id, String text) {
      this.id = id;
      this.text = text;
    }
    
    @Override
    public boolean isProtectedRegion() {
      return id != null;
    }

    @Override
    public String getId() {
      return id;
    }

    @Override
    public String getText() {
      return text;
    }
  }
  
}
