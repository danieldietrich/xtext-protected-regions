package net.danieldietrich.xtext.generator.protectedregions;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserFactory {

  private static final MergeStyle DEFAULT_MERGE_STYLE = MergeStyle.PROTECTED_REGION;
  private static final boolean DEFAULT_SWITCHABLE = false;
  
  private RegionParserFactory() {
  }

  // Clojure
  public static IRegionParser createDefaultClojureParser() {
    return createClojureParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createClojureParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment(";")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

  // Java
  public static IRegionParser createDefaultJavaParser() {
    return createJavaParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createJavaParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

  // Ruby
  public static IRegionParser createDefaultRubyParser() {
    return createClojureParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createRubyParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("#")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

  // Scala
  public static IRegionParser createDefaultScalaParser() {
    return createScalaParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createScalaParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addNestableComment("/*", "*/").addComment("//")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

  // Xml
  public static IRegionParser createDefaultXmlParser() {
    return createXmlParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXmlParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("<!--", "-->")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }
  
  // Xtend2
  public static IRegionParser createDefaultXtend2Parser() {
    return createJavaParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXtend2Parser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

  // Xtext
  public static IRegionParser createDefaultXtextParser() {
    return createJavaParser(DEFAULT_MERGE_STYLE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXtextParser(MergeStyle mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setMergeStyle(mergeStyle).setSwitchable(switchable).build();
  }

}
