package net.danieldietrich.protectedregions

import static java.lang.Boolean.*
import static net.danieldietrich.protectedregions.parser.ModelBuilder.*
import java.util.List
import net.danieldietrich.protectedregions.parser.Leaf
import net.danieldietrich.protectedregions.parser.Node
import net.danieldietrich.protectedregions.parser.Parser

class ProtectedRegionParser {
	
	Parser parser
	
	new(Parser parser) {
		this.parser = parser
	}
	
	def parse(CharSequence input) {
		val ast = parser.parse(input)
		/*DEBUG*/println(ast)
		val List<Region> result = newArrayList()
		val buf = new StringBuffer()
		parse(ast, result, buf)
		if (buf.length > 0) {
			val region = result.last
			if (region == null || region.isMarked) {
				regionStart("", result, buf)
			} else {
				regionEnd("", result, buf)
			}
		}
		result
	}
	
	def private dispatch void parse(Node node, List<Region> regions, StringBuffer buf) {
		if (node.id == RegionStart) {
			val text = (node.children.head as Leaf).value
			regionStart(text, regions, buf)
		} else if (node.id == RegionEnd) {
			val text = (node.children.head as Leaf).value
			regionEnd(text, regions, buf)
		} else {
			node.children.forEach[parse(regions, buf)]
		}
	}
	
	def private dispatch void parse(Leaf node, List<Region> regions, StringBuffer buf) {
		buf.append(node.value)
	}
	
	def private regionStart(String text, List<Region> regions, StringBuffer buf) {
		buf.append(text)
		val region = regions.last
		if (region == null || region.isMarked) {
			regions.add(new Region(buf.toString, getId(text))) // create generated region
			buf.setLength(0)
		} // else IllegalStateException("Missing end of protected region")
	}
	
	def private regionEnd(String text, List<Region> regions, StringBuffer buf) {
		val region = regions.last
		if (region != null && !region.isMarked) {
			regions.add(new Region(buf.toString, null))
			buf.setLength(0)
		} // else IllegalStateException("Missing start of protected region")
		buf.append(text)
	}
	
	def private getId(String markedRegionStart) {
		val i = markedRegionStart.indexOf("(")
      	val j = 1 + i + markedRegionStart.substring(i + 1).indexOf(")")
      	return if (i != -1 && j != -1) markedRegionStart.substring(1 + i, j).trim() else null
	}
	
}
