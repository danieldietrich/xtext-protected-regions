package net.danieldietrich.protectedregions

import com.google.inject.Guice
import org.junit.Before
import org.junit.Test

class ParserTest {

	extension ParserFactory parserFactory

	@Before
	def void setup() {
		parserFactory = Guice::createInjector().getInstance(typeof(ParserFactory))
	}
	
	@Test
	def void testJavaParser() {
		test("java parser fails", javaParser, javaContent)
	}
	
	@Test
	def void testXtendParser() {
		test("xtend parser fails", xtendParser, xtendContent)
	}
	
	@Test
	def void testXmlParser() {
		test("xml parser fails", xmlParser, xmlContent)
	}
	
	@Test
	def void testXmlParserCorruptedXml() {
		testException("corrupted xml parsed wrong", xmlParser, xmlContent_corrupted, "xml parser: Str(') not found at [4,23]")
	}
		
	def private test(String msg, ProtectedRegionParser parser, CharSequence content) {
		val regions = parser.parse(content)
		val parsed = toString(regions)
		if (!parsed.equals(content.toString)) {
			throw new IllegalStateException(msg +"\n\nOriginal:\n###"+ content +"###\n\nParsed:\n###"+ parsed +"###\n\n")
		}
	}
	
	def private toString(Iterable<Region> regions) {
		val buf = new StringBuffer()
		for (region : regions) {
			buf.append(region.content)
		}
		buf.toString()
	}
			
	def private testException(String msg, ProtectedRegionParser parser, CharSequence content, String exception) {
		try {
			parser.parse(content)
			throw new IllegalStateException("Parser DIDN'T throw exception "+ exception)
		} catch(Exception x) {
			if (!x.message.equals(exception)) {
				throw new IllegalStateException(msg, x)
			}
		}
	}

	val javaContent = '''
		public class GeneratedClass {
			/**
			 * Generated comment.
			 */
			public void generatedMethod() {
			// PROTECTED REGION ID(test) START
			
			// TODO: implementation
			System.out.println("Protected regions end with \"/* PROTECTED REGION END */\"");
			
			// PROTECTED REGION END
			}
		}
	'''
	
	val xmlContent = '''
		<xml>
			<!-- PROTECTED REGION ID(test) START -->
			<![CDATA[this is character data]]>
			<element attribute1='value1' attribute2="value2">
				text
			</element>
			<!-- PROTECTED REGION END -->
		</xml>
	'''
		
	val xmlContent_corrupted = '''
		<xml>
			<!-- PROTECTED REGION ID(test) START -->
			<![CDATA[this is character data]]>
			<element attribute1='value1 attribute2="value2">
				text
			</element>
			<!-- PROTECTED REGION END -->
		</xml>
	'''
	
	val xtendContent = {
		"'''This is «\"\\\"a\"» rich «\"'''\"»string«\"'''\"» which ends here:'''"
	}

}
