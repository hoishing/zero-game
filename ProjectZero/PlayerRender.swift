
import SpriteKit

// MARK: - Render
extension Player {

    func renderNode() {
        node = SKNode()
        node.position = grid.pos
        node.zRotation = dir.radian
        armyNode = army.sprite(team)
        rankNode = rank.sprite(team)
        spNode = Bar.sp.adjSprite(team, rank)
        spNode.xScale = sp.cgFloat / absBarMax.cgFloat
        hpNode = Bar.hp.adjSprite(team, rank)
        hpNode.xScale = hp.cgFloat / absBarMax.cgFloat
        litLayer = node.addLayer(z: -30)    //20 - 30 = -10
        attLayer = node.addLayer(z: 30)     //20 + 30 = 50
        node.addChildren(armyNode, rankNode, spNode, hpNode)
        gameScene.playerLayer.addChildren(node)
    }
    
    func scale(_ node: SKSpriteNode, to newVal: Int) {
        let newScale = newVal.cgFloat / absBarMax.cgFloat
        node.run(SKAction.scaleX(to: newScale, duration: scaleDuration))
        gameScene.updateHUD()
    }
    
    func rotate(to dir: Dir) {
        node.zRotation = dir.radian
    }

    func resetNode() {
        node.position = grid.pos
        node.zRotation = dir.radian
    }
    
    func changeColor(dim: Bool) {
        [armyNode, rankNode, spNode, hpNode].forEach{
            $0?.color = dim ? team.dimColor : team.color
        }
        spNode.colorBlendFactor = dim ? spDimBlend : spBlend
    }
    

}

