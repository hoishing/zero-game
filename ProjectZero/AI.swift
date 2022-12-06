/*
 Test Scenario
 Use magic for multiple kill
 leaving defend / hpWell to kill
 stay in hpWell and use magic for damage, instead of go out to kill
 
 
 */

import SpriteKit

//typealias AIMove = (seq: [Act], score: Double, idleSleep: Bool)
typealias ScoreBlk = (GridPt) -> Double?

extension Player: PathFinder {
    var hpPercent: Int { return hp / barMax }
    var mpPercent: Int { return mp / barMax }
    
    var basicAttackable: Bool { return army.attPattern(for: rank) != nil }
    
    var actionTypes: [ActionType] {
        let types = ActionType.all.filter { type -> Bool in
            switch type {
            case .basic: return basicAttackable
            case .sleep: return true
            default: return type.army == army && (type.rank!.rawValue <= rank.rawValue)
            }
        }
        return types
    }

    var aiMove: AIMove {
        let dicts = pathDicts(self, incOccupy: false)
        let orgPaths = dicts.org
        let orgGrids = orgPaths.keys
        let moves = orgGrids.map(bestAiOn)
        let orgBest = bestMove(in: moves)
        guard let extPaths = dicts.ext, orgBest.idleSleep else {
            return orgBest
        }
        
        //extra phase
        let extMoves = extPaths.keys.map(bestAiOn)
        let extBest = bestMove(in: extMoves)
        if extBest.score <= orgBest.score { return orgBest }
        let planningPath = extPaths[extBest.onGrid]!
        let actualPath = planningPath.filter(orgGrids.contains)
        let destin = actualPath.last!
//        print("plan:", planningPath, "actual:", actualPath, "destin:", destin)
        return bestAiOn(destin)
    }
    
    func bestAiOn(_ grid: GridPt) -> AIMove {
        let at = actionTypes
        let movesFromActions = at.compactMap { (type) -> AIMove? in
            aiMoveFor(type, on: grid, scoreBlk: type.aiScoreBlk(self))
        }
        return bestMove(in: movesFromActions)
    }

    
    func aiMoveFor(_ type: ActionType, on grid: GridPt, scoreBlk: ScoreBlk ) -> AIMove? {
        guard let targets = targets(for: type, on: grid) else { return nil }
        //sort out highest score from each target
        return targets.reduce(nil) { (prevAI, target) -> AIMove? in
            guard actionState.valid(type: type, target: target, onGrid: grid) else { return prevAI }
            let affGrids = grid.affectedGrids(for: type, on: target)    //including the target itself
            //add up scores for all affected grids
            guard let score = affGrids.reduce(nil, ({ (prevScore, affGrid) -> Double? in
                guard let newScore = scoreBlk(affGrid) else { return prevScore }
                guard let preScr = prevScore else { return newScore }
                return newScore + preScr
            })) else { return prevAI }
            let adjScore = score * type.scoreAdj(for: sp)
                + locationBonus(on: grid)
                + nonFightBackBonus(on: target, from: grid, type: type)
            if (prevAI?.score ?? 0) < adjScore {
                let ai = AIMove(player: self, score: adjScore, type: type, onGrid: grid, target: target)
                ai.printDebugInfo()
                return ai
            }
            return prevAI
        }
    }
    
    // MARK: - score block
    
    func attackHits(_ hits: Int) -> ScoreBlk {
        let blk = { (grid: GridPt) -> Double? in
            guard let enemy = self.enemyAt(grid) else { return nil }
            let damage = self.basicAttack(enemy) * hits
            let damageFraction = damage.double / enemy.hp.double
            let score = damageFraction < 1 ? damageFraction * attackWeight : killScr
            return score
        }
        return blk
    }
    
    func recover(hp: Bool) -> ScoreBlk {
        let blk = { (grid: GridPt) -> Double? in
            guard let friendly = self.friendlyAt(grid) else { return nil }
            let val = hp ? friendly.hp : friendly.sp
            if val == friendly.barMax { return nil }
            let upAmt = hp ? self.healAmt : meditateAmt     //healAmt vary by rank, meditateAmt is constant
            let up = min((val + upAmt), friendly.barMax) - val
            let fineTune = hp ? 1.0 : 1.5   //lower meditate triggering point
            let upFraction = up.double / (val.double * fineTune)
            let score = upFraction * recoverWeight
            return score
        }
        return blk
    }
    
    func scrByArmySp(_ type: ActionType) -> ScoreBlk {
        let targetBlk: (GridPt) -> Player?
        switch type {
        case .restore: targetBlk = idleFriendAt
        case .idle: targetBlk = activeEnemy
        default: fatalError()
        }
        let blk = { (grid: GridPt) -> Double? in
            guard let target = targetBlk(grid),
                  let armyScr = target.army.aiScore(type) else { return nil }
            let spScr = target.sp.double / target.barMax.double
            return armyScr + spScr
        }
        return blk
    }
    
    func shieldScore(_ grid: GridPt) -> Double? {
        guard let f = friendlyAt(grid), f.onSpecial(.shield) else { return nil }
        return shieldScr
    }
    
    func randomScr(_ grid: GridPt) -> Double? {
        return Uti.randDouble * randomMax
    }    
    
    func doNothing(_ grid: GridPt) -> Double? {
        return nil
    }
    
    // MARK: - Uti
    func targets(for type: ActionType, on grid: GridPt) -> [GridPt]? {
        switch type {
        case .sleep: return [grid]
        case .basic: return attGrids(from: grid)
        default:
            guard sp >= type.sp else { return nil }
            actionState.type = type
            return actionState.validMagicGrids(from: grid)
        }
    }
    
    func locationBonus(on grid: GridPt) -> Double {
        var op = gameScene.feature(on: grid)?.aiScore ?? 0
        if grid == self.grid { op += notMoveBonus }
        return op
    }
    
    func nonFightBackBonus(on target: GridPt, from: GridPt, type: ActionType) -> Double {
        guard type == .basic, let enemy = enemyAt(target) else { return 0 }
        return enemy.canAttack(target, from: from) ? 0 : noFightBackBonus
    }
    
    func bestMove(in moves: [AIMove]) -> AIMove {
        
        guard moves.count > 1 else { return moves[0] }
        return moves[1...].reduce(moves[0]) { (prev, move) -> AIMove in
            move.score > prev.score ? move : prev
        }
    }
    
    func farthestGrid(on path: [GridPt], within dict1: PathDict) -> GridPt {
        guard path.count > 1 else { return path[0] }
        var op: GridPt = path[0]
        path[1...].forEach {
            if dict1[$0] == nil { return }
            op = $0
        }
        return op
    }
    
}
