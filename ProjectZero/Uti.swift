//
//  Uti.swift
//  Uti
//
//  Created by Kelvin Ng on 2/10/14.
//  Copyright (c) 2014 Kelvin Ng. All rights reserved.
//

import Foundation

typealias Func = () -> Void
typealias StrDict = [String: String]

// MARK: - Globals

let fm = FileManager.default
let ud = UserDefaults.standard
let udCloud = NSUbiquitousKeyValueStore.default
let nc = NotificationCenter.default
let bd = Bundle.main
let appName = bd.infoDictionary?["CFBundleName"] as? String ?? ""
let versionNum = bd.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"

func udSync(_ newVal: Any?, key: String) {
    ud.set(newVal, forKey: key)
    ud.synchronize()
}

func udCloudSync(_ newVal: Any?, key: String) {
    udCloud.set(newVal, forKey: key)
    udCloud.synchronize()
}

#if os(iOS)
    import UIKit
    
    let pb = UIPasteboard.general
    let app = UIApplication.shared
    
    typealias Image = UIImage
    
    extension Uti {
        static func alert(_ title: String?, msg: String?, vc: UIViewController, actions: UIAlertAction...) {
            let alertC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            actions.forEach(alertC.addAction)
            vc.present(alertC, animated: true, completion: nil)
        }
        
        static func openSite(_ urlStr: String) {
            guard let url = URL(string: urlStr) else { return }
            UIApplication.shared.open(url)
        }
    }
    
//    extension Image {
//        var pngData: Data? {
////            return self.pngData()
//            return self.UIImagePNGRepresentation()
//        }
//    }
    
#elseif os(OSX)
    import AppKit
    
    let ws = NSWorkspace.shared
    let pb = NSPasteboard.general
    
    typealias Image = NSImage
    
    extension Uti {
        static func alert(_ str: String, detail: String = " ", window: NSWindow? = nil, okBlk: Func? = nil) {
            let alert = NSAlert()
            alert.messageText = str
            alert.informativeText = detail  //don't use nil or "" for default value because macOS layout bug when informativeText not set
            guard let win = window else {
                alert.runModal()
                return
            }
            guard let blk = okBlk else {
                alert.beginSheetModal(for: win, completionHandler: nil)
                return
            }
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: win) {
                if $0.rawValue == 1000 { blk() }     //response of right button = 1000
            }
        }
        
        //prevent open in WKWebView in place
        static func safari(url: URL) {
            ws.open([url], withAppBundleIdentifier: "com.apple.Safari", options: .default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
        }
        
        static func openSite(_ urlStr: String) {
            guard let url = URL(string: urlStr) else { return }
            ws.open(url)
        }
    }
    
    extension NSPasteboard {
        var string: String? {
            get { return self.string(forType: .string) }
            set {
                guard let str = newValue else { return }
                self.declareTypes([.string], owner: nil)
                self.setString(str, forType: .string)
            }
        }
    }
    
    extension Image {
        var pngData: Data? {
            guard let tiff = tiffRepresentation else { return nil }
            let bitmap = NSBitmapImageRep(data: tiff)
            return bitmap?.representation(using: .png, properties: [:])
        }
    }
#endif

// MARK: - Function Composition

precedencegroup CompositionPrecedence {
    associativity: left
}

infix operator >>>: CompositionPrecedence

func >>> <T, U, V>(lhs: @escaping (T) -> U, rhs: @escaping (U) -> V) -> (T) -> V {
    return { rhs(lhs($0)) }
}


struct Uti {
	// MARK: - Constants
    static let alphaRange = Character("a")...Character("z")
    static let alphabets = "abcdefghijklmnopqrstuvwxyz"
    static let puntuations = " 1234567890-/:;()$&@\".,?!'[]\\{}#%^*+=•¥£€><~|_@／：；（）$「」＂。，、？！＜＞"
    
	// MARK: - Path
	
	static var tmpPath: String {return NSTemporaryDirectory()}
	
	static var docPath: String {
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
		return paths[0]
	}
	
	static var docURL: URL {
		return Uti.standardURL(.documentDirectory)
	}
	
	static var bundlePath: String {return Bundle.main.resourcePath!}
	
	static var bundleURL: URL {return Bundle.main.resourceURL!.absoluteURL}  //can't just use resourceURL, its a general URL instead of file url
	
	static var cachePath: String {
		let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
		return paths[0]
	}
	
	static var supportURL: URL {
		return Uti.standardURL(.applicationSupportDirectory)
	}
	
	static func tmpFile(_ name: String) -> String {
		return tmpPath.stringByAppendingPathComponent(name)
	}

	static func docFile(_ name: String) -> String {
		return (docPath as NSString).appendingPathComponent(name)
	}

	static func bundleFile(_ name: String) -> String {
		return bundlePath.stringByAppendingPathComponent(name)
	}

    static func bundleFileURL(_ fileName: String) -> URL {
        return Uti.bundleURL.appendingPathComponent(fileName)
    }
    
	static func cacheFile(_ name: String) -> String {
		return cachePath.stringByAppendingPathComponent(name)
	}
	
	static func standardURL(_ dir: FileManager.SearchPathDirectory) -> URL {
		var err: NSError?
		let url: URL?
		do {
			url = try FileManager.default.url(for: dir, in: .userDomainMask, appropriateFor: nil, create: true)
		} catch let error as NSError {
			err = error
			url = nil
		}
		if err != nil {NSException(name: NSExceptionName(rawValue: "Can't create URL"), reason: err!.domain, userInfo: err!.userInfo).raise()}
		return url!
	}
    
    static var simulatorPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        return paths[0]
    }
 	
	
	// MARK: Time
	
	static func second2String(_ second: TimeInterval) -> String {
		let hh = Int(second / 3600)
		let mm = Int(second/60) - hh * 60
		let ss = Int(second.truncatingRemainder(dividingBy: 60))
		if hh > 0 {
			return NSString(format: "%d:%02d:%02d", hh, mm, ss) as String
		} else {
			return NSString(format: "%02d:%02d", mm, ss) as String
		}
	}
	
	static func currentTimestamp() -> String {
		let t = Date().timeIntervalSince1970 as Double
		return "\(t)"
	}
	
    //attach to current thread: main or background
	static func wait(_ seconds: Double) {
		RunLoop.current.run(until: Date(timeIntervalSinceNow: seconds))
	}

    static func wait(_ seconds: Double, blk: @escaping Func) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            blk()
        }
    }
    
	@discardableResult static func exeTime(_ log: Bool, block: () -> ()) -> Double {
		let d1 = Date()
		block()
		let t = Date().timeIntervalSince(d1)
		if log {print("Execution time: \(t)")}
		return t
	}
	
	static func logExeTime(_ block: () -> ()) {
		self.exeTime(true, block: block)
	}
	
	// MARK: File
	
	static func txt2Arr(_ path: String) -> [String] {
		let txt = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		return txt.split("\n")
	}
	
	static func enumFile(_ path: String, block: @escaping (_ line: String) -> ()) {
		let str = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		str.enumerateLines { (line, stop) -> () in
			block(line)
		}
	}
	
	static func folderSize(_ path: String) -> UInt64 {
		let fm = FileManager.default
		let filesEnumerator = fm.enumerator(atPath: path)!
		var fileSize: UInt64 = 0

		while let fileName = filesEnumerator.nextObject() as? String {
			let filePath = path.stringByAppendingPathComponent(fileName)
			var isDir = ObjCBool(false)
			fm.fileExists(atPath: filePath, isDirectory: &isDir)
			if isDir.boolValue == false {
				let fileDict = (try? fm.attributesOfItem(atPath: filePath)) as NSDictionary?
				fileSize += fileDict!.fileSize()
			}
		}
		return fileSize
	}
	
	static func size2Str(_ byte: UInt64) -> String {
		let formatter = ByteCountFormatter()
		return formatter.string(fromByteCount: Int64(byte))
	}
	
	static func clearCache() {
		let fm = FileManager.default
		let tmpPath = NSTemporaryDirectory()
        guard let fileNames = try? fm.contentsOfDirectory(atPath: tmpPath) else { return }
        fileNames.forEach{
            let filePath = tmpPath.stringByAppendingPathComponent($0)
            try? fm.removeItem(atPath: filePath)
        }
	}

	
	// MARK: MISC
    
    static func contactUs(_ addr: String = "info@fbm.hk", info: String = "", body: String = "") {
        let subject = "\(appName) v\(versionNum) \(info)"
        guard let urlStr = "mailto:\(addr)?subject=\(subject)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        Uti.openSite(urlStr)
    }
    
    func reachApple(handler: @escaping (Bool) -> Void) {
        let url = URL(string: "http://apple.com")!
        let config = URLSessionConfiguration.ephemeral  //no cache
        config.timeoutIntervalForRequest = 8
        let session = URLSession(configuration: config)
        //        let d1 = Date()
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            let code = (response as? HTTPURLResponse)?.statusCode
            if error == nil && code == 200 {
                handler(true)
            } else {
                handler(false)
            }
            //            let d2 = Date()
            //            let t = d2.timeIntervalSince(d1)
            //            print("Execution time: \(t)")
        })
        task.resume()
    }
	
    static func printOpt(_ item: Any?) {
        if let obj = item { print(obj) }
    }
    
    //for debug
    static func address(obj: AnyObject) -> String {
        return "\(Unmanaged<AnyObject>.passUnretained(obj).toOpaque())"
    }
    
	//max is inclusive, min can be omitted
	static func random(min: Int = 0, max: Int) -> Int {
		return Int(arc4random_uniform(UInt32(max - min + 1))) + min
	}
    
    //random Double between 0.0 and 1.0, inclusive
    static var randDouble: Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    static func bgTask(_ blk: @escaping Func, compBlk: Func? = nil, priority: DispatchQoS.QoSClass = .background) {
        DispatchQueue.global(qos: priority).async {
            blk()
            if let compBlk = compBlk {
                DispatchQueue.main.async { compBlk() }
            }
        }
    }
    
	
	static func globals(_ key: String) -> AnyObject? {
		let globals = NSDictionary(contentsOfFile: self.bundleFile("Globals.plist"))!
		return globals.object(forKey: key) as AnyObject
	}
	
	static func raise(_ name: String) {
		NSException(name: NSExceptionName(rawValue: name), reason: nil, userInfo: nil).raise()
	}

}

extension String {
    var int: Int? {
        return Int(self)
    }
    
    var isEng: Bool {
        guard let first = self.lowercased().first else { return false }
        return Uti.alphaRange ~= first
    }
    
    //whether contain Chinese characters in the string
    var hasChi: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
	
	var trimmed: String {
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	var stripHTML: String {
		let scanner = Scanner(string: self)
		var html = self
		while !scanner.isAtEnd {
            _ = scanner.scanUpToString("<")
//			var str: NSString? = nil
//			scanner.scanUpTo("<", into: nil)
//			scanner.scanUpTo(">", into: &str)
            if let foundStr = scanner.scanUpToString(">") {
				html = html.replacingOccurrences(of: "\(foundStr)>", with: "")
			}
		}
		return html
	}
	
	// MARK: Unicode
	
	var hex2Dec: UInt32 {
		var sum: Int = 0
		let hex = NSString(string: self)
		for i: Int in 0 ..< hex.length {
			let c: unichar = hex.character(at: i)
			var num: unichar = 0;
			if (c >= 65 && c <= 70) {
				num = c - 55;
			} else if (c >= 97 && c <= 102) {
				num = c - 87;
			} else if (c >= 48 && c <= 57) {
				num = c - 48;
			}
			let tmp = Int(pow(16, CDouble(hex.length - i - 1)))
			sum = sum + Int(num) * tmp
		}
		return UInt32(sum)
	}
	
	var hex2Str: String {
		let char = Character(UnicodeScalar(self.hex2Dec)!)
		return "\(char)"
	}
	
	var str2Hex: String {
		let scalars = self.unicodeScalars
		let dec = scalars[scalars.startIndex].value
		return NSString(format:"%2X", Int(dec)) as String
	}
	
	// MARK: Range

	
	func idx(_ num: Int) -> String.Index {
        return self.index(self.startIndex, offsetBy: num)
	}
    
    subscript(r: CountableClosedRange<Int>) -> String {
        let idxRange = self.idx(r.lowerBound)...self.idx(r.upperBound)
        return String(self[idxRange])
    }
		
    func removing(suffix: String) -> String? {
        guard self.hasSuffix(suffix) else { return nil }
        let idx = self.range(of: suffix)!.lowerBound
        return String(self[..<idx])
    }
    
    func removing(prefix: String) -> String? {
        guard self.hasPrefix(prefix) else { return nil }
        let idx = self.range(of: prefix)!.upperBound
        return String(self[idx...])
    }
	
	func split(_ str: String = ",") -> [String] {
        return self.isEmpty ? [String]() : self.components(separatedBy: str).map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
	}
    
	
	// MARK: RegEx
	
	func regex1stMatch(_ pattern:String) -> (full: String, subMatches: [String])? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options:.anchorsMatchLines) else { return nil }
        guard let result = regex.firstMatch(in: self, options: .reportProgress, range: NSMakeRange(0, self.count)) else { return nil }
		return matchesForTarget(self, textCheckingResult: result)
	}
	
	func regexAllMatches(_ pattern: String) -> [(full: String, subMatches: [String])]? {
		let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
		let results = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
		if results.count == 0 {return nil}
		var op = Array<(full: String, subMatches: [String])>()
		for result in results as [NSTextCheckingResult] {
			op.append(matchesForTarget(self, textCheckingResult: result))
		}
		return op
	}
	
	func regexReplace(_ pattern: String, replacement: String) -> String {
		let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
		let results = regex.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
		var offset = 0
		let mutableStr = NSMutableString(string: self)
		for result in results as [NSTextCheckingResult] {
			let resultRange = result.range //the outer most range
			let replacementRange = NSRange(location: resultRange.location + offset,length: resultRange.length)
			mutableStr.replaceCharacters(in: replacementRange, with: replacement)
			offset += (replacement.count - resultRange.length)
		}
		return mutableStr as String
	}
    
    // MARK: Path
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
    
	// MARK: Private
	
	fileprivate func matchesForTarget(_ target: String, textCheckingResult result: NSTextCheckingResult) -> (full: String, subMatches: [String]) {
		var fullMatch = ""
		var subMatches = [String]()
		for i in 0..<result.numberOfRanges {
            let range = result.range(at: i)
			let matchStr = (target as NSString).substring(with: range)
			if i == 0 {fullMatch = matchStr}
			else {subMatches.append(matchStr)}
		}
		return (fullMatch, subMatches)
	}
	
}

extension Int {
    var str: String { return String(self) }
    var double: Double { return Double(self) }
}

extension Array {
	
	mutating func shuffle () {
        if count < 2 { return }
        for i in indices.dropLast() {
            let diff = distance(from: i, to: endIndex)
            let j = index(i, offsetBy: numericCast(arc4random_uniform(numericCast(diff))))
            swapAt(i, j)
        }
	}
	
	func shuffled () -> Array {
		var shuffled = self
		shuffled.shuffle()
		return shuffled
	}
    
    func writeTo(path: String) {
        let strArr = self.compactMap{ ($0 as? CustomStringConvertible)?.description }
        try? strArr.joined(separator: "\n").write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
	}
    
    subscript(safe idx: Int) -> Element? {
        return idx < endIndex ? self[idx] : nil
    }
    
}

extension Array where Element: Hashable {
    //much more efficient then old method below, see unit test
    var unique: Array {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
    
    var unique2: Array {
        //reduce(into:_:) work by mutating the result array,
        //so much more efficient then reduce(_:_:) when return type is a collection.
        //here the initial array type is infered by the return type of this function,
        //so no need specify [Element]()
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
 
    

}

extension Character {
    var isChi: Bool {
        return String(self).hasChi
    }
}

extension Set {
    var arr: Array<Element> { return Array<Element>(self) }
}

extension Dictionary {
    func appending(_ dict: [Key: Value]) -> [Key: Value] {
        var copy = self
        dict.forEach{ copy[$0] = $1 }
        return copy
    }
}

extension Substring {
    var str: String { return String(self) }
}

extension Double {
    var int: Int { return Int(self) }
}






