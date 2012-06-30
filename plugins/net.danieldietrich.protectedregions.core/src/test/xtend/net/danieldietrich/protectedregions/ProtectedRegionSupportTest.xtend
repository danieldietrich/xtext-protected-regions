package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import com.google.common.io.Files
import com.google.inject.Guice

import java.io.File
import java.nio.charset.Charset

import org.junit.Before
import org.junit.Test
import java.rmi.UnexpectedException

/**
 * Note: These test cases access the file system instead of passing
 *       CharSequencesto simulate real parsing conditions.
 */
class ProtectedRegionSupportTest {
	
	extension ParserFactory parserFactory
	extension ProtectedRegionSupport support
	
	static val BASE_DIR = "src/test/resources"
	static val CHARSET = Charset::forName("UTF-8")
	
	@Before
	def void setup() {
		val injector = Guice::createInjector()
		parserFactory = injector.getInstance(typeof(ParserFactory))
		support = injector.getInstance(typeof(ProtectedRegionSupport))
	}
	
	@Test
	def void nonExistingFilesShouldByHandledGracefully() {
		support.merge(new File("does_not_exist"), "")
	}
	
	@Test
	def void mergeShouldMatchExpected() {
		
		val currentFile = "src/test/resources/protected_current.txt".file
		val previousFile = "src/test/resources/protected_previous.txt".file
		val expectedFile = "src/test/resources/protected_expected.txt".file

		// only support files relevant for this test case
		support.addParser(javaParser, previousFile.filter)

		// only read previous content
		support.read(BASE_DIR.file, [CHARSET])
		
		val generatedContent = currentFile.read
		val mergedContent = support.merge(previousFile, generatedContent) // pass previous to use the correct parser
		val expectedContent = expectedFile.read
		
		assertEquals(expectedContent, mergedContent)
		
	}

	@Test
	def void idsShouldBeUniquePerFile() {
		val file = "src/test/resources/non_unique_ids.txt".file
		support.addParser(javaParser, file.filter)
		try {
			support.read(BASE_DIR.file, [CHARSET])
			assertTrue("Duplicate marked region with id 'uniqueId' not detected.", false)
		} catch (IllegalStateException x) {
			assertEquals("Duplicate marked region with id 'uniqueId' detected", x.getMessage());
		}
	}

//	IRegionOracle NESTED_COMMENT_ORACLE = new IRegionOracle() {
//		// example: PROTECTED REGION /*1234*/ START
//		private final Pattern PR_START = Pattern
//				.compile("\\s*PROTECTED\\s+REGION\\s+/\\*\\s*[0-9]+\\s*\\*/\\s+(ENABLED\\s+)?START\\s*");
//		private final Pattern PR_END = Pattern.compile("\\s*PROTECTED\\s+REGION\\s+END\\s*");
//
//		//@Override
//		public boolean isMarkedRegionStart(String comment) {
//			return PR_START.matcher(comment).matches();
//		}
//
//		//@Override
//		public boolean isMarkedRegionEnd(String comment) {
//			return PR_END.matcher(comment).matches();
//		}
//
//		//@Override
//		public String getId(String markedRegionStart) {
//			int i = markedRegionStart.indexOf("/*") + 1;
//			int j = i + 1 + markedRegionStart.substring(i + 1).indexOf("*/");
//			return (i != -1 && j != -1) ? markedRegionStart.substring(i + 1, j).trim() : null;
//		}
//
//		//@Override
//		public boolean isEnabled(String markedRegionStart) {
//			return markedRegionStart.contains("ENABLED");
//		}
//	};
//
//	@Test
//	public void scalaParserShouldReadNestedComments() throws Exception {
//		IRegionParser parser = RegionParserFactory.createScalaParser(NESTED_COMMENT_ORACLE, false);
//		IDocument doc = parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
//		// Scala does not recognize nested comment-like id's
//		assertTrue(doc.getMarkedRegion("1234") != null);
//	}
//
//	@Test
//	public void javaParserShouldntReadNestedComments() throws Exception {
//		try {
//			IRegionParser parser = RegionParserFactory.createJavaParser(NESTED_COMMENT_ORACLE, false);
//			parser.parse(new FileInputStream("src/test/resources/nested_comments.txt"));
//		} catch (IllegalStateException x) {
//			assertTrue(
//					x.getMessage(),
//					"Detected marked region end without corresponding marked region start between (5,7) and (6,1), near [ PROTECTED REGION END]."
//							.equals(x.getMessage()));
//		}
//	}
//
//	@Test
//	public void switchedRegionsParserShouldPreserveEnabledRegionsOnly() throws Exception {
//
//		IDocument currentDoc =
//				javaParser.parse(new FileInputStream("src/test/resources/switched_current.txt"));
//		IDocument previousDoc =
//				javaParser.parse(new FileInputStream("src/test/resources/switched_previous.txt"));
//
//		IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
//		String mergedContents = _merged.getContents();
//		String expectedContents =
//				IOUtil.toString(new FileReader("src/test/resources/switched_expected.txt"));
//
//		assertEquals(expectedContents, mergedContents);
//	}
//
//	IRegionOracle FILL_IN_ORACLE = new IRegionOracle() {
//		// example: GENERATED ID(1234) START
//		private final Pattern PR_START = Pattern
//				.compile("\\s*GENERATED\\s+ID\\s*\\(\\s*[0-9]+\\s*\\)\\s+(DISABLED\\s+)?START\\s*");
//		private final Pattern PR_END = Pattern.compile("\\s*GENERATED\\s+END\\s*");
//
//		//@Override
//		public boolean isMarkedRegionStart(String comment) {
//			return PR_START.matcher(comment).matches();
//		}
//
//		//@Override
//		public boolean isMarkedRegionEnd(String comment) {
//			return PR_END.matcher(comment).matches();
//		}
//
//		//@Override
//		public String getId(String markedRegionStart) {
//			int i = markedRegionStart.indexOf("(");
//			int j = i + 1 + markedRegionStart.substring(i + 1).indexOf(")");
//			return (i != -1 && j != -1) ? markedRegionStart.substring(i + 1, j).trim() : null;
//		}
//
//		//@Override
//		public boolean isEnabled(String markedRegionStart) {
//			return !markedRegionStart.contains("DISABLED");
//		}
//	};
//
//	@Test
//	public void fillInShouldMatchExpected() throws Exception {
//
//		IRegionParser parser = RegionParserFactory.createJavaParser(FILL_IN_ORACLE, false);
//
//		IDocument currentDoc =
//				parser.parse(new FileInputStream("src/test/resources/fill_in_current.txt"));
//		IDocument previousDoc =
//				parser.parse(new FileInputStream("src/test/resources/fill_in_previous.txt"));
//
//		IDocument _merged = RegionUtil.fillIn(currentDoc, previousDoc);
//		String mergedContents = _merged.getContents();
//		String expectedContents =
//				IOUtil.toString(new FileReader("src/test/resources/fill_in_expected.txt"));
//
//		assertEquals(expectedContents, mergedContents);
//	}
//
//	IRegionOracle SIMPLE_ORACLE = new IRegionOracle() {
//		//@Override
//		public boolean isMarkedRegionStart(String s) {
//			String _s = s.trim();
//			return _s.startsWith("$(") && _s.endsWith(")-{");
//		}
//
//		//@Override
//		public boolean isMarkedRegionEnd(String s) {
//			return "}-$".equals(s.trim());
//		}
//
//		//@Override
//		public String getId(String s) {
//			int i = s.indexOf("(");
//			int j = i + 1 + s.substring(i + 1).indexOf(")");
//			return (i != -1 && j != -1) ? s.substring(i + 1, j).trim() : null;
//		}
//
//		//@Override
//		public boolean isEnabled(String s) {
//			return true;
//		}
//	};
//
//	@Test
//	public void alternativeRegionNotationsWorkAsWell() throws Exception {
//
//		IRegionParser parser =
//				new RegionParserBuilder().addComment("/*", "*/").addComment("//").setInverse(false)
//						.useOracle(SIMPLE_ORACLE).build();
//
//		IDocument currentDoc =
//				parser.parse(new FileInputStream("src/test/resources/simple_current.txt"));
//		IDocument previousDoc =
//				parser.parse(new FileInputStream("src/test/resources/simple_previous.txt"));
//
//		IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
//		String mergedContents = _merged.getContents();
//		String expectedContents =
//				IOUtil.toString(new FileReader("src/test/resources/simple_expected.txt"));
//
//		assertEquals(expectedContents, mergedContents);
//	}
//
//	@Test
//	public void xmlParserShouldMatchExpected() throws Exception {
//
//		IRegionParser parser = RegionParserFactory.createXmlParser();
//
//		IDocument currentDoc = parser.parse(new FileInputStream("src/test/resources/xml_current.txt"));
//		IDocument previousDoc =
//				parser.parse(new FileInputStream("src/test/resources/xml_previous.txt"));
//
//		IDocument _merged = RegionUtil.merge(currentDoc, previousDoc);
//		String mergedContents = _merged.getContents();
//		String expectedContents =
//				IOUtil.toString(new FileReader("src/test/resources/xml_expected.txt"));
//
//		assertEquals(expectedContents, mergedContents);
//	}
//
//	@Test
//	public void xmlCDataShouldBeIgnored() throws Exception {
//		try {
//			RegionParserFactory.createXmlParser().parse(
//					new FileInputStream("src/test/resources/ignore_xml_cdata.txt"));
//		} catch (IllegalStateException x) {
//			assertTrue(
//					x.getMessage(),
//					"Detected marked region end without corresponding marked region start between (5,7) and (5,32), near [ PROTECTED REGION END ]."
//							.equals(x.getMessage()));
//		}
//	}
//
//	@Test
//	public void javaStringsShouldBeIgnored() throws Exception {
//		try {
//			RegionParserFactory.createJavaParser().parse(
//					new FileInputStream("src/test/resources/ignore_java_strings.txt"));
//		} catch (IllegalStateException x) {
//			assertTrue(
//					x.getMessage(),
//					"Detected marked region end without corresponding marked region start between (5,5) and (5,29), near [ PROTECTED REGION END ]."
//							.equals(x.getMessage()));
//		}
//	}
//
//	@Test
//	public void javaStringEscapesShouldBeIgnored() throws Exception {
//		RegionParserFactory.createJavaParser().parse(
//				new FileInputStream("src/test/resources/ignore_java_string_escapes.txt"));
//	}

	def private file(String fileName) {
		new File(fileName)
	}
	
	def private filter(File file) {
		new SingleFileFilter(file)
	}

	def private read(File file) {
		Files::toString(file, CHARSET)
	}
	
}

@Data class SingleFileFilter extends FileFilter {
	val File file
	override accept(File file) {
		_file.equals(file)
	}
}
