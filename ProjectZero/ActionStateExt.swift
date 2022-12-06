//
//  ActionStateExt.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 2/11/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import GameplayKit

extension ActionState {
    var waitAfter: Act { return wait(elapse3) }
    var waitHeal: Act { return wait(elapseHeal) }
    
    func basic() -> [Act] {
        var seq = [player.army.soundAct,
                   attackAct(target),
                   waitAfter]
        
        guard let enemy = enemyAt(target),
            let attGrids = enemy.attackGrids,   //can do basic attack
            attGrids.contains(player.grid),
            !(enemy.stateMachine.currentState! is IdleState),
            player.basicAttack(enemy) < enemy.hp
            else { return seq }
        
        let enSt = enemy.actionState
        seq += [Act.run { gameScene.moveSelectNode(enemy.grid) },
                Act.run { enemy.rotate(for: self.player.grid) },
                Act.run { enSt.litAttPattern(filter: enSt.hasEnemy) },
                waitAfter,
                enemy.army.soundAct,
                enSt.attackAct(player.grid),
                waitAfter,
                Act.run(enSt.cleanUp)]
        return seq
    }
    
    func sleep() -> [Act] {
//        return [Sound.sleep.waitedAct]
        return [Act]()
    }
    
    func double() -> [Act] {
        return [Sound.infant2.act,
                attackAct(target),
                wait(elapse2),
                Sound.infant1.act,
                attackAct(target),
                waitAfter]
    }
    
    func stab() -> [Act] {
        let grids = player.grid.adjGrids(.ahead2, on: target, inclusive: true)
        let seq = grids.flatMap{
            [Sound.fire.act,
             particleAct("explode", on: $0),
             attackAct($0),
             wait(elapse)]
        }
        return seq + [waitAfter]
    }
    
    
    func adjoin() -> [Act] {
        //not use attGrids because need a specific order
        let grids = player.grid.squareGrids(for: target)
        let seq = grids.flatMap {
            [Sound.fire.act,
             particleAct("explode", on: $0),
             attackAct($0),
             wait(elapse/2)]
        }
        return seq + [waitAfter]
    }
    
    func snipe() -> [Act] {
        return [player.army.soundAct,
                attackAct(target),
                waitAfter]
    }
    
    func volley() -> [Act] {
        let grids = target.attGrids(.square, inclusive: true)
        let seq = grids.flatMap {
            [particleAct("whiteSmoke", on: $0),
             attackAct($0)]
        }
        return [Sound.volley.act] + seq + [wait(1.3)]
    }
    
    func shield() -> [Act] {
        let grids = target.attGrids(.fillSquare)
        let actions: [Act] = grids.map { g in
            let blk = {
                guard let f = self.friendlyAt(g) else { return }
                f.actionState.applySpecial(.shield, on: g)
            }
            
            return Act.run { self.effect(on: g, color: .yellow, upBlk: blk) }
        }

        return [Sound.shield.act] + actions + [wait(elapseShield)]
    }
    
//    func pin() -> [Act] {
//        let blk = {
//            self.applySpecial(.pin)
//            self.enemyAt(self.target)!.node.run(Act.shake())
//        }
//        return [Act.run(blk),
//                Sound.archer.act,
//                waitAfter]
//    }
    
    func saw() -> [Act] {
        return [Sound.saw.act,
                wait(elapse2),
                setFeatureAct(nil, at: target),
                waitAfter]
    }

    func fencing() -> [Act] {
        let grids = player.grid.adjGrids(.side, on: target, inclusive: true)
        let seq = grids.flatMap { grid -> [Act] in
            guard gameScene.feature(on: grid) == nil,
                    gameScene.players[grid] == nil else { return [Act]() }
            return [Sound.fencing.act,
                    setFeatureAct(fenceTileGp, at: grid),
                    wait(elapse)]
        }
        return seq + [waitAfter]
    }
    
    func rapid() -> [Act] {
        return [Act.run{ self.applySpecial(.rapid, on: self.target) },
                Sound.rapid.act,
                waitAfter]
    }

    func restore() -> [Act] {
        let f = friendlyAt(target)!
        let blk = {self.effect(on: self.target,
                               color: .white,
                               upBlk: f.stateMaster.toReadyState)}
        return [Sound.restore.act,
                Act.run(blk),
                wait(elapseShield)]
    }

    func heal() -> [Act] {
        return [Sound.heal.act,
                hpUpAct(target),
                waitHeal]
    }

    func reinforce() -> [Act] {
        var seq = [Sound.reinf.act]
        let grids = target.attGrids(.fill2)
        for grid in grids {
            seq += [hpUpAct(grid)]
        }
        return seq + [waitHeal]
    }

    func meditate() -> [Act] {
        return [Sound.meditate.act,
                spUpAct(target),
                waitHeal]
    }

    func idle() -> [Act] {
        let enemy = enemyAt(target)!
        return [Act.run { enemy.node.run(Act.shake()) },
                Sound.idle.waitedAct,
                Act.run(enemy.stateMaster.toIdleState),
                waitAfter]
    }
    
    // MARK: - Uti
    
    func particleAct(_ name: String, on grid: GridPt) -> Act {
        return Act.run{
            guard let emitter = emitters[name]??.copy() as? SKEmitterNode else {
                print("emitter node '\(name)' not found")
                return
            }
            emitter.position = grid.pos
            emitter.removeAfterwards()
            gameScene.effectLayer.addChild(emitter)
        }
    }
    
    func attackGrid(_ grid: GridPt) {
        guard let enemy = enemyAt(grid) else { return }
        let lost = player.basicAttack(enemy)
        enemy.deduct(hp: lost, by: player)
    }
    
    func attackAct(_ grid: GridPt) -> Act {
        return Act.run{ self.attackGrid(grid) }
    }
        
    func setFeatureAct(_ tileGp: SKTileGroup?, at grid: GridPt) -> Act {
        return Act.run { gameScene.featureMap.setTileGroup(tileGp, forColumn: grid.x, row: grid.y) }
    }
    
    func effect(on grid: GridPt, color: UIColor, upBlk: @escaping () -> Void) {
        let node = SKSpriteNode(texture: #imageLiteral(resourceName: "effect").tx)
        node.position = grid.pos
        node.alpha = 0
        node.color = color
        node.colorBlendFactor = 1
        
        let seq1 = [Act.fadeInOut,
                   Act.removeFromParent()]
        let seq2 = [wait(1.5),
                    Act.run(upBlk)]
        let gp = Act.group([Act.sequence(seq1), Act.sequence(seq2)])
        gameScene.addChild(node)
        node.run(gp)
    }
    
    func hpUpAct(_ grid: GridPt) -> Act {
        let blk = {
            guard let friendly = self.friendlyAt(grid) else {return}
            let newHP = friendly.hp + self.player.healAmt
            friendly.hp = min(friendly.barMax, newHP)
        }
        return Act.run { self.effect(on: grid, color: .green, upBlk: blk) }
    }
    
    func spUpAct(_ grid: GridPt) -> Act {
        let blk = {
            guard let friendly = self.friendlyAt(grid) else {return}
            let newSp = friendly.sp + meditateAmt
            friendly.sp = min(friendly.barMax, newSp)
        }
        return Act.run { self.effect(on: grid, color: spUpColor, upBlk: blk) }
    }
    
    func applySpecial(_ mode: SpecialMode, on target: GridPt) {
        guard let targetPlayer = gameScene.players[target],
            targetPlayer.node.childNode(withName: mode.rawValue) == nil
            else { return }
        
        let sprite = SKSpriteNode(color: .red, size: tileSize)
        sprite.name = mode.rawValue
        
        let effect = {
            let isShield = mode == .shield
            let alpha: CGFloat = 0.9
            sprite.texture = targetPlayer.army.tx
            sprite.color = isShield ? .yellow : .white
            sprite.alpha = alpha
            if isShield { sprite.setScale(0.8) }
            sprite.colorBlendFactor = 1
            sprite.zPosition = -1
            if !isShield {
                let seq = [Act.run{ sprite.alpha = alpha; sprite.setScale(1) },
                           SKAction(named: "expandFade")!]
                sprite.run(Act.repeatForever(Act.sequence(seq)))
            }

        }
        
        switch mode {
        case .pin: sprite.texture = #imageLiteral(resourceName: "pinMark").tx
        case .rapid: effect()
        case .shield: effect()
        }
        
        targetPlayer.node.addChild(sprite)
    }

}








