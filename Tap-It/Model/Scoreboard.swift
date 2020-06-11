import Foundation

class Scoreboard {
	
	var players = [Player]()
	var availableIds = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] {
		didSet {
			self.availableIds.sort()
		}
	}
	
	func addPlayer(name:String, serviceId:Int) -> Int? {
		if !self.players.contains(where: { (player) -> Bool in
			return serviceId == player.serviceId
		}) {
			let id = self.availableIds[0]
			self.availableIds.remove(at: 0)
			let player = Player(id: id, name: name, serviceId:serviceId)
			self.players.append(player)
			return id
		}
		return nil
	}
	
	func deletePlayer(serviceId:Int) {
		if let position = self.players.index(where: { (player) -> Bool in
			return serviceId == player.serviceId
		}) {
			let id = self.players[position].id
			self.availableIds.append(id)
			self.players.remove(at: position)
		}
	}
	
	func hasEverybodyJoined() -> Bool {
		for player in self.players {
			if !player.hasJoined {
				return false
			}
		}
		return true
	}
	
	func playerIsJoining(playerName: String) {
		if let index = self.players.index(where: { (player) -> Bool in
			return player.name == playerName
		}) {
			self.players[index].hasJoined = true
		}
	}
}
