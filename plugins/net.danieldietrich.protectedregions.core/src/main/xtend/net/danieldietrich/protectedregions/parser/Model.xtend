package net.danieldietrich.protectedregions.parser

import static extension net.danieldietrich.protectedregions.parser.ElementExtensions.*
import static extension net.danieldietrich.protectedregions.parser.TreeExtensions.*

import static net.danieldietrich.protectedregions.parser.Match.*

import java.util.regex.Pattern

abstract class ModelExtensions {
	
	def static Model(String id, Element start, Element end) {
		if (typeof(None).equals(start.getClass)) throw new IllegalArgumentException("The start element cannot be None.")
		new Node<Element>(id) => [
			add(new Leaf<Element>('Start', start))
			add(new Leaf<Element>('End', end))
		]
	}
	
	def static Model(String id, String start, Element end) {
		Model(id, start.str, end)
	}

	def static Model(String id, String start, String end) {
		Model(id, start.str, end.str)
	}
	
	def static start(Node<Element> node) {
		node.leafs.find('Start')
	}

	def static end(Node<Element> node) {
		node.leafs.find('End')
	}

}

abstract class ElementExtensions {
	
	def static greedy(String s) {
		new GreedyStr(s)
	}
	
	def static Dynamic(()=>Element delegate) {
		new Dynamic(delegate)
	}
	
  	def static None() {
		new None()
	}

	// Scala's parser combinator regex style
	def static r(String regEx) {
		new RegEx(regEx)
	}
	
	def static Seq(Element... sequence) {
		new Seq(sequence)
	}
	
	def static Some(Element... elements) {
  		new Some(elements)
  	}
  	
	def static str(String s) {
		new Str(s)
	}
	
}

/** Element which can be located within a String. */
abstract class Element {
	
	/** Returns an implementation specific Match of this Element, maybe NOT_FOUND. */
	def Match indexOf(String source, int index)

	/**
	 * Checks if this.indexOf(input, index) < that.indexOf(input, index).
	 * Also true if that not found or indexes are equal and that.length < this.length.
	 */
	def ahead(Element that, String input, int index) {
		val m1 = this.indexOf(input, index)
		val m2 = that.indexOf(input, index)
		!m2.found || (m1.found && (m1.index < m2.index || (m1.index == m2.index && m1.length >= m2.length)))
	}
	
}

/** A greedy String representation. */
class GreedyStr extends Element {

	val String s

	new(String s) {
		if (s.isNullOrEmpty) throw new IllegalArgumentException("GreedyStr argument cannot be empty")
		s.toCharArray.reduce[x,y | if (x == y) x else throw new IllegalArgumentException("All characters have to be equal")]
		this.s = s
	}
	
	/**
	 * Returns the first greedy Match of this String or NOT_FOUND.
	 * Example: new GreedyElement("'''").indexOf("Test''''123", 0) returns Match(5, 3) remaining "123"
	 */
	override indexOf(String source, int index) {
		var int i = source.indexOf(s, index)
		while (source.indexOf(s, i+1) == i+1) i = i + 1
		if (i == -1) NOT_FOUND else new Match(i, s.length)
	}

	override String toString() {
		"GreedyStr("+ s.replaceAll("\\r", "\n").replaceAll("\\n+", "<EOL>").replaceAll("\\s+", " ") +")"
	}
	
}

/** A late bindable Element. */
class Dynamic extends Element {
	
	val ()=>Element delegate
	
	new(()=>Element delegate) {
		this.delegate = delegate
	}
	
	override indexOf(String source, int index) {
		delegate.apply().indexOf(source, index)
	}
	
	override String toString() {
		"Dynamic("+ delegate.apply() +")"
	}
	
}

/** Placeholder for no Element. */
class None extends Element {
	
	/** By definition NoElement cannot be found. */
	override indexOf(String source, int index) {
		NOT_FOUND
	}
	
	override String toString() {
		"None"
	}
	
}

/** An reqular expression element. */
class RegEx extends Element {
	
	val Pattern pattern
	
	new(String regEx) {
		if (regEx.isNullOrEmpty) throw new IllegalArgumentException("RegEx argument cannot be empty")
		pattern = Pattern::compile(regEx)
	}
	
	/** Returns the first Match of this Pattern or NOT_FOUND. */
	override indexOf(String source, int index) {
		val m = pattern.matcher(source)
		val found = m.find(index)
		if (found) new Match(m.start, m.end - m.start) else NOT_FOUND
	}
	
	override String toString() {
		"RegEx("+ pattern.pattern() +")"
	}
	
}

/** A sequence of Elements. */
class Seq extends Element {
	
	val Element[] sequence
	
	new(Element... sequence) {
		if (sequence.size == 0) throw new IllegalArgumentException("Seq argument needs at least one Element")
		this.sequence = sequence
	}
	
	/** Matches the concatenation of this sequence or NOT_FOUND. */
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

/** A list of possibilities. */
class Some extends Element {
	
	val Element[] elements
	
	new(Element... elements) {
		if (elements.size == 0) throw new IllegalArgumentException("Some argument needs at least one Element")
		this.elements = elements
	}
	
	/** Returns the Match of the Element occurring first or NOT_FOUND. */
	override indexOf(String source, int index) {
		val e = elements.reduce(e1, e2 | if (e1.ahead(e2, source, index)) e1 else e2)
		if (e == null) NOT_FOUND else e.indexOf(source, index)
	}
	
	override String toString() {
		"Some("+ elements.map[toString].reduce(s1, s2 | s1 +", "+ s2) +")"
	}
	
}

/** A plain String representation. */
class Str extends Element {
	
	val String s

	new(String s) {
		if (s.isNullOrEmpty) throw new IllegalArgumentException("Str argument cannot be empty")
		this.s = s
	}

	/** Returns the first Match of this String or NOT_FOUND. */	
	override indexOf(String source, int index) {
		val int i = source.indexOf(s, index)
		if (i == -1) NOT_FOUND else new Match(i, s.length)
	}
	
	override String toString() {
		"Str("+ s.replaceAll("\\r", "\n").replaceAll("\\n+", "<EOL>").replaceAll("\\s+", " ") +")"
	}
	
}

/** A location (index, length) of a string match. */
@Data class Match {
	
	public static val NOT_FOUND = new Match(-1, -1)
	
	val int index
	val int length
	
	def boolean found() { index > -1 }
	def int end() { index + length }
	
	override toString() {
		"Match("+ index +", "+ length +")"
	}
	
}
