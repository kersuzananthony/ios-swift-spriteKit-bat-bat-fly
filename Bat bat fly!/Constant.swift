//
//  Constant.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

typealias Completed = () -> ()

let TEXTURE_ATLAS = SKTextureAtlas(named: "images")
let APP_ID = "1078053085"

enum ZPosition: CGFloat {
    case background = 1
    case chain = 2
    case obstacle = 3
    case userInterface = 4
    case bat = 5
    case windowBroken = 6
    case gameOverScreen = 7
    case gameOverUI = 8
}