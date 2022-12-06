//
//  MenuVC.swift
//  ProjectZero
//
//  Created by hoishing on 30/11/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import UIKit
import AVFoundation

class MenuVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var bgMusic: AVAudioPlayer?
    var observer: NSObjectProtocol!
    
    var maxLevel: Int {
        return udCloud.object(forKey: "level") as? Int ?? 1
    }
    
    let mask: CAGradientLayer = {
        let mask = CAGradientLayer()
        mask.startPoint = CGPoint(x: 0.5, y: 0.0)
        mask.endPoint = CGPoint(x:0.5, y:1.0)
        mask.colors = [0.0, 1.0, 1.0, 0.0].map{
            UIColor.white.withAlphaComponent($0).cgColor
        }
        mask.locations = [0.0, 0.05, 0.95, 1.0].map(NSNumber.init)
        return mask
    }()
    
    @IBOutlet var containerV: UIView!
    @IBOutlet var collectionV: UICollectionView!
    @IBOutlet var musicBut: UIButton!
    @IBOutlet var loadBut: UIButton!
    
    @IBAction func toggleMusic(_ sender: Any) {
        musicOn = !musicOn
        playPauseMusic()
    }
    
    @IBAction func loadAutoSave(_ sender: UIButton) {
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            guard let data = udCloud.object(forKey: "autoSave") as? Data,
                let state = try? JSONDecoder().decode(LvState.self, from: data)
                else { return }
            self.presentScene(state.lv, state)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        Uti.alert("Load auto-saved progress?",
                  msg: "Progess auto-saved every Blue turn",
                  vc: self, actions: cancel, ok)
    }
    

    // MARK: - Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        observer = nc.addObserver(forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                  object: nil, queue: nil) { [weak self] _ in
            self?.collectionV?.reloadData()
            self?.enablingSaveBut()
        }
        udCloud.synchronize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionV.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
//        setMaxLevel(to: 20)
        prepareBgMusic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionV.reloadData()
        playPauseMusic()
        enablingSaveBut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyMask()
    }
    
    deinit {
        nc.removeObserver(observer as Any)
    }
    
    // MARK: - VC Related
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        applyMask()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalLevel
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LevelCell
        let unlocked = maxLevel > indexPath.row
        let img = unlocked ? #imageLiteral(resourceName: "iconLevel") : #imageLiteral(resourceName: "iconLevelLock")
        cell.levelBut.setImage(img, for: .normal)
        cell.lvLabel.text = String(indexPath.row + 1)
        cell.lvLabel.textColor = unlocked ? .white : .gray
        return cell
    }
    
    // MARK: - Uti
    
    func enablingSaveBut() {
        loadBut?.isEnabled = udCloud.object(forKey: "autoSave") != nil
    }
    
    func setMaxLevel(to cnt: Int) {
        udCloudSync(cnt, key: "level")
    }
    
    func prepareBgMusic() {
        let url = Uti.bundleFileURL("everlasting.mp3")
        bgMusic = try? AVAudioPlayer(contentsOf: url, fileTypeHint: "mp3")
        bgMusic?.volume = bgMusicVol
        bgMusic?.numberOfLoops = -1     //negative means infinit loops
    }
    
    func playPauseMusic() {
        musicBut.setImage(musicOn ? #imageLiteral(resourceName: "menuMusicOn") : #imageLiteral(resourceName: "menuMusicOff"), for: .normal)
        musicOn ? _ = bgMusic?.play() : bgMusic?.pause()
    }
    
    func presentScene(_ lv: Int, _ lvState: LvState? = nil) {
        bgMusic?.pause()
        let gameVC = storyboard?.instantiateViewController(withIdentifier: "GameVC") as! GameVC
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.level = lv
        gameVC.lvState = lvState
        present(gameVC, animated: true)
    }
    
    func applyMask() {
        mask.frame = containerV.bounds
        containerV.layer.mask = mask
    }
}


