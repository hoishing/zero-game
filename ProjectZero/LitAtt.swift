
import SpriteKit

protocol LitAtt {
    var player: Player { get }
}

extension LitAtt {
    
    func litPattern(_ grids: [GridPt], filter: (GridPt) -> Bool) {
        for grid in grids {
            if grid.outOfBound(gameScene) {continue}
            let bright = filter(grid)
            let z = bright ? 0 : -59
            let node = LitNode(player: player, texture: #imageLiteral(resourceName: "att").tx, grid: grid, z: z)
            node.colorBlendFactor = bright ? 0 : 0.3
            player.attLayer.addChild(node)
        }
    }
    
    func litAttPattern(filter: (GridPt) -> Bool = {_ in false}) {
        guard let attGrids = player.attackGrids else { return }
        litPattern(attGrids, filter: filter)
    }
    
    func clearLitAtt() {
        player.attLayer.removeAllChildren()
    }
    
}
