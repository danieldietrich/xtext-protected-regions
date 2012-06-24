package net.danieldietrich.protectedregions.util

import static java.lang.Math.*
import java.util.regex.Pattern

class Strings {
	
	static Pattern EOL = Pattern::compile("(\\r\\n|\\n|\\r)")
	
	def static operator_multiply(int count, String s) {
		var result = new StringBuffer()
		var i = 0
		while (i < count) {
			result.append(s)
			i = i + 1
		}
		result.toString()
	}

	def static operator_multiply(String s, int count) {
		operator_multiply(count, s)
	}

	/**
	 * Returnes len*2 spaces.
	 * @param len
	 * @return
	 */
	def static indent(int times) {
		operator_multiply(times, "  ")
	}

	def static indent(int times, int width) {
		operator_multiply(times, operator_multiply(width, " "))
	}

	/**
	 * Computes line and column of index within s.
	 * @param s input
	 * @param index <= s.length
	 * @return [line,column]
	 */
	def static lineAndColumn(String s, int index) {
		val documentToCursor = s.substring(0, index)
		val matcher = EOL.matcher(documentToCursor)
		var line = 1
		while (matcher.find()) line = line + 1
		val eol = max(documentToCursor.lastIndexOf("\r"), documentToCursor.lastIndexOf("\n"))
		val len = documentToCursor.length()
		val column = if (len == 0) 1 else len - (if (eol == -1) 0 else eol)
		return "[" + line + "," + column + "]"
	}
	
}
