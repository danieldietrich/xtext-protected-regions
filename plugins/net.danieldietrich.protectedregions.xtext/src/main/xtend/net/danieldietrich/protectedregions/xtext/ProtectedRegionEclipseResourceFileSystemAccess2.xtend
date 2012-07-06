package net.danieldietrich.protectedregions.xtext

import com.google.common.io.CharStreams
import com.google.common.io.InputSupplier
import com.google.inject.Inject

import java.io.InputStream
import java.nio.charset.Charset
import java.util.Map

import net.danieldietrich.protectedregions.File
import net.danieldietrich.protectedregions.ProtectedRegionSupport

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IResource
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.generator.OutputConfiguration

import org.slf4j.LoggerFactory

// TODO: JDTAwareEclipseResourceFileSystemAccess2 vs EclipseResourceFileSystemAccess2
// @@UPDATE-INFO: Check class hierarchie for new API annotated with @since
// JDTAwareEclipseResourceFileSystemAccess2 is currently used in xtend only
class ProtectedRegionEclipseResourceFileSystemAccess2 extends EclipseResourceFileSystemAccess2 {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionEclipseResourceFileSystemAccess2))
	
	@Inject ProtectedRegionSupport support
	
	def support() { support }
	
	val (String,File)=>Charset charsetProvider = [outputName, file |
		val encoding = getEncoding(getFile(file.path, outputName))
		if (Charset::isSupported(encoding)) Charset::forName(encoding) else Charset::defaultCharset
	]
	
	override deleteFile(String fileName, String outputName) {
		logger.info("deleteFile("+ fileName +", "+ outputName +")")
		val file = getFile(fileName, outputName)
		support.removeRegions(new EclipseResourceFile(file), charsetProvider.curry(outputName))
		super.deleteFile(fileName, outputName)
	}
	
	override postProcess(String fileName, String outputConfiguration, CharSequence content) {
		logger.info("postProcess("+ fileName +", "+ outputConfiguration +", <content>)")
		val postProcessed = super.postProcess(fileName, outputConfiguration, content)
		val file = file(fileName, outputConfiguration)
		support.merge(file, postProcessed, charsetProvider.curry(outputConfiguration))
	}
	
	override setOutputConfigurations(Map<String, OutputConfiguration> outputs) {
		logger.info("setOutputConfigurations(<outputs>)")
		super.setOutputConfigurations(outputs)
		support.clearRegions()
		outputs.values.forEach[support.read(file(it), charsetProvider.curry(it.name))]
	}
	
	override setOutputPath(String outputName, String path) {
		logger.info("setOutputPath("+ outputName +", "+ path +")")
		super.setOutputPath(outputName, path)
		val file = file(getOutputConfig(outputName))
		support.read(file, charsetProvider.curry(outputName))
	}
	
	def private file(String path, String outputName) {
		new EclipseResourceFile(getFile(path, outputName))
	}
	
	def private file(OutputConfiguration config) {
		new EclipseResourceFile(getFolder(config))
	}
	
}

class EclipseResourceFile extends File {
	
	protected val IResource resource
	
	new(IResource resource) {
		this.resource = resource
	}
	
	override children() {
		(switch resource {
			IFolder : resource.members
			default : throw new UnsupportedOperationException("No IFolder")
		}).map[new EclipseResourceFile(it)]
	}
	override exists() {
		resource.exists
	}
	override getPath() {
		resource.location.toPortableString
	}
	override isDirectory() {
		switch resource {
			IFolder : true
			default : false
		}
	}
	override isFile() {
		switch resource {
			IFile : true
			default : false
		}
	}
	override CharSequence read(Charset charset) {
		switch resource {
			IFile : {
				val InputSupplier<? extends InputStream> streamSupplier = [|resource.contents]
				val readerSupplier = CharStreams::newReaderSupplier(streamSupplier, charset)
				CharStreams::toString(readerSupplier) // Guava handles closing resources
			}
			default : throw new UnsupportedOperationException("No IFile")
		}
	}
	
	override equals(Object o) {
		o != null && switch o {
			EclipseResourceFile : o.resource == resource
			default : false
		}
	}
	
	override hashCode() {
		resource.hashCode
	}
	
}
