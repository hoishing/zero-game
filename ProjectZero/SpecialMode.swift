//
//  SpecialMode.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 7/11/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

enum SpecialMode: String, EnumCollections {
    
    case pin, rapid, shield
//    case penetrate, attUp, defUp //for future use
    
    static var all: [SpecialMode] = [.pin, .rapid, .shield]  //+ [penetrate, .attUp, .defUp]
    
//    var days: Int { return switchVals(3,2,2,2,2) }
}
/*
 Future use

    //Player
    var specialDurations = [SpecialMode: Int]()

    //PlayerRender
    func checkSpecial() {
        for (mode, day) in specialDurations {
            switch mode {
            case .pin:
                specialUI(mode, day: day) { $0.texture = #imageLiteral(resourceName: "pinMark").tx }
            case .rapid:
                specialUI(mode, day: day) { sprite in
                    sprite.texture = self.army.tx
                    sprite.zPosition = -1
                    let seq = [Act.run{ sprite.alpha = 0.5; sprite.setScale(1) },
                               SKAction(named: "expandFade")!]
                    sprite.run(Act.repeatForever(Act.sequence(seq)))
                }
            case .attUp, .defUp, .penetrate: ()
            }
        }
    }

    func specialUI(_ mode: SpecialMode, day: Int, activate: (SKSpriteNode) -> Void) {
        let modeName = mode.rawValue
        if gameScene.day > day {
            if let specialNode = node.childNode(withName: modeName) {
                specialNode.removeFromParent()
            }
            specialDurations[mode] = nil
        } else {
            if node.childNode(withName: modeName) == nil {
                let sprite = SKSpriteNode(color: .red, size: tileSize)
                sprite.name = modeName
                node.addChild(sprite)
                activate(sprite)
            }
        }
    }
 
    //PlayerCombat
    func onSpecial(_ mode: SpecialMode) -> Bool {
        return (specialDurations[mode] ?? 0) >= gameScene.day
    }
 
    func adj(mode: SpecialMode) -> Double {
        return onSpecial(mode) ? specialModeAdj : 1.0
    }
 
     //ActionStateExt
     func applySpecial(_ mode: SpecialMode) {
             let player = gameScene.players[target]!
             let endDay = gameScene.day + mode.days - 1   //inclusive
             player.specialDurations[mode] = endDay
             player.checkSpecial()
     }
 
    //gameScene
    func checkSpecialAll() {
        players.values.forEach{
            $0.checkSpecial()
        }
    }
*/
