package net.danieldietrich.protectedregions

import com.google.inject.Inject
import net.danieldietrich.protectedregions.parser.Model
import net.danieldietrich.protectedregions.parser.Parser
import net.danieldietrich.protectedregions.parser.ModelBuilder

class ParserFactory {
	
	@Inject extension ModelBuilder
	
	def javaParser() {
		println("MODEL START\n"+ model[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		] +"\nMODEL END")
		parser("java", model[
			comment("//")
			comment("/*", "*/")
			string('"').withEscape("\\")
			string("'").withEscape("\\")
		])
	}
	
	def xmlParser() {
		parser("xml", model[
			comment("<!--", "-->")
			string("<![CDATA[", "]]>")
			string("'")
			string('"')
		])
	}
	
	def xtendParser() {
		parser("xtend", model[
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
//      string('"""')
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
