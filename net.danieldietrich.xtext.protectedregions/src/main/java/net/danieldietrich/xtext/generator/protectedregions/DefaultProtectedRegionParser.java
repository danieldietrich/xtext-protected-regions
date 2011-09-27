package net.danieldietrich.xtext.generator.protectedregions;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import net.danieldietrich.xtext.generator.protectedregions.IDocument.IRegion;

import org.apache.commons.io.IOUtils;

/**
 * Parses InputStream, returning an IDocument which consists of IRegions.
 * <ul>
 *   <li>Each IRegion is either protected or non-protected.</li>
 *   <li>Protected and non-protected regions are alternating.</li>
 *   <li>The protected region start and end comments are not protected, but(!)
 * the protected region end comment indentation may not be restored
 * because all characters within the protected region, including white space, are
 * preserved (=> works as designed).</li>
 * <br>
 * @author Daniel Dietrich - Initial contribution and API
 */
public class DefaultProtectedRegionParser implements IProtectedRegionParser {
 
  /**
   *  CAUTION: the order of this new line strings is sufficient, by the following means:<br>
   * For all end of line flavors there is an order defined as follows:<br>
   * s_i.contains(s_j) => i < j, for all i,j where i != j.<br>
   * (The first match wins, see {@link #getSinglelineComment(ParserContext, CommentOccurrence))
   */
  private static final String[] END_OF_LINE_FLAVORS = new String[] { "\r\n", "\n", "\r",  };
  
  private List<CommentType> commentTypes = new ArrayList<CommentType>();
  private IProtectedRegionOracle oracle;
  
  @Override
  public DefaultProtectedRegionParser addComment(String start, String end) {
    commentTypes.add(new CommentType(start, end, CommentType.Style.MULTILINE));
    return this;
  }

  @Override
  public DefaultProtectedRegionParser addNestableComment(String start, String end) {
    commentTypes.add(new CommentType(start, end, CommentType.Style.MULTILINE_NESTABLE));
    return this;
  }

  @Override
  public DefaultProtectedRegionParser addComment(String start) {
    commentTypes.add(new CommentType(start, null, CommentType.Style.SINGLELINE));
    return this;
  }

  @Override
  public DefaultProtectedRegionParser setOracle(IProtectedRegionOracle oracle) {
    this.oracle = oracle;
    return this;
  }

  /**
   * @see #parse(CharSequence)
   */
  @Override
  public IDocument parse(InputStream in) throws IOException {
    return parse(IOUtils.toString(in));
  }
  
  /**
   * This implementation first reads the whole InputStream.
   * Then the document is read region by region until
   * no more regions exist.<br>
   * <br>
   * Reading the whole document before parsing it is very
   * performant. Index based parsers are able to search
   * the next token with n operations, where n = number of
   * different comment flavors. Then the complexity
   * < O(r*n), where r = number of regions (= small number).<br>
   * <br>
   * Note: If the stream would be interpreted char by char,
   * with every read operation the occurrence of a comment
   * flavor has to be testet. With m characters in the stream
   * and n comment flavors this would be a complexity
   * of O(n*m), where m is a great number compared to the number
   * of regions (one can count factor 1000).
   * 
   * @see #getNextRegion(Input)
   */
  @Override
  public IDocument parse(CharSequence in) {
    
    DefaultDocument result = new DefaultDocument();
    Input input = new Input(in.toString());
    
    // subsequentially read regions until end of input reached
    while (!input.endOfDocumentReached()) {
      result.addRegion(getNextRegion(input));
    }
    
    // consider buffered input
    if (input.hasRemaining()) {
      result.addRegion(remainingRegion(input));
    }
    
    return result;
  }
  
  /**
   * Try to find the nearest occurrence of a start character sequence
   * of one of the comments configured with this ProtectedRegionParser.
   * If there are no more comments, return the last Region (i.e. the remaining input).
   * If there is another comment, then read the next region accordingly to
   * the type of the comment (singleline, multiline etc.).
   * 
   * @param input
   * @return
   */
  private IRegion getNextRegion(Input input) {
    
    // find protected region start/end
    String comment;
    boolean stateChanged;
    boolean isProtectedRegionStart;
    boolean isProtectedRegionEnd;
    
    // read input until protected region is entered, leaved or eof reached
    do {
      
      /*
       * Find next comment start,
       * not necessarily a protected region start/end
       * - this will be tested later.
       */
      CommentType type = getNextCommentType(input);
      
      // no more comments => last region found (a non-protected one)
      if (type == null) {
        return remainingRegion(input);
      }

      // deal with different comment styles
      switch (type.style) {
        case MULTILINE : {
          comment = getMultilineComment(input, type);
          break;
        }
        case MULTILINE_NESTABLE : {
          comment = getMultilineNestableComment(input, type);
          break;
        }
        case SINGLELINE : {
          comment = getSinglelineComment(input, type);
          break;
        }
        default : throw new IllegalStateException("Unknown comment type style: " + type.style);
      }
      
      isProtectedRegionStart = oracle.isProtectedRegionStart(comment);
      isProtectedRegionEnd = oracle.isProtectedRegionEnd(comment);
      stateChanged = (!input.isProtectedRegion() && isProtectedRegionStart)
          || (input.isProtectedRegion() && isProtectedRegionEnd);
      
    } while (/*comment != null && */!stateChanged);
    
    // finished, if no more comments or no protected regions entered/leaved
    if (/*comment == null || */!stateChanged) {
      return remainingRegion(input);
    }
      
    // comment != null && state changed => current comment is a protected region start or end
    if (isProtectedRegionStart) {
      String id = oracle.getId(comment);
      String text = input.enterProtectedRegion(id);
      return new Region(text);
    } else if (isProtectedRegionEnd) {
      String id = input.getProtectedRegionId();
      String text = input.leaveProtectedRegion();
      return new Region(id, text);
    } else {
      throw new IllegalStateException("tertium non datur");
    }
  }
  
  /**
   * Get the remaining text of input,
   * performing sanity checks.
   * 
   * @param input
   * @return
   */
  private IRegion remainingRegion(Input input) {
    if (input.isProtectedRegion()) {
      throw new IllegalStateException("Protected region does not end properly.");
    } else {
      return new Region(input.remaining());
    }
  }
  
  /**
   * Gathers information about the next occurrence of a comment
   * (added via one of the #addComment() methods). The information
   * is not sufficient to tell if it is a protected region
   * start/end. This information will be parsed later.
   * 
   * @param input
   * @return
   */
  private CommentType getNextCommentType(Input input) {
    CommentType result = null;
    int lowestIndex = Integer.MAX_VALUE;
    for (CommentType commentType : commentTypes) {
      int i = input.indexOf(commentType.start);
      if (i != -1 && i < lowestIndex) { // the first match wins, because of '<'
        lowestIndex = i;
        result = commentType;
      }
    }
    if (result == null) {
      input.setCommentStart(-1); // undefined
      return null;
    } else {
      input.setCommentStart(lowestIndex);
      input.update(lowestIndex, result.start.length());
      return result;
    }
  }
  
  /**
   * Read the content of a multiline comment (not supporting nested comments).
   * 
   * @param input
   * @param type
   * @return
   */
  private String getMultilineComment(Input input, CommentType type) {
    int i = input.indexOf(type.end);
    if (i == -1) {
      throw new IllegalArgumentException("Comment does not end properly: " + input.getStringAtCursor());
    }
    return input.consume(i, type.end.length()); // text between start and end of comment
  }
  
  /**
   * Read the content of a multiline comment (supporting nested comments).
   * 
   * @param input
   * @param type
   * @return
   */
  private String getMultilineNestableComment(Input input, CommentType type) {
    StringBuilder result = new StringBuilder();
    int depth = 1;
    int endIndex;
    do {
      int startIndex = input.indexOf(type.start);
      endIndex = input.indexOf(type.end);
      if (startIndex != -1 && startIndex < endIndex) {
        depth++;
        // nested comment start strings are part of the comment
        String part = input.consume(startIndex + type.start.length(), 0);
        result.append(part);
      } else if (endIndex != -1) {
        depth--;
        String part;
        if (depth == 0) {
          // omit last comment end string
          part = input.consume(endIndex, type.end.length());
        } else {
          // nested comment end strings are part of the comment
          part = input.consume(endIndex + type.end.length(), 0);
        }
        result.append(part);
      } else {
        throw new IllegalArgumentException("Comment does not end properly: " + input.getStringAtCursor());
      }
    } while(depth > 0);
    return result.toString();
  }
  
  /**
   * Read the content of a singleline comment.
   * 
   * @param input
   * @param type
   * @return
   */
  private String getSinglelineComment(Input input, CommentType type) {
    String eol = null;
    int lowestIndex = Integer.MAX_VALUE;
    for (String currentEol : END_OF_LINE_FLAVORS) {
      int i = input.indexOf(currentEol);
      if (i != -1 && i < lowestIndex) { // the first match wins, because of '<'
        lowestIndex = i;
        eol = currentEol;
      }
    }
    if (eol == null) {
      return input.getStringAtCursor(); // EOF reached, reading all.
    } else {
      return input.consume(lowestIndex, eol.length());
    }
  }
  
  // --- The following helper classes contain only data
  // --- and are helping to unclutter the code and make
  // --- it more readable.
  
  /**
   * Class for encapsulating comment information:
   * <ul>
   *   <li>Start String, e.g. &#47;*</li>
   *   <li>End String, e.g. *&#47;</li>
   *   <li>Style, e.g. MULTILINE</li>
   * </ul>
   */
  private static class CommentType {
    
    final String start;
    final String end;
    final Style style;
    
    CommentType(String start, String end, Style style) {
      this.start = start;
      this.end = end;
      this.style = style;
    }
    
    /** Different comment styles/flavors. */
    static enum Style {
      MULTILINE, MULTILINE_NESTABLE, SINGLELINE
    }
  }
  
  /**
   * Encapsulating the parser input read while parsing.
   * In particular there is no business logic.<br>
   * <br>
   * Invariant: 0 <= marker <= cursor <= document.length()
   */
  private static class Input {
    
    final String document;
    String protectedRegionId;
    int marker = 0;
    int index = 0;
    
    // Take care of comment starts because of protected region end comments,
    // which are not part of protected regions.
    int commentStart;
    
    // read InputStream into String
    Input(String document) {
      this.document = document;
    }
    
    // cursor reached end?
    boolean endOfDocumentReached() {
      return index >= document.length();
    }
    
    // all characters read (i.e. marker reached end)?
    boolean hasRemaining() {
      return marker < document.length();
    }
    
    // read rest of document, starting at marker position
    String remaining() {
      String result = document.substring(marker);
      marker = document.length();
      index = marker; // consumed all
      return result;
    }
    
    // read rest of document, starting at cursor position
    String getStringAtCursor() {
      return document.substring(index);
    }
    
    // read document part, moving cursor
    String consume(int endIndex, int additionalChars) {
      String result = document.substring(index, endIndex);
      index = endIndex + additionalChars;
      return result;
    }
    
    // move cursor
    void update(int endIndex, int additionalChars) {
      index = endIndex + additionalChars;
    }
    
    // index of a substring, starting at current cursor position
    int indexOf(String substring) {
      return document.indexOf(substring, index);
    }
    
    // entering protected region => remembering id and returning previous region
    String enterProtectedRegion(String id) {
      protectedRegionId = id;
      String result = document.substring(marker, index);
      marker = index;
      return result;
    }
    
    // leaving protected region => clearing id and returning previous region
    String leaveProtectedRegion() {
      protectedRegionId = null;
      String result = document.substring(marker, commentStart); // protected region end comment not part of protected region
      marker = commentStart; // protected region end comment part of next (non-protected) region
      return result;
    }
    
    // marker currently within protected region? (cursor may be outside)
    boolean isProtectedRegion() {
      return protectedRegionId != null;
    }
    
    // get protected region id (null, if isProtectedRegion() == false)
    String getProtectedRegionId() {
      return protectedRegionId;
    }
    
    void setCommentStart(int index) {
      commentStart = index;
    }
  }
  
  /**
   * A default implementation of IDocument.IRegion, returned by the
   * #parse(InputStream) method and needed to merge documents
   * (@see ProtectedRegionUtil#merge(IDocument, IDocument)).
   */
  private static class Region implements IRegion {
    
    final String id;
    final String text;
    
    Region(String text) {
      this(null, text);
    }
    
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
