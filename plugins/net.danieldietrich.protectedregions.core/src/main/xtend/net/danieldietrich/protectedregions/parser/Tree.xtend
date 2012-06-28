package net.danieldietrich.protectedregions.parser

import static extension net.danieldietrich.protectedregions.parser.TreeExtensions.*
import static extension net.danieldietrich.protectedregions.util.OptionExtensions.*

import static net.danieldietrich.protectedregions.util.Strings.*

import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.Some
import java.util.List

abstract class TreeExtensions {

	/** Construct a Node. */
	def static <T> Node Node(String id, Tree<T>... children) {
		val node = new Node<T>(id)
		children.forEach[node.add(it)]
		node
	}

	/** Construct a Leaf. */
	def static <T> Leaf(String id, T value) {
		new Leaf<T>(id, value)
	}
	
	/** Construct a Link. */
	def static <T, X extends Tree<T>> Link(X ref) {
		switch ref {
			Node<T> : new NodeLink<T>(ref)
			Leaf<T> : new LeafLink<T>(ref)
		}
	}
	
	/** Example: node.leafs.find[id.equals('xxx')] */
	def static <T, X extends Tree<T>> Option<X> find(Iterable<X> children, (X)=>Boolean predicate) {
		Option(children.findFirst(predicate))
	}
	
	/** Example: node.leafs.find('xxx') */
	def static <T, X extends Tree<T>> Option<X> find(Iterable<X> children, String _id) {
		children.find[id.equals(_id)]
	}
	
	/** Return all children of type Leaf. */
	def static <T> Iterable<Leaf<T>> leafs(Node<T> node) {
		node.children.map[switch it {
			Leaf<T> : new Some<Leaf<T>>(it)
			Node<T> : new None<Leaf<T>>
		}].flatten
	}
	
	/** Return all children of type Node. */
	def static <T> Iterable<Node<T>> nodes(Node<T> node) {
		node.children.map[switch it {
			Node<T> : new Some<Node<T>>(it)
			Leaf<T> : new None<Node<T>>
		}].flatten
	}
	
	/**
	 * Traverses a Tree top down, applying a function f to each tree node.
	 * If f returns true, descend children, else go on with neighbors.
	 */
	def static <T> void traverse(Tree<T> tree, (Tree<T>)=>Boolean f) {
		val descend = f.apply(tree)
		if (descend == null || descend) switch tree {
			Node<T> : tree.children.forEach[it.traverse(f)]
		}
	}
	
}

abstract class Tree<T> {
	
	@Property val String id // identifier, not necessarily unique
	@Property var Node<T> parent = null
	
	new(String id) {
		if (id == null) throw new IllegalArgumentException("Id cannot be null")
		this._id = id
	}
	
	def isRoot() { _parent == null }
	def Tree<T> root() { if (isRoot) this else _parent.root }
	
	override toString() { toString(0) }
	def protected String toString(int depth)
	
}

class Node<T> extends Tree<T> {
	
	@Property val List<Tree<T>> children = newArrayList()
	
	new(String id) {
		super(id)
	}
	
	def add(Tree<T> child) {
		if (isCycle(child)) throw new IllegalArgumentException("A tree has no cycles.")
		_children.add(child)
		child.parent = this
		child
	}
	
	def private isCycle(Tree<T> child) {
		this == child || (!isRoot && (parent as Node<T>).isCycle(child)) // BUG: parent.isCycle(child)
	}
	
	override protected toString(int depth) {
		val indent = indent(depth) // BUG:map[toString(depth+1)]
		indent + id +"(\n"+ _children.map[Tree<T> child | child.toString(depth+1)].reduce[l,r | l +",\n"+ r] +"\n"+ indent +")"
	}

}

class Leaf<T> extends Tree<T> {

	@Property val T value

	new(String id, T value) {
		super(id)
		this._value = value
	}
	
	override protected toString(int depth) {
		val indent = indent(depth)
		indent + id +"("+ _value.toString.replaceAll("\\s+", " ") +")"
	}
	
}

class NodeLink<T> extends Node<T> {
	
	@Property Node<T> ref
	
	new(Node<T> ref) {
		super('Link->'+ ref.id)
		this._ref = ref
	}
	
	override getChildren() { ref.children }
	
	override add(Tree<T> child) {
		ref.add(child)
	}

	override protected toString(int depth) {
		val indent = indent(depth)
		indent + id
	}
	
}

class LeafLink<T> extends Leaf<T> {
	
	@Property Leaf<T> ref
	
	new(Leaf<T> ref) {
		super('Link->'+ ref.id, null)
		this._ref = ref
	}

	override getValue() { ref.value }

	override protected toString(int depth) {
		val indent = indent(depth)
		indent + id
	}
	
}
