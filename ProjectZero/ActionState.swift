
import GameplayKit

class ActionState: StateMaster, MenuAjustable, LitAtt {
    
    var type: ActionType!
    var target: GridPt!
    let fenceTileGp = SKTileSet(named: "feature")!.tileGroups.lazy.filter{$0.name == "fence"}.first!
    
    override func willExit(to nextState: GKState) {
        cleanUp()
    }
    
    override func didEnter(from previousState: GKState?) {
        switch type! {
        case .basic: litAttPattern(filter: hasEnemy)
        case .sleep:
            player.idleSleeped = player.oldGrid == nil  //old grid is nil when not moved
            takeAction(on: player.grid)
        default: litPattern(magicGrids(from: player.grid), filter: typeValidity)
        }
    }
    
    override func select(at grid: GridPt) {
        toReadyState() //no matter on or off
    }
    
    func adjustButtons() {
        let buts = (0 ... player.rank.rawValue).compactMap {
            gameScene.actionButsLayer.childNode(withName: "\(player.army.rawValue)\($0)") as? ActionButton
        }
        adjustMenu(layer: gameScene.actionButsLayer, buttons: buts)
    }
    
    func prepareAction(on grid: GridPt) -> [Act]? {
        target = grid
        guard typeValidity(grid) && (player.sp >= type.sp) else { toReadyState(); return nil }
        player.sp -= type.sp
        player.rotate(for: target)
        clearLitAtt()
        gameScene.moveSelectNode(grid)
        let seq = type.action(self)()
        return seq + [Act.run(gameScene.updateHUD),
                      Act.run(toIdleState),
                      wait(elapse)]
    }
    
    func takeAction(on grid: GridPt) {
        guard let seq = prepareAction(on: grid) else { return }
        player.node.run(seq)
    }
    
    // MARK: - Uti
    
    func magicGrids(from grid: GridPt) -> [GridPt] {
        //can't use player rank, as r3 player can use r0 - r3 magic
        guard let rank = type.rank, let att = player.army.magicPattern(for: rank) else {
            return [GridPt]()    //empty for r0 of infant/archer
        }
        return grid.attGrids(att)
    }
    
    func validMagicGrids(from grid: GridPt) -> [GridPt]? {
        let grids = magicGrids(from: grid).filter(typeValidity)
        return grids.isEmpty ? nil : grids
    }
    
    func clearEffectLayer() -> Act {
        return Act.run(gameScene.effectLayer.removeAllChildren)
    }
    
    func typeValidity(_ grid: GridPt) -> Bool {
        return valid(type: type, target: grid)
    }
    
    func valid(type: ActionType, target: GridPt, onGrid: GridPt? = nil) -> Bool {
        switch type.applicant {
        case .enemy:
            return hasEnemy(target)
        case .friendly:
            if let toBe = onGrid, target == toBe { return true }
            return friendlyAt(target) != nil
        case .activeFriend:
            return player.activeFriend(target) != nil
        case .empty:
            return gameScene.players[target] == nil && gameScene.feature(on: target) == nil
        case .sawable:
            if let feature = gameScene.feature(on: target), feature.sawable { return true }
        case .idleFriend:
            return player.idleFriendAt(target) != nil
        case .activeEnemy:
            return player.activeEnemy(target) != nil
        case .pinable:
            if let enemy = enemyAt(target), !enemy.onSpecial(.pin) { return true }
        }
        return false
    }
    
    func enemyAt(_ grid: GridPt) -> Player? {
        return player.enemyAt(grid)
    }
    
    func friendlyAt(_ grid: GridPt) -> Player? {
        return player.friendlyAt(grid)
    }

    func hasEnemy(_ grid: GridPt) -> Bool {
        return enemyAt(grid) != nil
    }
    
    func cleanUp() {
        clearLitAtt()
        type = nil
        target = nil
    }
    
    
}


