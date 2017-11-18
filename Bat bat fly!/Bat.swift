//
//  Player.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Bat: SKSpriteNode {
    
    var isFlying = true
    let batSize: CGFloat = GameManager.sharedInstance.BOX_SIZE * 0.9
    
    convenience init() {
        self.init(texture: GameManager.sharedInstance.batTexture)
        setupCharacter()
    }
    
    func setupCharacter() {
        
        self.zPosition = ZPosition.bat.rawValue
        self.size = CGSize(width: self.batSize, height: self.batSize)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height / 2)
        self.physicsBody!.allowsRotation = false
        self.physicsBody?.mass = 0.1
        self.physicsBody!.isDynamic = true
        
        self.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_BOMB | GameManager.sharedInstance.COLLIDER_TRAP | GameManager.sharedInstance.COLLIDER_GROUND
        self.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_BOMB | GameManager.sharedInstance.COLLIDER_TRAP | GameManager.sharedInstance.COLLIDER_GROUND
        
        playFlyAnim()
        
    }
    
    func impulse() {
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 55))
    }
    
    func turnPhysicBodyDynamism(_ value: Bool) {
        self.physicsBody!.isDynamic = value
    }
    
    func playFlyAnim() {
        self.removeAllActions()
        self.run(SKAction.repeatForever(SKAction.animate(with: GameManager.sharedInstance.batFlyingAnimationTexture, timePerFrame: 0.1)))
    }
    
    func playExplodeAnim() {
        self.removeAllActions()
        
        let explodeFrames = GameManager.sharedInstance.batExplodeAnimationTexture
        
        let scaleYFactor = explodeFrames[explodeFrames.count - 1].size().height / self.size.height
        let scaleXFactor = explodeFrames[explodeFrames.count - 1].size().width / self.size.width
        
        self.run(SKAction.animate(with: explodeFrames, timePerFrame: 0.1))
        self.run(SKAction.scaleX(to: scaleXFactor, duration: Double(explodeFrames.count) * 0.1))
        self.run(SKAction.scaleY(to: scaleYFactor, duration: Double(explodeFrames.count) * 0.1))
        
        _ = Timer.scheduledTimer(timeInterval: Double(explodeFrames.count - 1) * 0.1, target: self, selector: #selector(Bat.explosionNotification), userInfo: nil, repeats: false)
    }

    func playTrappedAnim() {
        self.removeAllActions()
        self.removeFromParent()
    }
    
    func explosionNotification() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "explosionNotification"), object: nil, userInfo: nil))
    }

}
