//
//  Team.swift
//  Wars
//
//  Created by Kelvin Ng on 6/1/2017.
//  Copyright © 2017 Kelvin Ng. All rights reserved.
//

import SpriteKit

enum Team: String, EnumCollections {
    case red, blue

    static var all: [Team] = [.blue, .red]
    static let allStr = Team.all.map{$0.rawValue}
    
    var color: UIColor {
        switch self {
        case .blue: return UIColor(red: 0.48, green: 0.75, blue: 1.0, alpha: 1.0)
        case .red: return UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        }
    }
    
    var dimColor: UIColor {
        switch self {
        case .blue: return UIColor(red: 0.18, green: 0.30, blue: 0.42, alpha: 1.0)
        case .red: return UIColor(red: 0.42, green: 0.18, blue: 0.18, alpha: 1.0)
        }
    }
    
}
