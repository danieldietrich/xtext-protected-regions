package net.danieldietrich.protectedregions.xtext

import com.google.inject.Inject

import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.File
import net.danieldietrich.protectedregions.JavaIoFile
import net.danieldietrich.protectedregions.ProtectedRegionSupport

import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.parser.IEncodingProvider
import org.eclipse.xtext.resource.IResourceServiceProvider

import org.eclipse.emf.common.util.URI
import org.slf4j.LoggerFactory

// @@UPDATE-INFO: Check class hierarchie for new API annotated with @since
class ProtectedRegionJavaIoFileSystemAccess extends JavaIoFileSystemAccess {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionJavaIoFileSystemAccess))
	
	val (File)=>Charset charsetProvider = [file |
		val URI uri = URI::createURI(file.toURI)
		val encoding = getEncoding(uri)
		if (Charset::isSupported(encoding)) Charset::forName(encoding) else Charset::defaultCharset
	]
	
	@Inject ProtectedRegionSupport support
	
	@Inject
	new(IResourceServiceProvider$Registry registry, IEncodingProvider encodingProvider) {
		super(registry, encodingProvider)
		logger.debug("{} created", getClass.simpleName)
	}
	
	def support() { support }
	
	override deleteFile(String fileName, String outputName) {
		logger.debug("deleteFile('{}', '{}')", fileName, outputName)
		val file = file(fileName, outputName)
		support.removeRegions(file, charsetProvider)
		super.deleteFile(fileName, outputName)
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		logger.debug("postProcess('{}', '{}', <content>)", fileName, outputConfiguration)
		val postProcessed = super.postProcess(fileName, outputConfiguration, content)
		val file = file(fileName, outputConfiguration)
		support.merge(file, postProcessed, charsetProvider)
	}
	
	override setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		logger.debug("setOutputConfigurations(<outputs>)")
		super.setOutputConfigurations(outputs)
		outputs.values.forEach[support.read(file("", it.name), charsetProvider)]
	}
	
	override setOutputPath(String outputName, String path) {
		logger.debug("setOutputPath('{}', '{}')", outputName, path)
		super.setOutputPath(outputName, path)
		val file = file("", outputName)
		support.read(file, charsetProvider)
	}
	
	def private file(String path, String outputName) {
		new JavaIoFile(getFile(path, outputName))
	}

}
