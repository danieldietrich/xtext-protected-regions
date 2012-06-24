package net.danieldietrich.protectedregions

import com.google.common.io.Files

import java.io.File
import java.nio.charset.Charset
import java.util.Map
import net.danieldietrich.protectedregions.parser.Parser

abstract class ResourceReader {
	// TODO
}

// TODO: RegionOracle = RegionResolver (isStart, isEnd, getId, ...)
abstract class RegionResolver {
	
}

class ProtectedRegionSupport {
	
	val Map<String, Parser> parsers = newHashMap()
	
	def addParser(Parser parser, String... fileExtensions) {
		fileExtensions.forEach[parsers.put(it, parser)]
	}
	
	def read(File dir) {
		dir.listFiles.forEach[if (directory) read else parse]
	}

	def merge(String file, CharSequence contents) {
		/*TODO(@@dd): val Map<String,String> regions =*/ // contents.toString.parse(fileName)
		return contents // TODO: preserve/insert protected regions
	}

	// TODO: use encoding provider of FSA!?
	def private parse(File file) {
		Files::toString(file, Charset::defaultCharset).parse(file.path)
	}

	def private parse(String contents, String fileName) {
		println("parsing " + fileName)
		val i = fileName.lastIndexOf('.')
		val ext = if (i == -1) null else fileName.substring(i+1)
		val parser = if (ext == null) null else parsers.get(ext)
		if (parser == null) {
			println("no parser found for file " + fileName)
		}
		/*TODO(@@dd)*///parser.parse(contents)
	}
}
