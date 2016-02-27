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
    
    func startMoving(yPos yPos: CGFloat) {
        self.position = CGPointMake(Moveable.START_X_POS, yPos)

        moveAction = SKAction.moveByX(self.ITEM_SPEED, y: 0, duration: 0.02)
        moveForever = SKAction.repeatActionForever(moveAction)
        
        self.runAction(moveForever, withKey: "moveItForever")
    }
    
    override func update() {
        if self.position.x <= Moveable.RESET_X_POS {
            didExceedBounds()
        }
    }
    
    func didExceedBounds() {
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "removeMoveableObject", object: self))
        self.removeFromParent()
    }
}


