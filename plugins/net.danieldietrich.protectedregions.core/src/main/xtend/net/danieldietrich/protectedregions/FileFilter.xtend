package net.danieldietrich.protectedregions

import java.util.Collection

abstract class FileFilter {
	
	/** Returns true, if file is accepted, false otherwise. File may be a dir or a file. */
	def boolean accept(File file)
	
}

/** Accepts all dirs and files. */
class AcceptAllFilter extends FileFilter {
	
	override accept(File file) { true }
	
}

/** Case-insensitive file extension filter. */
class FileExtensionFilter extends FileFilter {
	
	/** Extensions stored w/o leading dot '.' */
	val Collection<String> extensions
	
	/** Accepted file extensions, with or without leading dot '.' */
	new(String... extensions) {
		this.extensions = extensions.map[it.norm]
	}
	
	override accept(File file) {
		 file.isFile && extensions.contains(file.getExtension)
	}
	
	def private getExtension(File file) {
		val fileName = file.path
		val index = fileName.lastIndexOf('.')
		if (index == -1) null else fileName.substring(index + 1).norm
	}
	
	def private norm(String fileExtension) {
		val s = fileExtension.trim.toLowerCase
		if (s.startsWith('.')) s.substring(1) else s
	}
	
}
