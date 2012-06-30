package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import com.google.inject.Guice
import org.junit.Before
import org.junit.Test

class ModelTest {
	
	extension ParserFactory parserFactory

	@Before
	def void setup() {
		parserFactory = Guice::createInjector().getInstance(typeof(ParserFactory))
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
	
}
