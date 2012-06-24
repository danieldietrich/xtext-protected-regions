package net.danieldietrich.protectedregions

class Region {

	String id
	String content

	new(String id, String content) {
		this.id = id
		this.content = content
	}
	
	def id() { id }
	def content() { content }

	def isMarked() {
		id != null
	}
	
}
