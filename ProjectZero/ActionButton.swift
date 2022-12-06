
import SpriteKit

class ActionButton: SKSpriteNode {
    
    weak var player: Player?
    let type: ActionType
    var highlighted = false
    var enoughSP: Bool { return player?.sp ?? 0 >= type.sp }
    
    init(type: ActionType) {
        self.type = type
        super.init(texture: type.tx, color: .clear, size: type.tx.size())
        self.name = type.rawValue
        self.isHidden = true
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard gameScene.currentTeam == .blue && !highlighted else { return }    //prevent pressing during AI phase
        guard enoughSP else {
            self.player?.stateMaster.toReadyState()
            return
        }
        highlight()
        Uti.wait(elapse)
        player?.toActionState(type: self.type)
    }
    
    func highlight() {
        color = .yellow
        colorBlendFactor = 0.7
        highlighted = true
    }

    func show(_ player: Player, pos: CGPoint) {
        self.player = player
        color = .black
        colorBlendFactor = enoughSP ? 0 : 0.6
        position = pos
        isHidden = false
        highlighted = false
    }

}

