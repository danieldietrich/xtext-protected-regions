package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import com.google.inject.Guice

import java.io.FileNotFoundException
import java.nio.charset.Charset

import org.junit.Before
import org.junit.Test

/**
 * Note: These test cases access the file system instead of passing
 *       CharSequences to simulate real parsing conditions.
 */
class ProtectedRegionSupportTest {
	
	extension ModelBuilder modelBuilder
	extension ParserFactory parserFactory
	extension ProtectedRegionSupport support
	
	static val BASE_DIR = "src/test/resources"
	static val CHARSET = Charset::forName("UTF-8")
	
	@Before
	def void setup() {
		val injector = Guice::createInjector
		modelBuilder = injector.getInstance(typeof(ModelBuilder))
		parserFactory = injector.getInstance(typeof(ParserFactory))
		support = injector.getInstance(typeof(ProtectedRegionSupport))
	}
	
	@Test
	def void mergeShouldMatchExpected() {
		parsingPreviousAndMergingCurrentShouldMatchExpected(javaParser, "protected")
	}
	
	@Test
	def void xmlParserShouldMatchExpected() {
		parsingPreviousAndMergingCurrentShouldMatchExpected(xmlParser, "xml")
	}
	
	@Test
	def void switchedRegionsParserShouldPreserveEnabledRegionsOnly() {
		parsingPreviousAndMergingCurrentShouldMatchExpected(javaParser, "switched")
	}
	
	@Test
	def void fillInShouldMatchExpected() {
		
		val parser = javaParser => [
			inverse = true
			resolver = new FillInRegionResolver
		]
		
		parsingPreviousAndMergingCurrentShouldMatchExpected(parser, "fill_in")
		
	}	
	
	def private parsingPreviousAndMergingCurrentShouldMatchExpected(ProtectedRegionParser parser, String fileNamePrefix) {
		
		val currentFile = '''src/test/resources/«fileNamePrefix»_current.txt'''.file
		val previousFile = '''src/test/resources/«fileNamePrefix»_previous.txt'''.file
		val expectedFile = '''src/test/resources/«fileNamePrefix»_expected.txt'''.file

		// only support files relevant for this test case
		support.addParser(parser, previousFile.filter)

		// only read previous content
		support.read(BASE_DIR.file, [CHARSET])
		
		val generatedContent = currentFile.read
		val mergedContent = support.merge(previousFile, generatedContent, [CHARSET]) // pass previous to use the correct parser
		val expectedContent = expectedFile.read
		
		assertEquals(expectedContent, mergedContent)
		
	}

	@Test
	def void nonExistingFilesShouldByHandledGracefully() {
		support.merge("does_not_exist".file, "", [CHARSET])
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

	@Test
	def void scalaParserShouldReadNestedComments() {
		
		val regions = (scalaParser => [
			resolver = new NestedCommentRegionResolver	
		]).parse("src/test/resources/nested_comments.txt".file.read)
		
		// Scala does not recognize nested comment-like id's
		assertTrue(regions.findFirst[id == "1234"] != null)
		
	}

	@Test
	def void javaParserShouldntReadNestedCommentsButDoesWhichIsOkInThisCase() {
		
		val regions = (javaParser => [
			resolver = new NestedCommentRegionResolver	
		]).parse("src/test/resources/nested_comments.txt".file.read)

		// SPECIAL CASE
		// ------------
		// xpr reads:  /* PROTECTED REGION /*1234*/ ENABLED START */
		// java reads: /* PROTECTED REGION /*1234*/
		// -> remaining string invalid java:        ENABLED START */
		//
		// GOLDEN RULE: xtext-protected-regions reads valid code only
		// => this case cannot occur
		// => the following xpr behavior is ok:
		assertTrue(regions.findFirst[id == "1234"] != null)
		
	}
	
	@Test
	def void alternativeRegionNotationsShouldWorkAsWell() {
		
		val parser = parser("java")[
			model[
				comment("//")
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		] => [
			resolver = new SimpleRegionResolver
		]
		
		parsingPreviousAndMergingCurrentShouldMatchExpected(parser, "simple")
		
	}
	
	@Test
	def void xmlCDataShouldBeIgnored() {
		val regions = xmlParser.parse("src/test/resources/ignore_xml_cdata.txt".file.read)
		assertTrue(regions.findFirst[id == "no.id"] == null)
	}
	
	@Test
	def void javaStringsShouldBeIgnored() {
		val regions = javaParser.parse("src/test/resources/ignore_java_strings.txt".file.read)
		assertTrue(regions.findFirst[id == "no.id"] == null)
	}

	@Test
	def void javaStringEscapesShouldBeIdentified() {
		val regions = javaParser.parse("src/test/resources/ignore_java_string_escapes.txt".file.read)
		assertTrue(regions.findFirst[id == "no.id"] == null)
	}

	@Test(expected = typeof(IllegalStateException))
	def void locallyDuplicatedRegionIdsShouldBeDetected() {
		support.addParser(javaParser, "src/test/resources/locally_duplicated_id.txt".file.filter)
		support.read(BASE_DIR.file, [CHARSET])
	}

 	@Test(expected = typeof(IllegalStateException))
	def void globallyDuplicatedRegionIdsShouldBeDetected() {
		support.addParser(xmlParser => [
			resolver = new DefaultGeneratedRegionResolver
			inverse = true
		], "src/test/resources/globally_duplicated_id1.txt".file.filter)
		support.addParser(javaParser, "src/test/resources/globally_duplicated_id2.txt".file.filter)
		support.read(BASE_DIR.file, [CHARSET])
	}

	@Test(expected = typeof(IllegalStateException))
	def void missingStartMarkerShouldBeDetected() {
		javaParser.parse("src/test/resources/missing_start_marker.txt".file.read)
	}

	@Test(expected = typeof(IllegalStateException))
	def void missingNestedStartMarkerShouldBeDetected() {
		javaParser.parse("src/test/resources/nested_start_marker.txt".file.read)
	}
	
	@Test(expected = typeof(IllegalStateException))
	def void missingEndMarkerAtEndOfFileShouldBeDetected() {
		javaParser.parse("src/test/resources/missing_end_marker.txt".file.read)
	}
	
	@Test
	def void issue37ShouldBeSolved() {
		javaParser.parse("src/test/resources/issue#37.txt".file.read)
	}

	def private file(CharSequence fileName) {
		new JavaIoFile(new java.io.File(fileName.toString))
	}
	
	def private filter(File file) {
		new SingleFileFilter(file)
	}

	def private read(File file) {
		if (!file.exists) throw new FileNotFoundException("File "+ file +" not found.")
		file.read(CHARSET)
	}
	
}

@Data class SingleFileFilter extends FileFilter {
	val File file
	override accept(File file) {
		_file.equals(file)
	}
}

class NestedCommentRegionResolver extends RegionResolver {
	
	// example: PROTECTED REGION /*1234*/ START
	static val PR_START = "PROTECTED\\s+REGION\\s+/\\*\\s*([0-9]+)\\s*\\*/\\s+(?:(ENABLED)\\s+)?START"
	static val PR_END = "PROTECTED\\s+REGION\\s+END"
	
	new() { super(PR_START, PR_END) }
	
	override isEnabled(String regionStart) {
		"ENABLED".equals(getEnabled(regionStart))
	}
	
}

class FillInRegionResolver extends RegionResolver {
	
	// example: GENERATED ID(1234) START
	static val PR_START = "GENERATED\\s+ID\\s*\\(\\s*([0-9]+)\\s*\\)\\s+(?:(DISABLED)\\s+)?START"
	static val PR_END = "GENERATED\\s+END"
	
	new() { super(PR_START, PR_END) }
	
	override isEnabled(String regionStart) {
		!"DISABLED".equals(getEnabled(regionStart))
	}
	
}

class SimpleRegionResolver extends RegionResolver {
	
	// $(SomeClass.imports)-{
	// }-$
	static val ID = "[\\p{L}\\p{N}\\.:_$]*"
	static val PR_START = "\\$\\(("+ ID +")\\)-\\{"
	static val PR_END = "\\}-\\$"
	
	new() { super(PR_START, PR_END) }
	
	override isEnabled(String regionStart) { true }
	
}
