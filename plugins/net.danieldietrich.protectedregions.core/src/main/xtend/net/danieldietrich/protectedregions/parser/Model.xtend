package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.parser.Match.*
import static net.danieldietrich.protectedregions.util.Strings.*

import java.util.List
import java.util.regex.Pattern;

/** A model is built by blocks with start/end Element and children between. */
class Model {
	
	@Property var Model root = this
	@Property val List<Model> children = newArrayList()
	@Property val Symbol symbol
	@Property val Element start
	@Property val Element end

	new(Symbol symbol, Element start, Element end) {
		this._symbol = symbol
		this._start = start
		this._end = end
	}

	def add(Model child) {
		if (child == root && child != this) {
			children.addAll(root.children)
		} else {
			children.add(child)
			child.root = root
		}
		child
	}
	
	override toString() { toString(0) }
	
	def private String toString(int depth) {
		val indent = indent(depth)
    	indent + symbol.name +"("+ start +", "+ end +")"+
    		if (children.size == 0) ""
    		else "(\n"+ children.map[toString(depth+1)].reduce(l,r | l +",\n"+ r) +"\n"+ indent +")"
	}
	
}

@Data class Symbol {
	val String name
}

/** Elements can be located within a string. */
abstract class Element {
	
	def Match indexOf(String source, int index)
	
	def ahead(Element that, String input, int index) {
		val m1 = this.indexOf(input, index)
		val m2 = that.indexOf(input, index)
		!m2.found || (m1.found && (m1.index < m2.index || (m1.index == m2.index && m1.length >= m2.length)))
	}
	
}

/** A string element, indexOf is a string match. */
class Str extends Element {
	
	val String s

	new(String s) {
		this.s = s
	}
	
	override indexOf(String source, int index) {
		val int i = source.indexOf(s, index)
		if (i == -1) NOT_FOUND else new Match(i, s.length)
	}
	
	override String toString() {
		"Str("+ s.replaceAll("\\r", "\n").replaceAll("\\n+", "<EOL>").replaceAll("\\s+", " ") +")"
	}
	
}

/** An reqular expression element, indexOf is a pattern match. */
class RegEx extends Element {
	
	val Pattern pattern
	
	new(String regEx) {
		pattern = Pattern::compile(regEx)
	}
	
	override indexOf(String source, int index) {
		val m = pattern.matcher(source)
		val found = m.find(index)
		if (found) new Match(m.start, m.end - m.start) else NOT_FOUND
	}
	
	override String toString() {
		"RegEx("+ pattern.pattern() + ")"
	}
	
}

/** A list of elements, indexOf matches one or none of them. */
class Some extends Element {
	
	val Element[] elements
	
	new(Element... elements) {
		if (elements.size == 0) throw new IllegalArgumentException("No elements specified")
		this.elements = elements
	}
	
	override indexOf(String source, int index) {
		val e = elements.reduce(e1, e2 | if (e1.ahead(e2, source, index)) e1 else e2)
		if (e == null) NOT_FOUND else e.indexOf(source, index)
	}
	
	override String toString() {
		"Some("+ elements.map[toString].reduce(s1, s2 | s1 +", "+ s2) +")"
	}
	
}

/** Placeholder for no element, indexOf is not supported. */
class None extends Element {
	
	override indexOf(String source, int index) {
		throw new UnsupportedOperationException()
	}
	
	override String toString() {
		"None"
	}
	
}

/** A sequence of elements, indexOf matches their concatenation or none. */
class Seq extends Element {
	
	val Element[] sequence
	
	new(Element... sequence) {
		if (sequence.size == 0) throw new IllegalArgumentException("Empty sequence not allowed")
		this.sequence = sequence
	}
	
	override indexOf(String source, int index) {
		sequence.map[indexOf(source, index)].reduce(m1, m2 |
			if (m1 == NOT_FOUND || m2 == NOT_FOUND || m2.index != m1.index + m1.length)
				NOT_FOUND
			else
				new Match(m1.index, m1.length + m2.length)
		)
	}
	
	override String toString() {
		"Seq("+ sequence.map[toString].reduce(s1, s2 | s1 +", "+ s2) +")"
	}
	
}

/** A location of a string match. */
@Data class Match {
	
	public static val NOT_FOUND = new Match(-1, -1)
	
	val int index
	val int length
	
	def boolean found() { index > -1 }
	def int end() { index + length }
	
}
