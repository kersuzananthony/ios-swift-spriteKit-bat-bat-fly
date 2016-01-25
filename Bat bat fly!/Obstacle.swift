//
//  Obstacle.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Obstacle: Moveable {
    
    override func startMoving(yPos yPos: CGFloat) {
        self.ITEM_SPEED = GameManager.sharedInstance.OBSTACLES_SPEED
        super.startMoving(yPos: yPos)
        
        self.initPhysics()
    }
    
    func initPhysics() {
        self.physicsBody?.dynamic = false
        
    }
    
    func makeItDynamic() {
        print("make it dynamic again")
        self.physicsBody!.dynamic = true
        self.physicsBody!.allowsRotation = true
    }
    
}
