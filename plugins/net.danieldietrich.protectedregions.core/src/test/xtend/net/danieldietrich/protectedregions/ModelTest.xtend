package net.danieldietrich.protectedregions

import static extension net.danieldietrich.protectedregions.parser.ElementExtensions.*
import static org.junit.Assert.*

import net.danieldietrich.protectedregions.parser.Match
import org.junit.Test

class ModelTest {

	@Test
	def void seqShouldBeFound() {
		
		val should = new Match(1, 2)
		val match = Seq("\\".str, Any).indexOf(" \\\" /* PROTECTED REGION ID(no.id) ENABLED START */ \\\"; }", 0)
		
		assertTrue("match = "+ match +" but should be "+ should, match == should)
		
	}
	
}
