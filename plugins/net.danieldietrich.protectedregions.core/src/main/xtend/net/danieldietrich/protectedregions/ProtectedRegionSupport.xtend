package net.danieldietrich.protectedregions

import static net.danieldietrich.protectedregions.ProtectedRegionSupport.*
import static extension net.danieldietrich.protectedregions.util.IterableExtensions.*

import java.nio.charset.Charset
import java.util.List
import java.util.Map

import net.danieldietrich.protectedregions.util.Box

import org.slf4j.LoggerFactory
import java.util.Set

class ProtectedRegionSupport {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionSupport))
	
	/** By default the protected region support traverses all output dirs. */
	@Property var FileFilter dirFilter = new AcceptAllFilter()
	
	/** Map of parsers by FileFilter (in insertion-order). */
	val Map<FileFilter, ProtectedRegionParser> parsers = newLinkedHashMap()
	
	/** Pool of known *protected* regions. */
	val Map<String, Region> protectedRegions = newHashMap()
	
	/** Known (globally unique) id's of protected *and* generated regions. */
	val List<String> knownIds = newArrayList()
	
	/** Add a parser parsing all files. */
	def ProtectedRegionParser addParser(ProtectedRegionParser parser) {
		logger.debug("Adding {} (for all files)", parser)
		internal_addParser(parser, new AcceptAllFilter())
	}
	
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
		parsers.put(filter, parser)
	}
	
	/** Scan recursively for marked (= protected/generated) regions containing (potentially) manual changes. */
	def void read(File dir, (File)=>Charset charsetProvider) {
		read(dir, charsetProvider, newHashSet)
	}
	
	/** Search regions, observing visited dirs. */
	def private void read(File dir, (File)=>Charset charsetProvider, Set<File> visited) {
		if (dir.exists && dir.directory && dirFilter.accept(dir)) {
			if (!visited.contains(dir)) {
				logger.debug("Reading directory {}", dir)
				visited.add(dir)
				dir.children.forEach[file |
					if (file.directory) {
						file.read(charsetProvider, visited)
					} else {
						file.parse(charsetProvider)
					}
				]
			}
		}
	}
	
	/** Parse the regions of a specific file. */
	def private parse(File file, (File)=>Charset charsetProvider) {
		file.parsers.forEach[parser|
			val inverse = parser.inverse
			val regions = parser.parse(file, charsetProvider)
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
					// don't store inverse regions because they contain generated content
					if (region.enabled && !inverse) {
						protectedRegions.put(id, region)
					}
				}
			]
		]
	}
	
	/** Remove all previously read regions. */
	def clearRegions() {
		protectedRegions.clear
		knownIds.clear
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
	 * 
	 * @param file contains manual changes
	 * @param contents are newly generated
	 * @param charsetProvider needed for inverse parsing
	 */
	def CharSequence merge(File file, CharSequence contents, (File)=>Charset charsetProvider) {
		val result = new Box(contents)
		file.parsers.forEach[parser|
			val inverse = parser.inverse
			if (inverse) {
				// preserved regions are read from file
				if (file.exists) {
					logger.debug("Filling-in generated regions into {}", file)
					// do not filter region.enabled, because the generated regions are disabled by default (Github Issue #33)
					val generatedRegions = parser.parse(result.x).filter[marked].asMap[id -> it]
					val regions = parser.parse(file, charsetProvider)
					result.x = mergeContents(generatedRegions, regions)
				}
			} else {
				// preserved regions are read from memory
				logger.debug("Merging protected regions into {}", file)
				val regions = parser.parse(result.x)
				result.x = mergeContents(protectedRegions, regions)
			}
		]
		result.x
	}
	
	/** Merge marked and enabled regions (which are stored in given pool) into the given regions. */
	def private CharSequence mergeContents(Map<String,Region> regionPool, Iterable<Region> regions) {
		regions.fold(new StringBuffer)[buf, r |
			val match = r.marked && r.enabled && regionPool.containsKey(r.id)
			val region = if (match) regionPool.get(r.id) else r 
			buf.append(region.content)
		].toString
	}

	/** Remove known regions found in given file. Useful for further merge operations. */
	def void removeRegions(File file, (File)=>Charset charsetProvider) {
		file.parsers.forEach[parser|
			val Iterable<Region> regions = parser.parse(file, charsetProvider)
			regions.filter[isMarked].forEach[protectedRegions.remove(id)]
		]
	}

	/** May return null if no parser found for given file. */
	def private Iterable<Region> parse(ProtectedRegionParser parser, File file, (File)=>Charset charsetProvider) {
		val charset = charsetProvider.apply(file)
		logger.debug("Parsing {} with charset {} using "+ parser, file.path, charset.toString)
		val contents = file.read(charset)
		parser.parse(contents)
	}
	
	/** Return all parsers which are applyable to the given file. */
	def private parsers(File file) {
		parsers.keySet.filter[accept(file)].map[parsers.get(it)]
	}
	
}
