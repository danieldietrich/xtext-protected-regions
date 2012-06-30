package net.danieldietrich.protectedregions

import com.google.common.io.Files
import java.io.File
import java.nio.charset.Charset
import org.slf4j.LoggerFactory

import static net.danieldietrich.protectedregions.ProtectedRegionSupport.*
import java.util.Map
import java.util.List

class ProtectedRegionSupport {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionSupport))
	
	/** By default the protected region support traverses all output dirs. */
	@Property var FileFilter globalFilter = new AcceptAllFilter()
	
	/** Maintain the order of parser addition. The first matching parser wins. */
	val List<FileFilter> parserFilters = newArrayList()
	val Map<FileFilter, ProtectedRegionParser> parsers = newHashMap()
	
	/** Pool of known regions. */
	val Map<String, Region> knownRegions = newHashMap()
	
	/** Add a parser parsing files with specific file extensions. */
	def ProtectedRegionParser addParser(ProtectedRegionParser parser, String... fileExtensions) {
		logger.debug("Adding {}, given file extensions {}", parser, fileExtensions)
		internal_addParser(parser, new FileExtensionFilter(fileExtensions))
	}

	/** Add a parser parsing files accepted by a specific FileFilter. */
	def ProtectedRegionParser addParser(ProtectedRegionParser parser, FileFilter filter) {
		logger.debug("Adding {}, given file filter {}", parser, filter.getClass)
		internal_addParser(parser, filter)
	}
	
	def private internal_addParser(ProtectedRegionParser parser, FileFilter filter) {
		parserFilters.add(filter) 
		parsers.put(filter, parser)
	}
	
	/** Scan recursively for marked (= protected/generated) regions. */
	def read(File dir, (File)=>Charset charsetProvider) {
		if (dir.exists && globalFilter.accept(dir)) {
			logger.debug("Reading directory "+ dir)
			dir.listFiles.forEach[file |
				if (file.directory) {
					file.read(charsetProvider)
				} else {
					val regions = file.parse(charsetProvider)
					regions.forEach[region |
						if (region.marked && region.enabled) {
							val id = region.id
							if (knownRegions.containsKey(id)) {
								logger.warn("WARNING: Skipping duplicate region with id: '{}'. File {} may not be processed correctly.", id, file)
							} else {
								logger.debug("Found region with id {} in file {}", id, file)
								knownRegions.put(id, region)
							}
						}
					]
				}
			]
		}
	}
	
	def merge(File file, CharSequence contents) {
		logger.debug("Merging {} with <content>", file)
		val parser = getParser(file)
		if (parser != null) {
			val regions = parser.parse(contents)
			val inverse = parser.inverse
			regions.fold(new StringBuffer)[buf, r |
				val match = r.marked && r.enabled && knownRegions.containsKey(r.id)
				val region = if ((match && inverse) || (!match && !inverse)) r else knownRegions.get(r.id)
				buf.append(region.content)
			]
		} else {
			contents
		}
	}

	/** Remove known regions found in given file. Useful for further merge operations. */
	def removeRegions(File file, (File)=>Charset charsetProvider) {
		val Iterable<Region> regions = file.parse(charsetProvider)
		regions.filter[isMarked].forEach[knownRegions.remove(id)]
	}

	/** May return null if no parser found for given file. */
	def private Iterable<Region> parse(File file, (File)=>Charset charsetProvider) {
		val parser = getParser(file)
		if (parser == null) {
			newArrayList() // creating an instance instead of return null reduces boilerplate in other locations
		} else {
			val charset = charsetProvider.apply(file)
			logger.debug("Parsing {} with charset {} using "+ parser, file.path, charset.toString)
			val contents = Files::toString(file, charset)
			parser.parse(contents)
		}
	}
	
	/**
	 * Returns first parser where the corresponding FileFilter accepts the given file
	 * in the order the parsers were added via one of the add() methods.
	 */
	def private getParser(File file) {
		val filter = parserFilters.reduce[f1, f2 | if (f1.accept(file)) f1 else f2]
		if (filter.accept(file)) parsers.get(filter) else null
	}
	
}
