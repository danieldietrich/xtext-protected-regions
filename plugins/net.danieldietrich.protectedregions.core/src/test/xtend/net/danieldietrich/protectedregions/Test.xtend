package net.danieldietrich.protectedregions

import com.google.inject.Guice
import com.google.inject.Inject
import java.util.List

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class Test {

	@Inject extension ParserFactory

	def static void main(String[] args) {
		Guice::createInjector().getInstance(typeof(Test)).run()
	}
	
	def private run() {
		println("starting tests...")
		test("java parser fails", javaParser, javaContent)
		test("xtend parser fails", xtendParser, xtendContent)
		test("xml parser fails", xmlParser, xmlContent)
		testException("corrupted xml parsed wrong", xmlParser, xmlContent_corrupted, "xml parser: end of String (', [']) not found at [4,23]")
		println("all test ok!")
	}
	
	def private test(String msg, ProtectedRegionParser parser, CharSequence content) {
		val start = System::currentTimeMillis()
		val regions = parser.parse(content)
		/*DEBUG*/println("Parsed content in " + (System::currentTimeMillis - start) + " ms.")
		val parsed = toString(regions)
		/*DEBUG*/println(parsed)
		if (!parsed.equals(content.toString)) {
			throw new IllegalStateException(msg + "\n\nOriginal:\n###" + content + "###\n\nParsed:\n###" + parsed + "###\n\n")
		}
	}
	
	def private toString(List<Region> regions) {
		val buf = new StringBuffer()
		for (region : regions) {
			buf.append(region.content)
		}
		buf.toString()
	}
			
	def private testException(String msg, ProtectedRegionParser parser, CharSequence content, String exception) {
		val start = System::currentTimeMillis()
		try {
			parser.parse(content)
			throw new IllegalStateException("Parser DIDN'T throw exception " + exception)
		} catch(Exception x) {
			if (!x.message.equals(exception)) {
				throw new IllegalStateException(msg, x)
			}
		} finally {
			/*DEBUG*/println("Parsed content in " + (System::currentTimeMillis - start) + " ms.")
		}
	}

	def javaContent() '''
		public class GeneratedClass {
			/**
			 * Generated comment.
			 */
			public void generatedMethod() {
			// PROTECTED REGION ID(test) START
			
			// TODO: implementation
			System.out.println("Protected regions end with \"/* PROTECTED REGION END */\"");
			
			// PROTECTED REGION END
			}
		}
	'''
	
	def private xmlContent() '''
		<xml>
			<!-- PROTECTED REGION ID(test) START -->
			<![CDATA[this is character data]]>
			<element attribute1='value1' attribute2="value2">
				text
			</element>
			<!-- PROTECTED REGION END -->
		</xml>
	'''
		
	def private xmlContent_corrupted() '''
		<xml>
			<!-- PROTECTED REGION ID(test) START -->
			<![CDATA[this is character data]]>
			<element attribute1='value1 attribute2="value2">
				text
			</element>
			<!-- PROTECTED REGION END -->
		</xml>
	'''
	
	def private xtendContent() {
		"'''This is «\"\\\"a\"» rich «\"'''\"»string«\"'''\"» which ends here:'''"
	}

}
