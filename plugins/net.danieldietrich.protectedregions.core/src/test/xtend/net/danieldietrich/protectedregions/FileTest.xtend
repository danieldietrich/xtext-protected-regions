package net.danieldietrich.protectedregions

import static org.junit.Assert.*

import org.junit.Test

class FileTest {

	@Test
	def void fileShouldBeSelfEqual() {

		val fileName = "src-gen/net/danieldietrich/protectedregions/Test.java"
		val file1 = new JavaIoFile(new java.io.File(fileName))
		val file2 = new JavaIoFile(new java.io.File(fileName))
		
		assertTrue(file1.path == file2.path)
		assertTrue(file1.hashCode == file2.hashCode)
		assertTrue(file1.equals(file2))
	}

	@Test
	def void unequalityShouldBehaveRight() {
		
		val file1 = new JavaIoFile(new java.io.File("x"))
		val file2 = new JavaIoFile(new java.io.File("y"))
		
		assertTrue(file1.path != file2.path)
		assertTrue(file1.hashCode != file2.hashCode)
		assertTrue(!file1.equals(file2))
		
	}

}
