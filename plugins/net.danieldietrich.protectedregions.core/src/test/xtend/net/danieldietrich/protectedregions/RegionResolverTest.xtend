package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import org.junit.Test

class RegionResolverTest {
	
	@Test
	def void defaultProtectedRegionShouldBeValid() {
		
		val resolver = new DefaultProtectedRegionResolver()
		val id = "$Some:123.id_"
		val startEnabled = "PROTECTED REGION ID("+ id +") ENABLED START"
		val startDisabled = "PROTECTED REGION ID("+ id +") START"
		val end = "PROTECTED REGION END"
		
		assertRegionIsValid(resolver, id, startEnabled, startDisabled, end)
		
	}
	
	@Test
	def void defaultGeneratedRegionShouldBeValid() {
		
		val resolver = new DefaultGeneratedRegionResolver()
		val id = "$Some:123.id_"
		val startEnabled = "GENERATED REGION ID( "+ id +" )  ENABLED  START"
		val startDisabled = "GENERATED  REGION  ID  ( "+ id +" )  START"
		val end = "GENERATED  REGION  END"
		
		assertRegionIsValid(resolver, id, startEnabled, startDisabled, end)

	}
	
	def private void assertRegionIsValid(RegionResolver resolver, String id, String startEnabled, String startDisabled, String end) {
		
		val resolverName = resolver.getClass().name
		
		assertTrue(resolverName +" didn't recognize START of enabled region: "+ startEnabled, resolver.isStart(startEnabled))
		assertTrue(resolverName +" didn't recognize START of disabled region: "+ startDisabled, resolver.isStart(startDisabled))
		assertTrue(resolverName +" didn't recognize region END: "+ end, resolver.isEnd(end))
		assertTrue(resolverName +" didn't recognize ENABLED state: "+ startEnabled, resolver.isEnabled(startEnabled))
		assertTrue(resolverName +" didn't recognize DISABLED state: "+ startDisabled, !resolver.isEnabled(startDisabled))
		assertTrue(resolverName +" didn't recognize ID of enabled region: "+ startEnabled, id.equals(resolver.getId(startEnabled)))
		assertTrue(resolverName +" didn't recognize ID of disabled region: "+ startDisabled, id.equals(resolver.getId(startDisabled)))
		
	}
	
}
