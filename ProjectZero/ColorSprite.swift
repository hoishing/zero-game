//
//  ColorSprite.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 19/9/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

protocol ColorSprite: RawRepresentable {
    var tx: SKTexture { get }
}

extension ColorSprite {
    var tx: SKTexture {
        let texture = SKTexture(imageNamed: "\(self.rawValue)")    //need cast rawValue to String
        texture.filteringMode = .linear
        return texture
    }
    
    func sprite(_ team: Team) -> SKSpriteNode {
        let node = SKSpriteNode(texture: tx)
        node.color = team.color
        node.colorBlendFactor = 1
        return node
    }
}
