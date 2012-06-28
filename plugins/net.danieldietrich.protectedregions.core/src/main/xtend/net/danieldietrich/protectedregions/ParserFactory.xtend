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
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class ParserFactory {
	
	static val DEFAULT_RESOLVER = new DefaultProtectedRegionResolver()
	
	@Inject extension ModelBuilder
	
	def javaParser() { javaParser(null) }
	def javaParser(RegionResolver customResolver) {
		val resolver = getResolver(customResolver)
		parser("java", resolver, model(resolver)[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		])
	}
	
	def xmlParser() { xmlParser(null) }
	def xmlParser(RegionResolver customResolver) {
		val resolver = getResolver(customResolver)
		parser("xml", resolver, model(resolver)[
			comment("<!--", "-->")
			string("<![CDATA[", "]]>")
			string("'")
			string('"')
		])
	}
	
	def xtendParser() { xtendParser(null) }
	def xtendParser(RegionResolver customResolver) {
		val resolver = getResolver(customResolver)
		parser("xtend", resolver, model(resolver)[
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
	
	def private parser(String name, RegionResolver resolver, Node<Element> model) {
		new ProtectedRegionParser(
			new Parser(name, model),
			resolver
		)
	}
	
	def private getResolver(RegionResolver customResolver) {
		if (customResolver == null) DEFAULT_RESOLVER else customResolver
	}
	
}

class Regions {
	
	static val Logger logger = LoggerFactory::getLogger(typeof(Regions))
	
	val List<Region> regions = newArrayList()
	var String id = null
	var Boolean enabled = null
	var buf = new StringBuffer()
	
	def void begin(String start, String id, boolean enabled) {
		if (this.id != null) {
			logger.warn("Already started a region with id '"+ this.id +"' but found another region with id '"+ id +"'")
		} else {
			buf.append(start)
			regions.add(new Region(null, buf.toString, null))
			buf.setLength(0)
			this.id = id
			this.enabled = enabled
		}
	}
	
	def void end(String end) {
		if (id == null) {
			logger.warn("Missing region start")
		} else {
			regions.add(new Region(id, buf.toString, enabled))
			buf.setLength(0) // clear buffer
			buf.append(end)
			id = null
			enabled = null
		}
	}
	
	def void append(String text) {
		buf.append(text)
	}
	
	def Iterable<Region> get() {
		if (id != null) logger.warn("Missing end of last region with id '"+ id +"'")
		if (buf.length > 0) {
			regions.add(new Region(id, buf.toString, enabled))
		}
		regions
	}
	
}

@Data class Region {

	val String id
	val String content
	val Boolean eanbled

	def isMarked() { id != null }
	
}

@Data class ProtectedRegionParser {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionParser))
	
	val Parser parser
	val RegionResolver resolver
	
	def parse(CharSequence input) {
		
		val ast = parser.parse(input)
		val regions = new Regions()

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
	
	def private text(Node<String> node) {
		val buf = new StringBuffer()
		node.traverse[switch it { Leaf<String> : buf.append(it.value) }; true]
		buf.toString
	}
	
}

/** Needed to pass informations when building the model. */
@Data class ModelBuilderContext {
	val Node<Element> model
	val RegionResolver resolver
}

// cycles definitely allowed when building models because of nested- and code-structures
class ModelBuilder {
	
	def model(RegionResolver regionResolver, (ModelBuilderContext)=>void initializer) {
		Model('Code', "^".r, "\\z".r) => [
			initializer.apply(ctx(regionResolver))	
		]
	}
	
	def comment(ModelBuilderContext ctx, String s) {
		(Model('Comment', s, EOL) => [
			ctx.model.add(it)
			ctx(ctx.resolver).withProtectedRegion
		]).ctx(ctx.resolver)
	}
	
	def comment(ModelBuilderContext ctx, String start, String end) {
		(Model('Comment', start, end) => [
			ctx.model.add(it)
			ctx(ctx.resolver).withProtectedRegion
		]).ctx(ctx.resolver)
	}
	
	def nestableComment(ModelBuilderContext ctx, String start, String end) {
		(Model('Comment', start, end) => [
			ctx.model.add(it)
			ctx(ctx.resolver).withProtectedRegion
			add(Link(it)) // nestable: comment may contain comments
		]).ctx(ctx.resolver)
	}
	
	def string(ModelBuilderContext ctx, String s) {
		(Model('String', s, s) => [
			ctx.model.add(it)
		]).ctx(ctx.resolver)
	}

	def greedyString(ModelBuilderContext ctx, String s) {
		(Model('GreedyString', s, s.grstr) => [
			ctx.model.add(it)	
		]).ctx(ctx.resolver)
	}
		
	def string(ModelBuilderContext ctx, String start, String end) {
		(Model('String', start, end) => [
			ctx.model.add(it)
		]).ctx(ctx.resolver)
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
  		val resolver = ctx.resolver
  		ctx.model => [
  			add(Model('RegionStart', resolver.start.pattern.r, None))
  			add(Model('RegionEnd', resolver.end.pattern.r, None))
  		]
  	}
  	
  	def private ctx(Node<Element> model, RegionResolver resolver) {
		new ModelBuilderContext(model, resolver)
	}
	
}
