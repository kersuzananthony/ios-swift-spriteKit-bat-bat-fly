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
        //let trapBottomTexture = SKTexture(imageNamed: "trap-bottom")
        self.init(initWithTexture: GameManager.sharedInstance.trapDown)
        self.anchorPoint = CGPoint(x: 0.5, y: 0)
        
//        for var i = 1; i <= 2; i++ {
//            self.trapClosedFrame.append(SKTexture(imageNamed: "trap-bottom-animation-\(i)"))
//        }
        
        self.trapClosedFrame = GameManager.sharedInstance.trapDownCloseAnimationTexture
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, 2 * self.size.height))
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_TRAP
        
        super.initPhysics()
    }
    
}
