//
//  GameOverScreen.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 26/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class GameOverScreen: SKSpriteNode {
    
    let UI_Z_POSITION: CGFloat = ZPosition.gameOverUI.rawValue
    let TEXT_NODE_GAP: CGFloat = 40
    let ITEM_HEIGHT_RATIO: CGFloat = 0.1333
    let ITEM_GAP_RATIO: CGFloat = 0.0666
    
    var playerScoreNodes: SKSpriteNode!
    var bestScoreNodes: SKSpriteNode!
    var gameOverNode: SKSpriteNode!
    var yourScoreNode: SKSpriteNode!
    var playerScoreTextNode: TextNode!
    var bestScoreNode: SKSpriteNode!
    var bestScoreTextNode: TextNode!
    var bottomNodes: SKSpriteNode!
    
    convenience init(screenWidth: CGFloat, frame: CGRect, playerScore: Int, bestScore: Int) {
        let gameOverMiniScreenTexture = TEXTURE_ATLAS.textureNamed("white-board")
        self.init(texture: gameOverMiniScreenTexture)
        self.size.width =  screenWidth < 400 ? 400 : screenWidth
        self.size.height = gameOverMiniScreenTexture.size().height * (self.size.width / gameOverMiniScreenTexture.size().width)
        self.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame))
        self.zPosition = ZPosition.gameOverScreen.rawValue
        
        self.playerScoreNodes = SKSpriteNode()
        self.bestScoreNodes = SKSpriteNode()
        self.bottomNodes = SKSpriteNode()
        self.addChild(self.playerScoreNodes)
        self.addChild(self.bestScoreNodes)
        self.addChild(self.bottomNodes)
        
        makeGameOverNode()
        makeBestScoreButton()
        makePlayerScoreButton()
        makeBestTextNode(bestScore)
        makePlayerTextNode(playerScore)
        makeBottomItems()
    
        positionNodes()
        
        let scaleOutAction = SKAction.scaleTo(0, duration: 0)
        self.runAction(scaleOutAction)
    }
    
    func positionNodes() {
        
        let playerOrBestScoreWidthToTakeCareOf = self.playerScoreNodes.size.width > self.bestScoreNodes.size.width ? self.playerScoreNodes.size.width : self.bestScoreNodes.size.width
        
        self.playerScoreNodes.position = CGPoint(x: 0 - playerOrBestScoreWidthToTakeCareOf / 2, y: self.frame.size.height / 2 - self.gameOverNode.size.height - self.playerScoreNodes.size.height / 2 - 2 * self.ITEM_GAP_RATIO * self.frame.height)
        
        self.bestScoreNodes.position = CGPoint(x: 0 - playerOrBestScoreWidthToTakeCareOf / 2, y: self.frame.size.height / 2 - self.gameOverNode.size.height - self.playerScoreNodes.size.height - self.bestScoreNodes.size.height / 2 - 3 * self.ITEM_GAP_RATIO * self.frame.height)
        
        self.bottomNodes.position = CGPoint(x: 0 - self.bottomNodes.size.width / 2, y: self.frame.size.height / 2 - self.gameOverNode.size.height - self.playerScoreNodes.size.height - self.bestScoreNodes.size.height - self.bottomNodes.size.height / 2 - 4 * self.ITEM_GAP_RATIO * self.frame.height)
    }
    
    func makeGameOverNode() {
        let gameOverTexture = TEXTURE_ATLAS.textureNamed("gameover")
        self.gameOverNode = SKSpriteNode(texture: gameOverTexture)
        self.gameOverNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO * 2
        self.gameOverNode.size.width = gameOverTexture.size().width * (gameOverNode.size.height / gameOverTexture.size().height)
        
        self.gameOverNode.zPosition = self.UI_Z_POSITION
        self.gameOverNode.position = CGPoint(x: 0, y: self.frame.size.height / 2 - self.gameOverNode.size.height / 2 - self.ITEM_GAP_RATIO * self.frame.height)
        
        // GameOverNode Animation
        let scaleUpAction = SKAction.scaleTo(1.2, duration: 0)
        let scaleDownAction = SKAction.scaleTo(1.0, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        let fadeInAction = SKAction.fadeInWithDuration(0.5)
        let waitAction = SKAction.waitForDuration(0.5)
        let fadeOutAction = SKAction.fadeAlphaTo(0.5, duration: 1)
        let fadeInOutSequence = SKAction.sequence([waitAction, fadeOutAction, fadeInAction])
        let fadeInOutSequenceForever = SKAction.repeatActionForever(fadeInOutSequence)
        self.gameOverNode.runAction(scaleSequence)
        self.gameOverNode.runAction(fadeInOutSequenceForever)

        self.addChild(self.gameOverNode)
    }
    
    func makePlayerScoreButton() {
        let yourScoreTexture = TEXTURE_ATLAS.textureNamed("your-score")
        self.yourScoreNode = SKSpriteNode(texture: yourScoreTexture)
        self.yourScoreNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        self.yourScoreNode.size.width = yourScoreTexture.size().width * (self.yourScoreNode.size.height / yourScoreTexture.size().height)
        self.yourScoreNode.zPosition = self.UI_Z_POSITION
        
        self.yourScoreNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.yourScoreNode.position = CGPoint(x: 0, y: 0)
        self.playerScoreNodes.addChild(self.yourScoreNode)
        self.playerScoreNodes.size.height = self.yourScoreNode.size.height
        self.playerScoreNodes.size.width += self.yourScoreNode.size.width
    }

    
    func makePlayerTextNode(score: Int) {
    
        let availableWidth: CGFloat = self.frame.width - self.yourScoreNode.frame.width - self.TEXT_NODE_GAP
        
        self.playerScoreTextNode = TextNode(score: score)
        self.playerScoreTextNode.zPosition = self.UI_Z_POSITION
        
        let textNodeSizeAndRatio = calculateTextNodeSize(self.playerScoreTextNode.size, availableWidth: availableWidth)
        self.playerScoreTextNode.size = textNodeSizeAndRatio.newSize
        self.playerScoreTextNode.scaleByRatio(textNodeSizeAndRatio.ratio)
        
        self.playerScoreTextNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.playerScoreTextNode.position =  CGPoint(x: self.yourScoreNode.size.width + self.TEXT_NODE_GAP, y: 0)
        self.playerScoreNodes.addChild(playerScoreTextNode)
        self.playerScoreNodes.size.width += self.playerScoreTextNode.size.width + self.TEXT_NODE_GAP
    }
    
    func makeBestScoreButton() {
        let bestNodeTexture = TEXTURE_ATLAS.textureNamed("best-score")
        self.bestScoreNode = SKSpriteNode(texture: bestNodeTexture)
        self.bestScoreNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        self.bestScoreNode.size.width = bestNodeTexture.size().width * (self.bestScoreNode.size.height / bestNodeTexture.size().height)
        self.bestScoreNode.zPosition = self.UI_Z_POSITION
        
        self.bestScoreNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.bestScoreNode.position = CGPoint(x: 0, y: 0)
        self.bestScoreNodes.addChild(self.bestScoreNode)
        self.bestScoreNodes.size.height = self.bestScoreNode.size.height
        self.bestScoreNodes.size.width += self.bestScoreNode.size.width
    }

    
    func makeBestTextNode(bestScore: Int) {
    
        let availableWidth: CGFloat = self.frame.width - self.bestScoreNode.frame.width - self.TEXT_NODE_GAP
        
        self.bestScoreTextNode = TextNode(score: bestScore)
        let textNodeSizeAndRatio = calculateTextNodeSize(self.bestScoreTextNode.size, availableWidth: availableWidth)
        
        self.bestScoreTextNode.size = textNodeSizeAndRatio.newSize
        self.bestScoreTextNode.scaleByRatio(textNodeSizeAndRatio.ratio)
        self.bestScoreTextNode.zPosition = self.UI_Z_POSITION
        self.bestScoreTextNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        self.bestScoreTextNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.bestScoreTextNode.position = CGPoint(x: self.bestScoreNode.size.width + self.TEXT_NODE_GAP, y: 0)
        self.bestScoreNodes.addChild(self.bestScoreTextNode)
        self.bestScoreNodes.size.width += self.bestScoreTextNode.size.width + self.TEXT_NODE_GAP
    }
    

    func makeBottomItems() {
        // Rate button
        let rateTexture = TEXTURE_ATLAS.textureNamed("rate-button")
        let rateNode = SKSpriteNode(texture: rateTexture)
        rateNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        rateNode.size.width = rateTexture.size().width * (rateNode.size.height / rateTexture.size().height)
        rateNode.zPosition = self.UI_Z_POSITION
        rateNode.name = "rateButton"
        
        rateNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        rateNode.position = CGPoint(x: 0, y: 0)
        self.bottomNodes.addChild(rateNode)
        self.bottomNodes.size.height = rateNode.size.height
        self.bottomNodes.size.width += rateNode.size.width
        
        // Score/Classment button
        let classmentTexture = TEXTURE_ATLAS.textureNamed("score-button")
        let classmentNode = SKSpriteNode(texture: classmentTexture)
        classmentNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        classmentNode.size.width = classmentTexture.size().width * (classmentNode.size.height / classmentTexture.size().height)
        classmentNode.zPosition = self.UI_Z_POSITION
        classmentNode.name = "classmentButton"
        
        classmentNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        classmentNode.position = CGPoint(x: rateNode.size.width + self.TEXT_NODE_GAP / 2, y: 0)
        self.bottomNodes.addChild(classmentNode)
        self.bottomNodes.size.width += classmentNode.size.width + self.TEXT_NODE_GAP / 2
        
        // Share button
        let shareTexture = TEXTURE_ATLAS.textureNamed("share-button")
        let shareNode = SKSpriteNode(texture: shareTexture)
        shareNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        shareNode.size.width = shareTexture.size().width * (shareNode.size.height / shareTexture.size().height)
        shareNode.zPosition = self.UI_Z_POSITION
        shareNode.name = "shareButton"
        
        shareNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        shareNode.position = CGPoint(x: classmentNode.size.width + rateNode.size.width + 2 * self.TEXT_NODE_GAP / 2, y: 0)
        self.bottomNodes.addChild(shareNode)
        self.bottomNodes.size.width += shareNode.size.width + self.TEXT_NODE_GAP / 2
        
        // Start button
        let restartTexture = TEXTURE_ATLAS.textureNamed("start-button")
        let startNode = SKSpriteNode(texture: restartTexture)
        startNode.size.height = self.size.height * self.ITEM_HEIGHT_RATIO
        startNode.size.width = restartTexture.size().width * (startNode.size.height / restartTexture.size().height)
        startNode.zPosition = self.UI_Z_POSITION
        startNode.name = "restartButton"
        
        startNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        startNode.position = CGPoint(x: rateNode.size.width + classmentNode.size.width + shareNode.size.width + 3 * self.TEXT_NODE_GAP / 2, y: 0)
        self.bottomNodes.addChild(startNode)
        self.bottomNodes.size.width += startNode.size.width + self.TEXT_NODE_GAP / 2
        
    }
    
    func calculateTextNodeSize(originalSize: CGSize, availableWidth: CGFloat) -> (newSize: CGSize, ratio: CGFloat) {
        // Need to calculate width and height for better display
        var height = self.size.height * self.ITEM_HEIGHT_RATIO
        var width: CGFloat = 0
        var ratio: CGFloat = 1
        
        if originalSize.width * (height / originalSize.height) > availableWidth {
            width = availableWidth
            ratio = availableWidth / originalSize.width
            height = originalSize.height * ratio
        } else {
            width = originalSize.width * (height / originalSize.height)
            ratio = width / originalSize.width
        }

        return (CGSizeMake(width, height), ratio)
    }
    
    func displayGameOverScreen() {
        let scaleAction = SKAction.scaleTo(1, duration: 0.3)
        self.runAction(scaleAction)
    }
    
    func removeGameOverScreen() {
        let scaleAction = SKAction.scaleTo(0, duration: 0.5)
        self.runAction(scaleAction) { () -> Void in
            self.removeFromParent()
        }
    }
    
}
