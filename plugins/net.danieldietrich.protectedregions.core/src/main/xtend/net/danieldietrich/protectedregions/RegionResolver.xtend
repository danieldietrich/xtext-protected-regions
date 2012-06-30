package net.danieldietrich.protectedregions

import java.util.regex.Pattern

/**
 * The prototype for resolvers of protected regions.
 * Write your own resolvers by implementing getId() and isEnabled().
 * Pass regular expressions for protected region start and end to the constructor.
 * The id has to be the first regex group (denoted by '(' and ')').
 * The enabled part has to be the second regex group.
 * If additional groups are nescessary they have to be disabled using '(?:' and ')'.
 * Nested groups are allowed, e.g. '(?:xxx(xxx))*'.
 */
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

	def String getId(String regionStart) {
		getString(regionStart, 1)
	}

	def getEnabled(String regionStart) {
		getString(regionStart, 2)
	}
	
	/** To be implemented by custom resolvers. */
	def boolean isEnabled(String regionStart)
	
	def protected getString(String regionStart, int group) {
		val matcher = start.matcher(regionStart)
		val found = matcher.find()
		if (!found) null else matcher.group(group)
	}
	
}

class DefaultProtectedRegionResolver extends RegionResolver {
	
	static val ID = "([\\p{L}\\p{N}\\.:_$]*)"
	static val PR_START = "PROTECTED\\s+REGION\\s+ID\\s*\\(\\s*"+ ID +"\\s*\\)\\s+(?:(ENABLED)\\s+)?START"
	static val PR_END = "PROTECTED\\s+REGION\\s+END"
	
	new() { super(PR_START, PR_END) }
	
	override isEnabled(String regionStart) {
		"ENABLED".equals(getEnabled(regionStart)?.trim)
	}
	
}

class DefaultGeneratedRegionResolver extends RegionResolver {

	static val ID = "([\\p{L}\\p{N}\\.:_$]*)"
	static val GR_START = "GENERATED\\s+REGION\\s+ID\\s*\\(\\s*"+ ID +"\\s*\\)\\s+(?:(ENABLED)\\s+)?START"
	static val GR_END = "GENERATED\\s+REGION\\s+END"
	
	new() { super(GR_START, GR_END) }
	
	override isEnabled(String regionStart) {
		"ENABLED".equals(getEnabled(regionStart)?.trim)
	}
	
}
