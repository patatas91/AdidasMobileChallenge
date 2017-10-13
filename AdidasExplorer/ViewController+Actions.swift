//
//  ViewController+Actions.swift
//  AdidasExplorer
//
//  Created by Cristian Simon Moreno on 12/10/17.
//  Copyright © 2017 Cristian Simon Moreno. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension ViewController: UIPopoverPresentationControllerDelegate {

    // Accion al pulsar el boton "Shoe"
    @IBAction func pulsarButtonShoe(_ sender: UIButton) {
        // Shoe
        guard !shoeActive else { return }
        NSLog("BOTON ZAPATILLA");
        
        putLoadAlert()
        
        // Quitar nodos
        removeNodes()
        ballActive = false
        shoeActive = true
        
        removeLoadAlert()
    }
    
    // Accion al pulsar el boton "Ball"
    @IBAction func pulsarButtonBall(_ sender: UIButton) {
        // Ball
        guard !ballActive else { return }
        NSLog("BOTON BALON");
        
        putLoadAlert()
        
        // Quitar nodos
        removeNodes()
        ballActive = true
        shoeActive = false
        
        removeLoadAlert()
    }

}


