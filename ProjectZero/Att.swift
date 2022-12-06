//
//  Att.swift
//  Wars
//
//  Created by Kelvin Ng on 10/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import Foundation

enum Att {
    case origin
    case basic, basic2, basic3, basic4, basic5
    case fill, fill2, fill3, fill4, fill5, fillSquare
    case square, square2
    case corner, corner2
    case cross3, cross4, cross5
    case archer, archer2, archer3, archer4
    case archerSide, archer2a, archer3a, archer4a
    case cata, cata2, cata3
    case straight2, straight3, straight4, straight5
    case boldUp2, boldLeft2, boldDown2, boldRight2

    //adjacent hits
    case up, up2, up3, left, left2, left3, right, right2, right3, down, down2, down3
    case sideVert, sideHori
    
    static func + (lhs: Att, rhs: Att) -> String {
        return lhs.str + "," + rhs.str
    }
    
    static func + (lhs: String, rhs: Att) -> String {
        return lhs + "," + rhs.str
    }
    
    static func + (lhs: Att, rhs: String) -> String {
        return lhs.str + "," + rhs
    }
    
    var str: String {
        switch self {
        case .origin: return "o"
        case .basic: return "u,d,l,r"
        case .basic2: return .basic + .archer2
        case .basic3: return .cross3 + .archer3 + .basic
        case .basic4: return .square + "uuul,uuur,dddl,dddr,lllu,llld,rrru,rrrd" + .cross3 + .cross4
        case .basic5: return .cata3 + .archer3 + .basic
        case .fill: return .basic + .origin
        case .fillSquare: return .fill + .corner
        case .fill2: return .basic2 + .origin
        case .fill3: return .basic3 + .origin
        case .fill4: return .basic4 + .origin
        case .fill5: return .basic5 + .origin
        case .corner: return "ul,ur,dl,dr"
        case .corner2: return "uull,uurr,ddll,ddrr"
        case .cross3: return "uuu,ddd,lll,rrr"
        case .cross4: return "uuuu,dddd,llll,rrrr"
        case .cross5: return "uuuuu,ddddd,lllll,rrrrr"
        case .square: return .basic + .corner
        case .square2: return .archer3 + .basic + .corner2
        case .archer: return "uu,dd,ll,rr"
        case .archerSide: return "uul,uur,ddl,ddr,llu,lld,rru,rrd"
        case .archer2: return .archer + .corner
        case .archer2a: return .archer + .archerSide
        case .archer3: return .archer2 + .archerSide
        case .archer3a: return .archerSide + .cross3
        case .archer4a: return .archer3a + "uuul,uuur,dddl,dddr,lllu,llld,rrru,rrrd" + .corner2
        case .archer4: return .archer3 + .cross3
        case .cata: return .cross3 + "uuul,uuull,uuur,uuurr,dddl,dddll,dddr,dddrr,lllu,llluu,llld,llldd,rrru,rrruu,rrrd,rrrdd"
        case .cata2: return .cata + "uuuul,uuuur,ddddl,ddddr,llllu,lllld,rrrru,rrrrd" + .cross4
        case .cata3: return .cata2 + .corner2 + .cross5
        case .straight2: return .basic + .archer
        case .straight3: return .straight2 + .cross3
        case .straight4: return .straight3 + .cross4
        case .straight5: return .straight4 + .cross5
        case .boldUp2: return .up2 + "l,lu,luu,r,ru,ruu"
        case .boldDown2: return .down2 + "l,ld,ldd,r,rd,rdd"
        case .boldRight2: return .right2 + "u,ur,urr,d,dr,drr"
        case .boldLeft2: return .left2 + "u,ul,ull,d,dl,dll"
        case .up: return "u"
        case .up2: return "u,uu"
        case .up3: return "u,uu,uuu"
        case .down: return "d"
        case .down2: return "d,dd"
        case .down3: return "d,dd,ddd"
        case .left: return "l"
        case .left2: return "l,ll"
        case .left3: return "l,ll,lll"
        case .right: return "r"
        case .right2: return "r,rr"
        case .right3: return "r,rr,rrr"
        case .sideVert: return "l,r"
        case .sideHori: return "u,d"
        }
    }
}

enum AdjAtt: String, EnumCollections {
    case side, ahead, ahead2, ahead3, boldAhead2
    static var all: [AdjAtt] = [.side, .ahead, .ahead2, .ahead3, .boldAhead2]
}
