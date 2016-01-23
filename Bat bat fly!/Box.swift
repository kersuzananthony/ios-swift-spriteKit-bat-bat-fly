//
//  Box.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Box: Obstacle {
    
    var boxExplosionFrames: [SKTexture] = [SKTexture]()
    
    convenience init() {
        print("BOX INIT")
        let boxTexture = SKTexture(imageNamed: "box-explode-0")
        self.init(texture: boxTexture)
        
        self.size = CGSizeMake(GameManager.sharedInstance.BOX_SIZE, GameManager.sharedInstance.BOX_SIZE)
        self.zPosition = 10
        
        for var i = 0; i <= 7; i++ {
            self.boxExplosionFrames.append(SKTexture(imageNamed: "box-explode-\(i)"))
        }

        //playBoxExplodedAnimation()
    }
    
    override func initPhysics() {
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_BOMB
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.usesPreciseCollisionDetection = true
        super.initPhysics()
    }
    
    func playBoxExplodedAnimation() {
        self.removeAllActions()
        
        self.runAction(SKAction.animateWithTextures(self.boxExplosionFrames, timePerFrame: 0.1, resize: true, restore: false)) { () -> Void in
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "stopPhysicWorld", object: nil, userInfo: nil))
        }
    }
}