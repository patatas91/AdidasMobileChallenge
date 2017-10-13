//
//  SplashController.swift
//  AdidasExplorer
//
//  Created by Cristian Simon Moreno on 12/10/17.
//  Copyright © 2017 Cristian Simon Moreno. All rights reserved.
//

import Foundation
import UIKit

class SplashController: UIViewController {
    
    
    @IBOutlet weak var Splash: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 5 Segundos
        perform(#selector(SplashController.showMain), with: nil, afterDelay: 5)
    }
    
    @objc func showMain(){
        performSegue(withIdentifier: "splashController", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
