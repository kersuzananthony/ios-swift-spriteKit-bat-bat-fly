//
//  Player.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Bat: SKSpriteNode {
    
    var batFlyFrames = [SKTexture]()
    var batExplodeFrames = [SKTexture]()
    var isFlying = true
    
    convenience init() {
        let firstTexture = SKTexture(imageNamed: "bat-fly-1")
        self.init(texture: firstTexture)
        setupCharacter()
    }
    
    func setupCharacter() {
        
        for var x = 1; x <= 6; x++ {
            batFlyFrames.append(SKTexture(imageNamed: "bat-fly-\(x)"))
        }
        
        for var x = 0; x <= 6; x++ {
            batExplodeFrames.append(SKTexture(imageNamed: "bat-explode-\(x)"))
        }
        
        self.zPosition = GameManager.sharedInstance.playerPosition
        self.size = CGSizeMake(80, 80)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody!.allowsRotation = false
        self.physicsBody?.mass = 0.1
        self.physicsBody!.dynamic = true
        
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_BOMB | GameManager.sharedInstance.COLLIDER_TRAP | GameManager.sharedInstance.COLLIDER_GROUND
        self.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_BOMB | GameManager.sharedInstance.COLLIDER_TRAP | GameManager.sharedInstance.COLLIDER_GROUND
        
        playFlyAnim()
        
    }
    
    func playFlyAnim() {
        self.removeAllActions()
        self.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(self.batFlyFrames, timePerFrame: 0.1)))
    }
    
    func playExplodeAnim() {
        self.removeAllActions()
        let scaleYFactor = self.batExplodeFrames[self.batExplodeFrames.count - 1].size().height / self.size.height
        let scaleXFactor = self.batExplodeFrames[self.batExplodeFrames.count - 1].size().width / self.size.width
        
        self.runAction(SKAction.animateWithTextures(self.batExplodeFrames, timePerFrame: 0.1))
        self.runAction(SKAction.scaleXTo(scaleXFactor, duration: Double(self.batExplodeFrames.count) * 0.1))
        self.runAction(SKAction.scaleYTo(scaleYFactor, duration: Double(self.batExplodeFrames.count) * 0.1))
        
        _ = NSTimer.scheduledTimerWithTimeInterval(Double(self.batExplodeFrames.count - 1) * 0.1, target: self, selector: "explosionNotification", userInfo: nil, repeats: false)
    }

    func playTrappedAnim() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
    func explosionNotification() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "explosionNotification", object: nil, userInfo: nil))
    }

}
