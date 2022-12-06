
import SpriteKit

// MARK: - Combat
extension Player {
    
    var hpStr: String { return "\(hp)/\(barMax)" }
    var spStr: String { return "\(sp)/\(barMax)" }
    var movable: Bool { return !onSpecial(.pin) }
    var restorable: Bool { return army == .engine && rank == .r3 }
    var healAmt: Int { return healBaseAmt - rank.healDeduction }
    
    var geoAdj: Double {
        let geoDelta = army.performance(on: geo) ?? 0
        return geoDelta * 0.1 + 1.0
    }
    
    var attackGrids: [GridPt]? { return attGrids(from: grid) }
    
    func canAttack(_ target: GridPt, from grid: GridPt) -> Bool {
        return attGrids(from: grid)?.contains(target) ?? false
    }
    
    func attGrids(from grid: GridPt) -> [GridPt]? {
        guard let pattern = army.attPattern(for: rank) else {return nil}
        return grid.attGrids(pattern)
    }
    
    func basicAttack(_ enemy: Player) -> Int {
        let defUp = enemy.onSpecial(.shield) ? shieldAmt : 1.0
        let attDelta = geoAdj * killingRate     // * adj(mode: .attUp)
        let defDelta = enemy.geoAdj * defUp
        return Int(barMax * attDelta / defDelta)
    }
    
    func deduct(hp: Int, by attacker: Player) {
        let newHP = self.hp - hp
        self.hp = max(0, newHP)
        node.run(Act.shake())
        if self.hp == 0 { die() }
    }
    
    func onSpecial(_ mode: SpecialMode) -> Bool {
        return node.childNode(withName: mode.rawValue) != nil
    }
    
    func rotate(for target: GridPt) {
        if let rotation = grid.rotation(for: target) {
            dir = rotation
        } else {
            switch (target.x - grid.x, target.y - grid.y) {
            case let (dx, dy) where dx > 0 && dx == dy:
                if dir != .up { dir = .right }
            case let (dx, dy) where dx < 0 && -dx == dy:
                if dir != .up { dir = .left }
            case let (dx, dy) where dx > 0 && dx == -dy:
                if dir != .down { dir = .right }
            case let (dx, dy) where dx < 0 && -dx == -dy:
                if dir != .down { dir = .left }
            default: ()
            }
        }
        rotate(to: dir)
    }
    
    func clear(mode: SpecialMode) {
        node.childNode(withName: mode.rawValue)?.removeFromParent()
    }
    
    func featurePayoff() {
        guard let f = gameScene.feature(on: grid) else { return }
        let st = actionState
        st.target = grid
        var seq: [Act]? = nil
        switch f {
        case .spWell: seq = st.meditate()
        case .hpWell: seq = st.heal()
        default: ()
        }
        node.run(seq, completion: st.cleanUp)
    }
    
    func die() {
        gameScene.players[grid] = nil
        gameScene.checkGameOver()
        let seq = [wait(scaleDuration + shakeDuration),
                   Sound.die.act,
                   Act.blinkToVanish()]
        node.run(seq)
    }
    
    // MARK: - Uti
    
    func enemyAt(_ grid: GridPt) -> Player? {
        guard let enemy = gameScene.players[grid], enemy.team != team else { return nil }
        return enemy
    }
    
    func friendlyAt(_ grid: GridPt) -> Player? {
        guard let friendly = gameScene.players[grid], friendly.team == team else { return nil }
        return friendly
    }
    
    func idleFriendAt(_ grid: GridPt) -> Player? {
        guard let f = friendlyAt(grid),
            f.isIdle,
            !f.idleSleeped  //not idle sleeped on last move
            else { return nil }
        return f
    }
    
    func activeFriend(_ grid: GridPt) -> Player? {
        guard let f = friendlyAt(grid),
            f.grid != self.grid,
            !f.isIdle else { return nil }
        return f
    }
    
    func activeEnemy(_ grid: GridPt) -> Player? {
        guard let enemy = enemyAt(grid), enemy.isReady else { return nil }
        return enemy
    }
    

}
