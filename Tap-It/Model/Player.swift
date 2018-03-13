import Foundation

class Player {
	let id: Int
	let serviceId:Int?
	let name: String
	var cards = [Int]()
	var hasJoined = false
	
	init(id: Int, name: String, serviceId: Int?) {
		self.id = id
		self.name = name
		self.serviceId = serviceId
	}
}
