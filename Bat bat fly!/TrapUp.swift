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
        let trapTopTexture = SKTexture(imageNamed: "trap-top")
        self.init(initWithTexture: trapTopTexture)
        
        for var i = 1; i <= 2; i++ {
            self.trapClosedFrame.append(SKTexture(imageNamed: "trap-top-animation-\(i)"))
        }
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_TRAP
        
        super.initPhysics()
    }
    
}
