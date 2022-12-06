//
//  LitNode.swift
//  Wars
//
//  Created by hoishing on 11/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import SpriteKit

class LitNode: SKSpriteNode {
    unowned let player: Player
    let grid: GridPt
    
    init(player: Player, texture: SKTexture, grid: GridPt, z: Int) {
        self.player = player
        self.grid = grid
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = CGFloat(z)
        position = convert(grid.pos, to: player.node)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let state = player.stateMachine.currentState
        if state is LitState || state is IdleLitState { return }
        
//        let scenePos = touches.first?.location(in: gameScene)
//        print("Lit Pressed at: ", scenePos ?? "nil")
        
        if let actionState = state as? ActionState {
            actionState.takeAction(on: grid)
        }
    }
}
