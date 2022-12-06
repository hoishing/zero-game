/*
 zPosition:
 - 10: litLayer
 - 9: att at dim
 - 1: debug
 0: bg
 1: actionPad
 2: feature
 20: players
 25: select
 27: touch layer
 30: Action Menu
 50: att
 100: effect
 100: Camera
 
*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var lvState: LvState?
    weak var vc: GameVC!
    var isGameOver = false
    var aiTimer: Timer?
    var processingAI = false
    
    var playerLayer: SKNode!
    var effectLayer: SKNode!
    var actionButsLayer: SKNode!
    var debugLayer: SKNode!
    
    var configMaps: [SKTileMapNode?] {
        return [childNode(withName: "army") as? SKTileMapNode,
                childNode(withName: "team") as? SKTileMapNode,
                childNode(withName: "dir") as? SKTileMapNode,
                childNode(withName: "rank") as? SKTileMapNode,
                childNode(withName: "aggr") as? SKTileMapNode]
    }
    
    
    var players = [GridPt: Player]()
    
    var day = 1
    var currentTeam = Team.blue

    lazy var maxDay: Int = { self.userData?["maxDay"] as! Int }()
    
    lazy var selectNode: SKSpriteNode = {
        let node = #imageLiteral(resourceName: "select").sprite
        node.isHidden = true
        node.zPosition = 25
        self.addChild(node)
        return node
    }()

    var featureMap: SKTileMapNode!
    lazy var bgNode: SKTileMapNode = { self.childNode(withName: "bg") as! SKTileMapNode }()
    
    override func didMove(to view: SKView) {
        _ = Sound.all.map{$0.waitedAct} //preload sound
        isUserInteractionEnabled = false
        addChild(TouchLayer())
        prepareLayers()
        prepareFeatures()
        preparePlayers()
        removeConfigMaps()
        hideSceneEditingTiles()
        prepareDay()
        preapareDebugLayer()
        aiTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: timerBlk)
//        allBlueSleep()
    }
    
//    deinit {
//        print("gameScene deinited")
//    }
    
    func prepareDay() {
        if let d = lvState?.day {
            day = d
        }
        updateLabel("cal", str: "\(day)/\(maxDay)")
    }
    
    func prepareFeatures() {
        let orgFeatureMap = childNode(withName: "feature") as? SKTileMapNode
        guard let state = lvState else {
            //not load from saved data
            featureMap = orgFeatureMap
            return
        }
        
        orgFeatureMap?.removeFromParent()
        
        let tileSet = SKTileSet(named: "feature")!
        featureMap = SKTileMapNode(tileSet: tileSet,
                                   columns: bgNode.numberOfColumns,
                                   rows: bgNode.numberOfRows,
                                   tileSize: bgNode.tileSize)
        featureMap.zPosition = 2
        featureMap.anchorPoint = CGPoint.zero
        addChild(featureMap)
        
        let tileGps = tileSet.tileGroups.lazy
        enumerateGridState(state, filter: { $0.feature != nil }) { (grid, gState) in
            let tileGp = tileGps.filter{$0.name == gState.feature!}.first!
            featureMap.setTileGroup(tileGp, forColumn: grid.x, row: grid.y)
        }
    }
    
    func tmpSetTileGrp() {
        let (col, row) = (1,1)
        let grid = GridPt(1,1)

        let p = players.first!.value
        let act = players.first!.value.actionState.setFeatureAct(p.actionState.fenceTileGp, at: grid)
        p.node.run(act)
        print(featureMap.tileGroup(atColumn: col, row: row)?.description ?? "nil")

    }
    
    func preparePlayers() {
        guard let state = lvState else {
            loadDefaultPlayers()
            return
        }
        
        enumerateGridState(state, filter: { $0.player != nil }) { (grid, gridState) in
            guard let playerState = gridState.player else { return }
            players[grid] = Player(state: playerState, grid: grid)
        }
    }
    
    //can have tileMap for initial HP/MP in future, handle in didMove(to:)
    func loadDefaultPlayers() {
        let maps = configMaps
        guard let armyMap = maps[0] else { fatalError() }
        let teamMap = maps[1]
        let dirMap = maps[2]
        let rankMap = maps[3]
        let aggMap = maps[4]
        armyMap.enumerateTiles { (col, row, _) in
            guard let armyStr = armyMap.tileDefinition(atColumn: col, row: row)?.name,
                let army = Army(rawValue: armyStr)
                else { fatalError() }
            let team: Team = teamMap?.tileDefinition(atColumn: col, row: row)?.name.map(Team.init(rawValue:))! ?? .blue
            let dir = dirMap?.tileDefinition(atColumn: col, row: row)?.name.map{ Dir.init(rawValue:$0)! } ?? Dir.up
            let rank = rankMap?.tileDefinition(atColumn: col, row: row)?.name.map(Rank.init) ?? Rank.r0
            let aggr = aggMap?.tileDefinition(atColumn: col, row: row)?.name.map(Double.init) ?? nil
            let grid = GridPt(col, row)
            gameScene.players[grid] = Player(team, army, rank, dir, grid, aggr)
        }
    }
    
    func prepareLayers() {
        playerLayer = addLayer(z: 20)
        effectLayer = addLayer(z: 100)
        actionButsLayer = addLayer(z: 30)
        let allButs = ActionType.all.map { ActionButton(type: $0) }
        actionButsLayer.addChildren(allButs)
        actionButsLayer.isHidden = true
    }
    
    func preapareDebugLayer() {
        guard debugMode else { return }
        debugLayer = addLayer(z: -1)
        bgNode.enumerateTiles { (col, row, _) in
            let grid = GridPt(col, row)
            let labelNode = SKLabelNode(text: "\(grid.x),\(grid.y)")
            labelNode.fontSize = 10
            labelNode.fontColor = .white
            labelNode.verticalAlignmentMode = .top
            labelNode.position = grid.pos
            debugLayer.addChild(labelNode)
        }
    }
    
    func timerBlk(_ timer: Timer) {
        checkChangeTeam()
        runAI()
    }
    
    //hide tiles for scene editing, not game play
    //remove texture only, tile still exist
    func hideSceneEditingTiles() {
        featureMap.tileSet.tileGroups.last!.rules.first!.tileDefinitions.first!.textures = [SKTexture]()
    }
    
    //MARK: - Uti
        
    func enumerateGridState(_ state: LvState, filter: (GridState) -> Bool, blk: (GridPt, GridState)->()) {
        let filtered = state.grids.filter { filter($0.value) }
        for (gridStr, gridState) in filtered {
            blk(GridPt(gridStr), gridState)
        }
    }
    
    func removeConfigMaps() {
        configMaps.forEach { $0?.removeFromParent() }
    }
    
    //for testing
    func allBlueSleep() {
        lazyPlayers.filter{$0.team == .blue}.forEach {
            $0.toState(cls: IdleState.self)
        }
    }
}




