//
//  Army.swift
//  Wars
//
//  Created by Kelvin Ng on 22/12/2016.
//  Copyright © 2016 Kelvin Ng. All rights reserved.
//

import SpriteKit

enum Army: String, EnumCollections, ColorSprite {
    case infant, archer, engine, medic
    static var all: [Army] = [.infant, .archer, .engine, .medic]
    static let allStr = Army.all.map{$0.rawValue}
    
    var baseMP: Int {
        return switchVals(2,3,3,2)
    }
    
    var explode: Bool {
        return Bool(truncating: switchVals(0,0,1,0))
    }
    
    var soundAct: Act {
        let vals = switchVals(Sound.infant1.act, Sound.archer.act, nil, nil)
        guard let act = vals else { return Act.run{} }
        return act
    }
    
    func mpUsed(on geo: Geo) -> Int? {
        guard let perform = performance(on: geo) else { return nil }
        return perform < 0 ? 1 - perform : 1
    }
    
    static let geoPerform: [[Int]] = [[0,1,-1],
                                      [0,2,-1],
                                      [0,-1,-2],
                                      [0,-1,-2]]
    
    func performance(on geo: Geo?) -> Int? {
        guard let geo = geo else { return nil }
        return valFor(matrix: Army.geoPerform, rowIdx: geo.idx)
    }
    
    static let attPattern: [[Att?]] = [[.basic, .square, .square, .square],
                                       [.archer, .archer2, .archer2a, .archer3a],
                                       [nil, nil, nil, nil],
                                       [nil, nil, nil, nil]]
    
    func attPattern(for rank: Rank) -> Att? {
        return valFor(matrix: Army.attPattern, rowIdx: rank.rawValue)
    }
    
    static let magicPattern: [[Att?]] = [[nil, .basic, .basic, .square],
                                        [nil, .cata, .archer2a, .basic3],
                                        [.fillSquare, .basic, .fillSquare, .basic2],
                                        [.fill3, .fill2, .fillSquare, .fill2]]
    
    func magicPattern(for rank: Rank) -> Att? {
        return valFor(matrix: Army.magicPattern, rowIdx: rank.rawValue)
    }
    
    // MARK: - AI
    
    func aiScore(_ type: ActionType) -> Double? {
        switch type {
        case .restore: return switchVals(0.8, 0.4, nil, 0.6)
        case .idle: return switchVals(0.4, 0.5, 0.1, 0.5)
        default: return nil
        }
    }

}
    

    
    
    
    
    
    
    
    
    

