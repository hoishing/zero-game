//
//  LevelCell.swift
//  ProjectZero
//
//  Created by hoishing on 30/11/2017.
//  Copyright © 2017 Fbm Development. All rights reserved.
//

import UIKit

class LevelCell: UICollectionViewCell {
    
    @IBOutlet var levelBut: UIButton!
    @IBOutlet var lvLabel: UILabel!
    
    @IBAction func showScene(_ sender: UIButton) {
        guard let vc = window?.rootViewController as? MenuVC, let lv = lvLabel.text?.int else { return }
        vc.presentScene(lv)
    }
}

