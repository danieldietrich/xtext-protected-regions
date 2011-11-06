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
		return new RegionParserBuilder().name("clojure").addComment(";").ignoreCData('"', '\\').setInverse(inverse)
				.useOracle(oracle).build();
	}

	// CSS
	public static IRegionParser createCssParser() {
		return createCssParser(null, false);
	}

	public static IRegionParser createCssParser(boolean inverse) {
		return createCssParser(null, inverse);
	}

	public static IRegionParser createCssParser(IRegionOracle oracle, boolean inverse) {
		return new RegionParserBuilder().name("css").addComment("/*", "*/").ignoreCData('"', '\\').setInverse(inverse)
				.useOracle(oracle).build();
	}

	// HTML
	public static IRegionParser createHtmlParser() {
		return createHtmlParser(null, false);
	}

	public static IRegionParser createHtmlParser(boolean inverse) {
		return createHtmlParser(null, inverse);
	}

	public static IRegionParser createHtmlParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("html").addComment("<!--", "-->").ignoreCData("<![CDATA[", "]]>")
				.ignoreCData('"').ignoreCData('\'').setInverse(mergeStyle).useOracle(oracle).build();
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
				.ignoreCData('\'', '\\').setInverse(mergeStyle).useOracle(oracle).build();
	}

	// JavaScript
	public static IRegionParser createJavaScriptParser() {
		return createJavaScriptParser(null, false);
	}

	public static IRegionParser createJavaScriptParser(boolean inverse) {
		return createJavaScriptParser(null, inverse);
	}

	public static IRegionParser createJavaScriptParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("js").addComment("/*", "*/").addComment("//").ignoreCData('"', '\\')
				.ignoreCData('\'', '\\').setInverse(mergeStyle).useOracle(oracle).build();
	}

	// PHP
	public static IRegionParser createPhpParser() {
		return createPhpParser(null, false);
	}

	public static IRegionParser createPhpParser(boolean inverse) {
		return createPhpParser(null, inverse);
	}

	public static IRegionParser createPhpParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("php").addComment("/*", "*/").addComment("//").addComment("#")
				.ignoreCData('"', '\\').ignoreCData('\'', '\\').setInverse(mergeStyle).useOracle(oracle).build();
	}

	// Ruby
	public static IRegionParser createRubyParser() {
		return createClojureParser(null, false);
	}

	public static IRegionParser createRubyParser(boolean inverse) {
		return createRubyParser(null, inverse);
	}

	public static IRegionParser createRubyParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("ruby").addComment("#").ignoreCData('"', '\\').ignoreCData('\'', '\\')
				.setInverse(mergeStyle).useOracle(oracle).build();
	}

	// Scala 2.8+ (supporting raw strings)
	public static IRegionParser createScalaParser() {
		return createScalaParser(null, false);
	}

	public static IRegionParser createScalaParser(boolean inverse) {
		return createScalaParser(null, inverse);
	}

	public static IRegionParser createScalaParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("scala").addNestableComment("/*", "*/").addComment("//")
				.ignoreCData("\"\"\"", "\"\"\"").ignoreCData('"', '\\').ignoreCData('\'', '\\').setInverse(mergeStyle)
				.useOracle(oracle).build();
	}

	// XML
	public static IRegionParser createXmlParser() {
		return createXmlParser(null, false);
	}

	public static IRegionParser createXmlParser(boolean inverse) {
		return createXmlParser(null, inverse);
	}

	public static IRegionParser createXmlParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("xml").addComment("<!--", "-->").ignoreCData("<![CDATA[", "]]>").ignoreCData('"')
				.ignoreCData('\'').setInverse(mergeStyle).useOracle(oracle).build();
	}

	// Xtend2 (content of rich strings is not parsed)
	public static IRegionParser createXtend2Parser() {
		return createJavaParser(null, false);
	}

	public static IRegionParser createXtend2Parser(boolean inverse) {
		return createXtend2Parser(null, inverse);
	}

	public static IRegionParser createXtend2Parser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("xtend2").addComment("/*", "*/").addComment("//").ignoreCData("'''", "'''")
				.ignoreCData('"', '\\').ignoreCData('\'', '\\').setInverse(mergeStyle).useOracle(oracle).build();
	}

	// Xtext
	public static IRegionParser createXtextParser() {
		return createJavaParser(null, false);
	}

	public static IRegionParser createXtextParser(boolean inverse) {
		return createXtextParser(null, inverse);
	}

	public static IRegionParser createXtextParser(IRegionOracle oracle, boolean mergeStyle) {
		return new RegionParserBuilder().name("xtext").addComment("/*", "*/").addComment("//").ignoreCData('"', '\\')
				.ignoreCData('\'', '\\').setInverse(mergeStyle).useOracle(oracle).build();
	}
}
