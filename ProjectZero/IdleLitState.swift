
import GameplayKit

class IdleLitState: StateMaster, Litable {
    var pathDict = [GridPt : [GridPt]]()
    
    override func didEnter(from previousState: GKState?) {
        if player.movable {
            litPath(isActive: false)
        }
        litAttPattern()
    }
    
    override func willExit(to nextState: GKState) {
        clearLit()
    }
    
    //no matter on or off
    override func select(at grid: GridPt) {
        toIdleState()
    }
}
