//
//  LitState.swift
//  Wars
//
//  Created by Kelvin Ng on 16/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import GameplayKit

class LitState: StateMaster, Litable{
    var noActions: Bool { return !player.node.hasActions() }
    var pathDict: PathDict = [:]
    
    // MARK: - Override
    override func didEnter(from previousState: GKState?) {
        lit()
    }
    
    override func willExit(to nextState: GKState) {
        clearLit()
        pathDict = [:]
    }
    
    override func on(_ grid: GridPt) {
        guard isCurrentTeam, noActions else { toReadyState(err: false); return }
        toMenuState()
    }
    
    override func off(_ grid: GridPt) {
        guard isCurrentTeam, noActions,
            gameScene.players[grid] == nil,
            let gridPath = pathDict[grid] else  {
            toReadyState(err: false)
            return
        }
        move(to: gridPath)
    }
    
    func lit() {
        pathDict = litPath(isActive: isCurrentTeam)     //return [:] if not movable
        litAttPattern()                                 //return if not lit-able
    }
    
    func move(to gridPath: [GridPt]) {
        clearLit()
        let lastGrid = gridPath.last!
        let secLastGrid = gridPath[gridPath.count - 2]
        let p = player
        let changePos = {
            p.dir  = secLastGrid.dir(to: lastGrid)
            p.grid = lastGrid
        }
        let path = CGMutablePath()
        for (i, g) in gridPath.enumerated() {
            i == 0 ? path.move(to: g.pos) : path.addLine(to: g.pos)
        }
        let followAct = Act.follow(path, asOffset: false, orientToPath: true, speed: moveSpeed)
        let seq = [followAct,
                   Act.run(changePos),
                   Act.run(toMenuState)]
        player.node.run(seq)
    }
    


}
