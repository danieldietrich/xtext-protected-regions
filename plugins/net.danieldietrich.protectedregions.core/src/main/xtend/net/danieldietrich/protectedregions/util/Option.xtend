package net.danieldietrich.protectedregions.util

import java.util.ArrayList

class OptionExtensions {
	def <T> Option<T> Option(T obj) { if (obj == null) None else Some(obj) }
	def <T> Some<T> Some(T obj) { new Some(obj) }
	def <T> None<T> None() { new None<T> }
}

// A life without NullPointerExceptions
abstract class Option<T> implements Iterable<T> {
	def T get()
	def boolean isEmpty() // Caution: also defined in IterableExtensions
	def T getOrElse(T _default) { if (isEmpty) _default else get }
}

class Some<T> extends Option<T> {
	val T obj
	new(T obj) {
		if (obj == null) throw new IllegalArgumentException("Some cannot contain null. Use None instead.")
		this.obj = obj
	}
	override T get() { obj }
	override isEmpty() { false }
	override iterator() {
		(new ArrayList<T> => [ add(obj) ]).iterator
	}
	override equals(Object o) {
		o != null && switch o {
			Some<T> : o.obj.equals(obj)
			default : false
		}
	}
	override hashCode() { obj.hashCode + 31 }
	override toString() { "Some("+ obj +")" }
}

class None<T> extends Option<T> {
	override T get() { throw new UnsupportedOperationException() }
	override isEmpty() { true }
	override iterator() {
		new ArrayList<T>.iterator
	}
	override equals(Object o) {
		o != null && switch o {
			None<T> : true
			default : false
		}
	}
	override hashCode() { 0 }
	override toString() { "None" }
}
