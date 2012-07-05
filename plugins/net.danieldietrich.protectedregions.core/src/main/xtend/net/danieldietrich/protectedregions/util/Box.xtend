package net.danieldietrich.protectedregions.util

// this class boxes variables to be accessed from within closures.
class Box<T> {
	
	public var T x
	
	new(T x) {
		this.x = x
	}
	
}
