//
//  Global.swift
//  Wars
//
//  Created by Kelvin Ng on 5/12/2016.
//  Copyright © 2016 Kelvin Ng. All rights reserved.
//

import SpriteKit

typealias Act = SKAction

//constants
let totalLevel = 20
let iconGrey = UIColor(red: 1, green: 1, blue: 1, alpha: 0.64)
let tileLen: CGFloat = 64
let tileSize = CGSize(width: tileLen, height: tileLen)
let specialModeAdj = 1.3
let killingRate = 0.2
let shieldAmt = 2.5   //2 == damage/2
let scaleDuration = 0.3
let spBlend: CGFloat = 0.5
let spDimBlend: CGFloat = 0.8
let healBaseAmt = 80
let meditateAmt = 50
let moveSpeed: CGFloat = 800
let elapse = 0.2
let elapse2 = 2.0 * elapse
let elapse3 = 3.0 * elapse
let elapseHeal = 2.4
let elapseShield = 1.6
let shakeAmp = 8
let shakeDuration = 0.3
let glowRadius = 5
let absBarMax = Rank.all.last!.rawValue * 20 + 100
let bgMusicVol: Float = 0.3
let spUpColor = UIColor(red: 252.0/255.0, green: 46.0/255.0, blue: 1, alpha: 1)

//AI
let debugMode = false
let notMoveBonus = 0.5
let noFightBackBonus = 1.5
let spLocScr = 7.0
let defendLocScr = 2.0
let killScr = 20.0
let sleepScr = 1.0
let attackWeight = 10.0
let recoverWeight = 20.0
let randomMax = 1.5
let aiScrSpAdjMax = 0.2
let shieldScr = 0.3


weak var gameScene: GameScene!
var musicOn = true

//object pool, for SpriteKit bug when calling SKEmitterNode(fileNamed: "whiteSmoke") multiple times
let emitters = ["whiteSmoke": SKEmitterNode(fileNamed: "whiteSmoke"),
                "explode": SKEmitterNode(fileNamed: "explode")]


let deviceModel: String = {
    if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
    var sysinfo = utsname()
    uname(&sysinfo) // ignore return value
    return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
}()

func wait(_ sec: TimeInterval) -> Act {
    return Act.wait(forDuration: sec)
}

func + (lhs: Int, rhs: Double) -> Double {
    return Double(lhs) + rhs
}

func * (lhs: Int, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

func / (lhs: Int, rhs: Double) -> Double {
    return Double(lhs) / rhs
}

func - (lhs: Int, rhs: Double) -> Double {
    return Double(lhs) - rhs
}


