package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.parser.Match.*

import java.util.regex.Pattern
import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.Some

/** Extensions helping model builders. */
class ModelExtensions {
	
	extension ElementExtensions = new ElementExtensions()
	extension TreeExtensions = new TreeExtensions()
	
	def Model(String id, Element start, Element end) {
		if (NoElement.equals(start)) throw new IllegalArgumentException("The start element cannot be NoElement.")
		new Node<Element>(id) => [
			add(new Leaf<Element>('Start', start))
			add(new Leaf<Element>('End', end))
		]
	}
	
	def Model(String id, String start, Element end) {
		Model(id, StrElement(start), end)
	}

	def Model(String id, String start, String end) {
		Model(id, StrElement(start), StrElement(end))
	}
	
	def start(Node<Element> node) {
		node.leafs.find('Start')
	}

	def end(Node<Element> node) {
		node.leafs.find('End')
	}

}

/** Syntactic sugar creating elements. */
class ElementExtensions {
	
	public val EOL = SomeElement(StrElement("\r\n"), StrElement("\n"), StrElement("\r"))
	
	def GreedyElement(String s) {
		new GreedyElement(s)
	}
	
  	def NoElement() {
		new NoElement()
	}

	// Scala's parser combinator regex style
	def r(String regEx) {
		new RegExElement(regEx)
	}
	
	def SeqElement(Element... sequence) {
		new SeqElement(sequence)
	}
	
	def SomeElement(Element... elements) {
  		new SomeElement(elements)
  	}
  	
	def StrElement(String s) {
		new StrElement(s)
	}
	
	/** Returns a Some<Element> of the Element contained in o or None<Element>. */
	def unpack(Option<Leaf<Element>> o) {
		switch o {
			Some<Leaf<Element>> : new Some<Element>(o.get.value)
			None<Leaf<Element>> : new None<Element>
		}
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
class GreedyElement extends Element {

	val String s

	new(String s) {
		if (s.isNullOrEmpty) throw new IllegalArgumentException("GreedyElement argument cannot be empty")
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
		"GreedyElement("+ s.replaceAll("\\r", "\n").replaceAll("\\n+", "<EOL>").replaceAll("\\s+", " ") +")"
	}
	
}

/** Placeholder for no Element. */
class NoElement extends Element {
	
	/** By definition NoElement cannot be found. */
	override indexOf(String source, int index) {
		NOT_FOUND
	}
	
	override String toString() {
		"NoElement"
	}
	
}

/** An reqular expression element. */
class RegExElement extends Element {
	
	val Pattern pattern
	
	new(String regEx) {
		if (regEx.isNullOrEmpty) throw new IllegalArgumentException("RegExElement argument cannot be empty")
		pattern = Pattern::compile(regEx)
	}
	
	/** Returns the first Match of this Pattern or NOT_FOUND. */
	override indexOf(String source, int index) {
		val m = pattern.matcher(source)
		val found = m.find(index)
		if (found) new Match(m.start, m.end - m.start) else NOT_FOUND
	}
	
	override String toString() {
		"RegExElement("+ pattern.pattern() + ")"
	}
	
}

/** A sequence of Elements. */
class SeqElement extends Element {
	
	val Element[] sequence
	
	new(Element... sequence) {
		if (sequence.size == 0) throw new IllegalArgumentException("SeqElement argument needs at least one Element")
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
		"SeqElement("+ sequence.map[toString].reduce(s1, s2 | s1 +", "+ s2) +")"
	}
	
}

/** A list of possibilities. */
class SomeElement extends Element {
	
	val Element[] elements
	
	new(Element... elements) {
		if (elements.size == 0) throw new IllegalArgumentException("SomeElement argument needs at least one Element")
		this.elements = elements
	}
	
	/** Returns the Match of the Element occurring first or NOT_FOUND. */
	override indexOf(String source, int index) {
		val e = elements.reduce(e1, e2 | if (e1.ahead(e2, source, index)) e1 else e2)
		if (e == null) NOT_FOUND else e.indexOf(source, index)
	}
	
	override String toString() {
		"SomeElement("+ elements.map[toString].reduce(s1, s2 | s1 +", "+ s2) +")"
	}
	
}

/** A plain String representation. */
class StrElement extends Element {
	
	val String s

	new(String s) {
		if (s.isNullOrEmpty) throw new IllegalArgumentException("StrElement argument cannot be empty")
		this.s = s
	}

	/** Returns the first Match of this String or NOT_FOUND. */	
	override indexOf(String source, int index) {
		val int i = source.indexOf(s, index)
		if (i == -1) NOT_FOUND else new Match(i, s.length)
	}
	
	override String toString() {
		"StrElement("+ s.replaceAll("\\r", "\n").replaceAll("\\n+", "<EOL>").replaceAll("\\s+", " ") +")"
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
