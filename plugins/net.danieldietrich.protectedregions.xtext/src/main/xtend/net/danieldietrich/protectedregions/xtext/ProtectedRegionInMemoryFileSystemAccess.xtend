package net.danieldietrich.protectedregions.xtext

import org.eclipse.xtext.generator.InMemoryFileSystemAccess

class ProtectedRegionInMemoryFileSystemAccess extends InMemoryFileSystemAccess {
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		val processed = super.postProcess(fileName, outputConfiguration, content)
		val merged = processed // TODO: merge protected regions
		merged
	}
	
}
