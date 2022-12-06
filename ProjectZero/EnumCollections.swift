
import Foundation

protocol EnumCollections {
    static var all: [Self] {get}
}

extension EnumCollections where Self: Hashable{
    var idx: Int {
        guard let index = Self.all.firstIndex(of: self) else { fatalError() }
        return index
    }
    
    func switchVals<Q>(_ vals: [Q]) -> Q {
        guard let op = dictFor(vals: vals)[self] else { fatalError() }
        return op
    }
    
    func switchVals<Q>(_ vals: Q...) -> Q {
        return switchVals(vals)
    }
    
    func valFor<Q>(matrix: [[Q?]], rowIdx: Int) -> Q? {
        let arr1d = matrix.map { $0[rowIdx] }
        return switchVals(arr1d)
    }
    
    // Uti
    func dictFor<Q>(vals: [Q]) -> Dictionary<Self, Q> {
        return Dictionary(keys: Self.all, vals: vals)
    }
}
