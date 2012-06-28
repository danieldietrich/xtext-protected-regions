package net.danieldietrich.protectedregions.parser

import static extension net.danieldietrich.protectedregions.parser.ModelExtensions.*
import static extension net.danieldietrich.protectedregions.parser.TreeExtensions.*

import static net.danieldietrich.protectedregions.util.Strings.*

/**
 * The underlying model of the parser denotes some kind of grammar. It is a tree, consisting of nodes and leafs.
 * Each tree element has two children 'Start' and 'End' which mark then beginning and the end of a text block.
 * Of course the inner nodes of the model (tree) have children, which may occur before the end marker of the parent node.
 * The parser starts at the beginning of the input string, traversing the model while searching for marker matches.
 * The output of the parser is a tree, consisting of the matched text of each model element (plus the text between matches).
 */
@Data class Parser {

	val String name
	val Node<Element> model

	/** Applies the parser model to the given CharSequence and returns the corresponding AST. */
	def parse(CharSequence original) {
		val input = original.toString()
		val Node<String> output = Node(model.id)
		parse(model, input, output, 0)
		output
	}
	
	def private parse(Node<Element> model, String input, Node<String> output, int startIndex) {
		
		val end = model.end
		val children = model.nodes // it is specific for the model that the children are of type Node (vice versa)
		
		var finished = false
		var index = startIndex
		
		do {
			
			val currIndex = index
			val Leaf<Element> next = children.fold(end, [leaf, child | min(leaf, child.start, input, currIndex)])
			val match = next.value.indexOf(input, currIndex)
			val hasEnd = !end.value.isNoElement

			if (hasEnd && !match.found) {
				throw new IllegalStateException(name +" parser: "+ end.value.toString +" not found at "+ lineAndColumn(input, index))
			}
			if (currIndex < match.index) {
				output.add(input.copy(currIndex, match.index))
			}
			if (next == end) {
				if (hasEnd) {
					if (model != model.root) {
						output.add(input.copy(match))
					}
					index = match.end
				}
				finished = true
			} else {
				val child = next.parent
				val ast = Node(child.id, input.copy(match))
				output.add(ast)
				index = if (!hasEnd) match.end else parse(child, input, ast, match.end)						
			}
			
		} while (!finished)
		
		index
		
	}
	
	/** Returns the leaf whose Element occurs first in input (starting the search at given index). */
	def private min(Leaf<Element> l1, Leaf<Element> l2, String input, int index) {
		if (l1.value.ahead(l2.value, input, index)) l1 else l2
	}
	
	def private isNoElement(Element e) {
		switch e {
			None : true
			default : false
		}
	}
	
	def private copy(String input, int beginIndex, int endIndex) {
		new Leaf('Text', input.substring(beginIndex, endIndex))
	}

	def private copy(String input, Match match) {
		copy(input, match.index, match.end)
	}
		
}
