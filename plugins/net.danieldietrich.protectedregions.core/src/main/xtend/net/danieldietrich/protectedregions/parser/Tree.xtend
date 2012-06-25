package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.util.Strings.*

import java.util.List

abstract class Tree {
	
	@Property val String id
	
	new(String id) {
		this._id = id
	}
	
	def void traverse((Tree)=>Object f)
	
	override toString() {
		toString(0)
	}
	
	def protected String toString(int depth)
	
}

class Node extends Tree {
	
	@Property val List<Tree> children = newArrayList()
	
	new(String id) {
		super(id)
	}
	
	// build tree-like structures by adding children
	def <T extends Tree> T add(T child) {
		children.add(child); child
	}

	override traverse((Tree)=>Object f) {
		f.apply(this)
		children.forEach[traverse(f)]
	}
		
	override protected toString(int depth) {
		val indent = indent(depth)
    	indent + id +"(\n"+ children.map[toString(depth+1)].reduce(l,r | l +",\n"+ r) +"\n"+ indent +")"
	}
		

}

class Leaf extends Tree {
	
	@Property val String value
	
	new(String id, String value) {
		super(id)
		this._value = value
	}
	
	override traverse((Tree)=>Object f) {
		f.apply(this)
	}
	
	override protected toString(int depth) {
		val indent = indent(depth)
    	indent + id +"("+ value.replaceAll("\\s+", " ") +")"
	}
	
}
