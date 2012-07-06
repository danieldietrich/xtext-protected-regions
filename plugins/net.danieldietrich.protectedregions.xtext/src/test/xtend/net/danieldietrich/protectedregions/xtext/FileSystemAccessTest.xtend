package net.danieldietrich.protectedregions.xtext

import static org.junit.Assert.*

import net.danieldietrich.protectedregions.ModelBuilder
import net.danieldietrich.protectedregions.ParserFactory

import org.junit.Before
import org.junit.Test
import net.danieldietrich.protectedregions.ProtectedRegionSupport

class FileSystemAccessTest {

	extension ModelBuilder modelBuilder = new ModelBuilder
	extension ParserFactory parserFactory = new ParserFactory
	
	val fsa = new ProtectedRegionInMemoryFileSystemAccess[outputName, file | 'UTF-8']
	
	val cssParser = parser("css")[
			model[
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	val htmlParser = xmlParser()
	val javaParser = javaParser()
	val jsParser = parser("java")[
			model[
				comment("//")
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	val phpParser = parser("php")[
			model[
				comment("//")
				comment("/*", "*/")
				comment("#")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	val xmlParser = xmlParser()
	
	@Before
	def void setup() {
		
	}

	@Test
	def void mergeOfMultilanguageFilesShouldMatchExpected() {

		/*
		 * css has escaped double quotes in strings, html/xml not. that's currently not considered here
		 * when combining parsers(!)
		 */
		val support = new ProtectedRegionSupport()
		support.addParser(htmlParser, ".html")
		support.addParser(phpParser, ".html")
		support.addParser(jsParser, ".html")
		support.addParser(cssParser, ".html")

//		// create FileSystemAccess, which reads protected regions when calling setOuputPath(...)
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new EndsWithFilter("multilang_previous.html"))
//		fsa.setOutputPath("src/test/resources")
//
//		// start generator (writing via fsa.generateFile(...))
//		testGenerator.doGenerate("src/test/resources/multilang_current.html", fsa)
//
//		// test results
//		String mergedContents = fsa.getSingleResult()
//		String expectedContents =
//				IOUtil.toString(new FileReader("src/test/resources/multilang_expected.html"))
//
//		assertEquals(expectedContents, mergedContents)
	}


}

//	@Test
//	public void nonUniqueIdsShouldBeGloballyDetected() throws Exception {
//
//		IProtectedRegionSupport support = new ProtectedRegionSupport()
//		support.addParser(javaParser, ".java")
//
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new PatternFilter(".*\\/duplicate_id_\\d.java"))
//
//		try {
//			fsa.setOutputPath("src/test/resources")
//			assertTrue("Duplicate id not recognized", false)
//		} catch (IllegalStateException x) {
//			assertTrue("Other exception catched as expected: "+ x.getMessage(),
//					"Duplicate protected region id: 'duplicate'. Protected region ids have to be globally unique."
//							.equals(x.getMessage()))
//		}
//	}
//
//	@Test
//	public void protectedRegionStartInStringLiteralShouldBeIgnored() throws Exception {
//
//		IProtectedRegionSupport support = new ProtectedRegionSupport()
//		support.addParser(javaParser, ".java")
//
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new EndsWithFilter("string_literals_ignore_start.java"))
//
//		try {
//			fsa.setOutputPath("src/test/resources")
//		} catch (IllegalStateException x) {
//			assertTrue("Protected region start in string literal not ignored. Original message: "
//					+ x.getMessage(), false)
//		}
//	}
//
//	@Test
//	public void protectedRegionEndInStringLiteralShouldBeIgnored() throws Exception {
//
//		IProtectedRegionSupport support = new ProtectedRegionSupport()
//		support.addParser(javaParser, ".java")
//
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new EndsWithFilter("string_literals_ignore_end.java"))
//
//		try {
//			fsa.setOutputPath("src/test/resources")
//		} catch (IllegalStateException x) {
//			assertTrue("Protected region end in string literal not ignored. Original message: "
//					+ x.getMessage(), false)
//		}
//	}
//
//	@Test
//	public void protectedRegionStartInXmlCDATAShouldBeIgnored() throws Exception {
//
//		IProtectedRegionSupport support = new ProtectedRegionSupport()
//		support.addParser(xmlParser, ".xml")
//
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new EndsWithFilter("string_literals_ignore_cdata.xml"))
//
//		try {
//			fsa.setOutputPath("src/test/resources")
//		} catch (IllegalStateException x) {
//			assertTrue("Protected region end in xml CDATA not ignored. Original message: "
//					+ x.getMessage(), false)
//		}
//	}
//
//	@Test
//	public void commentsInStringLiteralsShouldBeIgnored() throws URISyntaxException {
//
//		IProtectedRegionSupport support = new ProtectedRegionSupport()
//		support.addParser(javaParser, ".java")
//
//		TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//		fsa.setFilter(new EndsWithFilter("string_literals_ignore_comments.java"))
//
//		try {
//			fsa.setOutputPath("src/test/resources")
//		} catch (IllegalStateException x) {
//			assertTrue(
//					"Comments in string literals are not ignored. Original message: "+ x.getMessage(), false)
//		}
//	}
//	
//	@Test
//	public void ensureStringLiteralsParsedCorrectly() {
//		
//	IProtectedRegionSupport support = new ProtectedRegionSupport()
//	support.addParser(javaParser, ".java")
//	
//	TestableBidiJavaIoFileSystemAccess fsa = new TestableBidiJavaIoFileSystemAccess(support)
//	fsa.setFilter(new EndsWithFilter("ensure_str_literals_parsed_correctly.java"))
//	
//	fsa.setOutputPath("src/test/resources")
//	}

//
//	/**
//	 * Filter checking if a path ends with a name.
//	 */
//	static class EndsWithFilter implements IPathFilter {
//
//		private String name
//
//		EndsWithFilter(String name) {
//			this.name = name
//		}
//
//		//@Override
//		public boolean accept(URI path) {
//			return path.getPath().endsWith(name)
//		}
//	}
//
//	/**
//	 * Filter checking if a pattern matches a path.
//	 */
//	static class PatternFilter implements IPathFilter {
//
//		private final Pattern pattern
//
//		PatternFilter(String pattern) {
//			this.pattern = Pattern.compile(pattern)
//		}
//
//		//@Override
//		public boolean accept(URI path) {
//			return pattern.matcher(path.getPath()).matches()
//		}
//	}
