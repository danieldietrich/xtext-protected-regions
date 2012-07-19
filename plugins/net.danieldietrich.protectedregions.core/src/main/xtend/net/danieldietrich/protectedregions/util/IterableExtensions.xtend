package net.danieldietrich.protectedregions.util

import static extension net.danieldietrich.protectedregions.util.IterableExtensions.*
import java.util.LinkedHashMap
import org.eclipse.xtext.xbase.lib.Pair

class IterableExtensions {
	
	// Note: name toMap clashes with org.eclipse.xtext.base.lib.IterableExtensions.toMap
	/** Usage: seq.asMap[key -> value] */
	def static <T,K,V> asMap(Iterable<T> seq, (T)=>Pair<K,V> toPair) {
	    seq.map(toPair).fold(new LinkedHashMap<K,V>)[map, pair | map.put(pair.key, pair.value); map]
	}
	
	/** (a,b,c) -> ((a,0), (b,1), (c,2)) */
	def static <T> zipWithIndex(Iterable<T> seq) {
		val list = seq.toList
		seq.map[it -> list.indexOf(it)]
	}
    
}
