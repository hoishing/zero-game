//
//  TouchLayer.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 9/11/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

class TouchLayer: SKSpriteNode {
    
    init() {
        super.init(texture: nil, color: .clear, size: gameScene.size)
        anchorPoint = CGPoint.zero
        isUserInteractionEnabled = true
        zPosition = 27
    }
    
    var actionsRunning: Bool {
        if gameScene.hasActions() { return true }
        for p in gameScene.players.values {
            if p.node.hasActions() { return true }
        }
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameScene.isGameOver {
//            gameScene.vc.dismiss()
            return
        }
        if gameScene.currentTeam == .red { return }
        let scenePos = touches.first!.location(in: gameScene)
//        print("scene touched pos: ", scenePos)
        let grid = GridPt(scenePos)
        if grid.outOfBound(gameScene) { return }
        if actionsRunning {
            Sound.err.play()
            return
        }
        gameScene.players.forEach {
            $0.value.stateMaster.select(at: grid)
        }
        gameScene.moveSelectNode(grid)
    }
}
