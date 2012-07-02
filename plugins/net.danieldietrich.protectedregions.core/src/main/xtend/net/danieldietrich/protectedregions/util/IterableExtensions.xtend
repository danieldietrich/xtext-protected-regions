package net.danieldietrich.protectedregions.util

import java.util.LinkedHashMap
import org.eclipse.xtext.xbase.lib.Pair

class IterableExtensions {
	
	// TODO: name toMap clashes with IterableExtensions.toMap
	/** Examples: seq.toMap_[key -> value] or seq.toMap_[key.appy(id) -> value.apply(it)] */
	def static <T,K,V> asMap(Iterable<T> seq, (T)=>Pair<K,V> toPair) {
        seq.map(toPair).fold(new LinkedHashMap<K,V>)[map, pair | map.put(pair.key, pair.value); map]
    }
	
}
