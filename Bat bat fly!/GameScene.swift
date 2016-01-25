//
//  GameScene.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright (c) 2016 Kersuzan. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Type of objects
    let colliderTrap = GameManager.sharedInstance.COLLIDER_TRAP
    let colliderBomb = GameManager.sharedInstance.COLLIDER_BOMB
    let colliderGround = GameManager.sharedInstance.COLLIDER_GROUND
    let colliderPlayer = GameManager.sharedInstance.COLLIDER_PLAYER
    let colliderScore = GameManager.sharedInstance.COLLIDER_SCORE_GATE
    
    // Timers
    var makeBoxesTimer: NSTimer!
    var makeChainsTimer: NSTimer!
    
    // Sounds
    var backgroundSound: AVAudioPlayer!
    var sfxBomb: AVAudioPlayer!
    var sfxGlass: AVAudioPlayer!
    
    // Variables
    let BACKGROUND_DIMENSION = CGSizeMake(640, 1136)
    var bat: Bat!
    var modePause: Bool = false
    var gameOver: Bool = false
    var cancelTouchGestureRecognizer: Bool = false
    var movingGameObjects = SKNode()
    var backgrounds = SKNode()
    var obstaclesGroup: [ObstacleGroup] = [ObstacleGroup]()
    var score: Int = 0
    var bestScore: Int = 0
    var scoreNode: SKNode!
    var headerNode: SKSpriteNode!
    var headerNodeButton: SKSpriteNode?
    
    
    
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -8)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(self.backgrounds)
        self.addChild(self.movingGameObjects)
        
        setUpGround()
        setUpCeil()
        setUpBackground()
        
        createBat()
        makeScoreLabel()
        
        createTimers()
        
        // Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowIsNowBroken", name: "explosionNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeMoveableObject:", name: "removeMoveableObject", object: nil)
        
        // Manage sounds
        do {
            try self.backgroundSound = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "wav")!))
            
            self.backgroundSound.prepareToPlay()
            
            self.backgroundSound.play()
            self.backgroundSound.volume = 0.3
            
            try self.sfxBomb = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bomb", ofType: "wav")!))
            self.sfxBomb.prepareToPlay()
            
            try self.sfxGlass = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mirror", ofType: "wav")!))
            self.sfxBomb.prepareToPlay()
            
            
        } catch _ {
            print("Error with sounds")
        }
        
    }
    
    func createTimers() {
//        self.makeBoxesTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "makeObstacles", userInfo: nil, repeats: true)
//        self.makeChainsTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: "makeChain", userInfo: nil, repeats: true)
        
        let waitAction = SKAction.waitForDuration(2.0)
        //let waitActionForever = SKAction.repeatActionForever(waitAction)
        self.runAction(waitAction) { () -> Void in
            self.makeObstacles()
            self.createTimers()
        }
        
    }
    
    func makeScoreLabel() {
        
        if let scoreNode = scoreNode {
            scoreNode.removeFromParent()
        }
        
        let scoreText = "\(self.score)"
        self.scoreNode = SKNode()
        self.addChild(scoreNode)
        var charPositionX: CGFloat = 0
        
        for char in scoreText.characters {
            let charNode = SKSpriteNode(imageNamed: "score-\(char)")
            scoreNode.addChild(charNode)
            charNode.position = CGPoint(x: charPositionX, y: 0)
            
            if char == "1" {
                charPositionX += charNode.size.width * 1.4
            } else {
                charPositionX += charNode.size.width
            }
        
        }
        
        scoreNode.zPosition =  100
        scoreNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: 50)
    }
    
    
    func setUpCeil() {
        let ceilNode = SKNode()
        ceilNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 1))
        ceilNode.physicsBody!.dynamic = false
        ceilNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - 48)
        
        self.addChild(ceilNode)
    }
    
    func setUpGround() {
        let groundNode = SKNode()
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 1))
        groundNode.physicsBody!.dynamic = false
        groundNode.physicsBody!.categoryBitMask = self.colliderGround
        groundNode.physicsBody!.contactTestBitMask =  self.colliderPlayer
        groundNode.physicsBody!.collisionBitMask = self.colliderPlayer | self.colliderBomb | self.colliderTrap
        groundNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: 0)
        
        self.addChild(groundNode)
    }
    
    func setUpBackground() {
        toggleHeaderNodeButton()
        
        let coefToScale: CGFloat = (self.frame.height - 48) / self.BACKGROUND_DIMENSION.height
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for var i: CGFloat = 0; i < 4; i++ {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.size.height = self.BACKGROUND_DIMENSION.height * coefToScale
            backgroundNode.size.width = (backgroundNode.size.height / self.BACKGROUND_DIMENSION.height) * self.BACKGROUND_DIMENSION.width
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.position = CGPoint(x: backgroundNode.size.width * i, y: 0)
            
            let moveByXAction = SKAction.moveByX(-backgroundNode.size.width, y: 0, duration: 5.0)
            let replaceBackground = SKAction.moveByX(backgroundNode.size.width, y: 0, duration: 0)
            let sequenceAction = SKAction.sequence([moveByXAction, replaceBackground])
            let moveAndReplaceBackgroundForever = SKAction.repeatActionForever(sequenceAction)
            
            backgroundNode.runAction(moveAndReplaceBackgroundForever)
            self.backgrounds.addChild(backgroundNode)
        }

    }
    
    func makeChain() {
        let chainNode = Chain()
        chainNode.startMoving(yPos: self.frame.height - 48 - chainNode.size.height / 2)
        self.movingGameObjects.addChild(chainNode)
    }
    
    func makeObstacles() {
        print("MAKEBOX")
        let obstacleGroup = ObstacleGroup(screenHeight: self.frame.height)

        for obstacle in obstacleGroup.obstacleGroupTop.obstacles {
            self.movingGameObjects.addChild(obstacle)
        }
        
        for obstacle in obstacleGroup.obstacleGroupBottom.obstacles {
            self.movingGameObjects.addChild(obstacle)
        }
        
        self.movingGameObjects.addChild(obstacleGroup.scoreGate)
        
        self.obstaclesGroup.append(obstacleGroup)
    }
    
    func createBat() {
        self.bat = Bat()
        self.bat.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(self.bat)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !self.gameOver {
            if contact.bodyA.categoryBitMask == self.colliderTrap || contact.bodyB.categoryBitMask == self.colliderTrap {
                self.gameIsOver()
                
                self.bat.playTrappedAnim()
                
                if let trap = contact.bodyA.node as? Trap {
                    trap.playTrapClosedAnimation()
                }
                
                if let trap = contact.bodyB.node as? Trap {
                    trap.playTrapClosedAnimation()
                }
                
                _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "displayGameOverMessage", userInfo: nil, repeats: false)

                
            } else if contact.bodyA.categoryBitMask == self.colliderBomb || contact.bodyB.categoryBitMask == self.colliderBomb {
                self.gameIsOver()
                
                if let box = contact.bodyA.node as? Box {
                    self.makeBoxCascadeExplosion(box)
                }
                
                if let box = contact.bodyB.node as? Box {
                    self.makeBoxCascadeExplosion(box)
                }
                
                if self.sfxBomb.playing {
                    self.sfxBomb.stop()
                }
                
                self.sfxBomb.play()
                
                self.bat.playExplodeAnim()
            
            } else if contact.bodyA.categoryBitMask == self.colliderScore || contact.bodyB.categoryBitMask == self.colliderScore {
                updateScore()
            }
        }
    }
    
    func makeBoxCascadeExplosion(box: Box) {
        
        for obstacleGroup in self.obstaclesGroup {
            if obstacleGroup.obstacleGroupBottom.obstacles.contains(box) {
                obstacleGroup.makeCascadeExplosion(ObstacleGroup.ObstaclePosition.Bottom, box: box)
                break
            }
            
            if obstacleGroup.obstacleGroupTop.obstacles.contains(box) {
                obstacleGroup.makeCascadeExplosion(ObstacleGroup.ObstaclePosition.Top, box: box)
                break
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first!
        let viewTouchLocation = touch.locationInView(self.view)
        let sceneTouchPoint = scene?.convertPointFromView(viewTouchLocation)
        
        if CGRectContainsPoint(self.headerNodeButton!.frame, sceneTouchPoint!) {
            if let node = scene?.nodeAtPoint(sceneTouchPoint!) where node.name == "Pause" {
//                pauseGame()
                
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "getGameCenterStatistics", object: nil, userInfo: nil))
                
            } else if let node = scene?.nodeAtPoint(sceneTouchPoint!) where node.name == "Play" {
                restartGame()
            }
        } else if self.gameOver == false && self.modePause == false {
            self.bat.physicsBody?.velocity = CGVectorMake(0, 0)
            self.bat.physicsBody?.applyImpulse(CGVectorMake(0, 55))
        } else if self.gameOver == true && self.cancelTouchGestureRecognizer == false {
            let scene = GameScene(fileNamed: "GameScene")
            scene!.scaleMode = .AspectFill
            let transition = SKTransition.doorsOpenHorizontalWithDuration(1.0)
            self.view?.presentScene(scene!, transition: transition)
            
            for child in self.movingGameObjects.children {
                child.removeFromParent()
            }
            
            self.obstaclesGroup = [ObstacleGroup]()

        }
    }
    
    func windowIsNowBroken() {
        
        let windowBrokenNode = SKSpriteNode(imageNamed: "cracking-glass")
        windowBrokenNode.position = self.bat.position
        windowBrokenNode.zPosition = 10
        
        let scaleDownAction = SKAction.scaleTo(0, duration: 0)
        let scaleUpAction = SKAction.scaleTo(1.5, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleDownAction, scaleUpAction])
        windowBrokenNode.runAction(scaleSequence)
        
        self.addChild(windowBrokenNode)
        
        if self.sfxGlass.playing {
            self.sfxGlass.stop()
        }
        
        self.sfxGlass.play()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "displayGameOverMessage", userInfo: nil, repeats: false)
    }
    
    func displayGameOverMessage() {
    
        self.backgroundSound.stop()
        print(self.frame.width)
        
        let screenWidth = UIScreen.mainScreen().bounds.width * 0.70
        
        let gameOverMiniScreenTexture = SKTexture(imageNamed: "white-board")
        let gameOverMiniScreen = SKSpriteNode(texture: gameOverMiniScreenTexture)
        gameOverMiniScreen.size.width =  screenWidth < 400 ? 400 : screenWidth
        print("WIDTHHHH \(gameOverMiniScreen.size.width)")
        gameOverMiniScreen.size.height = gameOverMiniScreenTexture.size().height * (gameOverMiniScreen.size.width / gameOverMiniScreenTexture.size().width)
        gameOverMiniScreen.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        gameOverMiniScreen.zPosition = 500
        self.addChild(gameOverMiniScreen)
        
        let gameOverTexture = SKTexture(imageNamed: "gameover")
        let gameOverNode = SKSpriteNode(texture: gameOverTexture)
        gameOverNode.size.height = gameOverMiniScreen.size.height * 0.3
        gameOverNode.size.width = gameOverTexture.size().width * (gameOverNode.size.height / gameOverTexture.size().height)
        gameOverMiniScreen.addChild(gameOverNode)
        gameOverNode.zPosition = 501
        gameOverNode.position = CGPoint(x: 0, y: gameOverNode.size.height)
        // GameOverNode Animation
        let scaleUpAction = SKAction.scaleTo(1.2, duration: 0)
        let scaleDownAction = SKAction.scaleTo(1.0, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        let fadeInAction = SKAction.fadeInWithDuration(0.5)
        let waitAction = SKAction.waitForDuration(0.5)
        let fadeOutAction = SKAction.fadeAlphaTo(0.5, duration: 1)
        let fadeInOutSequence = SKAction.sequence([waitAction, fadeOutAction, fadeInAction])
        let fadeInOutSequenceForever = SKAction.repeatActionForever(fadeInOutSequence)
        gameOverNode.runAction(scaleSequence)
        gameOverNode.runAction(fadeInOutSequenceForever)
        
        let yourScoreTexture = SKTexture(imageNamed: "your-score")
        let yourScoreNode = SKSpriteNode(texture: yourScoreTexture)
        yourScoreNode.size.height = gameOverMiniScreen.size.height * 0.15
        yourScoreNode.size.width = yourScoreTexture.size().width * (yourScoreNode.size.height / yourScoreTexture.size().height)
        gameOverMiniScreen.addChild(yourScoreNode)
        yourScoreNode.zPosition = 501
        yourScoreNode.position = CGPoint(x: -gameOverMiniScreen.size.width / 2 + yourScoreNode.size.width / 2 + 20, y: -yourScoreNode.size.height / 2)
        
        let bestScoreTexture = SKTexture(imageNamed: "best-score")
        let bestScoreNode = SKSpriteNode(texture: bestScoreTexture)
        bestScoreNode.size.height = gameOverMiniScreen.size.height * 0.15
        bestScoreNode.size.width = bestScoreTexture.size().width * (bestScoreNode.size.height / bestScoreTexture.size().height)
        gameOverMiniScreen.addChild(bestScoreNode)
        bestScoreNode.zPosition = 501
        bestScoreNode.position = CGPoint(x: -gameOverMiniScreen.size.width / 2 + bestScoreNode.size.width / 2 + 20, y: -gameOverMiniScreen.size.height / 2 + bestScoreNode.size.height / 2 + 20)
        
        let shareTexture = SKTexture(imageNamed: "share")
        let shareNode = SKSpriteNode(texture: shareTexture)
        shareNode.size.height = gameOverMiniScreen.size.height * 0.15
        shareNode.size.width = shareTexture.size().width * (shareNode.size.height / shareTexture.size().height)
        gameOverMiniScreen.addChild(shareNode)
        shareNode.zPosition = 501
        shareNode.position = CGPoint(x: gameOverMiniScreen.size.width / 2 - shareNode.size.width / 2 - 20, y: -shareNode.size.height / 2)
        
        let restartTexture = SKTexture(imageNamed: "start")
        let restartNode = SKSpriteNode(texture: restartTexture)
        restartNode.size.height = gameOverMiniScreen.size.height * 0.15
        restartNode.size.width = restartTexture.size().width * (restartNode.size.height / restartTexture.size().height)
        gameOverMiniScreen.addChild(restartNode)
        restartNode.zPosition = 501
        restartNode.position = CGPoint(x: gameOverMiniScreen.size.width / 2 - restartNode.size.width / 2 - 20, y: -gameOverMiniScreen.size.height / 2 + restartNode.size.height / 2 + 20)

//        
//        self.addChild(gameOverNode)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "canReplay", userInfo: nil, repeats: false)
    }
    
    func pauseGame() {
        self.makeBoxesTimer.invalidate()
        self.makeChainsTimer.invalidate()
        
        self.backgrounds.speed = 0
        self.movingGameObjects.speed = 0
        self.bat.speed = 0
        
        self.modePause = true
        self.bat.turnPhysicBodyDynamism(false)
        toggleHeaderNodeButton()
    }
    
    func restartGame() {
        createTimers()
        
        self.backgrounds.speed = 1
        self.movingGameObjects.speed = 1
        self.bat.speed = 1
        
        self.modePause = false
        self.bat.turnPhysicBodyDynamism(true)
        toggleHeaderNodeButton()
    }
    
    func toggleHeaderNodeButton() {
        
        let pauseNodeTexture = SKTexture(imageNamed: "pause-button")
        let playNodeTexture = SKTexture(imageNamed: "play-button")
        
        if self.headerNodeButton == nil || self.headerNodeButton?.name == "Play" {
            self.headerNodeButton?.removeFromParent()
            self.headerNodeButton = SKSpriteNode(texture: pauseNodeTexture)
            self.headerNodeButton!.name = "Pause"
        } else {
            self.headerNodeButton!.removeFromParent()
            self.headerNodeButton = SKSpriteNode(texture: playNodeTexture)
            self.headerNodeButton!.name = "Play"
        }
        

        self.addChild(headerNodeButton!)
        self.headerNodeButton!.size.height = 48 * 0.8
        self.headerNodeButton!.size.width = pauseNodeTexture.size().width * (self.headerNodeButton!.size.height / pauseNodeTexture.size().height)
        print("headerNodeButton width \(self.headerNodeButton!.size.width)")
        print("headerNodeButton height \(self.headerNodeButton!.size.height)")
        self.headerNodeButton!.position = CGPoint(x: self.frame.width / 4, y: 20)
        self.headerNodeButton!.anchorPoint = CGPoint(x: 0, y: 0)
        print("headerNodeButton x \(self.headerNodeButton!.position.x)")
        print("headerNodeButton y \(self.headerNodeButton!.position.y)")
        self.headerNodeButton!.zPosition = 500
    }
    
    // MARK: - Game is over and we invalide the two timers and stop movings objects
    func gameIsOver() {
        self.gameOver = true
        self.cancelTouchGestureRecognizer = true
//        self.makeChainsTimer.invalidate()
//        self.makeBoxesTimer.invalidate()
//        
//        self.makeChainsTimer = nil
//        self.makeBoxesTimer = nil
        self.removeAllActions()
        
        for movingNode in self.movingGameObjects.children {
            if let _ = movingNode.actionForKey("moveItForever") {
                movingNode.removeActionForKey("moveItForever")
            }
        }
        self.backgrounds.speed = 0
        self.physicsWorld.contactDelegate = nil
        
        // Set bestScore
        GameManager.sharedInstance.setPlayerBestScore(self.score)
    }
    
    // MARK: - Update user's score
    func updateScore() {
        self.score++
        self.makeScoreLabel()
    }
   
    // MARK: - Function called each time per frame, it calculates the position of each moving objects and remove it from the parent if it exceeds bounds
    override func update(currentTime: CFTimeInterval) {
        if self.gameOver || self.modePause {
            return
        } else {
            for object in self.movingGameObjects.children {
                object.update()
            }
        }
    }
    
    func canReplay() {
        self.cancelTouchGestureRecognizer = false
    }
    
    func removeMoveableObject(sender: NSNotification) {
        if let obstacle = sender.object as? Obstacle {
            print("Before delete : \(self.movingGameObjects.children.count)")
            let index = self.movingGameObjects.children.indexOf(obstacle)
            print(index)
            obstacle.removeFromParent()
            print("After delete: \(self.movingGameObjects.children.count)")
        }
    }
    
}
