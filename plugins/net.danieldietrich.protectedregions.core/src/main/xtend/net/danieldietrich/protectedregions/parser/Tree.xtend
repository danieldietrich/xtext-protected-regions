package net.danieldietrich.protectedregions.parser

import static net.danieldietrich.protectedregions.util.Strings.*

import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.OptionExtensions
import net.danieldietrich.protectedregions.util.Some
import java.util.List

class TreeExtensions {

	extension OptionExtensions = new OptionExtensions()

	/** Construct a Node. */
	def <T> Node Node(String id, Tree<T>... children) {
		val node = new Node<T>(id)
		children.forEach[node.add(it)]
		node
	}

	/** Construct a Leaf. */
	def <T> Leaf(String id, T value) {
		new Leaf<T>(id, value)
	}
	
	/** Construct a Link. */
	def <T, X extends Tree<T>> Link(X ref) {
		switch ref {
			Node<T> : new NodeLink<T>(ref)
			Leaf<T> : new LeafLink<T>(ref)
		}
	}
	
	/** Find first child of node which satisfies the given predicate. */
	def <T> Option<Tree<T>> find(Node<T> node, (Tree<T>)=>Boolean predicate) {
		node.children.find(predicate)
	}
	
	/** Example: node.leafs.find[id.equals('xxx')] */
	def <T, X extends Tree<T>> Option<X> find(Iterable<X> children, (X)=>Boolean predicate) {
		Option(children.findFirst(predicate))
	}
	
	/** Example: node.leafs.find('xxx') */
	def <T, X extends Tree<T>> Option<X> find(Iterable<X> children, String _id) {
		children.find[id.equals(_id)]
	}
	
	/** Return all children satisfying the given predicate. */
	def <T> Iterable<Tree<T>> filter(Node<T> node, (Tree<T>)=>Boolean predicate) {
		node.children.filter(predicate)
	}
	
	/** Return all children of type Leaf. */
	def <T> Iterable<Leaf<T>> leafs(Node<T> node) {
		node.children.map[switch it {
			Leaf<T> : new Some<Leaf<T>>(it)
			Node<T> : new None<Leaf<T>>
		}].flatten
	}
	
	/** Return all children of type Node. */
	def <T> Iterable<Node<T>> nodes(Node<T> node) {
		node.children.map[switch it {
			Node<T> : new Some<Node<T>>(it)
			Leaf<T> : new None<Node<T>>
		}].flatten
	}
	
	/** Traversing a Tree top down, applying a function f to each tree node. */
	def <T> void traverse(Tree<T> tree, (Tree<T>)=>Object f) {
		f.apply(tree)
		switch tree {
			Node<T> : tree.children.forEach[traverse(f)]
		}
	}
	
	/** Return all tree nodes satisfying the given predicate. */
	def <T> List<Tree<T>> collect(Tree<T> tree, (Tree<T>)=>Boolean predicate) {
		val List<Tree<T>> result = newArrayList()
		tree.traverse[if (predicate.apply(it)) result.add(it)]
		result
	}
	
	/** Returns the children, if tree is a Node or an empty List. */
	def <T> List<Tree<T>> children(Tree<T> tree) {
		switch tree {
			Node<T> : tree.children
			Leaf<T> : newArrayList()
		}
	}
	
}

abstract class Tree<T> {
	
	@Property val String id
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
