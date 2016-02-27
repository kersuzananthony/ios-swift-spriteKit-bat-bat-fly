//
//  TrapDown.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 21/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit


class TrapDown: Trap {
    
    convenience init() {
        self.init(initWithTexture: GameManager.sharedInstance.trapDown)
        self.anchorPoint = CGPoint(x: 0.5, y: 0)
    
        self.trapClosedFrame = GameManager.sharedInstance.trapDownCloseAnimationTexture
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, 2 * self.size.height))
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_TRAP
        
        super.initPhysics()
    }
    
}
