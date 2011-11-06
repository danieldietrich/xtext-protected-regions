package net.danieldietrich.protectedregions.core;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import net.danieldietrich.protectedregions.core.IRegionParser.ICDataType;
import net.danieldietrich.protectedregions.core.IRegionParser.ICommentType;

/**
 * IRegionParser Builder, hiding the implementing class from the outside.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserBuilder {

  private final List<ICommentType> commentTypes = new ArrayList<ICommentType>();
  private final List<ICDataType> cdataTypes = new ArrayList<ICDataType>();

  private String name = "unnamed";
  private IRegionOracle oracle = null;
  private boolean inverse = false;

  public RegionParserBuilder name(String name) {
    this.name = name;
    return this;
  }
  
  /**
   * Add multiline comment.
   * 
   * @param start Start String of comment
   * @param end End String of comment
   * @return this
   */
  public RegionParserBuilder addComment(String start, String end) {
    commentTypes.add(new CommentType(start, end, CommentType.Style.MULTILINE));
    return this;
  }

  /**
   * Add nestable multiline comment.
   * 
   * @param start
   * @param end
   * @return this
   */
  public RegionParserBuilder addNestableComment(String start, String end) {
    commentTypes.add(new CommentType(start, end, CommentType.Style.MULTILINE_NESTABLE));
    return this;
  }

  /**
   * Add singleline comment. A singleline comment ends with the end of a line, namely newline '\n',
   * '\r\n', '\r' or EOF.
   * 
   * @param start Start String of comment
   * @return this
   */
  public RegionParserBuilder addComment(String start) {
    commentTypes.add(new CommentType(start, null, CommentType.Style.SINGLELINE));
    return this;
  }

  /**
   * Tells the parser to ignore character data (e.g. comments) surrounded by a given delimiter. The
   * delimiter is not allowed to occur within the character data. Example: String literals like
   * <code>"/*no comment*"</code>.
   * 
   * @param delimiter
   * @return
   */
  public RegionParserBuilder ignoreCData(char delimiter) {
    cdataTypes.add(new CDataType(String.valueOf(delimiter), String.valueOf(delimiter), null));
    return this;
  }

  /**
   * Tells the parser to ignore character data (e.g. comments) surrounded by given delimiter,
   * allowing the delimiter to occur within the character sequence. Example: String literals like
   * <code>"\"/*no comment*&#47;\""</code>.
   * 
   * @param delimiter
   * @param escapeCharacter
   * @return
   */
  public RegionParserBuilder ignoreCData(char delimiter, char escapeCharacter) {
    cdataTypes.add(new CDataType(String.valueOf(delimiter), String.valueOf(delimiter), String.valueOf(escapeCharacter)));
    return this;
  }

  /**
   * Tells the parser to ignore character data (e.g. comments) surrounded by given start and end
   * strings. Example: String literals like <code>&lt;![CDATA[&lt;!-- no comment -->]]></code>.
   * 
   * @param start
   * @param end
   * @return
   */
  public RegionParserBuilder ignoreCData(String start, String end) {
    cdataTypes.add(new CDataType(start, end, null));
    return this;
  }

  /**
   * The parser asks the IRegionOracle if comments are valid marked region starts/ends.
   * 
   * @param oracle A specific IRegionOracle
   */
  public RegionParserBuilder useOracle(IRegionOracle oracle) {
    this.oracle = oracle;
    return this;
  }

  public RegionParserBuilder setInverse(boolean inverse) {
    this.inverse = inverse;
    return this;
  }

  public IRegionParser build() {
    if (oracle == null) {
      oracle = new DefaultOracle(inverse);
    }
    IRegionParser result = new DefaultRegionParser(name, commentTypes, cdataTypes, oracle, inverse);
    return result;
  }

  /**
   * Class for encapsulating comment information:
   * <ul>
   *   <li>Start String, e.g. &#47;*</li>
   *   <li>End String, e.g. *&#47;</li>
   *   <li>Style, e.g. MULTILINE</li>
   * </ul>
   */
  private static class CommentType implements ICommentType {

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

    //@Override
    public boolean isMultiline() {
      return !Style.SINGLELINE.equals(style); // null case included
    }

    //@Override
    public boolean isNestable() {
      return Style.MULTILINE_NESTABLE.equals(style); // null case included
    }

    //@Override
    public String getStart() {
      return start;
    }

    //@Override
    public String getEnd() {
      return end;
    }
  }
  
  /**
   * Class for encapsulating character data information:
   * <ul>
   *   <li>Start String, e.g. <code>"</code></li>
   *   <li>End String, e.g. <code>"</code></li>
   *   <li>Escape String, <code>\"</code></li>
   * </ul>
   */
  private static class CDataType implements ICDataType {

    final String start;
    final String end;
    final String escapeString;
    
    CDataType(String start, String end, String escapeString) {
      this.start = start;
      this.end = end;
      this.escapeString = escapeString;
    }
    
    //@Override
    public String getStart() {
      return start;
    }

    //@Override
    public String getEnd() {
      return end;
    }
    
    //@Override
    public String getEscapeString() {
      return escapeString;
    }
    
    //@Override
    public boolean isEscapable() {
      return escapeString != null;
    }
  }

  /**
   * Default IRegionOracle
   */
  private static class DefaultOracle implements IRegionOracle {

    private static final String ID = "([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*";

    private Pattern start;
    private Pattern end;

    DefaultOracle(boolean inverse) {
      String label = inverse ? "GENERATED" : "PROTECTED\\s+REGION";
      start =
          Pattern.compile("\\s*" + label + "\\s+ID\\s*\\(\\s*" + ID
              + "\\s*\\)\\s+(ENABLED\\s+)?START\\s*");
      end = Pattern.compile("\\s*" + label + "\\s+END\\s*");
    }

    //@Override
    public boolean isMarkedRegionStart(String s) {
      return start.matcher(s).matches();
    }

    //@Override
    public boolean isMarkedRegionEnd(String s) {
      return end.matcher(s).matches();
    }

    //@Override
    public String getId(String markedRegionStart) {
      int i = markedRegionStart.indexOf("(");
      int j = i + 1 + markedRegionStart.substring(i + 1).indexOf(")");
      return (i != -1 && j != -1) ? markedRegionStart.substring(i + 1, j).trim() : null;
    }

    //@Override
    public boolean isEnabled(String markedRegionStart) {
      return markedRegionStart.contains("ENABLED");
    }
  }
}
