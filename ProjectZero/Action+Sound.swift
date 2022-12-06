//
//  Actions.swift
//  Wars
//
//  Created by Kelvin Ng on 21/12/2016.
//  Copyright © 2016 Kelvin Ng. All rights reserved.
//

import SpriteKit

extension Act {
    static let fadeInOut = Act(named: "FadeInOut")!
    static let penetrate = Act(named: "Penetrate")!
}

enum Sound: String, EnumCollections {
    case err, die, idle,
        infant1, infant2, fire,
        archer, volley, sleep,
        saw, fencing, rapid, restore,
        heal, meditate, reinf, shield,
        win, lose
    
    static var all: [Sound] = [.err, .die, .idle,
                               .infant1, .infant2, .fire,
                               .archer, .volley, .sleep,
                               .saw, .fencing, .rapid, .restore,
                               .heal, .meditate, .reinf, .shield,
                               .win, .lose]
    
    var mp3: String { return rawValue + ".mp3" }
    
    var act: Act {
        guard musicOn else { return SKAction() }
        return Act.play(mp3)
    }
    
    var waitedAct: Act {
        guard musicOn else { return SKAction() }
        return Act.playSoundFileNamed(mp3, waitForCompletion: true)
    }
    
    func play() {
        guard musicOn else { return }
        gameScene.run(self.act)
    }
}

