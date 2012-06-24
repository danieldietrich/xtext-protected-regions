package net.danieldietrich.protectedregions.xtext

import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2

class ProtectedRegionEclipseResourceFileSystemAccess2 extends EclipseResourceFileSystemAccess2 {
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		val processed = super.postProcess(fileName, outputConfiguration, content)
		val merged = processed // TODO: merge protected regions
		merged
	}
	
}
