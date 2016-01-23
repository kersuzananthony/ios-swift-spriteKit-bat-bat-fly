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
        let trapBottomTexture = SKTexture(imageNamed: "trap-bottom")
        self.init(initWithTexture: trapBottomTexture)
        
        for var i = 1; i <= 2; i++ {
            self.trapClosedFrame.append(SKTexture(imageNamed: "trap-bottom-animation-\(i)"))
        }
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_TRAP
        
        super.initPhysics()
    }
    
}
