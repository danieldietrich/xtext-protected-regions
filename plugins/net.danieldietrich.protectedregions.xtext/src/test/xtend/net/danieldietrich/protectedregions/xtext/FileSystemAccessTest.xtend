package net.danieldietrich.protectedregions.xtext

import static extension org.eclipse.xtext.util.Tuples.*

import org.junit.Test

class FileSystemAccessTest {

	@Test def void testJavaIoFileSystemAccess() {
		
		val Runnable runnable = [|println('running')]
		
		runnable.run
		
	}
	
}
