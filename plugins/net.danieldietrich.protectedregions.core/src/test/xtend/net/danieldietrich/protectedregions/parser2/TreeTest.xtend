package net.danieldietrich.protectedregions.parser2

import static org.junit.Assert.*

import org.junit.Test

class TreeTest {
	
	@Test(expected = typeof(IllegalArgumentException))
	def void testSelfParentNotAllowed() {
		
		val root = new Node<Void>('root')
		
		root.add(root) // should fail, because a node cannot be parent of itself
		assertTrue("Cycle not detected", false)
	}
	
	@Test(expected = typeof(IllegalArgumentException))
	def void testSimpleCycleDetection() {
		
		val root = new Node<Void>('root')
		val child = new Node<Void>('root')
		
		root.add(child)
		assertTrue("root.parent should be null", root.parent == null)
		assertTrue("child.parent should be root", child.parent == root)
		
		child.add(root) // should fail, because of child.parent == root
		assertTrue("Cycle not detected", false)
	}

	@Test(expected = typeof(IllegalArgumentException))
	def void testSubtreeCycleDetection() {

		val child1 = new Node<Void>('child1')
		val root1 = new Node<Void>('root1') => [ add(child1) ]
		
		val child2 = new Node<Void>('child2')
		val root2 = new Node<Void>('root2') => [ add(child2) ]
		
		child1.add(root2) // combine trees
		assertTrue("child2.parent should be root2", child2.parent == root2)
		assertTrue("root2.parent should be child1", root2.parent == child1)
		assertTrue("child1.parent should be root1", child1.parent == root1)
		assertTrue("root1.parent should be null", root1.parent == null)
		
		child2.add(root1)
		assertTrue("Cycle not detected", false)
	}
	
}
