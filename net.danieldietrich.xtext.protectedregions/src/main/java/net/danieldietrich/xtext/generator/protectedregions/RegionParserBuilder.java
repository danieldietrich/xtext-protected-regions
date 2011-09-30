package net.danieldietrich.xtext.generator.protectedregions;

import java.util.regex.Pattern;

/**
 * IRegionParser Builder, hiding the implementing class from the outside.
 * 
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserBuilder {
  
  final private DefaultRegionParser parser;
  
  private MergeStyle mergeStyle = MergeStyle.PROTECTED_REGION;
  private boolean switchable = false;
  
  public RegionParserBuilder() {
    parser = new DefaultRegionParser();
  }
  
  public RegionParserBuilder addComment(String start, String end) {
    parser.addComment(start, end);
    return this;
  }
  
  public RegionParserBuilder addNestableComment(String start, String end) {
    parser.addNestableComment(start, end);
    return this;
  }

  public RegionParserBuilder addComment(String start) {
    parser.addComment(start);
    return this;
  }

  public RegionParserBuilder setMergeStyle(MergeStyle mergeStyle) {
    this.mergeStyle = mergeStyle;
    return this;
  }

  public RegionParserBuilder setSwitchable(boolean switchable) {
    this.switchable = switchable;
    return this;
  }

  public IRegionParser build() {
    parser.setOracle(new Oracle(mergeStyle, switchable));
    return parser;
  }
  
  /**
   * Default IRegionOracle
   */
  private static class Oracle implements IRegionOracle {

    private static final String ID = "([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*";
    
    private final boolean switchable;
    
    private Pattern start;
    private Pattern end;
    
    Oracle(MergeStyle mergeStyle, boolean switchable) {
      
      this.switchable = switchable;
      
      String label;
      switch(mergeStyle) {
        case GENERATED_REGION : {
          label = "GENERATED";
          break;
        }
        case PROTECTED_REGION : {
          label = "PROTECTED\\s+REGION";
          break;
        }
        default : {
          throw new IllegalStateException("Unknown merge style: " + mergeStyle);
        }
      }
      
      start = Pattern.compile("\\s*" + label + "\\s+ID\\s*\\(\\s*" + ID + "\\s*\\)\\s+" + (switchable ? "(ENABLED\\s+)?" : "") + "START\\s*");
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
      return switchable ? markedRegionStart.contains("ENABLED") : true;
    }

  }

}
