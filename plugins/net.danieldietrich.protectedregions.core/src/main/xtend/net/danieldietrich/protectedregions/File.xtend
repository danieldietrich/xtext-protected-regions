package net.danieldietrich.protectedregions

import com.google.common.io.Files
import java.nio.charset.Charset

abstract class File {
	
	def File[] children()
	def boolean exists()
	def String getPath()
	def boolean isDirectory()
	def boolean isFile()
	def CharSequence read(Charset charset)
	
	override equals(Object o) {
		o != null && (o instanceof File) && hashCode == o.hashCode
	}
	override hashCode() { path.hashCode }
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

}
