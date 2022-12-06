//
//  StateMaster.swift
//  Wars
//
//  Created by Kelvin Ng on 16/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import GameplayKit

class StateMaster: GKState {
    unowned var player: Player
    var isCurrentTeam: Bool { return player.team == gameScene.currentTeam }
    
    init(player: Player) {
        self.player = player
        super.init()
    }
    
    // MARK: - To Be Overrided
    
    func select(at grid: GridPt) {
        gameScene.moveSelectNode(grid)
        player.grid == grid ? on(grid) : off(grid)
    }
    
    func on(_ grid: GridPt) {
    }
    
    func off(_ grid: GridPt) {
    }

    
    // MARK: - Convenient Methods
    func to(state: AnyClass) {
        stateMachine?.enter(state)
    }
    
    func toReadyState() {
        toReadyState(err: true)
    }
    
    func toReadyState(err: Bool) {  //can't pass as funtion name with default para value
        to(state: ReadyState.self)
        if err {
            Sound.err.play()
            gameScene.moveSelectNode(player.grid)
        }
    }
    
    func toIdleState() {
        to(state: IdleState.self)
    }
    
    func toMenuState() {
        to(state:MenuState.self)
    }

    
}

