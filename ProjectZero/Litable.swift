
import SpriteKit

protocol Litable: class, LitAtt, PathFinder {

}

extension Litable {
    var bgTileNode: SKTileMapNode { return gameScene.bgNode }

    func clearLit() {
        player.litLayer.removeAllChildren()
        clearLitAtt()
    }
    
    @discardableResult
    func litPath(isActive: Bool) -> PathDict {
        guard player.movable else { return [:] }
        let pathDict = pathDicts(player).org
        
        pathDict.keys.forEach {
            let texture = isActive ? #imageLiteral(resourceName: "pathActive").tx : #imageLiteral(resourceName: "pathIdle").tx
            let node = LitNode(player: player, texture: texture, grid: $0, z: 0)
            player.litLayer.addChild(node)
        }
        return pathDict
    }
    

}
