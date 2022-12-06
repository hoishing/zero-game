//  Created by Kelvin Ng on 5/12/2016.
//  Copyright © 2016 Kelvin Ng. All rights reserved.
//

import GameplayKit

class Player: NSObject {
    
    let army: Army
    let team: Team
    var dir: Dir { didSet{ oldDir = oldValue } }
    var rank: Rank
    var grid: GridPt {
        didSet {                    //won't trigger during init
            if grid != oldValue {   //resetPos may set old == new for non-active player objects
                gameScene.players[grid] = self
                gameScene.players[oldValue] = nil
            }
            oldGrid = oldValue
        }
    }
    let aggr: Double?   //aggressiveness
    var barMax: Int { return rank.barMax }
    
    // RenderPlayer
    var node: SKNode!
    var armyNode: SKSpriteNode!
    var rankNode: SKSpriteNode!
    var spNode: SKSpriteNode!
    var hpNode: SKSpriteNode!
    
    var litLayer: SKNode!   //can't add on GameScene because the running sequence
    var attLayer: SKNode!   //of each player is indetermined in player dict
    
    var hp: Int { didSet{ scale(hpNode, to: hp) } }
    var sp: Int { didSet{ scale(spNode, to: sp) } }
    
    var oldDir: Dir?
    var oldGrid: GridPt?
    var idleSleeped = false //for AI restore
    
    var mp: Int { return army.baseMP + rank.mpBoost + mpAdj}
    var mpAdj: Int { return onSpecial(.rapid) ? 3 : 0 }
    var geo: Geo? { return gameScene.geo(on: grid) }
    
    lazy var stateMachine: GKStateMachine = {
        let stateMachine = GKStateMachine(states: [
            ReadyState(player: self),
            LitState(player: self),
            MenuState(player: self),
            IdleState(player: self),
            IdleLitState(player: self),
            ActionState(player: self)
            ])
        stateMachine.enter(ReadyState.self)
        return stateMachine
    }()
    
    var actionState: ActionState { return stateMachine.state(forClass: ActionState.self)! }
    var litState: LitState { return stateMachine.state(forClass: LitState.self)! }
    var stateMaster: StateMaster { return stateMachine.currentState as! StateMaster }
    var isReady: Bool { return stateMachine.currentState is ReadyState }
    var isIdle: Bool { return stateMachine.currentState is IdleState }

    init(_ team: Team, _ army: Army, _ rank: Rank, _ dir: Dir, _ grid: GridPt, _ aggr: Double?) {
        self.team = team
        self.army = army
        self.dir = dir
        self.rank = rank
        self.grid = grid
        self.aggr = aggr
        hp = rank.barMax
        sp = rank.barMax
        super.init()
        renderNode()
    }
    
    init(state: PlayerState, grid: GridPt) {
        self.team = Team(rawValue: state.team)!
        self.army = Army(rawValue: state.army)!
        self.dir = Dir(rawValue: state.dir)!
        self.rank = Rank(rawValue: state.rank)!
        self.grid = grid
        self.aggr = state.aggr
        hp = state.hp
        sp = state.sp
        super.init()
        renderNode()
        if state.isIdle { stateMaster.toIdleState() }
    }
    
    func select() {
        stateMaster.select(at: grid)
    }
    
    func resetPosDir() {
        dir = oldDir ?? dir
        oldDir = nil
        grid = oldGrid ?? grid
        oldGrid = nil
    }

    func settlePosDir() {
        oldDir = nil
        oldGrid = nil
    }
    
    func toState(cls: AnyClass) {
        stateMachine.enter(cls)
    }
    
    func toActionState(type: ActionType) {
        actionState.type = type
        stateMachine.enter(ActionState.self)
    }

    // MARK: - KVO
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        <#code#>
//    }
}
