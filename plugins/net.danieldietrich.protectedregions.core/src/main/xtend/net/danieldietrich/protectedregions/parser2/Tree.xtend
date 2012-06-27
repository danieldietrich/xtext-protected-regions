package net.danieldietrich.protectedregions.parser2

import static net.danieldietrich.protectedregions.util.Strings.*

import java.util.List
import net.danieldietrich.protectedregions.util.None
import net.danieldietrich.protectedregions.util.Option
import net.danieldietrich.protectedregions.util.OptionExtensions
import net.danieldietrich.protectedregions.util.Some
import java.util.ArrayList

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
		// TODO: flatMap instead
		node.children.map[switch it {
			Leaf : new Some<Leaf<T>>(it)
			Node : new None<Leaf<T>>
		}].flatten
	}
	
	/** Return all children of type Node. */
	def <T> Iterable<Node<T>> nodes(Node<T> node) {
		// TODO: flatMap instead
		node.children.map[switch it {
			Node : new Some<Node<T>>(it)
			Leaf : new None<Node<T>>
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
	
	def boolean isLeaf()
	def isRoot() { _parent == null }
	def Tree<T> root() { if (isRoot) this else _parent.root }
	
	override toString() { _toString(0, new ArrayList<Tree<T>>()) }
	
	// Need to name method _toString instead of toString because of Xtend 2.3.0 bug
	def protected String _toString(int depth, List<Tree<T>> visited)
	
}

class Node<T> extends Tree<T> {
	
	@Property val List<Tree<T>> children = newArrayList()
	
	new(String id) {
		super(id)
	}
	
	def add(Tree<T> child) {
		children.add(child)
		child.parent = this
		child
	}
		
	override isLeaf() { false }
	
	override protected _toString(int depth, List<Tree<T>> visited) {
		val indent = indent(depth)
		indent + id + if (visited.contains(this)) {
			"..."
		} else {
			visited.add(this)
			"(\n"+ _children.map[it._toString(depth+1, visited)].reduce[l,r | l +",\n"+ r] +"\n"+ indent +")"
		}
	}
	
}

class Leaf<T> extends Tree<T> {

	@Property val T value

	new(String id, T value) { super(id); this._value = value }
	
	override isLeaf() { true }
	
	override protected _toString(int depth, List<Tree<T>> visited) {
		val indent = indent(depth)
		visited.add(this)
		indent + id +"("+ _value +")"
	}
	
}
