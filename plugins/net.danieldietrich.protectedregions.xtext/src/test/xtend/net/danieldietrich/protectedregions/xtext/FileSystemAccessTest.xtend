package net.danieldietrich.protectedregions.xtext

import static org.eclipse.xtext.generator.IFileSystemAccess.*
import static org.junit.Assert.*

import com.google.inject.Guice

import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.ModelBuilder
import net.danieldietrich.protectedregions.ParserFactory

import org.junit.Test
import net.danieldietrich.protectedregions.JavaIoFile
import com.google.inject.Injector

class FileSystemAccessTest {

	val CHARSET = Charset::forName('UTF-8')
	
	var Injector injector = Guice::createInjector

	extension ModelBuilder modelBuilder = new ModelBuilder
	extension ParserFactory parserFactory = injector.getInstance(typeof(ParserFactory))
		
	@Test
	def void mergeOfMultilanguageFilesShouldMatchExpected() {

		val currentFile = "src/test/resources/multilang_current.html"
		val previousFile = "src/test/resources/multilang_previous.html"
		val expectedFile = "src/test/resources/multilang_expected.html"

		val fsa = createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile(previousFile)
			]
			support.addParser(xmlParser, ".html") // ~ htmlParser
			setOutputPath("src/test/resources/")
			generateFile(previousFile, currentFile.read)
		]
				
		val mergedContents = fsa.files.get(DEFAULT_OUTPUT+previousFile)
		val expectedContents = expectedFile.read
		
		assertEquals(expectedContents, mergedContents)

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

	def private addFile(Map<String,CharSequence> files, String fileName) {
		files.put(DEFAULT_OUTPUT+fileName, fileName.read)
	}

	def private createProtectedRegionInMemoryFileSystemAccess() {
		injector.getInstance(typeof(ProtectedRegionInMemoryFileSystemAccess))
	}
	
	def private read(String fileName) {
		new JavaIoFile(new java.io.File(fileName)).read(CHARSET)
	}
	
	def private cssParser() {
		parser("css")[
			model[
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	}
	
	def private jsParser() {
		parser("java")[
			model[
				comment("//")
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	}
	
	def private phpParser() {
		parser("php")[
			model[
				comment("//")
				comment("/*", "*/")
				comment("#")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	}
	
}
