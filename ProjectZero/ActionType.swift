
import SpriteKit

enum ActionType: String, EnumCollections {
    case basic, sleep,
        double, stab, adjoin,
        snipe, volley, idle,
        saw, fencing, rapid, restore,
        heal, meditate, reinf, shield
    
    static let all: [ActionType] = [.basic, .sleep,
                                    .double, .stab, .adjoin,
                                    .snipe, .volley, .idle,
                                    .saw, .fencing, .rapid, .restore,
                                    .heal, .meditate, .reinf, .shield]
    
    var tx: SKTexture {
        return SKTexture.init(imageNamed: self.rawValue)
    }
    
    var sp: Int {
        return switchVals(0,0,
                          30,40,50,
                          20,50,30,
                          10,30,30,50,
                          20,10,40,30)
    }
    
    var army: Army? {
        return switchVals(nil, nil,
                          .infant, .infant, .infant,
                          .archer, .archer, .archer,
                          .engine, .engine, .engine, .engine,
                          .medic, .medic, .medic, .medic)
    }
    
    var rank: Rank? {
        return switchVals(nil, nil,
                          .r1, .r2, .r3,
                          .r1, .r2, .r3,
                          .r0, .r1, .r2, .r3,
                          .r0, .r1, .r2, .r3)
    }
    
    var applicant: ActionTarget {
        return switchVals(.enemy, .friendly,
                          .enemy, .enemy, .enemy,
                          .enemy, .enemy, .activeEnemy,
                          .sawable, .empty, .activeFriend, .idleFriend,
                          .friendly, .friendly, .friendly, .friendly)
    }
    
    var action:(ActionState) -> () -> [Act] {
        typealias a = ActionState
        return switchVals(a.basic, a.sleep,
                          a.double, a.stab, a.adjoin,
                          a.snipe, a.volley, a.idle,
                          a.saw, a.fencing, a.rapid, a.restore,
                          a.heal, a.meditate, a.reinforce, a.shield)
    }
    
    // MARK: - AI
    
    func aiScoreBlk(_ p: Player) -> ScoreBlk {
        switch self {
        case .basic, .stab, .adjoin, .snipe, .volley: return p.attackHits(1)
        case .double: return p.attackHits(2)
        case .heal, .reinf: return p.recover(hp: true)
        case .meditate: return p.recover(hp: false)
        case .rapid: return p.randomScr
        case .shield: return p.shieldScore
        case .restore, .idle: return p.scrByArmySp(self)
        case .sleep: return { _ in sleepScr }
        case .saw, .fencing: return p.doNothing
        }
    }
    
    func scoreAdj(for playerSP: Int) -> Double {
        switch self {
        case .basic, .sleep: return 1
        default: return 1 - (sp.double / playerSP.double * aiScrSpAdjMax)
        }
    }
    
}

enum ActionTarget {
    case enemy, activeEnemy, friendly, activeFriend, idleFriend, empty, sawable, pinable
}
