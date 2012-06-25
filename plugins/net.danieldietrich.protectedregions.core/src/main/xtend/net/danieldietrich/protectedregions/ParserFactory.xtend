package net.danieldietrich.protectedregions

import static net.danieldietrich.protectedregions.Symbols.*

import com.google.inject.Inject
import net.danieldietrich.protectedregions.parser.Element
import net.danieldietrich.protectedregions.parser.GreedyStr
import net.danieldietrich.protectedregions.parser.Leaf
import net.danieldietrich.protectedregions.parser.Model
import net.danieldietrich.protectedregions.parser.None
import net.danieldietrich.protectedregions.parser.Parser
import net.danieldietrich.protectedregions.parser.RegEx
import net.danieldietrich.protectedregions.parser.Seq
import net.danieldietrich.protectedregions.parser.Some
import net.danieldietrich.protectedregions.parser.Str
import net.danieldietrich.protectedregions.parser.Symbol

class ParserFactory {
	
	@Inject extension ModelBuilder
	
	def javaParser(RegionResolver... optionalResolver) {
		parser("java", model(optionalResolver)[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		])
	}
	
	def xmlParser(RegionResolver... optionalResolver) {
		parser("xml", model(optionalResolver)[
			comment("<!--", "-->")
			string("<![CDATA[", "]]>")
			string("'")
			string('"')
		])
	}
	
	def xtendParser(RegionResolver... optionalResolver) {
		parser("xtend", model(optionalResolver)[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
			string("'''").withCode("«", "»") // .withCode("\u00ab", "\u00ba") // french braces
		])
	}
	
	def private parser(String name, Model model) {
		new ProtectedRegionParser(
			new Parser(name, model)
		)
	}
	
}

//  @Inject extension ParserBuilder
//
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

@Data class ProtectedRegionParser {
	
	val Parser parser
	
	def parse(CharSequence input) {
		val ast = parser.parse(input)
		
		println("### AST ###\n"+ ast +"\n")
		
		println("### TRAVERSE ###")
		ast.traverse[switch it {
			Leaf : print(it.value)
		}]
		
		val Region[] result = newArrayList()
		result
	}
	
//	new(Parser parser) {
//		this.parser = parser
//	}
//	
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
@Data class Region {

	val String id
	val String content

	def isMarked() {
		id != null
	}
	
}

class Symbols {
	
	public static val Code = new Symbol("Code")
	public static val Comment = new Symbol("Comment")
	public static val Escape = new Symbol("Escape")
	public static val RegionStart = new Symbol("RegionStart")
	public static val RegionEnd = new Symbol("RegionEnd")
	public static val String = new Symbol("String")
	
}

// TODO: move ModelBuilder to the outside (to ParserFactory, which needs it?)
// TODO: def greedyString(Model model, String s)
class ModelBuilder {
	
	static val DEFAULT_REGION_RESOLVER = new DefaultProtectedRegionResolver()
	static val EOL = Some(Str("\r\n"), Str("\n\r"), Str("\n"), Str("\r"))
	
	def model(RegionResolver[] optionalResolver, (Model)=>void initializer) {
		if (optionalResolver.size > 1) throw new IllegalArgumentException("Some or none RegionResolver allowed.")
		val resolver = if (optionalResolver.size == 0) DEFAULT_REGION_RESOLVER else optionalResolver.get(0)
		val model = new Model(Code, RegEx("^"), RegEx("\\z"))
		initializer.apply(model)
		withRegions(model, resolver)
		model
	}
	
	def comment(Model model, String s) {
		val Model comment = new Model(Comment, Str(s), EOL)
		model.add(comment)
	}
	
	def comment(Model model, String start, String end) {
		val Model comment = new Model(Comment, Str(start), Str(end))
		model.add(comment)
	}
	
	def nestableComment(Model model, String start, String end) {
		val comment = new Model(Comment, Str(start), Str(end))
		model.add(comment)
		comment.add(comment) // recursive model
	}
	
	def string(Model model, String s) {
		model.add(new Model(String, Str(s), Str(s)))
	}

	def greedyString(Model model, String s) {
		model.add(new Model(String, Str(s), GreedyStr(s)))
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
  	
  	def private void withRegions(Model model, RegionResolver resolver) {
  		if (model.symbol == Comment) {
  			model.add(new Model(RegionStart, RegEx(resolver.start.pattern), None))
  			model.add(new Model(RegionEnd, RegEx(resolver.end.pattern), None))
  		} else { // need 'else' here because of nested comments
  			model.children.forEach[withRegions(resolver)]
  		}
	}
	
	def private static Str(String s) {
		new Str(s)
	}
	
	def private static GreedyStr(String s) {
		new GreedyStr(s)
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
