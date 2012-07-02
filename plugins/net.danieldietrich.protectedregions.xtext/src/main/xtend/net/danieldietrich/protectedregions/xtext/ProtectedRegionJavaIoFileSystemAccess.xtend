package net.danieldietrich.protectedregions.xtext

import java.io.File
import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.ProtectedRegionSupport

import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration
import org.eclipse.xtext.parser.IEncodingProvider
import org.eclipse.xtext.resource.IResourceServiceProvider

import org.slf4j.LoggerFactory

class ProtectedRegionJavaIoFileSystemAccess extends JavaIoFileSystemAccess {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionJavaIoFileSystemAccess))
	
	val ProtectedRegionSupport protectedRegionSupport
	
	val (String,File)=>Charset charsetProvider = [outputName, file |
		val encoding = getEncoding(getURI(file.path, outputName))
		if (Charset::isSupported(encoding)) Charset::forName(encoding) else Charset::defaultCharset
	]
	
	new(ProtectedRegionSupport protectedRegionSupport, IResourceServiceProvider$Registry registry, IEncodingProvider encodingProvider) {
		super(registry, encodingProvider)
		this.protectedRegionSupport = protectedRegionSupport
		logger.debug("{} created", getClass.getSimpleName)
	}
	
	override deleteFile(String fileName, String outputName) {
		logger.debug("deleteFile('{}', '{}')", fileName, outputName)
		val file = getFile(fileName, outputName)
		protectedRegionSupport.removeRegions(file, charsetProvider.curry(outputName))
		super.deleteFile(fileName, outputName)
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		logger.debug("postProcess('{}', '{}', <content>)", fileName, outputConfiguration)
		val postProcessed = super.postProcess(fileName, outputConfiguration, content)
		val file = getFile(fileName, outputConfiguration)
		protectedRegionSupport.merge(file, postProcessed, charsetProvider.curry(outputConfiguration))
	}
	
	override setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		logger.debug("setOutputConfigurations(<outputs>)")
		super.setOutputConfigurations(outputs)
		outputs.values.forEach[protectedRegionSupport.read(new File(it.outputDirectory), charsetProvider.curry(it.name))]
	}
	
	override setOutputPath(String outputName, String path) {
		logger.debug("setOutputPath('{}', '{}')", outputName, path)
		super.setOutputPath(outputName, path)
		protectedRegionSupport.read(new File(path), charsetProvider.curry(outputName))
	}

}
