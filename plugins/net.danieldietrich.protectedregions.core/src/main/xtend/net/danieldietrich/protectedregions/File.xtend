package net.danieldietrich.protectedregions

import com.google.common.io.Files
import java.nio.charset.Charset

/** equals(Object) and hashCode() have to be overridden */
abstract class File {
	
	def File[] children()
	def boolean exists()
	def String getPath()
	def boolean isDirectory()
	def boolean isFile()
	def CharSequence read(Charset charset)
	
	override toString() { path }
	
}

class JavaIoFile extends File {
	
	val java.io.File file
	
	new(java.io.File file) {
		this.file = file
	}
	
	override children() {
		file.listFiles.map[new JavaIoFile(it)]
	}
	override exists() { file.exists }
	override getPath() { file.path }
	override isDirectory() { file.directory }
	override isFile() { file.file }
	override CharSequence read(Charset charset) {
		Files::toString(file, charset)
	}
	
	override equals(Object o) {
		o != null && switch o {
			File : o.equals(file)
			java.io.File : file.equals(o)
			default : false
		}
	}
	
	override hashCode() {
		file.hashCode
	}

}
