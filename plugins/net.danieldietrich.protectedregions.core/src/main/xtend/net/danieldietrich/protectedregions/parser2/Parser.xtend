package net.danieldietrich.protectedregions.parser2

import static net.danieldietrich.protectedregions.util.Strings.*

import net.danieldietrich.protectedregions.parser2.Element
import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.Some

@Data class Parser {

	extension ElementExtensions = new ElementExtensions
	extension ModelExtensions = new ModelExtensions
	extension TreeExtensions = new TreeExtensions

	val String name
	val Node<Element> model

	def parse(CharSequence original) {
		val input = original.toString()
		val Node<String> output = Node(model.id)
		parse(model, input, output)
		output
	}
	
	/**
	 * The parser algortihm.
	 * 
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
	def private parse(Node<Element> model, String input, Node<String> output) {
		
		val start = model.start
		val end = model.end
		val children = model.nodes // it is specific for the model that the children are of type Node (vice versa)

//		if (start.isEmpty())

		// TODO: ...
//		val currIndex = index
		
//		val next = children.fold(end, [leaf, child | min(leaf, child.start).apply(input, currIndex)])
//		val value = next.unpack // returns NoElement if next is None
//		
//		if (next == model.end) {
//			output.add(something)
//		} else if (value == NoElement) {
//			throw new IllegalStateException(name + " parser: no viable next element found for " + model.id + " at " + lineAndColumn(input, currIndex))
//		} else 
//			val leaf = next.get
//			if (leaf.isRoot)
//				Some :
//				None :
//			}
//		}
//			output.add(new Leaf<Element>('Text', input.copy(end, currIndex)))
//		} else {
//			switch next {
//				Element   : new None<Element>
//				NoElement : 
//			}
//		}
		
//		switch next {
//			Node<Element> : parse(next, input, output, startPosition)
//			Leaf<Element> :
//		}
		
	}
	
//	/** Returns a closure wich computes which element of {l1, l2} occurs first in input, starting with index. */
//	def private min(Option<Leaf<Element>> o1, Option<Leaf<Element>> o2) {
//		[String input, int index |
//			val l1 = o1.unpack
//			val l2 = o2.unpack
//			val m1 = l1.indexOf(input, index)
//			val m2 = l2.indexOf(input, index)
//			if (m1.found) {
//				if (!m2.found || m1.index < m2.index || (m1.index == m2.index && m1.length >= m2.length)) {
//					l1
//				} else {
//					l2
//				}
//			} else {
//				if (m2.found) {
//					l1
//				} else {
//					new None<Element>
//				}
//			}				
//// DELME: if (l1.unpack.ahead(l2.unpack, input, index)) l1 else l2
//		]
//	}
//	
//	def private copy(String input, Option<Leaf<Element>> o) {
//		
//	}
	
	
	
//		var index = startIndex
//		var finished = false
//		
//		do {
//
//			val currIndex = index // final var needed to refer from closure
//			val child = model.children.reduce(m1, m2 | if (m1.start.ahead(m2.start, input, currIndex)) m1 else m2)
//			val childMatch = if (child == null) NOT_FOUND else child.start.indexOf(input, currIndex)
//			val endMatch = model.end.indexOf(input, currIndex)
//			
//			// parse child if found and it is ahead of current model end
//			if (childMatch.found && (!endMatch.found || child.start.ahead(model.end, input, currIndex))) {
//				if (currIndex < childMatch.index) output.add(Text(input.substring(currIndex, childMatch.index)))
//				val unit = output.add(Node(child.symbol.name, Text(input.substring(childMatch.index, childMatch.end))))
//				index = if (child.end.isNone) childMatch.end else parse(child, input, unit, childMatch.end, depth+1)
//			} else if (endMatch.found) {
//				if (currIndex < endMatch.index) output.add(Text(input.substring(currIndex, endMatch.index)))
//				if (model != model.root) output.add(Text(input.substring(endMatch.index, endMatch.end)))
//				index = endMatch.end
//				finished = true
//			} else {
//				throw new IllegalStateException(name + " parser: end of " + model.symbol.name + " not found at " + lineAndColumn(input, currIndex))
//			}
//			
//		} while(!finished)
//		
//		index
//	}
//	
//	def static Node Node(String id, Tree... children) {
//		val node = new Node(id)
//		children.forEach[node.add(it)]
//		node
//	}
//
//	def private Text(String value) {
//		new Leaf("Text", value)
//	}
//	
//	def private isNone(Element e) {
//		typeof(None).equals(e.getClass)
//	}
	
}
