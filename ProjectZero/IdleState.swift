//
//  FinishedState.swift
//  Wars
//
//  Created by Kelvin Ng on 17/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import GameplayKit

class IdleState: StateMaster {
    
    override func didEnter(from previousState: GKState?) {
        player.changeColor(dim: true)
        player.settlePosDir()
        player.clear(mode: .rapid)
//        gameScene.checkChangeTeam()
    }
    
    override func on(_ grid: GridPt) {
        to(state: IdleLitState.self)
    }
}
