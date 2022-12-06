//
//  AboutVC.swift
//  VideoCompressor
//
//  Created by Kelvin Ng on 19/9/14.
//  Copyright (c) 2014 Kelvin Ng. All rights reserved.
//

import UIKit

class AboutVC: UITableViewController {

	@IBAction func dismiss(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        switch indexPath.section {
        case 1:
            Uti.openSite("https://www.facebook.com/groups/2055058891426342/")
        case 2:
            if row == 1 {Uti.openSite("http://www.fbm.hk")}
            else if row == 2 {
                Uti.contactUs("info@fbm.hk", info: "Zero TBS, v\(versionNum)")
            }
        default: ()
        }
    }
	
}
