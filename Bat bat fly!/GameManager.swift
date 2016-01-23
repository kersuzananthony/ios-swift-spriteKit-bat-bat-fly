//
//  GameManager.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class GameManager {
    
    static let sharedInstance = GameManager()
    
    // Layers position
    let backgroundPosition: CGFloat = 1
    let backgroundHeaderPosition: CGFloat = 2
    let obstaclePosition: CGFloat = 3
    let playerPosition: CGFloat = 4
    
    //Colliders
    let COLLIDER_GROUND: UInt32 = 1 << 0
    let COLLIDER_TRAP: UInt32 = 1 << 1
    let COLLIDER_BOMB: UInt32 = 1 << 2
    let COLLIDER_PLAYER: UInt32 = 1 << 3
    
    // Obstacles speed
    let OBSTACLES_SPEED: CGFloat = -6
    let CHAIN_SPEED: CGFloat = -4
    
    // Sizes
    let BOX_SIZE: CGFloat = 90
    let GAP_SIZE: CGFloat = 300
}
