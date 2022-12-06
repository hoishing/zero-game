//
//  Extensions.swift
//  Wars
//
//  Created by Kelvin Ng on 24/11/2016.
//  Copyright © 2016 Kelvin Ng. All rights reserved.
//

import SpriteKit

extension CGFloat {
    var int: Int { return Int(self) }
}

extension CGPoint {
    @discardableResult public mutating func offset(pt: CGPoint) -> CGPoint {
        x += pt.x
        y += pt.y
        return self
    }
}

extension CGRect {
    func midPt() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}

extension CGSize {
    static func * (left: CGFloat, right: CGSize) -> CGSize {
        return CGSize(width: left * right.width, height: left * right.height)
    }
}

extension SKTileMapNode {
    func enumerateTiles(with block: (_ row: Int, _ col: Int, _ stop: inout Bool) -> Void) {
        var stop = false
        outer: for row in 0..<numberOfRows {
            for col in 0..<numberOfColumns {
                guard self.tileDefinition(atColumn: col, row: row) != nil else { continue }
                block(col, row, &stop)
                if stop {
                    break outer
                }
            }
        }
    }
    
    func tileGroup(at grid: GridPt) -> SKTileGroup? {
        return self.tileGroup(atColumn: grid.x, row: grid.y)
    }
    
    func tile(at grid: GridPt) -> SKTileDefinition? {
        return self.tileDefinition(atColumn: grid.x, row: grid.y)
    }
    
    func tiles2sprites(_ blk: (_ tileName: String, GridPt) -> Void) {
        self.enumerateTiles { (col, row, stop) in
            guard let tile = self.tileDefinition(atColumn: col, row: row), let name = tile.name else { return }
            blk(name, GridPt(col, row))
        }
    }
}

extension Int {
    var cgFloat: CGFloat { return CGFloat(self) }
}

extension Array {
    var boolVals: [Bool] {
        return self.map {
            guard let i = $0 as? Int else { fatalError("Element is not Int") }
            return i != 0
        }
    }
}

extension SKNode {
    func addChildren(_ children: [SKNode]) {
        for child in children {
            addChild(child)
        }
    }
    
    func addChildren(_ children: SKNode...) {
        addChildren(children)
    }
    
    func addLayer(z: Int) -> SKNode {
        let node = SKNode()
        node.zPosition = CGFloat(z)
        addChild(node)
        return node
    }
    
    func hideNodeTree() {
        self.children.forEach {$0.isHidden = true}
        self.isHidden = true
    }
    
    func  run(_ seq: [SKAction]?, completion: (() -> Void)? = nil) {
        guard let seq = seq else { return }
        guard let blk = completion else {
            run(SKAction.sequence(seq))
            return
        }
        run(SKAction.sequence(seq), completion: blk)
    }
}

extension Image {
    var tx: SKTexture {
        return SKTexture(image: self)
    }
    
    var sprite: SKSpriteNode {
        return SKSpriteNode(texture: self.tx)
    }
    
    func tint(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}

extension SKSpriteNode {
    func inset(_ cap: CGFloat) {
        guard let texture = self.texture else { return }
        let w = texture.size().width
        let x = cap/w
        let rectWidth = (w - CGFloat(2) * cap)/w
        let centerRect = CGRect(x: x, y: x, width: rectWidth, height: rectWidth)
        self.centerRect = centerRect
    }
    
    func scale(_ x: CGFloat, _ y: CGFloat) {
        self.xScale = x
        self.yScale = y
    }
    
    convenience init(texture: SKTexture?, z: Int = 0, pos: CGPoint = CGPoint.zero) {
        self.init(texture: texture)
        zPosition = CGFloat(z)
        position = pos
    }
}

extension Dictionary {
    init(keys: [Key], vals: [Value]) {
        guard keys.count == vals.count else {
            fatalError("keys.count != vals.count")
        }
        self.init()
        for idx in 0..<keys.count {
            self[keys[idx]] = vals[idx]
        }
    }
}

extension SKAction {
    class func shake(duration:TimeInterval = shakeDuration, amplitudeX:Int = shakeAmp, amplitudeY:Int = shakeAmp) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
    
    class func play(_ fileName: String) -> SKAction {
        return SKAction.playSoundFileNamed(fileName, waitForCompletion: false)
    }
    
    class func blinkToVanish() -> SKAction {
        var elapse = 0.2
        var seq = [SKAction]()
        var show = true
        for _ in (1...12) {
            let act = show ? SKAction.unhide() : SKAction.hide()
            seq += [act,
                    SKAction.wait(forDuration: elapse)]
            show = !show
            elapse -= 0.01
        }
        
        return SKAction.sequence(seq)
    }
    
    class func run(_ sec: TimeInterval, blk: @escaping () -> Void ) -> SKAction {
        let gp = [SKAction.run(blk),
                  SKAction.wait(forDuration: sec)]
        return SKAction.group(gp)
    }
}

//extension SKScene {
//    func fadeOutMusicAct(sec: TimeInterval) -> SKAction {
//        return SKAction.customAction(withDuration: sec) { (node, elapse) in
//            let vol = 1 - Float(elapse) / Float(sec)
//            self.audioEngine.mainMixerNode.outputVolume = vol
//        }
//    }
//}

extension SKEmitterNode {
    var lifeSpan: TimeInterval {
        guard numParticlesToEmit > 0 else { return 0 }
        let maxLifeSpan = CGFloat(numParticlesToEmit) / particleBirthRate + particleLifetime + particleLifetimeRange / 2
        return TimeInterval(maxLifeSpan)
    }
    
    func removeAfterwards() {
        let span = lifeSpan
        if span == 0 { return }
        let seq = [wait(lifeSpan * 2), Act.removeFromParent()]
        run(seq)
    }
}



