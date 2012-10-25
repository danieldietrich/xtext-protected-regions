package net.danieldietrich.protectedregions

import org.junit.runner.RunWith
import org.junit.runners.Suite
import org.junit.runners.Suite$SuiteClasses

@RunWith(
	typeof(Suite)
)

@SuiteClasses({
	typeof(FileTest),
	typeof(ModelTest),
    typeof(ProtectedRegionParserTest),
    typeof(ProtectedRegionSupportTest),
    typeof(RegionResolverTest)
})

class AllTests {}
