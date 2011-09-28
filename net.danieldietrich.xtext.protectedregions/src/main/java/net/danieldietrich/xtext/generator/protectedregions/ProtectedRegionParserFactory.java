package net.danieldietrich.xtext.generator.protectedregions;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class ProtectedRegionParserFactory {

  private static IProtectedRegionOracle defaultOracle = null;
  
  private ProtectedRegionParserFactory() {
  }
  
  // Clojure
  public static IProtectedRegionParser createDefaultClojureParser() {
    return createClojureParser(getDefaultOracle());
  }
  public static IProtectedRegionParser createClojureParser(IProtectedRegionOracle oracle) {
    return new DefaultProtectedRegionParser()
      .addComment(";")
      .setOracle(oracle);
  }

  // Java
  public static IProtectedRegionParser createDefaultJavaParser() {
    return createJavaParser(getDefaultOracle());
  }
  public static IProtectedRegionParser createJavaParser(IProtectedRegionOracle oracle) {
    return new DefaultProtectedRegionParser()
      .addComment("/*", "*/")
      .addComment("//")
      .setOracle(oracle);
  }
  
  // Ruby
  public static IProtectedRegionParser createDefaultRubyParser() {
    return createClojureParser(getDefaultOracle());
  }
  public static IProtectedRegionParser createRubyParser(IProtectedRegionOracle oracle) {
    return new DefaultProtectedRegionParser()
      .addComment("#")
      .setOracle(oracle);
  }
  
  // Scala
  public static IProtectedRegionParser createDefaultScalaParser() {
    return createScalaParser(getDefaultOracle());
  }
  public static IProtectedRegionParser createScalaParser(IProtectedRegionOracle oracle) {
    return new DefaultProtectedRegionParser()
      .addNestableComment("/*", "*/")
      .addComment("//")
      .setOracle(oracle);
  }
  
  // Xml
  public static IProtectedRegionParser createDefaultXmlParser() {
    return createXmlParser(getDefaultOracle());
  }
  public static IProtectedRegionParser createXmlParser(IProtectedRegionOracle oracle) {
    return new DefaultProtectedRegionParser()
      .addComment("<!--", "-->")
      .setOracle(oracle);
  }
  
  private static IProtectedRegionOracle getDefaultOracle() {
    if (defaultOracle == null) {
      defaultOracle = new DefaultProtectedRegionOracle();
    }
    return defaultOracle;
  }

}
