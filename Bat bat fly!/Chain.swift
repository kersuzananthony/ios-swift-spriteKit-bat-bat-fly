//
//  Chain.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 21/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Chain: Moveable {
    
    convenience init() {
        let chainNumber = arc4random_uniform(3) + 1
        let chainTexture = SKTexture(imageNamed: "chain-\(chainNumber)")
        self.init(texture: chainTexture)
        self.ITEM_SPEED = GameManager.sharedInstance.CHAIN_SPEED
        self.zPosition = 8
    }
}
