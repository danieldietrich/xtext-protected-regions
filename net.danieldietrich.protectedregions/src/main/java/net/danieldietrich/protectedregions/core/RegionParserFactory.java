package net.danieldietrich.protectedregions.core;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public class RegionParserFactory {

  private RegionParserFactory() {
  }

  // Clojure
  public static IRegionParser createClojureParser() {
    return createClojureParser(null, false);
  }

  public static IRegionParser createClojureParser(boolean inverse) {
    return createClojureParser(null, inverse);
  }

  public static IRegionParser createClojureParser(IRegionOracle oracle, boolean inverse) {
    return new RegionParserBuilder().name("clojure").addComment(";")/* TODO(@@dd):.ignore(...) */.setInverse(
        inverse).useOracle(oracle).build();
  }

  // Java
  public static IRegionParser createJavaParser() {
    return createJavaParser(null, false);
  }

  public static IRegionParser createJavaParser(boolean inverse) {
    return createJavaParser(null, inverse);
  }

  public static IRegionParser createJavaParser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("java").addComment("/*", "*/").addComment("//").ignoreCData('"', '\\')
        .setInverse(mergeStyle).useOracle(oracle).build();
  }

  // Ruby
  public static IRegionParser createRubyParser() {
    return createClojureParser(null, false);
  }

  public static IRegionParser createRubyParser(boolean inverse) {
    return createRubyParser(null, inverse);
  }

  public static IRegionParser createRubyParser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("ruby").addComment("#")/* TODO(@@dd):.ignore(...) */.setInverse(
        mergeStyle).useOracle(oracle).build();
  }

  // Scala
  public static IRegionParser createScalaParser() {
    return createScalaParser(null, false);
  }

  public static IRegionParser createScalaParser(boolean inverse) {
    return createScalaParser(null, inverse);
  }

  public static IRegionParser createScalaParser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("scala").addNestableComment("/*", "*/").addComment("//")
        /*TODO(@@dd):.ignore(...)*/.setInverse(mergeStyle).useOracle(oracle).build();
  }

  // Xml
  public static IRegionParser createXmlParser() {
    return createXmlParser(null, false);
  }

  public static IRegionParser createXmlParser(boolean inverse) {
    return createXmlParser(null, inverse);
  }

  public static IRegionParser createXmlParser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("xml").addComment("<!--", "-->").ignoreCData("<![CDATA[", "]]>")
        .setInverse(mergeStyle).useOracle(oracle).build();
  }

  // Xtend2
  public static IRegionParser createXtend2Parser() {
    return createJavaParser(null, false);
  }

  public static IRegionParser createXtend2Parser(boolean inverse) {
    return createXtend2Parser(null, inverse);
  }

  public static IRegionParser createXtend2Parser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("xtend2").addComment("/*", "*/").addComment("//")/*TODO(@@dd):.ignore(...)*/
        .setInverse(mergeStyle).useOracle(oracle).build();
  }

  // Xtext
  public static IRegionParser createXtextParser() {
    return createJavaParser(null, false);
  }

  public static IRegionParser createXtextParser(boolean inverse) {
    return createXtextParser(null, inverse);
  }

  public static IRegionParser createXtextParser(IRegionOracle oracle, boolean mergeStyle) {
    return new RegionParserBuilder().name("xtext").addComment("/*", "*/").addComment("//")/*TODO(@@dd):.ignore(...)*/
        .setInverse(mergeStyle).useOracle(oracle).build();
  }
}
