package net.danieldietrich.protectedregions.xtext

import com.google.inject.Inject

import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.File
import net.danieldietrich.protectedregions.ProtectedRegionSupport

import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration

import org.slf4j.LoggerFactory

// @@UPDATE-INFO: Check class hierarchie for new API annotated with @since
class ProtectedRegionInMemoryFileSystemAccess extends InMemoryFileSystemAccess {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionJavaIoFileSystemAccess))
	
	@Inject ProtectedRegionSupport support
	
	val (String,File)=>Charset charsetProvider
	
	new((String,String)=>String encodingProvider) {
		this.charsetProvider = [outputName, file |
			Charset::forName(encodingProvider.apply(outputName, file.path))
		]
	}
	
	def support() { support }
	
	override deleteFile(String fileName, String outputName) {
		logger.debug("deleteFile('{}', '{}')", fileName, outputName)
		val file = file(fileName, outputName)
		support.removeRegions(file, charsetProvider.curry(outputName))
		super.deleteFile(fileName, outputName)
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		logger.debug("postProcess('{}', '{}', <content>)", fileName, outputConfiguration)
		val postProcessed = super.postProcess(fileName, outputConfiguration, content)
		val file = file(fileName, outputConfiguration)
		support.merge(file, postProcessed, charsetProvider.curry(outputConfiguration))
	}
	
	override setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		logger.debug("setOutputConfigurations(<outputs>)")
		super.setOutputConfigurations(outputs)
		outputs.values.forEach[support.read(file("", it.name), charsetProvider.curry(it.name))]
	}
	
	override setOutputPath(String outputName, String path) {
		logger.debug("setOutputPath('{}', '{}')", outputName, path)
		super.setOutputPath(outputName, path)
		val file = file("", outputName)
		support.read(file, charsetProvider.curry(outputName))
	}
	
	def private file(String path, String outputName) {
		new InMemoryFile(files, outputName, path)
	}
	
}

class InMemoryFile extends File {

	// every file maintains a reference to the underlying in-memory file system	
	val Map<String, CharSequence> fileSystem
	val String outputName
	val String path
	
	new(Map<String, CharSequence> fileSystem, String outputName, String path) {
		this.fileSystem = fileSystem
		this.outputName = outputName
		this.path = path
	}
	
	override children() {
		fileSystem.keySet.filter[key |
			// @@UPDATE-INFO: Check InMemoryAccess#generateFile(...) for content of key
			key.startsWith(outputName) && key != outputName+path // TODO: currently not prefix-unique
		].map[path |
			new InMemoryFile(fileSystem, outputName, path)
		]
	}
	
	override exists() { true }
	override getPath() { outputName +"/"+ path }
	override isDirectory() { path == "" }
	override isFile() { path != "" }
	override read(Charset charset) {
		fileSystem.get(path)
	}
	
	override equals(Object o) {
		o != null && switch o {
			InMemoryFile : o.getPath() == getPath()
			default : false
		}
	}
	
	override hashCode() {
		path.hashCode
	}
	
}
