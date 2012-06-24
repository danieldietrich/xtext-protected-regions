package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.util.Strings.*

import java.util.List

abstract class Tree {
	
	@Property val String id
	
	protected new(String id) {
		this._id = id
	}
	
	override toString() {
		toString(0)
	}
	
	def protected String toString(int depth)
	
}

class Node extends Tree {
	
	@Property val List<Tree> children = newArrayList()
	
	protected new(String id) {
		super(id)
	}
	
	// syntactic sugar for Node creation
	def static Node Node(String type, Tree... children) {
		val node = new Node(type)
		children.forEach[node.add(it)]
		node
	}
	
	// build tree-like structures by adding children
	def <T extends Tree> T add(T child) { children.add(child); child }
	
	override protected toString(int depth) {
		val indent = indent(depth)
    	indent + id +"(\n"+ children.map[toString(depth+1)].reduce(l,r | l +",\n"+ r) +"\n"+ indent +")"
	}
		
}

class Leaf extends Tree {
	
	@Property val String value
	
	protected new(String id, String value) {
		super(id)
		this._value = value
	}
	
	// syntactic sugar for Leaf creation
	def static Leaf Leaf(String id, String value) {
		new Leaf(id, value)
	}
	
	override protected toString(int depth) {
		val indent = indent(depth)
    	indent + id +"("+ value.replaceAll("\\s+", " ") +")"
	}
	
}
