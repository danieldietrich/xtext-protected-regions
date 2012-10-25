package net.danieldietrich.protectedregions.xtext

import com.google.inject.Inject

import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.File
import net.danieldietrich.protectedregions.ProtectedRegionSupport

import org.eclipse.xtext.generator.InMemoryFileSystemAccess
import org.eclipse.xtext.generator.OutputConfiguration

import org.slf4j.LoggerFactory
import java.util.ArrayList

// @@UPDATE-INFO: Check class hierarchie for new API annotated with @since
class ProtectedRegionInMemoryFileSystemAccess extends InMemoryFileSystemAccess {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionJavaIoFileSystemAccess))
	
	@Inject ProtectedRegionSupport support
	
	def support() { support }
	
	override deleteFile(String fileName, String outputName) {
		logger.debug("deleteFile('{}', '{}')", fileName, outputName)
		val file = file(fileName, outputName)
		support.removeRegions(file, null)
		super.deleteFile(fileName, outputName)
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		logger.debug("postProcess('{}', '{}', <content>)", fileName, outputConfiguration)
		val postProcessed = super.postProcess(fileName, outputConfiguration, content)
		val file = file(fileName, outputConfiguration)
		support.merge(file, postProcessed, null)
	}
	
	override setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		logger.debug("setOutputConfigurations(<outputs>)")
		super.setOutputConfigurations(outputs)
		outputs.values.forEach[support.read(file("", it.name), null)]
	}
	
	override setOutputPath(String outputName, String path) {
		logger.debug("setOutputPath('{}', '{}')", outputName, path)
		super.setOutputPath(outputName, path)
		val file = dir(path, outputName)
		support.read(file, null)
	}
	
	def private dir(String path, String outputName) {
		if (!path.endsWith('/')) throw new IllegalStateException("No dir: "+ path)
		new InMemoryFile(files, outputName, path)
	}
	
	def private file(String path, String outputName) {
		if (path.endsWith('/')) throw new IllegalStateException("No file: "+ path)
		new InMemoryFile(files, outputName, path)
	}
	
	override toString() {
		files.keySet.sort.fold(new StringBuffer)[buf, path |
			buf.append(path +" ("+ files.get(path).length +" bytes)\n")
			buf
		].toString
	}
	
}

// @@UPDATE-INFO: Check InMemoryAccess#generateFile(...) for content of path
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
		if (isFile) {
			new ArrayList<InMemoryFile>
		} else {
			val name = getPath
			fileSystem.keySet.filter[path |
				path.startsWith(name) && !path.endsWith('/') && path != name
			].map[path |
				new InMemoryFile(fileSystem, outputName, path.substring(outputName.length))
			]
		}
	}
	
	override exists() { true }
	override getPath() { outputName+path }
	override isDirectory() { path.endsWith('/') }
	override isFile() { !path.endsWith('/') }
	override read(Charset charset) {
		fileSystem.get(getPath)
	}
	override toURI() { outputName+path }
	
	override equals(Object o) {
		o != null && switch o {
			InMemoryFile : o.path == path
			default : false
		}
	}
	
	override hashCode() {
		path.hashCode
	}
	
}
