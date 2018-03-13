import Foundation

class Player {
	let id: Int
	let name: String
	var cards = [Int]()
	var hasJoined = false
	
	init(id: Int, name: String) {
		self.id = id
		self.name = name
	}
}
