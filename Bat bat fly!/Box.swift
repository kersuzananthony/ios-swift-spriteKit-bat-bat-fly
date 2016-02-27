//
//  Box.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Box: Obstacle {
    
    convenience init() {
        self.init(texture: GameManager.sharedInstance.boxTexture)
        
        self.size = CGSizeMake(GameManager.sharedInstance.BOX_SIZE, GameManager.sharedInstance.BOX_SIZE)
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_BOMB
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_PLAYER | GameManager.sharedInstance.COLLIDER_GROUND
        self.physicsBody!.usesPreciseCollisionDetection = true
        super.initPhysics()
    }
    
    func playBoxExplodedAnimation() {
        self.removeAllActions()
        
        self.runAction(SKAction.animateWithTextures(GameManager.sharedInstance.boxExplodeAnimationTexture, timePerFrame: 0.1, resize: true, restore: false)) { () -> Void in
            
            self.removeFromParent()
        }
    }
}