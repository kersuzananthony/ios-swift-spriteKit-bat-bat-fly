//
//  Moveable.swift
//  RetroSkate
//
//  Created by Kersuzan Anthony on 20/01/2016.
//  Copyright © 2015 Devslopes. All rights reserved.
//

import SpriteKit

class Moveable: SKSpriteNode {
    static let RESET_X_POS: CGFloat = -1400
    static let START_X_POS: CGFloat = 1400
    
    var moveAction: SKAction!
    var moveForever: SKAction!
    var ITEM_SPEED: CGFloat = 0
    
    func startMoving(yPos: CGFloat) {
        self.position = CGPoint(x: Moveable.START_X_POS, y: yPos)

        moveAction = SKAction.moveBy(x: self.ITEM_SPEED, y: 0, duration: 0.02)
        moveForever = SKAction.repeatForever(moveAction)
        
        self.run(moveForever, withKey: "moveItForever")
    }
    
    override func update() {
        if self.position.x <= Moveable.RESET_X_POS {
            didExceedBounds()
        }
    }
    
    func didExceedBounds() {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "removeMoveableObject"), object: self))
        self.removeFromParent()
    }
}


