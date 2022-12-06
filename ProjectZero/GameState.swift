//
//  GameState.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 8/12/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    func checkGameOver() {   //do nothing if still have blue or red
        if !lazyPlayers.contains(where: {$0.team == .blue}) { lose() }
        if !lazyPlayers.contains(where: {$0.team == .red}) { win() }
    }
    
    func checkChangeTeam() {
        if isGameOver || hasRunningActions { return }
        let oldTeam = gameScene.currentTeam
        guard allIdled(oldTeam) else { return }
        let newTeam: Team = oldTeam == .blue ? .red : .blue
        if newTeam == .blue { newDay() }
        gameScene.currentTeam = newTeam
        
        clearShield(newTeam)    //clear speical shield mode
        let seqPayoff = featurePayoffAct(oldTeam) //timed actions or empty
        var seqHUD = changeTo(newTeam)  //3 secs
        seqHUD.append(Act.run{ self.refreshState(oldTeam) })
        
        run(seqPayoff + seqHUD)
    }
    
    func runAI() {
        if isGameOver || currentTeam == .blue ||
            hasRunningActions || processingAI { return }
        guard let enemies = readyPlayers(.red) else { return }

        //process ai in background
        processingAI = true
        var aiMoves: AIMove?
        var profileStr: Date?
        
        //only show spinner from lv 9
        if let lv = vc?.level, lv > 8 {
            vc?.spinner.startAnimating()
        }

        let aiBlk = {
            if debugMode { profileStr = Date() }
            aiMoves = enemies.reduce(nil, { (prevAI, enemy) -> AIMove? in
                let currentAI = enemy.aiMove
                return currentAI.score >= (prevAI?.score ?? 0) ? currentAI : prevAI
            })
        }
        
        let blk = {
            defer {
                self.processingAI = false
                self.vc?.spinner.stopAnimating()
            }
            guard let ai = aiMoves else { return }
            
            //profiling
            if let start = profileStr {
                print("Executed:", terminator: " ")
                ai.printDebugInfo()
                let timelapse = Date().timeIntervalSince(start)
                print(deviceModel, "time used:", timelapse)
            }
            
            self.run(ai.seq)
        }
        
        Uti.bgTask(aiBlk, compBlk: blk, priority: .userInteractive)
    }
    
    func unlockNextLevel() {
        let newLv = vc.level + 1
        if newLv > vc.menuVC.maxLevel {
            vc.menuVC.setMaxLevel(to: newLv)
        }
    }
    
    func newDay() {
        day += 1
        if day > maxDay {
            lose()
            return
        }
        updateLabel("cal", str: "\(day)/\(maxDay)")
        autoSave()
    }
    
    func lose() {
        endLevel(win: false)
    }
    
    func win() {
        unlockNextLevel()
        endLevel(win: true)
    }
    
    func endLevel(win: Bool) {
        isGameOver = true
        let icon: UIImageView = win ? vc.iconWin : vc.iconLose
        let sound: Sound = win ? .win : .lose
        let changeVol = Act.changeVolume(to: 0, duration: 4)
        let seq = [wait(2.5),          //wait for last die animation
                   Act.run{ icon.isHidden = false },
                   sound.act,
                   Act.run(changeVol, onChildWithName: "audioNode"),
                   Act.run{ self.vc.backBut.setImage(#imageLiteral(resourceName: "iconBackLit"), for: .normal) }]
        run(seq)
    }
}
