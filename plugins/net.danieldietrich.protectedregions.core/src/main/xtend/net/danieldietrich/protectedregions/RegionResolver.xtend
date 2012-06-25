package net.danieldietrich.protectedregions

import java.util.regex.Pattern

abstract class RegionResolver {
	
	@Property val Pattern start
	@Property val Pattern end
	
	new(String start, String end) {
		if (start.isNullOrEmpty) throw new IllegalArgumentException("Start cannot be empty")
		if (end.isNullOrEmpty) throw new IllegalArgumentException("End cannot be empty")
		this._start = Pattern::compile(start)
		this._end = Pattern::compile(end)
	}
	
	def boolean isStart(String region) {
		start.matcher(region).matches
	}
	
	def boolean isEnd(String region) {
		end.matcher(region).matches
	}

	def boolean isEnabled(String regionStart)
	
	def String getId(String regionStart)

	/** Intended to be used by getId(String) */
	def protected getEnabled(String regionStart, int regExGroup) {
		val matcher = start.matcher(regionStart)
		val found = matcher.find()
		if (!found) null else matcher.group(regExGroup)
	}
		
	/** Intended to be used by getId(String) */
	def protected getId(String regionStart, int regExGroup) {
		val matcher = start.matcher(regionStart)
		val found = matcher.find()
		if (!found) null else matcher.group(regExGroup)
	}
	
}

class DefaultProtectedRegionResolver extends RegionResolver {
	
	static val ID = "([\\p{L}\\p{N}\\.:_$]*)"
	static val PR_START = "PROTECTED\\s+REGION\\s+ID\\s*\\(\\s*" + ID + "\\s*\\)\\s+(?:(ENABLED)\\s+)?START"
	static val PR_END = "PROTECTED\\s+REGION\\s+END"
	
	new() {
		super(PR_START, PR_END)
	}
	
	override getId(String regionStart) {
		getId(regionStart, 1)
	}
	
	override isEnabled(String regionStart) {
		"ENABLED".equals(getEnabled(regionStart, 2)?.trim)
	}
	
}

class DefaultGeneratedRegionResolver extends RegionResolver {

	static val ID = "([\\p{L}\\p{N}\\.:_$]*)"
	static val GR_START = "GENERATED\\s+REGION\\s+ID\\s*\\(\\s*" + ID + "\\s*\\)\\s+(?:(ENABLED)\\s+)?START"
	static val GR_END = "GENERATED\\s+REGION\\s+END"
	
	new() {
		super(GR_START, GR_END)
	}
	
	override getId(String regionStart) {
		getId(regionStart, 1)
	}
	
	override isEnabled(String regionStart) {
		"ENABLED".equals(getEnabled(regionStart, 2)?.trim)
	}
	
}
