//
//  Feature.swift
//  Wars
//
//  Created by Kelvin Ng on 5/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import Foundation

enum Feature: String, EnumCollections {
    case fence, hpWell, spWell, stone, defend
    static var all: [Feature] = [.fence, .hpWell, .spWell, .stone, .defend]
    
    init(name: String) {
        guard let f = Feature(rawValue: name) else {
            fatalError("\(name) not found in Feature enum")
        }
        self = f
    }
    
    init?(name: String?) {
        guard let n = name, let f = Feature(rawValue: n) else {return nil}
        self = f
    }
    
    // MARK: - Properties
    
    var sawable: Bool {
        return Bool(truncating: switchVals(1,1,1,0,0))
    }
    
    var healable: Double? {
        return switchVals(nil,0.3,nil,nil,nil)
    }
    
    var awakable: Double? {
        return switchVals(nil,nil,0.3,nil,nil)
    }
    
    var passable: Bool {
        return Bool(truncating: switchVals(0,1,1,0,1))
    }
    
    var aiScore: Double {
        return switchVals(0,spLocScr,spLocScr,0,defendLocScr)
    }
    
}
