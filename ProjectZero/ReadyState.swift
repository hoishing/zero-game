
import GameplayKit


class ReadyState: StateMaster {

    override func didEnter(from previousState: GKState?) {
        player.resetPosDir()
        player.idleSleeped = false
    
        if player.node.hasActions() { player.node.removeAllActions() }
        player.resetNode()
        player.changeColor(dim: false)
    }

    override func on(_ grid: GridPt) {
        to(state: LitState.self)
    }
}

