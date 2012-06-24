package net.danieldietrich.protectedregions.xtext

import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess

@Deprecated
class ProtectedRegionEclipseResourceFileSystemAccess extends EclipseResourceFileSystemAccess {
	
	val Object protectedRegionSupport
	
	new(Object protectedRegionSupport) {
		super()
		this.protectedRegionSupport = protectedRegionSupport
	}
	
	override generateFile(String fileName, String outputConfigurationName, CharSequence contents) {
		// TODO
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		val processed = super.postProcess(fileName, outputConfiguration, content)
		val merged = processed // TODO: merge protected regions
		merged
	}
	
}
