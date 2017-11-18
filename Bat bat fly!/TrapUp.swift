//
//  TrapUp.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 21/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class TrapUp: Trap {
    
    convenience init() {
        self.init(initWithTexture: GameManager.sharedInstance.trapTop)
        self.anchorPoint = CGPoint(x: 0.5, y: 1)
    
        self.trapClosedFrame = GameManager.sharedInstance.trapTopCloseAnimationTexture
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 2 * self.size.height))
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_TRAP
        
        super.initPhysics()
    }
    
}
