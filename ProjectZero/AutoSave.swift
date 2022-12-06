//
//  Save.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 13/5/2018.
//  Copyright © 2018 Fbm Development. All rights reserved.
//

import GameplayKit

extension GameScene {
    
    func autoSave() {
        var grids = [String: GridState]()
        bgNode.enumerateTiles { (x, y, _) in
            let grid = GridPt(x, y)
        
            let player = players[grid]
            let playerState = player.map { p in
                PlayerState(hp: p.hp, sp: p.sp,
                            team: p.team.rawValue,
                            army: p.army.rawValue,
                            dir: p.dir.rawValue,
                            rank: p.rank.rawValue,
                            aggr: p.aggr,
                            isIdle: p.team != .red && p.isIdle) //red won't be idle
            }
            
            let gridState = GridState(feature: feature(on: grid)?.rawValue,
                                      player: playerState)
            
            grids[grid.description] = gridState
        }
        
        let lvState = LvState(lv: vc.level, day: day, grids: grids)
        
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(lvState) else { return }
        udCloudSync(data, key: "autoSave")
    }
}


