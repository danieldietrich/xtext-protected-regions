package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import com.google.inject.Guice
import org.junit.Before
import org.junit.Test

class ProtectedRegionParserTest {

	extension ParserFactory parserFactory

	@Before
	def void setup() {
		parserFactory = Guice::createInjector.getInstance(typeof(ParserFactory))
	}
	
	@Test
	def void parsedJavaContentShouldMatchOriginalContent() {
		assertParsedContentEqualsGivenContent("java parser fails", javaParser, javaContent)
	}
	
	@Test
	def void parsedXtendContentShouldMatchOriginalContent() {
		assertParsedContentEqualsGivenContent("xtend parser fails", xtendParser, xtendContent)
	}
	
	@Test
	def void parsedXmlContentShouldMatchOriginalContent() {
		assertParsedContentEqualsGivenContent("xml parser fails", xmlParser, xmlContent)
	}
	
	@Test
	def void corruptedXmlContentShouldNotBeParsed() {
		val msg = "xml parser: Str(') not found at [4,23]"
		try {
			xmlParser.parse(xmlContent_corrupted)
			throw new RuntimeException('''Parser didn't recognized corrupted xml. Expected IllegalStateException('«msg»')''')
		} catch(IllegalStateException x) {
			assertEquals('''Parser threw unexpected exception message. Expected '«msg»' but found '«x.message»'.''', msg, x.message)
		}
	}
	
	@Test
	def void regionResolverShouldBeDynamicallyExchangable() {
		
		val parser = javaParser // has DefaultProtectedRegionResolver
		val protectedRegions = parser.parse(lateBindingContent).filter[marked]
		assertSizeEqualsExpected(protectedRegions, 1)
		assertIdEqualsExpected(protectedRegions.findFirst[true].id, "dynamic::protected")
		
		// switching the RegionResolver on-the-fly should affect the parser model dynamically
		parser.setResolver(new DefaultGeneratedRegionResolver())
		val generatedRegions = parser.parse(lateBindingContent).filter[marked]
		assertSizeEqualsExpected(generatedRegions, 1)
		assertIdEqualsExpected(generatedRegions.findFirst[true].id, "dynamic::generated")
		
	}
	
	def private assertParsedContentEqualsGivenContent(String msg, ProtectedRegionParser parser, CharSequence content) {
		
		val regions = parser.parse(content)
		val parsed = regions.fold(new StringBuffer)[buf, region | buf.append(region.content)].toString
		
		assertEquals('''«msg»\n\nExpected:\n###«content»###\n\nFound:\n###«parsed»###''', parsed, content.toString)
		
	}
	
	def private assertSizeEqualsExpected(Iterable<Region> regions, int expected) {
		assertTrue('''Expected 1 region but found «regions.size»''', regions.size == 1)
	}
	
	def private assertIdEqualsExpected(String id, String expected) {
		assertTrue('''Found id «id» but expected «expected»''', id == expected)
	}
	
	val lateBindingContent = '''
		public class LateBindingTest {
			
			@Test
			public void testProtected() {
			// PROTECTED REGION ID(dynamic::protected) ENABLED START
			
			// implement testProtected()
			
			// PROTECTED REGION END
			}

			public void testGenerated() {
			// GENERATED REGION ID(dynamic::generated) START
			
			// implement testGenerated()
			
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
			
			// implementation
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
