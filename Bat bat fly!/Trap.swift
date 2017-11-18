//
//  Trap.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 21/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Trap: Obstacle {
    
    var trapClosedFrame: [SKTexture] = [SKTexture]()
    let trapSize: CGFloat = GameManager.sharedInstance.BOX_SIZE * 0.8
    
    convenience init(initWithTexture: SKTexture) {
        self.init(texture: initWithTexture)
        self.size.width = trapSize
        self.size.height = initWithTexture.size().height * (self.size.width / initWithTexture.size().width)
    }
    
    override func initPhysics() {
        self.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        self.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_PLAYER | GameManager.sharedInstance.COLLIDER_GROUND | GameManager.sharedInstance.COLLIDER_TRAP
        super.initPhysics()
    }
    
    func playTrapClosedAnimation() {
        self.removeAllActions()
    
        let scaleYFactor = (self.trapClosedFrame[self.trapClosedFrame.count - 1].size().height * 0.8) / self.size.height
        let scaleXFactor = (self.trapClosedFrame[self.trapClosedFrame.count - 1].size().width * 0.8) / self.size.width
        
        self.run(SKAction.animate(with: self.trapClosedFrame, timePerFrame: 0.2))
        self.run(SKAction.scaleX(to: scaleXFactor, duration: Double(self.trapClosedFrame.count) * 0.2))
        self.run(SKAction.scaleY(to: scaleYFactor, duration: Double(self.trapClosedFrame.count) * 0.2))
    }
}
