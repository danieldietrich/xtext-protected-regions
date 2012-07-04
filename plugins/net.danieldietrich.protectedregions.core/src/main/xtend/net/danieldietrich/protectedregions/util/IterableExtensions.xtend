package net.danieldietrich.protectedregions.util

import java.util.LinkedHashMap
import org.eclipse.xtext.xbase.lib.Pair

class IterableExtensions {
	
	// Note: name toMap clashes with org.eclipse.xtext.base.lib.IterableExtensions.toMap
	/** Usage: seq.asMap[key -> value] */
	def static <T,K,V> asMap(Iterable<T> seq, (T)=>Pair<K,V> toPair) {
	    seq.map(toPair).fold(new LinkedHashMap<K,V>)[map, pair | map.put(pair.key, pair.value); map]
	}
    
}
