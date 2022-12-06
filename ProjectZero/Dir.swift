//
//  Dir.swift
//  Wars
//
//  Created by hoishing on 19/2/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import SpriteKit

enum Dir: String, EnumCollections {
    case up, down, left, right
    static var all: [Dir] = [.up, .down, .left, .right]

    var radian: CGFloat {
        var deg: CGFloat
        switch self {
        case .up:
            deg = 0
        case .left:
            deg = 90
        case .down:
            deg = 180
        case .right:
            deg = 270
        }
        return deg.degreesToRadians()
    }
    
    var rotation: SKTileDefinitionRotation {
        return switchVals(.rotation0, .rotation180, .rotation90, .rotation270)
    }
    
    init(radian: CGFloat) {
        let deg = Int(radian.radiansToDegrees().rounded())
        self = Dir(deg: deg)
    }
    
    init(deg: Int) {
        let degree = deg < 0 ? deg + 360 : deg
        switch degree {
        case 0: self = .up
        case 90: self = .left
        case 180: self = .down
        case 270: self = .right
        default: fatalError()
        }
    }
    
    func attackAttFor(_ adj: AdjAtt) -> Att {
        let arr: [[Att]] = [[.sideVert, .sideVert, .sideHori, .sideHori],
                            [.up, .down, .left, .right],
                            [.up2, .down2, .left2, .right2],
                            [.up3, .down3, .left3, .right3],
                            [.boldUp2, .boldDown2, .boldLeft2, .boldRight2]]
        let attsOfAdj = adj.switchVals(arr)
        return switchVals(attsOfAdj)
    }
}
