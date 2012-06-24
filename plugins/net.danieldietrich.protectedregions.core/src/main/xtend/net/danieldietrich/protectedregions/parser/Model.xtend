package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.parser.Match.*
import static net.danieldietrich.protectedregions.util.Strings.*

import java.util.List
import java.util.regex.Pattern;

// TODO: def greedyString(Model model, String s)
class ModelBuilder {
	
	public static val Code = "Code";
	public static val Comment = "Comment";
	public static val Escape = "Escape";
	public static val RegionStart = "RegionStart";
	public static val RegionEnd = "RegionEnd";
	public static val String = "String";
	
	static String ID = "([a-zA-Z_$][a-zA-Z\\d_$]*\\.)*[a-zA-Z_$][a-zA-Z\\d_$]*"
	static String label = "PROTECTED\\s+REGION" // TODO(@@dd): if (inverse) "GENERATED" else "PROTECTED\\s+REGION"
	// TODO(@@dd): (^\\s*|\\s+) vs. \\s* and (\\s+|\\s*$) vs. \\s*
	static String start = label + "\\s+ID\\s*\\(\\s*" + ID + "\\s*\\)\\s+(ENABLED\\s+)?START"
    static String end = label + "\\s+END"
    
    static Model PR_START = new Model(RegionStart, RegEx(start), None())
    static Model PR_END = new Model(RegionEnd, RegEx(end), None())
	
	def model((Model)=>void initializer) {
		val model = new Model(Code, RegEx("^"), RegEx("\\z"))
		initializer.apply(model)
		model
	}
	
	def comment(Model model, String s) {
		val Model comment = new Model(Comment, Str(s), Some(Str("\r\n"), Str("\n\r"), Str("\n"), Str("\r")))
		model.add(comment)
		protectedRegion(comment)
	}
	
	def comment(Model model, String start, String end) {
		val Model comment = new Model(Comment, Str(start), Str(end))
		model.add(comment)
		protectedRegion(comment)
	}
	
	def nestableComment(Model model, String start, String end) {
		val comment = new Model(Comment, Str(start), Str(end))
		model.add(comment)
		protectedRegion(comment)
		comment.add(comment) // recursive model
	}
	
	def string(Model model, String s) {
		model.add(new Model(String, Str(s), Str(s)))
	}
	
	def string(Model model, String start, String end) {
		model.add(new Model(String, Str(start), Str(end)))
	}
	
	def withEscape(Model model, String escape) {
		if (model == model.root) throw new IllegalStateException("<root>.withEscape() not allowed")
		model.add(new Model(Escape, Seq(Str(escape), model.start), None()))
		model // return parent because escape models have no children
  	}
  	
  	def withCode(Model model, String start, String end) {
		if (model == model.root) throw new IllegalStateException("<root>.withCode() not allowed")
  		val code = new Model(Code, Str(start), Str(end))
  		model.add(code)
  		code.add(model.root)
  		model // return parent because code models have root as only child
  	}
  	
  	def private protectedRegion(Model model) {
		model.add(PR_START)
		model.add(PR_END)
		model // return parent because protected regions have no children
	}
	
	def private static Str(String s) {
		new Str(s)
	}
	
	def private static RegEx(String regEx) {
		new RegEx(regEx)
	}
	
	def private static Element Some(Element... elements) {
  		new Some(elements)
  	}
  	
  	def private static Element None() {
		new None()
	}
	
	def private static Element Seq(Element... sequence) {
		new Seq(sequence)
	}

}

class Model {
	
	@Property var Model root = this
	@Property val List<Model> children = newArrayList()
	@Property val String type
	@Property val Element start
	@Property val Element end

	new(String type, Element start, Element end) {
		this._type = type
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
    	indent + type +"("+ start +", "+ end +")"+
    		if (children.size == 0) ""
    		else "(\n"+ children.map[toString(depth+1)].reduce(l,r | l +",\n"+ r) +"\n"+ indent +")"
	}
	
}

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

/** A list of elements, indexof matches one or none of them. */
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

@Data class Match {
	
	public static val NOT_FOUND = new Match(-1, -1)
	
	val int index
	val int length
	
	def boolean found() { index > -1 }
	def int end() { index + length }
	
}
