//
//  MenuState.swift
//  Wars
//
//  Created by Kelvin Ng on 17/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import GameplayKit

class MenuState: StateMaster, MenuAjustable {
    
    override func didEnter(from previousState: GKState?) {
        showMenu()
    }
    
    override func willExit(to nextState: GKState) {
        gameScene.actionButsLayer.hideNodeTree()
    }
    
    override func select(at grid: GridPt) {
        toReadyState()  //no matter on or off
    }
    
    func showMenu() {
        let allowedTypes = player.actionTypes
        let buts = gameScene.actionButs.filter {
            allowedTypes.contains($0.type)
        }
        adjustMenu(layer: gameScene.actionButsLayer, buttons: buts)
    }
}
