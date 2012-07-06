package net.danieldietrich.protectedregions.xtext

import static org.eclipse.xtext.generator.IFileSystemAccess.*
import static org.junit.Assert.*

import com.google.inject.Guice

import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.ParserFactory

import org.junit.Test
import net.danieldietrich.protectedregions.JavaIoFile
import com.google.inject.Injector

class FileSystemAccessTest {

	val CHARSET = Charset::forName('UTF-8')
	
	var Injector injector = Guice::createInjector

	extension ParserFactory parserFactory = injector.getInstance(typeof(ParserFactory))
		
	@Test
	def void mergeOfMultilanguageFilesShouldMatchExpected() {

		val currentFile = "src/test/resources/multilang_current.html"
		val previousFile = "src/test/resources/multilang_previous.html"
		val expectedFile = "src/test/resources/multilang_expected.html"

		val fsa = createProtectedRegionInMemoryFileSystemAccess() => [
			files => [ addFile(previousFile) ]
			support.addParser(xmlParser, ".html") // ~ htmlParser
			setOutputPath("src/test/resources/")
			generateFile(previousFile, currentFile.read)
		]
				
		val mergedContents = fsa.files.get(DEFAULT_OUTPUT+previousFile)
		val expectedContents = expectedFile.read
		
		assertEquals(expectedContents, mergedContents)

	}

	@Test
	def void nonUniqueIdsShouldBeGloballyDetected() {

		val fsa = createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/duplicate_id_1.java")
				addFile("src/test/resources/duplicate_id_2.java")
			]
			support.addParser(javaParser, ".java")
		]
		
		try {
			fsa.setOutputPath("src/test/resources/") // Boom!
			assertTrue("Duplicate id 'duplicate' not recognized", false)
		} catch (IllegalStateException x) {
			assertEquals(x.getMessage, "Duplicate marked region with id 'duplicate' detected")
		}
	}
	
	@Test
	def void protectedRegionStartInStringLiteralShouldBeIgnored() {

		createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/string_literals_ignore_start.java")
			]
			support.addParser(javaParser, ".java")
			setOutputPath("src/test/resources/") // throws IllegalStateException if test fails
		]
		
	}
	
	@Test
	def void protectedRegionEndInStringLiteralShouldBeIgnored() {

		createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/string_literals_ignore_end.java")
			]
			support.addParser(javaParser, ".java")
			setOutputPath("src/test/resources/") // throws IllegalStateException if test fails
		]
		
	}
	
	@Test
	def void protectedRegionStartInXmlCDATAShouldBeIgnored() {

		createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/string_literals_ignore_cdata.xml")
			]
			support.addParser(xmlParser, ".xml")
			setOutputPath("src/test/resources/") // throws IllegalStateException if test fails
		]
		
	}
	
	@Test
	def void commentsInStringLiteralsShouldBeIgnored() {

		createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/string_literals_ignore_comments.java")
			]
			support.addParser(javaParser, ".java")
			setOutputPath("src/test/resources/") // throws IllegalStateException if test fails
		]
		
	}
	
	@Test
	def void ensureStringLiteralsParsedCorrectly() {

		createProtectedRegionInMemoryFileSystemAccess() => [
			files => [
				addFile("src/test/resources/ensure_str_literals_parsed_correctly.java")
			]
			support.addParser(javaParser, ".java")
			setOutputPath("src/test/resources/") // throws IllegalStateException if test fails
		]
		
	}

	def private addFile(Map<String,CharSequence> files, String fileName) {
		files.put(DEFAULT_OUTPUT+fileName, fileName.read)
	}

	def private createProtectedRegionInMemoryFileSystemAccess() {
		injector.getInstance(typeof(ProtectedRegionInMemoryFileSystemAccess))
	}
	
	def private read(String fileName) {
		new JavaIoFile(new java.io.File(fileName)).read(CHARSET)
	}
	
}
