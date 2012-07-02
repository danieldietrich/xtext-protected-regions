package net.danieldietrich.protectedregions

import static net.danieldietrich.protectedregions.ProtectedRegionSupport.*
import static extension net.danieldietrich.protectedregions.util.IterableExtensions.*

import com.google.common.io.Files

import java.io.File
import java.nio.charset.Charset
import java.util.List
import java.util.Map

import org.slf4j.LoggerFactory

class ProtectedRegionSupport {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionSupport))
	
	/** By default the protected region support traverses all output dirs. */
	@Property var FileFilter dirFilter = new AcceptAllFilter()
	
	/** Maintain the order of parser addition. The first matching parser wins. */
	val List<FileFilter> parserFilters = newArrayList()
	val Map<FileFilter, ProtectedRegionParser> parsers = newHashMap()
	
	/** Pool of known regions. */
	val Map<String, Region> knownRegions = newHashMap()
	val List<String> knownIds = newArrayList()
	
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
	def void read(File dir, (File)=>Charset charsetProvider) {
		if (dir.exists && dir.directory && dirFilter.accept(dir)) {
			logger.debug("Reading directory "+ dir)
			dir.listFiles.forEach[file |
				if (file.directory) {
					file.read(charsetProvider)
				} else {
					val inverse = file.parser?.inverse
					val regions = file.parse(charsetProvider)
					regions.forEach[region |
						if (region.marked) {
							val id = region.id
							logger.debug("Found {} region with id '{}' in file {}", newArrayList(if (region.enabled) "enabled" else "disabled", id, file))
							if (knownIds.contains(id)) {
								// TODO: Message like "Detected duplicate region id in src-gen/xxx/SomeFile.java between (5,7) and (5,32), near [ PROTECTED REGION ID(duplicate.id) ENABLED START ]."
								// Github Issue #33
								throw new IllegalStateException("Duplicate marked region with id '"+ id +"' detected")
							} else {
								knownIds.add(id)
							}
							if (region.enabled && !inverse) {
								knownRegions.put(id, region)
							}
						}
					]
				}
			]
		}
	}
	
	/**
	 * Returns merged contents, if given file exists and a parser filter matches the file,
	 * otherwise returns the given contents.
	 *
	 * If the underlying parser is inverse, all marked regions (@see RegionResolver.isMarked(String))
	 * will be overwritten with generated content - if the respective previous region was enabled -
	 * and all unmarked regions are preserved
	 * 
	 * If the underlying parser is not inverse, all marked regions will be overwritten with protected content
	 * - if the respective previous region was enabled - and all unmarked regions will be overwritten
	 * with generated content.
	 * @param file contains manual changes
	 * @param contents are newly generated
	 * @param charsetProvider needed for inverse parsing
	 */
	def CharSequence merge(File file, CharSequence contents, (File)=>Charset charsetProvider) {
		val parser = getParser(file)
		if (parser != null) {
			logger.debug("Merging {} with <content>", file)
			val inverse = parser.inverse
			if (inverse) {
				// fill in
				if (file.exists) {
					// do not filter region.enabled, because the generated regions are disabled by default (Github Issue #33)
					val localRegions = parser.parse(contents).filter[marked].toMap([id], [it])
					val regions = file.parse(charsetProvider)
					regions.fold(new StringBuffer)[buf, r |
						val match = r.marked && r.enabled && localRegions.containsKey(r.id)
						val region = if (match) localRegions.get(r.id) else r
						buf.append(region.content)
					].toString
				} else {
					contents
				}
			} else {
				// merge
				val regions = parser.parse(contents)
				regions.fold(new StringBuffer)[buf, r |
					val match = r.marked && r.enabled && knownRegions.containsKey(r.id)
					val region = if (match) knownRegions.get(r.id) else r 
					buf.append(region.content)
				].toString
			}
		} else {
			contents
		}
	}

	/** Remove known regions found in given file. Useful for further merge operations. */
	def void removeRegions(File file, (File)=>Charset charsetProvider) {
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
	def private ProtectedRegionParser getParser(File file) {
		val filter = parserFilters.reduce[f1, f2 | if (f1.accept(file)) f1 else f2]
		if (filter?.accept(file)) parsers.get(filter) else null
	}
	
}
