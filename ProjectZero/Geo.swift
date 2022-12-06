//
//  Geo.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 7/9/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

enum Geo: String, EnumCollections {
    static var all: [Geo] = [.dirt, .grass, .aqua]
    
    case dirt, grass, aqua
}
