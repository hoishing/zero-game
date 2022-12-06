//
//  AIMove.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 23/4/2018.
//  Copyright © 2018 Fbm Development. All rights reserved.
//

import SpriteKit

struct AIMove {
//    var seq: [Act]
    weak var player: Player?
    let score: Double
    let type: ActionType
    let onGrid: GridPt
    let target: GridPt
    
    var idleSleep: Bool {
        return type == .sleep && onGrid == target
    }
    
    var seq: [Act] {
        guard let p = player else { return [] }
        var op =  [Act.run(elapse) { gameScene.scrollTo(p.grid) },
                    Act.run(1) {p.stateMaster.select(at: p.grid)},
                    Act.run(1) {p.stateMaster.select(at: self.onGrid)},
                    
                    Act.run(elapse2) {gameScene.actionButs.filter({ $0.type == self.type }).first?.highlight()},
                    Act.run(elapse3) {p.toActionState(type: self.type)}]
        
        if type != .sleep {
            op.append(Act.run(elapse3) { p.actionState.takeAction(on: self.target)})
        }
        
        return op
    }
    
    func printDebugInfo() {
        guard debugMode, let player = self.player else { return }
        
        let scoreStr = String(format: "%.3f", score)
        let typeStr = type.rawValue.padding(toLength: 8, withPad: " ", startingAt: 0)
        let armyStr = player.army.rawValue.padding(toLength: 6, withPad: " ", startingAt: 0)
        let round = gameScene.lazyPlayers.filter{ $0.team == .red && $0.isIdle }.count + 1
        let roundStr = "\(gameScene.day)-\(round)".padding(toLength: 5, withPad: " ", startingAt: 0)

        print("\(roundStr) \(armyStr) \(player.grid.paddedStr) \(typeStr) on: \(onGrid.paddedStr) to: \(target.paddedStr) \(scoreStr)")
    }
}



