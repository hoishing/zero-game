//
//  GridPt.swift
//  Wars
//
//  Created by Kelvin Ng on 6/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import CoreGraphics

struct GridPt: Hashable, CustomStringConvertible {
    
    var x: Int
    var y: Int
    
    static func - (lhs: GridPt, rhs: GridPt) -> GridPt {
        return GridPt(lhs.x - rhs.x, lhs.y - rhs.y)
    }
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    init(_ scenePos: CGPoint) {
        self.x = gameScene.bgNode.tileColumnIndex(fromPosition: scenePos)
        self.y = gameScene.bgNode.tileRowIndex(fromPosition: scenePos)
    }
    
    init(_ str: String) {
        let arr = str.split("_")
        guard arr.count == 2, let x = arr[0].int, let y = arr[1].int else {
            fatalError("incorrect input string: \(str)")
        }
        self.x = x
        self.y = y
    }
    
    var explores: [GridPt] {
        return [self.up, self.down, self.left, self.right]
    }
    
    var description: String {
        return "\(x)_\(y)"
    }
    
    var paddedStr: String {
        return self.description.padding(toLength: 5, withPad: " ", startingAt: 0)
    }
    
    var cgPt: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    var pos: CGPoint {
        return gameScene.bgNode.centerOfTile(atColumn: x, row: y)
    }
    
    func outOfBound(_ scene: GameScene) -> Bool {
        let row = scene.bgNode.numberOfRows
        let col = scene.bgNode.numberOfColumns
        return x < 0 || y < 0 || x >= col || y >= row
    }
    
    func attGrids(_ att: Att, inclusive: Bool = false) -> [GridPt] {
        let op = att.str.split().map { delta(str: $0) }
        return inclusive ? [self] + op : op
    }
    
    func adjGrids(_ adj: AdjAtt, on target: GridPt, inclusive: Bool = false) -> [GridPt] {
        let dir = enemyDir(at: target)
        let att = dir.attackAttFor(adj)
        return target.attGrids(att, inclusive: inclusive)
    }
    
    func affectedGrids(for type: ActionType, on target: GridPt) -> [GridPt] {
        //too many variations, use switch instead of enum
        switch type {
        case .stab : return adjGrids(.ahead2, on: target, inclusive: true)
//        case .fencing: return adjGrids(.side, on: target, inclusive: true)
        case .volley: return target.attGrids(.square, inclusive: true)
        case .adjoin: return target.attGrids(.square, inclusive: false)
        case .reinf: return target.attGrids(.fill2, inclusive: false) //fill2 included origin already
        default: return [target]
        }
    }
    
    func dir(to grid: GridPt) -> Dir {
        if grid.x == x {    //only move in 4 directions
            return grid.y > y ? .up : .down
        }
        return grid.x > x ? .right : .left
    }
    
    func rotation(for enemy: GridPt) -> Dir? {
        switch (enemy.x - x, enemy.y - y) {
        case let (dx, dy) where dx > abs(dy): return .right
        case let (dx, dy) where -dx > abs(dy): return .left
        case let (dx, dy) where dy > abs(dx): return .up
        case let (dx, dy) where -dy > abs(dx): return .down
        default: return nil //determined by player
        }
    }
    
    func squareGrids(for grid: GridPt) -> [GridPt] {
        let str: String
        switch (grid.x, grid.y) {
        case let (x1, y1) where (x1 == x) && (y1 > y): str = "u,ur,r,dr,d,dl,l,ul"      //敵上
        case let (x1, y1) where (x1 > x) && (y1 > y): str = "ur,r,dr,d,dl,l,ul,u"       //右上
        case let (x1, y1) where (x1 > x) && (y1 == y): str = "r,dr,d,dl,l,ul,u,ur"      //敵右
        case let (x1, y1) where (x1 > x) && (y1 < y): str = "dr,d,dl,l,ul,u,ur,r"       //敵右下
        case let (x1, y1) where (x1 == x) && (y1 < y): str = "d,dl,l,ul,u,ur,r,dr"      //敵下
        case let (x1, y1) where (x1 < x) && (y1 < y): str = "dl,l,ul,u,ur,r,dr,d"       //左下
        case let (x1, y1) where (x1 < x) && (y1 == y): str = "l,ul,u,ur,r,dr,d,dl"      //敵左
        case let (x1, y1) where (x1 < x) && (y1 > y): str = "ul,u,ur,r,dr,d,dl,l"       //敵左
        default: fatalError()
        }
        return str.split().map { delta(str: $0) }
    }
    
    // MARK: Hasable
//    var hashValue: Int {
//        return x.hashValue ^ y.hashValue
//    }
//
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    static func == (lhs: GridPt, rhs: GridPt) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    // MARK: Directions
    var up: GridPt { return delta(0, 1) }
    var down: GridPt { return delta(0, -1) }
    var left: GridPt { return delta(-1, 0) }
    var right: GridPt { return delta(1, 0) }
    
    // MARK: - Uti
    func enemyDir(at grid: GridPt) -> Dir {
        switch (grid.x, grid.y) {
        case let (x1, y1) where (x1 == x) && (y1 > y): return .up       //敵上
        case let (x1, y1) where (x1 == x) && (y1 < y): return .down     //敵下
        case let (x1, y1) where (x1 > x) && (y1 == y): return .right    //敵右
        case let (x1, y1) where (x1 < x) && (y1 == y): return .left     //敵左
        default: fatalError()
        }
    }
    
    func delta(_ dx: Int, _ dy: Int) -> GridPt {
        return GridPt(x + dx, y + dy)
    }
    
    func delta(str: String) -> GridPt {
        var dx = 0
        var dy = 0
        for chr in str {
            switch chr {
            case "u": dy += 1
            case "d": dy -= 1
            case "l": dx -= 1
            case "r": dx += 1
            case "o": ()
            default: fatalError()
            }
        }
        return delta(dx, dy)
    }
    
}
