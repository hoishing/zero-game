import Foundation

protocol PathFinder {
    typealias PathDict = [GridPt: [GridPt]]
}

extension PathFinder {
    private typealias PathsInfo = [GridPt:(pathMP: Int, path: [GridPt])]
    
    func pathDicts(_ player: Player, incOccupy: Bool = true) -> (org: PathDict, ext: PathDict?) {
        let multiplier = incOccupy ? 1 : (player.aggr ?? 1)
        let initialMP = Int(player.mp.double * multiplier)
        var pathsInfo: PathsInfo = [player.grid: (0, [player.grid])]
        let pinned = player.onSpecial(.pin)
        
        if !pinned {
            findPath(initialMP: initialMP,
                     army: player.army,
                     team: player.team,
                     on: player.grid,
                     remainMP: initialMP,
                     with: &pathsInfo,
                     path: [player.grid])
        }
        
        var dict = dictFor(player, pathsInfo: pathsInfo, incOccupy: incOccupy)
        if multiplier == 1 || pinned {
            return (dict, nil)
        }
        let mp = player.mp
        let extra = dict.filter {
            pathsInfo[$0.key]!.pathMP > mp
        }
        extra.keys.forEach {
            dict[$0] = nil
        }
        let ext: PathDict? = extra.isEmpty ? nil : extra
        return (dict, ext)
    }
    
    private func findPath(initialMP: Int, army: Army, team: Team,
                          on grid: GridPt, remainMP: Int,
                          with pathsInfo: inout PathsInfo, path: [GridPt]) {
        for gridPt in grid.explores {
            if gridPt.outOfBound(gameScene) { continue }
            
            //occupied
            if let target = gameScene.players[gridPt], target.team != team { continue }
            
            //geo is nil for occuppied feature: wall / mountain..etc
            guard let geo = gameScene.geo(on: gridPt) else { continue }
            
            //army can't go inside the specific feature
            guard let mpUsed = army.mpUsed(on: geo) else { continue }
            
            //not enough mp
            let newRemainMP = remainMP - mpUsed
            if newRemainMP < 0 { continue }
            
            let newPath = path + [gridPt]  //can't append, path immutable
            let newPathMP = initialMP - newRemainMP
            let newPathInfo = (pathMP: newPathMP, path: newPath)
            
            //must use >= instead of > for newPathMP, otherwise repeat what have been done before
            if let pathInfo = pathsInfo[gridPt], newPathMP >= pathInfo.pathMP { continue }
            pathsInfo[gridPt] = newPathInfo
            findPath(initialMP: initialMP, army: army, team: team,
                     on: gridPt, remainMP: newRemainMP,
                     with: &pathsInfo, path: newPath)
        }
    }

    private func dictFor(_ player: Player, pathsInfo: PathsInfo, incOccupy: Bool) -> PathDict {
        var op: PathDict = [:]
        for (grid, info) in pathsInfo {
            if incOccupy || grid == player.grid || gameScene.players[grid] == nil {
                op[grid] = info.path
            }
        }
        return op
    }
    
}
