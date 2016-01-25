//
//  ScoreGate.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 23/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class ScoreGate: Obstacle {
    
    convenience init(screenHeight: CGFloat) {
        self.init()
        self.size = CGSizeMake(1, screenHeight)
    }
 
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_SCORE_GATE
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.usesPreciseCollisionDetection = true
        super.initPhysics()
    }

    
}
