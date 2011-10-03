package net.danieldietrich.protectedregions.core;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import net.danieldietrich.protectedregions.core.IRegionParser.ICommentType;

/**
 * IRegionParser Builder, hiding the implementing class from the outside.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserBuilder {
  
  private final List<ICommentType> commentTypes = new ArrayList<ICommentType>();
  
  private IRegionOracle oracle = null;
  private boolean inverse = false;
  
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
   * Add singleline comment. A singleline comment ends with the
   * end of a line, namely newline '\n', '\r\n', '\r' or EOF.
   * 
   * @param start Start String of comment
   * @return this
   */
  public RegionParserBuilder addComment(String start) {
    commentTypes.add(new CommentType(start, null, CommentType.Style.SINGLELINE));
    return this;
  }

  /**
   * The parser asks the IRegionOracle if comments
   * are valid marked region starts/ends.
   * 
   * @param oracle A specific IRegionOracle
   */
  public RegionParserBuilder usingOracle(IRegionOracle oracle) {
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
    IRegionParser result = new DefaultRegionParser(commentTypes, oracle, inverse);
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

    @Override
    public boolean isMultiline() {
      return !Style.SINGLELINE.equals(style); // null case included
    }

    @Override
    public boolean isNestable() {
      return Style.MULTILINE_NESTABLE.equals(style); // null case included
    }

    @Override
    public String getStart() {
      return start;
    }

    @Override
    public String getEnd() {
      return end;
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
      start = Pattern.compile("\\s*" + label + "\\s+ID\\s*\\(\\s*" + ID + "\\s*\\)\\s+(ENABLED\\s+)?START\\s*");
      end = Pattern.compile("\\s*" + label + "\\s+END\\s*");
    }
    
    @Override
    public boolean isMarkedRegionStart(String s) {
      return start.matcher(s).matches();
    }
    
    @Override
    public boolean isMarkedRegionEnd(String s) {
      return end.matcher(s).matches();
    }

    @Override
    public String getId(String markedRegionStart) {
      int i = markedRegionStart.indexOf("(");
      int j = i + 1 + markedRegionStart.substring(i+1).indexOf(")");
      return (i != -1 && j != -1) ? markedRegionStart.substring(i+1, j).trim() : null;
    }

    @Override
    public boolean isEnabled(String markedRegionStart) {
      return markedRegionStart.contains("ENABLED");
    }
  }
}
