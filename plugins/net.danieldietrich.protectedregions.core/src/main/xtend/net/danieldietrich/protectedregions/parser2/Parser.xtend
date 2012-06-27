package net.danieldietrich.protectedregions.parser2

import static net.danieldietrich.protectedregions.util.Strings.*

import net.danieldietrich.protectedregions.parser2.Element
import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.Some

/**
 * Idea
 * ----
 * The underlying model of the parser denotes some kind of grammar. It is a tree, consisting of nodes and leafs.
 * Each tree element has two children 'Start' and 'End' which mark then beginning and the end of a text block.
 * | These marker elements have different strategies, when it comes to finding the first matching index in a String.
 * | E.g. there are different element types for plain strings, regular expressions, lists of elements etc.
 * | See Element.indexOf(String, int) and its implementations for more information.
 * Of course the inner nodes of the model (tree) have children, which occur before the end marker of the parent node.
 * The parser starts at the beginning of the input string, traversing the model while searching for marker matches.
 * The output of the parser is a tree, consisting of the matched text of each model element (plus the text between matches).
 * 
 * Algorithm
 * ---------
 * 1) get start, end and children of current model element
 * 2) get next occurrence of end + children
 * 3) if None -> Exception(Unexpected End)
 * 4) if Some
 * 4.1) if end found (may be NoElement) -> save text (last match to end) Finished iteration
 * 4.2) if child found -> save text (last match to child.start) and recurse with new model element = child
 * 5) if not finished, repeat with step 2)
 * 
 * A few words about extensions used
 * ---------------------------------
 * Because we don't want to cope with NullPointers, here are so called Options used.
 * An Option<T> is a type defining a container for a value of type T.
 * There are two implementations of Option: Some<T> and None<T>. Some.get returns the value,
 * None has no value and is used here instead of null. The difference to null is, that None is
 * an object which can be further processed.
 * 
 * Tree leafs contain values. In particular, the model leafs contain values of type Element.
 * ModelExtensions provides to mothods for searching start and end of a text block.
 * Given a node, node.start and node.end return an Option<Leaf<Element>>, which is
 * Some<Leaf<Element>>, if the leaf is found or else None<Leaf<Element>>.
 * Some.get results in a Leaf<Element> which is not null.
 * 
 * ElementExtensions provides a method to get the Element of an Option<Leaf<Element>>.
 * E.g. node.start.unpack yields an Option<Element>, if node.start is Some<Leaf<Element>> or else None<Element>. 
 * 
 */
@Data class Parser {

	extension ElementExtensions = new ElementExtensions
	extension ModelExtensions = new ModelExtensions
	extension TreeExtensions = new TreeExtensions

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
			val next = children.fold(end, [leaf, child | min(leaf, child.start, input, currIndex)])
			
			switch next {
				Some<Leaf<Element>> : {
					val match = next.unpack.get.indexOf(input, currIndex)
					if (currIndex < match.index) {
						output.add(Text(input.substring(currIndex, match.index)))
					}
					if (next == end) {
						if (!end.unpack.get.isNoElement) {
							if (model != model.root) {
								output.add(Text(input.substring(match.index, match.end)))
							}
							index = match.end
						}
						finished = true
					} else {
						val child = next.get.parent
						val ast = Node(child.id, Text(input.substring(match.index, match.end)))
						output.add(ast)
						index = if (end.unpack.get.isNoElement) match.end else parse(child, input, ast, match.end)						
					}
				}
				None<Leaf<Element>> : {
					throw new IllegalStateException(
						name +" parser: no viable match for model element "+
						model.id +" found at "+ lineAndColumn(input, currIndex))
					}
			}
		} while (!finished)
		
		index
		
	}
	
	/**
	 * The leaf (Option) whose Element occurs first in input (starting the search at given index)
	 * or None, if nothing matches at all. 
	 */
	def private min(Option<Leaf<Element>> l1, Option<Leaf<Element>> l2, String input, int index) {
		val e1 = l1.unpack
		val e2 = l2.unpack
		switch e1 {
			Some<Element> : switch e2 {
				Some<Element> : if (e1.get.ahead(e2.get, input, index)) l1 else l2
				None<Element> : l1
			}
			None<Element> : switch e2 {
				Some<Element> : l2
				None<Element> : new None<Leaf<Element>>
			}
		}
	}
	
	def private isNoElement(Element e) {
		switch e {
			NoElement : true
			default : false
		}
	}
	
	def private Text(String value) {
		new Leaf('Text', value)
	}
	
}
