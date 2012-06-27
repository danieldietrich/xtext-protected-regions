package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.parser.Leaf.*
import static net.danieldietrich.protectedregions.parser.Match.*
import static net.danieldietrich.protectedregions.parser.Node.*
import static net.danieldietrich.protectedregions.util.Strings.*

@Data class Parser {

	val String name
	val Model model
	
	def parse(CharSequence original) {
		val input = original.toString()
		val output = Node(model.symbol.name)
		parse(model, input, output, 0, 0)
		output
	}
	
	def private parse(Model model, String input, Node output, int startIndex, int depth) {

		var index = startIndex
		var finished = false
		
		do {

			val currIndex = index // final var needed to refer from closure
			val child = model.children.reduce(m1, m2 | if (m1.start.ahead(m2.start, input, currIndex)) m1 else m2)
			val childMatch = if (child == null) NOT_FOUND else child.start.indexOf(input, currIndex)
			val endMatch = model.end.indexOf(input, currIndex)
			
			// parse child if found and it is ahead of current model end
			if (childMatch.found && (!endMatch.found || child.start.ahead(model.end, input, currIndex))) {
				if (currIndex < childMatch.index) output.add(Text(input.substring(currIndex, childMatch.index)))
				val unit = output.add(Node(child.symbol.name, Text(input.substring(childMatch.index, childMatch.end))))
				index = if (child.end.isNone) childMatch.end else parse(child, input, unit, childMatch.end, depth+1)
			} else if (endMatch.found) {
				if (currIndex < endMatch.index) output.add(Text(input.substring(currIndex, endMatch.index)))
				if (model != model.root) output.add(Text(input.substring(endMatch.index, endMatch.end)))
				index = endMatch.end
				finished = true
			} else {
				throw new IllegalStateException(name + " parser: end of " + model.symbol.name + " not found at " + lineAndColumn(input, currIndex))
			}
			
		} while(!finished)
		
		index
	}
	
	def static Node Node(String id, Tree... children) {
		val node = new Node(id)
		children.forEach[node.add(it)]
		node
	}

	def private Text(String value) {
		new Leaf("Text", value)
	}
	
	def private isNone(Element e) {
		typeof(NoElement).equals(e.getClass)
	}
	
}
