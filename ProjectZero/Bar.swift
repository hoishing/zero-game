//
//  Bar.swift
//  Wars
//
//  Created by Kelvin Ng on 27/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import SpriteKit

enum Bar: String, EnumCollections, ColorSprite {    
    case hp, sp
    static let all: [Bar] = [.hp, sp]
    
    static func bars(_ team: Team) -> [SKSpriteNode] {
        return [Bar.hp.sprite(team), Bar.sp.sprite(team)]
    }
    
    func adjSprite(_ team: Team, _ rank: Rank) -> SKSpriteNode {
        let node = sprite(team)
        node.name = self.rawValue
        node.anchorPoint = CGPoint(x: 0, y: 0.5)
        let orgLen: CGFloat = 46
        let x = rank.barMax.cgFloat / absBarMax.cgFloat * orgLen / 2.0
        node.position = CGPoint(x: -x, y: 0)
        if self == .sp  { node.colorBlendFactor = spBlend }
        return node
    }
    
}
