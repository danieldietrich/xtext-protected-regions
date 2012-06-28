package net.danieldietrich.protectedregions

import com.google.inject.Inject
import net.danieldietrich.protectedregions.DefaultProtectedRegionResolver
import net.danieldietrich.protectedregions.RegionResolver
import net.danieldietrich.protectedregions.parser.Element
import net.danieldietrich.protectedregions.parser.ElementExtensions
import net.danieldietrich.protectedregions.parser.Leaf
import net.danieldietrich.protectedregions.parser.ModelExtensions
import net.danieldietrich.protectedregions.parser.Node
import net.danieldietrich.protectedregions.parser.Parser
import net.danieldietrich.protectedregions.parser.TreeExtensions
import org.slf4j.LoggerFactory
import java.util.List

// TODO: Only the model should depend on the resolver. The parser should return an AST containing all informations about the protected regions. (-> move getResolver to the ModelBuilder) 
class ParserFactory {
	
	static val DEFAULT_RESOLVER = new DefaultProtectedRegionResolver()
	
	@Inject extension ModelBuilder
	
	def javaParser(RegionResolver... optionalResolver) {
		val resolver = getResolver(optionalResolver)
		parser("java", resolver, model(resolver)[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		])
	}
	
	def xmlParser(RegionResolver... optionalResolver) {
		val resolver = getResolver(optionalResolver)
		parser("xml", resolver, model(resolver)[
			comment("<!--", "-->")
			string("<![CDATA[", "]]>")
			string("'")
			string('"')
		])
	}
	
	def xtendParser(RegionResolver... optionalResolver) {
		val resolver = getResolver(optionalResolver)
		parser("xtend", resolver, model(resolver)[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
			string("'''").withCode("«", "»") // .withCode("\u00ab", "\u00ba") // french braces
		])
	}
	
	def private getResolver(RegionResolver[] optionalResolver) {
		if (optionalResolver.size > 1) throw new IllegalArgumentException("Some or none RegionResolver allowed.")
		if (optionalResolver.size == 0) DEFAULT_RESOLVER else optionalResolver.get(0)
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
		/*DEBUG*/println("### MODEL:\n"+ model +"\n")
		new ProtectedRegionParser(
			new Parser(name, model),
			resolver
		)
	}
	
}

@Data class ProtectedRegionParser {
	
	static val logger = LoggerFactory::getLogger(typeof(ProtectedRegionParser))
	
	extension TreeExtensions treeExtensions = new TreeExtensions()
	
	val Parser parser
	val RegionResolver resolver
	
	def parse(CharSequence input) {
		
		val List<Region> result = newArrayList
		val ast = parser.parse(input)
		/*DEBUG*/println("### AST:\n"+ ast +"\n")
		
		println("--8<--*snip*--8<--")
		ast.traverse[switch it {
			Node<String> case id == 'RegionStart' : {
				//
			}
			Node<String> case id == 'RegionEnd' : {
				//
			}
			Leaf<String> : {
				print(it.value)
			}
		}]
		println("\n--8<--*snap*--8<--")
		
		result
		
	}
	
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

/** Needed to pass informations when building the model. */
@Data class ModelBuilderContext {
	val Node<Element> model
	val RegionResolver resolver
}

// cycles definitely allowed when building models because of nested- and code-structures
class ModelBuilder {

	@Inject extension ElementExtensions
	@Inject extension ModelExtensions	
	@Inject extension TreeExtensions	
	
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
		(Model('GreedyString', s, GreedyElement(s)) => [
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
		model.add(Model('Escape', SeqElement(StrElement(escape), model.start.unpack.get), NoElement))
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
  			add(Model('RegionStart', resolver.start.pattern.r, NoElement))
  			add(Model('RegionEnd', resolver.end.pattern.r, NoElement))
  		]
  	}
  	
  	def private ctx(Node<Element> model, RegionResolver resolver) {
		new ModelBuilderContext(model, resolver)
	}
	
}
