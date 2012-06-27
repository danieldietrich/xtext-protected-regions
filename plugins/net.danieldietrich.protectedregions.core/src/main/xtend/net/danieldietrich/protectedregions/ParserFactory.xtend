package net.danieldietrich.protectedregions

import com.google.inject.Inject
import net.danieldietrich.protectedregions.DefaultProtectedRegionResolver
import net.danieldietrich.protectedregions.RegionResolver
import net.danieldietrich.protectedregions.parser2.Element
import net.danieldietrich.protectedregions.parser2.ElementExtensions
import net.danieldietrich.protectedregions.parser2.ModelExtensions
import net.danieldietrich.protectedregions.parser2.Node
import net.danieldietrich.protectedregions.parser2.Parser
import net.danieldietrich.protectedregions.parser2.TreeExtensions
import org.slf4j.LoggerFactory
import net.danieldietrich.protectedregions.parser2.Tree

class ParserFactory {
	
	static val DEFAULT_RESOLVER = new DefaultProtectedRegionResolver()
	
	@Inject extension ModelBuilder
	
	def javaParser(RegionResolver... optionalResolver) {
		parser("java", optionalResolver, model[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		])
	}
	
	def xmlParser(RegionResolver... optionalResolver) {
		parser("xml", optionalResolver, model[
			comment("<!--", "-->")
			string("<![CDATA[", "]]>")
			string("'")
			string('"')
		])
	}
	
	def xtendParser(RegionResolver... optionalResolver) {
		parser("xtend", optionalResolver, model[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
			string("'''").withCode("«", "»") // .withCode("\u00ab", "\u00ba") // french braces
		])
	}
	
//  def clojureParser() {
//    parser("clojure")[
//      comment(";")
//      string('"', "\\")
//    ]
//  }
//  
//  def cssParser() {
//    parser("css")[
//      comment("/*", "*/")
//      string('"').withEscape("\\")
//    ]
//  }
//
//  def htmlParser() {
//    caseInsensitiveParser("html")[
//      comment("<!--", "-->")
//      string("<![CDATA[", "]]>")
//      string("'")
//      string('"')
//    ]
//  }
//  
//  def javaParser() {
//    parser("java")[
//      comment("//")
//      comment("/*", "*/")
//      string('"').withEscape("\\")
//      string("'").withEscape("\\")
//    ]
//  }
//  
//  def jsParser() {
//    parser("js")[
//      comment("//")
//      comment("/*", "*/")
//      string('"').withEscape("\\")
//      string("'").withEscape("\\")
//    ]
//  }
//  
//  def phpParser() {
//    parser("php")[
//      comment("#")
//      comment("//")
//      comment("/*", "*/")
//      string('"').withEscape("\\")
//      string("'").withEscape("\\")
//    ]
//  }
//  
//  def rubyParser() {
//    parser("ruby")[
//      comment("#")
//      string("'").withEscape("\\")
//      string('"').withEscape("\\")
//    ]
//  }
//  
//  def scalaParser() {
//    parser("scala")[
//      comment("//")
//      nestableComment("/*", "*/")
//      string('"').withEscape("\\")
//      string("'").withEscape("\\")
//      greedyString('"""')
//    ]
//  }
//  
//  def xtextParser() {
//    parser("xtext")[
//      comment("//")
//      comment("/*", "*/")
//      string('"').withEscape("\\")
//      string("'").withEscape("\\")
//    ]
//  }
	
	def private parser(String name, RegionResolver[] optionalResolver, Node<Element> model) {
		if (optionalResolver.size > 1) throw new IllegalArgumentException("Some or none RegionResolver allowed.")
		val resolver = if (optionalResolver.size == 0) DEFAULT_RESOLVER else optionalResolver.get(0)
// TODO: add protected region elements to model comments
//		model.augmentResolver(resolver)
		new ProtectedRegionParser(
			new Parser(name, model),
			resolver
		)
	}
	
//	def private void augmentResolver(Node<Element> model, RegionResolver resolver) {
//  		augmentResolver(model.root, resolver, newHashSet())
//	}
//
//  	def private void augmentResolver(Tree<Element> model, RegionResolver resolver, Set<Node<Element>> visited) {
//  		if (model.symbol == Comment) {
//  			model.add(new Model(RegionStart, RegExElement(resolver.start.pattern), NoElement))
//  			model.add(new Model(RegionEnd, RegExElement(resolver.end.pattern), NoElement))
//  		}
//  		visited.add(model)
//  		model.children.forEach[if (!visited.contains(it)) augmentResolver(resolver, visited)]
//	}
	
}

@Data class ProtectedRegionParser {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionParser))
	
	val Parser parser
	val RegionResolver resolver
	
	def parse(CharSequence input) {
		val ast = parser.parse(input)
		
		println("### AST ###\n"+ ast +"\n")
		
		println("### TRAVERSE ###")
		
//		val curr = new Region()
//		val List<Region> regions = newArrayList(curr)
//		val String[] id = newArrayList(false)
//		val boolean[] next = newArrayList(false)
//		
//		ast.traverse[switch it {
//			Node case id == RegionStart: {
//				if (in.get(0)) {
//					logger.warn("Nested region detected")
//				} else {
//					in.set(0, true)
//					next.set(0, true)
//				}
//			}
//			Node case id == RegionEnd: {
//				if (!in.get(0)) {
//					logger.warn("Missing region start")
//				} else {
//					in.set(0, false)
//					next.set(0, true)
//				}
//			}
//			Leaf: {
//				if (next) {
//					if ()
//					next.set(0, false)
//				}
//			}
//		}]
		
		val Region[] result = newArrayList()
		result
	}
	
//	def parse(CharSequence input) {
//		val ast = parser.parse(input)
//		/*DEBUG*/println(ast)
//		val List<Region> result = newArrayList()
//		val buf = new StringBuffer()
//		parse(ast, result, buf)
//		if (buf.length > 0) {
//			val region = result.last
//			if (region == null || region.isMarked) {
//				regionStart("", result, buf)
//			} else {
//				regionEnd("", result, buf)
//			}
//		}
//		result
//	}
//	
//	def private dispatch void parse(Node node, List<Region> regions, StringBuffer buf) {
//		if (node.id == RegionStart) {
//			val text = (node.children.head as Leaf).value
//			regionStart(text, regions, buf)
//		} else if (node.id == RegionEnd) {
//			val text = (node.children.head as Leaf).value
//			regionEnd(text, regions, buf)
//		} else {
//			node.children.forEach[parse(regions, buf)]
//		}
//	}
//	
//	def private dispatch void parse(Leaf node, List<Region> regions, StringBuffer buf) {
//		buf.append(node.value)
//	}
//	
//	def private regionStart(String text, List<Region> regions, StringBuffer buf) {
//		buf.append(text)
//		val region = regions.last
//		if (region == null || region.isMarked) {
//			regions.add(new Region(buf.toString, getId(text))) // create generated region
//			buf.setLength(0)
//		} // else IllegalStateException("Missing end of protected region")
//	}
//	
//	def private regionEnd(String text, List<Region> regions, StringBuffer buf) {
//		val region = regions.last
//		if (region != null && !region.isMarked) {
//			regions.add(new Region(buf.toString, null))
//			buf.setLength(0)
//		} // else IllegalStateException("Missing start of protected region")
//		buf.append(text)
//	}
//	
//	def private getId(String markedRegionStart) {
//		val i = markedRegionStart.indexOf("(")
//      	val j = 1 + i + markedRegionStart.substring(i + 1).indexOf(")")
//      	return if (i != -1 && j != -1) markedRegionStart.substring(1 + i, j).trim() else null
//	}
	
}

// TODO: needing this class?
// TODO: isEnabled()
@Data class Region {

	val String id
	val String content

	def isMarked() {
		id != null
	}
	
}

// cycles definitely allowed when building models because of nested- and code-structures
class ModelBuilder {

	@Inject extension ElementExtensions
	@Inject extension ModelExtensions	
	@Inject extension TreeExtensions	
	
	def model((Node<Element>)=>void initializer) {
		val model = Model('Code', "^".r, "\\z".r)
		initializer.apply(model)
		model
	}
	
	def comment(Node<Element> model, String s) {
		val comment = Model('Comment', s, EOL)
		model.add(comment)
		comment
	}
	
	def comment(Node<Element> model, String start, String end) {
		val comment = Model('Comment', start, end)
		model.add(comment)
		comment
	}
	
	def nestableComment(Node<Element> model, String start, String end) {
		val comment = Model('Comment', start, end)
		model.add(comment)
		comment.add(comment) // recursive model
	}
	
	def string(Node<Element> model, String s) {
		val string = Model('String', s, s)
		model.add(string)
		string
	}

	def greedyString(Node<Element> model, String s) {
		val greedy = Model('String', s, GreedyElement(s))
		model.add(greedy)
		greedy
	}
		
	def string(Node<Element> model, String start, String end) {
		val string = Model('String', start, end)
		model.add(string)
		string
	}
	
	def withEscape(Node<Element> model, String escape) {
		if (model == model.root) throw new IllegalStateException(model.id +".withEscape() not allowed at root node")
		// model.start.unpack.get allowed, because ModelExtension.Model ensures model.start is never None
		model.add(Model('Escape', SeqElement(StrElement(escape), model.start.unpack.get), NoElement))
		model // return parent because escape models have no children
  	}
  	
  	def withCode(Node<Element> model, String start, String end) {
		if (model == model.root) throw new IllegalStateException(model.id +".withCode() not allowed at root node")
  		val code = Model('Code', start, end)
  		model.add(code)
  		code.add(model.root.children as Tree<Element>[])
  		model // return parent because code models have root as only child
  	}
  	
}
