
import SpriteKit

extension GameScene {
    
    var lazyPlayers: LazyCollection<Dictionary<GridPt, Player>.Values> { return players.values.lazy }
    
    var hasRunningActions: Bool {
        if hasActions() { return true }
        return lazyPlayers.contains{ $0.node.hasActions() }
    }
    
    var actionButs: [ActionButton] { return actionButsLayer.children as! [ActionButton] }
    
    func scrollTo(_ grid: GridPt) {
        let w = 5 * tileLen
        let x = grid.x * tileLen - 2 * tileLen
        let y = grid.y * tileLen + 2 * tileLen
        let scenePt = CGPoint(x: x, y: y)
        //UIView zero at top, scene zero at bottom
        let scrollViewPt = gameScene.convertPoint(toView: scenePt)
        let visibleRect = CGRect(origin: scrollViewPt, size: CGSize(width: w, height: w))
        vc.scrollV.scrollRectToVisible(visibleRect, animated: true)
//        print(vc.scrollV.bounds, scenePt, scrollViewPt)
    }
    
    func readyPlayers(_ team: Team) -> [Player]? {
        let p: [Player] = lazyPlayers.filter{ $0.team == team && $0.isReady }
        return p.isEmpty ? nil : p
    }
    
    func allIdled(_ team: Team) -> Bool {
        return !lazyPlayers.contains { $0.team == team && !$0.isIdle }
    }
    
    func feature(on grid: GridPt) -> Feature? {
        guard let tile = featureMap.tileDefinition(atColumn: grid.x, row: grid.y),
            let name = tile.name,
                let feature = Feature(rawValue: name) else { return nil }
        return feature
    }
    
    func bgOn(_ grid: GridPt) -> Geo {
        return Geo(rawValue: bgNode.tileGroup(at: grid)!.name!)!
    }
    
    func geo(on grid: GridPt) -> Geo? {
        guard feature(on: grid)?.passable ?? true else { return nil }
        return bgOn(grid)
    }
    
    func refreshState(_ team: Team) {
        for p in players.values where p.team == team {
            p.toState(cls: ReadyState.self)
//            p.clear(mode: .pin)
        }
    }
    
    func clearShield(_ team: Team) {
        lazyPlayers.filter{ $0.team == team }.forEach {
            $0.clear(mode: .shield)
        }
    }
    
    func featurePayoffAct(_ team: Team) -> [Act] {
        //not use lazyPlayers because need to add wait action later
        let players = gameScene.players.values.filter {
            guard $0.team == team else { return false }
            guard let feature = gameScene.feature(on: $0.grid) else { return false }
            return feature == .hpWell || feature == .spWell
        }
        guard !players.isEmpty else { return [] }
        var payoffActs = players.map {
            Act.run(elapse + elapseHeal, blk: $0.featurePayoff)
        }
        payoffActs.append(wait(elapse + elapseHeal))
        return [Act.group(payoffActs)]
    }
    
    func moveSelectNode(_ grid: GridPt) {
        selectNode.isHidden = false
        selectNode.position = grid.pos
        updateHUD()
    }
    
    func clearAllPlayerActions() {
        removeAllActions()
        players.values.forEach{ $0.node.removeAllActions() }
    }

}
