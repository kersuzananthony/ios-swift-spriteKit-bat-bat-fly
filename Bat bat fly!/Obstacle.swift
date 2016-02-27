//
//  Obstacle.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class Obstacle: Moveable {
    
    private var _obstacleGroup: ObstacleGroup!
    
    var obstacleGroup: ObstacleGroup {
        return self._obstacleGroup
    }
    
    convenience init(texture: SKTexture, obstacleGroup: ObstacleGroup) {
        self.init(texture: texture)
        self._obstacleGroup = obstacleGroup
    }
    
    override func startMoving(yPos yPos: CGFloat) {
        super.startMoving(yPos: yPos)
        
        self.initPhysics()
        self.zPosition = ZPosition.obstacle.rawValue
    }
    
    func initPhysics() {
        self.physicsBody?.dynamic = false
        
    }
    
    func makeItDynamic() {
        self.physicsBody!.dynamic = true
        self.physicsBody!.allowsRotation = true
    }
    
    func setObstacleSpeed(speed: CGFloat) {
        self.ITEM_SPEED = speed
    }
    
}
