package net.danieldietrich.protectedregions.core;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserFactory {

  private static final boolean DEFAULT_INVERSE = false;
  private static final boolean DEFAULT_SWITCHABLE = false;
  
  private RegionParserFactory() {
  }

  // Clojure
  public static IRegionParser createDefaultClojureParser() {
    return createClojureParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createClojureParser(boolean inverse, boolean switchable) {
    return new RegionParserBuilder().addComment(";")
        .setInverse(inverse).setSwitchable(switchable).build();
  }

  // Java
  public static IRegionParser createDefaultJavaParser() {
    return createJavaParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createJavaParser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }

  // Ruby
  public static IRegionParser createDefaultRubyParser() {
    return createClojureParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createRubyParser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("#")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }

  // Scala
  public static IRegionParser createDefaultScalaParser() {
    return createScalaParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createScalaParser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addNestableComment("/*", "*/").addComment("//")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }

  // Xml
  public static IRegionParser createDefaultXmlParser() {
    return createXmlParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXmlParser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("<!--", "-->")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }
  
  // Xtend2
  public static IRegionParser createDefaultXtend2Parser() {
    return createJavaParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXtend2Parser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }

  // Xtext
  public static IRegionParser createDefaultXtextParser() {
    return createJavaParser(DEFAULT_INVERSE, DEFAULT_SWITCHABLE);
  }
  public static IRegionParser createXtextParser(boolean mergeStyle, boolean switchable) {
    return new RegionParserBuilder().addComment("/*", "*/").addComment("//")
        .setInverse(mergeStyle).setSwitchable(switchable).build();
  }

}
