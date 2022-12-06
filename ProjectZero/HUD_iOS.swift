//
//  HUD_iOS.swift
//  ProjectZero
//
//  Created by hoishing on 11/9/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    var labelDict: [String: UILabel] {
        return ["hp": vc.hpLabel, "sp": vc.spLabel, "cal": vc.calLabel]
    }
    
    func updateHUD() {
        let grid = GridPt(selectNode.position)
        guard let player = players[grid] else {
            showPlayerHUD(false)
            return
        }
        updateLabel("sp", str: player.spStr)
        updateLabel("hp", str: player.hpStr)
        showPlayerHUD(true)
    }
    
    func updateLabel(_ label: String, str: String) {
        labelDict[label]?.text = str
    }
    
    func showPlayerHUD(_ on: Bool) {
        vc.playerHUD.isHidden = !on
    }
    
    func changeTo(_ team: Team) -> [Act] {
        if isGameOver { return [Act]() }
        let veryHigh = UILayoutPriority(800)
        let xCons = vc.calCenterX!
        let yCons = vc.calCenterY!
        let container = vc.calContainerV!
        
        let zoomIn = {
            self.vc.cal_imgV.image = #imageLiteral(resourceName: "iconCal").tint(color: team.color)
            xCons.priority = veryHigh
            yCons.priority = veryHigh
            container.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        let zoomViewAni = {
            UIView.animate(withDuration: 1, delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.8,
                           options: .curveEaseInOut,
                           animations: zoomIn)
        }
        
        let zoomOut = {
            xCons.priority = .defaultLow
            yCons.priority = .defaultLow
            container.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        let seq = [wait(1),
                   Act.run(1, blk: zoomViewAni),
                   Act.run(1, blk: zoomOut)]
        return seq  //duration 3 sec
    }
    
    
}
