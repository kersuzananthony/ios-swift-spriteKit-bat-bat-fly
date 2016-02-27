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
        self.init(texture: GameManager.sharedInstance.chainTexture)
        self.ITEM_SPEED = GameManager.sharedInstance.CHAIN_SPEED
        self.zPosition = ZPosition.chain.rawValue
    }
}
