package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import com.google.inject.Guice
import org.junit.Before
import org.junit.Test
import java.rmi.UnexpectedException

class ProtectedRegionParserTest {

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
		val msg = "xml parser: Str(') not found at [4,23]"
		try {
			xmlParser.parse(xmlContent_corrupted)
			throw new UnexpectedException('''Parser didn't recognized corrupted xml. Expected IllegalStateException('«msg»')''')
		} catch(IllegalStateException x) {
			assertEquals('''Parser threw unexpected exception message. Expected '«msg»' but found '«x.message»'.''', msg, x.message)
		}
	}
	
	@Test
	def void testLateBinding() {
		
		val parser = javaParser // has DefaultProtectedRegionResolver
		val protectedRegions = parser.parse(lateBindingContent).filter[marked]
		assertSize(protectedRegions, 1)
		assertId(protectedRegions.findFirst[true].id, "dynamic::protected")
		
		// switching the RegionResolver on-the-fly should affect the parser model dynamically
		parser.setResolver(new DefaultGeneratedRegionResolver())
		val generatedRegions = parser.parse(lateBindingContent).filter[marked]
		assertSize(generatedRegions, 1)
		assertId(generatedRegions.findFirst[true].id, "dynamic::generated")
		
	}
	
	def private test(String msg, ProtectedRegionParser parser, CharSequence content) {
		
		val regions = parser.parse(content)
		val parsed = toString(regions)
		
		assertEquals('''«msg»\n\nExpected:\n###«content»###\n\nFound:\n###«parsed»###''', parsed, content.toString)
		
	}
	
	def private toString(Iterable<Region> regions) {
		val buf = new StringBuffer()
		for (region : regions) {
			buf.append(region.content)
		}
		buf.toString()
	}
	
	def private assertSize(Iterable<Region> regions, int expected) {
		assertTrue('''Expected 1 region but found «regions.size»''', regions.size == 1)
	}
	
	def private assertId(String id, String expected) {
		assertTrue('''Found id «id» but expected «expected»''', id == expected)
	}
	
	val lateBindingContent = '''
		public class LateBindingTest {
			
			@Test
			public void testProtected() {
			// PROTECTED REGION ID(dynamic::protected) ENABLED START
			
			// TODO: testProtected()
			
			// PROTECTED REGION END
			}

			public void testGenerated() {
			// GENERATED REGION ID(dynamic::generated) ENABLED START
			
			// TODO: testGenerated()
			
			// GENERATED REGION END
			}
			
		}
	'''

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
