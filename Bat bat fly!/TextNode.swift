//
//  TextNode.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 26/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class TextNode: SKSpriteNode {
    
    convenience init(score: Int) {
        self.init()
        
        let scoreText = "\(score)"
        var charPositionX: CGFloat = 0
        let charactersCount: Int = scoreText.characters.count
        
        for (index, char) in scoreText.characters.enumerated() {
            let charNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("score-\(char)"))
            charNode.name = "\(char)"
            self.addChild(charNode)
            charNode.position = CGPoint(x: charPositionX, y: 0)
            
            if char == "1" {
                charPositionX += charNode.size.width * 1.4
            } else {
                charPositionX += charNode.size.width
            }
            
            if index == charactersCount - 1 {
                self.size.width = charPositionX
                self.size.height = charNode.size.height
            }
            
        }
    }
    
    func scaleByRatio(_ ratio: CGFloat) {
        let scaleAction = SKAction.scale(to: ratio, duration: 0)
        var charPositionX: CGFloat = 0
        
        for child in self.children as! [SKSpriteNode] {
            child.run(scaleAction)
            
            child.position = CGPoint(x: charPositionX, y: 0)
            
            if child.name == "1" {
                charPositionX += child.size.width * 1.4 * ratio
            } else {
                charPositionX += child.size.width * ratio
            }
        }
    }
    
}
