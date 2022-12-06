
import SpriteKit

protocol MenuAjustable {
    var player: Player {get}
}

extension MenuAjustable {
    func adjustMenu(layer: SKNode, buttons: [ActionButton]) {
        let cnt = buttons.count
        var dx: CGFloat = (cnt - 1) * tileLen / -2.0
        buttons.forEach{
//            $0.isHidden = false
//            $0.position = CGPoint(x: dx, y:0)
//            $0.player = player
            $0.show(player, pos: CGPoint(x: dx, y:0))
            dx += tileLen
        }
        
        let menuWidth = cnt * tileLen / 2.0
        let left = player.node.position.x
        let bottom = player.node.position.y
        let right = gameScene.size.width - left
        
        let y = bottom < tileLen ? bottom + tileLen : bottom - tileLen
        var x: CGFloat = left
        if left < menuWidth {
            x = menuWidth
        } else if right < menuWidth {
            x = left - (menuWidth - right)
        }
        layer.position = CGPoint(x: x, y: y)
        layer.isHidden = false
    }
}
