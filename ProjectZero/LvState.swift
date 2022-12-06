//
//  LvState.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 16/5/2018.
//  Copyright © 2018 Fbm Development. All rights reserved.
//

import Foundation

struct LvState: Codable {
    let lv: Int
    let day: Int
    let grids: [String: GridState]
}

struct GridState: Codable {
    let feature: String?
    let player: PlayerState?
}

struct PlayerState: Codable {
    let hp: Int
    let sp: Int
    let team: String
    let army: String
    let dir: String
    let rank: Int
    let aggr: Double?
    let isIdle: Bool
}
