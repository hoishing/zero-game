//
//  GameViewController.swift
//  ProjectZero
//
//  Created by Kelvin Ng on 3/9/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameVC: UIViewController, Scrollable, UIScrollViewDelegate {
    
    @IBOutlet var scrollV: UIScrollView!
    @IBOutlet var calContainerV: UIView!
    @IBOutlet var cal_imgV: UIImageView!
    @IBOutlet var calCenterX: NSLayoutConstraint!
    @IBOutlet var calCenterY: NSLayoutConstraint!
    @IBOutlet var playerHUD: UIView!
    @IBOutlet var calLabel: UILabel!
    @IBOutlet var hpLabel: UILabel!
    @IBOutlet var spLabel: UILabel!
    @IBOutlet var iconWin: UIImageView!
    @IBOutlet var iconLose: UIImageView!
    @IBOutlet var iconBigLock: UIImageView!
    @IBOutlet var backBut: UIButton!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    var level: Int!
    var contentV: UIView!
    let scenePadding: CGFloat = 52
    var menuVC: MenuVC { return presentingViewController as! MenuVC }
    var audioNode: SKAudioNode!
    var observer: NSObjectProtocol!
    var lvState: LvState?
    
    @IBOutlet var musicBut: UIButton!
    @IBAction func toggleMusic(_ sender: UIButton) {
        musicOn = !musicOn
        playPauseMusic()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        sender.isEnabled = false
        while gameScene.processingAI {
            Uti.wait(0.1)
        }
        gameScene.isGameOver = true
        gameScene.clearAllPlayerActions()
        gameScene.aiTimer?.invalidate()
        dismiss(animated: true) {
            gameScene.removeAllChildren()
            gameScene = nil
        }
    }
    
    // MARK: - Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observer = nc.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.playPauseMusic()
        }
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
        adjustPadding()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadScene(level)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLvLock()
    }
    
    deinit {
        nc.removeObserver(observer as Any)
//        print("Lv\(level!) deinited")
    }
    
    // MARK: - Uti
    
    func musicOff() {
        if gameScene.audioEngine.isRunning {
            toggleMusic(musicBut)
        }
    }

    func loadScene(_ num: Int) {
        if let oldContentV = contentV { oldContentV.removeFromSuperview() }
        let sceneName = "Lv" + String(num)
        guard let scene = SKScene(fileNamed: sceneName) as? GameScene else { fatalError() }
        gameScene = scene
        gameScene.vc = self
        gameScene.lvState = lvState
        cal_imgV.image = #imageLiteral(resourceName: "iconCal").tint(color: Team.all.first!.color)
        scene.scaleMode = .resizeFill
        let v = SKView(frame: CGRect(origin: CGPoint.zero, size: scene.size))
        contentV = v
        v.presentScene(scene)
        v.ignoresSiblingOrder = true
//        v.showsFPS = true
//        v.showsNodeCount = true
        prepareScrollV()
        prepareMusic(num)
    }
    
    func checkLvLock() {
        if menuVC.maxLevel < level {
            gameScene.isGameOver = true
            backBut.setImage(#imageLiteral(resourceName: "iconBackLit"), for: .normal)
            iconBigLock.isHidden = false
        }
    }
    
    func prepareMusic(_ sceneNum: Int) {
        let name: String
        switch sceneNum {
        case 1...4: name = "army-of-heroes"
        case 5: name = "pirates-theme"
        case 6...9: name = "a-hero-is-born"
        case 10: name = "epic-action-chase"
        case 11...14: name = "king-of-glory"
        case 15: name = "victory-cinematic-trailer"
        case 16...19: name = "we-are-heroes"
        case 20: name = "triumph-and-glory"
        default: name = "army-of-heroes"
        }
        let node = SKAudioNode(fileNamed: name + ".mp3")    //bug? can't assign audioNode directly
        node.name = "audioNode"
        node.run(Act.changeVolume(to: bgMusicVol, duration: 0))
        gameScene.addChild(node)
        audioNode = node
        playPauseMusic()
    }
    
    func playPauseMusic() {
        musicBut.setImage(musicOn ?  #imageLiteral(resourceName: "iconMusicOn") :  #imageLiteral(resourceName: "iconMusicOff"), for: .normal)
        musicOn ? audioNode.run(Act.play()) : audioNode.run(Act.pause())
    }
    
    // MARK: - VC related
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // MARK: - Scroll View Delegates
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentV
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustPadding()
    }
    
}
