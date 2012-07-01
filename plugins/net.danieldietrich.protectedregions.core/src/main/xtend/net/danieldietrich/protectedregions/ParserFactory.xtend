package net.danieldietrich.protectedregions

import static extension net.danieldietrich.protectedregions.parser.ElementExtensions.*
import static extension net.danieldietrich.protectedregions.parser.ModelExtensions.*
import static extension net.danieldietrich.protectedregions.parser.TreeExtensions.*

import com.google.inject.Inject
import java.util.List
import net.danieldietrich.protectedregions.DefaultProtectedRegionResolver
import net.danieldietrich.protectedregions.RegionResolver
import net.danieldietrich.protectedregions.parser.Element
import net.danieldietrich.protectedregions.parser.Leaf
import net.danieldietrich.protectedregions.parser.Node
import net.danieldietrich.protectedregions.parser.Parser
import org.slf4j.LoggerFactory

class ParserFactory {
	
	@Inject extension ModelBuilder
	
	/** Custom parser builder */
	def parser(String name, (ProtectedRegionParser)=>Node<Element> initializer) {
		new ProtectedRegionParser() => [
			val model = initializer.apply(it)
			parser = new Parser(name, model)
		]
	}
	
	def javaParser() {
		parser("java")[
			model[
				comment("//")
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
			]
		]
	}
	
	def scalaParser() {
		parser("scala")[
			model[
				comment("//")
				nestableComment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
				greedyString('"""')
				// TODO: XML mode
				// TODO: XML mode vs. operator overloading ('<', '>', ...)
				// @see http://www.scala-lang.org/docu/files/ScalaReference.pdf
			]
		]
	}
	
	def xmlParser() {
		parser("xml")[
			model[
				comment("<!--", "-->")
				string("<![CDATA[", "]]>")
				string("'")
				string('"')
			]
		]
	}
	
	def xtendParser() {
		parser("xtend")[
			model[
				comment("//")
				comment("/*", "*/")
				string('"').withEscape("\\")
				string("'").withEscape("\\")
				string("'''").withCode("«", "»") // .withCode("\u00ab", "\u00ba") // french braces
			]
		]
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
	
}

/** Needed when post-processing the AST. */
class RegionBuffer {
	
	static val logger = LoggerFactory::getLogger(typeof(RegionBuffer))
	
	val List<Region> regions = newArrayList()
	
	var String id = null
	var Boolean enabled = null
	var buf = new StringBuffer()
	
	/** Called when a protected region start is found in the AST. */
	def void begin(String start, String id, boolean enabled) {
		if (this.id != null) {
			// TODO: Message like "Detected ... between (5,7) and (5,32), near [ PROTECTED REGION END ]."
			// Github Issue #33
			throw new IllegalStateException("Trying to start a region with id '"+ id +"' within a region with id '"+ this.id +"'")
		} else {
			buf.append(start) // Github Issue #31: move this line behind buf.setLength(0) to include start marker in region
			regions.add(new Region(null, buf.toString, null))
			buf.setLength(0)
			this.id = id
			this.enabled = enabled
		}
	}
	
	/** Called when a protected region end is found in the AST. */
	def void end(String end) {
		if (id == null) {
			// TODO: Message like "Detected marked region end without corresponding marked region start between (5,7) and (5,32), near [ PROTECTED REGION END ]."
			// Github Issue #33
			throw new IllegalStateException("Missing region start")
		} else {
			regions.add(new Region(id, buf.toString, enabled))
			buf.setLength(0) // clear buffer
			buf.append(end) // Github Issue #31: move this line in front of regions.add(...) to include end marker in region 
			id = null
			enabled = null
		}
	}
	
	/** Called to store the leaf values of the AST */
	def void append(String text) {
		buf.append(text)
	}
	
	/** Called once at the end of AST processing to retrieve the result. */
	def Iterable<Region> get() {
		// Github Issue #33
		if (id != null) throw new IllegalStateException("Missing end of last region with id '"+ id +"'")
		if (buf.length > 0) {
			regions.add(new Region(id, buf.toString, enabled))
		}
		regions
	}
	
}

/** Representation of regions (generated and non-generated). */
@Data class Region {

	val String id
	val String content
	val Boolean enabled

	def isMarked() { id != null }
	
}

/** A parser wrapper which postprocesses the resultung AST.  */
class ProtectedRegionParser {
	
	// dirty: parser has to be set after object creation because of cyclic dependency to model
	@Property var Parser parser = null
	@Property var RegionResolver resolver = new DefaultProtectedRegionResolver()
	@Property var boolean inverse = false
	
	def parse(CharSequence input) {
		
		val ast = parser.parse(input)
		val regions = new RegionBuffer()
		
		ast.traverse[switch it {
			Node<String> case id == 'RegionStart' : {
				val start = it.text
				val id = resolver.getId(start)
				val enabled = resolver.isEnabled(start)
				regions.begin(start, id, enabled)
				false
			}
			Node<String> case id == 'RegionEnd' : {
				regions.end(it.text)
				false
			}
			Leaf<String> : {
				regions.append(it.value)
				true
			}
		}]
		
		regions.get()
		
	}
	
	override toString() { "ProtectedRegionParser("+ parser.name +")" }
	
	def private text(Node<String> node) {
		val buf = new StringBuffer()
		node.traverse[switch it { Leaf<String> : buf.append(it.value) }; true]
		buf.toString
	}
	
}

/** Needed to pass informations when building the model. */
@Data class ModelBuilderContext {
	
	val Node<Element> model
	val ProtectedRegionParser parser
	
	def clone(Node<Element> newModel) {
		new ModelBuilderContext(newModel, parser)
	}
	
}

/** Builds a parser model. */
class ModelBuilder {
	
	static val EOL = Some("\r\n".str, "\n".str, "\r".str, "$".r) // line termination or end of file
	
	def model(ProtectedRegionParser parser, (ModelBuilderContext)=>void initializer) {
		Model('Code', "^".r, "\\z".r) => [
			val ctx = new ModelBuilderContext(it, parser)
			initializer.apply(ctx)
		]
	}
	
	def comment(ModelBuilderContext ctx, String s) {
		ctx.clone(Model('Comment', s, EOL) => [
			ctx.model.add(it)
			ctx.clone(it).withProtectedRegion
		])
	}
	
	def comment(ModelBuilderContext ctx, String start, String end) {
		ctx.clone(
			Model('Comment', start, end) => [
				ctx.model.add(it)
				ctx.clone(it).withProtectedRegion
			]
		)
	}
	
	def nestableComment(ModelBuilderContext ctx, String start, String end) {
		ctx.clone(
			Model('Comment', start, end) => [
				ctx.model.add(it)
				ctx.clone(it).withProtectedRegion
				add(Link(it)) // nestable: comment may contain comments
			]
		)
	}
	
	def string(ModelBuilderContext ctx, String s) {
		ctx.clone(
			Model('String', s, s) => [
				ctx.model.add(it)
			]
		)
	}

	def greedyString(ModelBuilderContext ctx, String s) {
		ctx.clone(
			Model('GreedyString', s, s.greedy) => [
				ctx.model.add(it)	
			]
		)
	}
		
	def string(ModelBuilderContext ctx, String start, String end) {
		ctx.clone(
			Model('String', start, end) => [
				ctx.model.add(it)
			]
		)
	}
	
	def void withEscape(ModelBuilderContext ctx, String escape) {
		val model = ctx.model
		if (model == model.root) throw new IllegalStateException(model.id +".withEscape() not allowed at root node")
		model.add(Model('Escape', Seq(escape.str, model.start.value), None))
  	}
  	
  	def void withCode(ModelBuilderContext ctx, String start, String end) {
  		val model = ctx.model
		if (model == model.root) throw new IllegalStateException(model.id +".withCode() not allowed at root node")
  		val code = Model('EmbeddedCode', start, end)
  		model.add(code)
  		code.add(Link(model.root))
  	}
  	
  	def void withProtectedRegion(ModelBuilderContext ctx) {
  		val parser = ctx.parser // the minimum information Deferred can be given
  		ctx.model => [
  			add(Model('RegionStart', Dynamic[|parser.resolver.start.pattern.r], None))
  			add(Model('RegionEnd', Dynamic[|parser.resolver.end.pattern.r], None))
  		]
  	}
	
}
