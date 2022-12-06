//
//  Rank.swift
//  Wars
//
//  Created by Kelvin Ng on 6/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import SpriteKit

enum Rank: Int, EnumCollections, ColorSprite {
    case r0, r1, r2, r3
    
    static var all: [Rank] = [.r0, .r1, .r2, .r3]
    static let allStr = Rank.all.map{String($0.rawValue)}
    
    init(name: String) {
        guard let rankNum = Int(name) else { fatalError("\(name) incorrect") }
        self = Rank.all[rankNum]
    }
    
    var tx: SKTexture {
        let imgName =  self == .r0 ? "0_runtime" : rawValue.str
        return SKTexture(imageNamed: imgName)
    }
    var mpBoost: Int {
        return self.rawValue
    }
    
    var rawStr: String {
        return String(rawValue)
    }
    
    var barMax: Int {
        return 100 + rawValue * 20
    }

    var healDeduction: Int {
        return switchVals(30, 20, 10, 0)
    }
    
    
}
