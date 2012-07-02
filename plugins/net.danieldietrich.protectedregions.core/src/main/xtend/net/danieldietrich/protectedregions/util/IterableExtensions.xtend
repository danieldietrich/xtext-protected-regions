package net.danieldietrich.protectedregions.util

import java.util.LinkedHashMap

class IterableExtensions {
	
	def static <T,K,V> toMap(Iterable<T> seq, (T)=>K key, (T)=>V value) {
		seq.fold(new LinkedHashMap<K,V>)[map, item | map.put(key.apply(item), value.apply(item)); map]
	}
	
}
