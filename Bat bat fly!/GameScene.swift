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
    
    // Timers
    var makeBoxesTimer: NSTimer!
    var makeChainsTimer: NSTimer!
    
    // Sounds
    var backgroundSound: AVAudioPlayer!
    var sfxBomb: AVAudioPlayer!
    var sfxGlass: AVAudioPlayer!
    
    let BACKGROUND_DIMENSION = CGSizeMake(640, 1136)
    var bat: Bat!
    var gameOver: Bool = false
    var movingGameObjects = SKNode()
    var backgrounds = SKNode()
    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -8)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(self.backgrounds)
        self.addChild(self.movingGameObjects)
        
        setUpGround()
        setUpBackground()
        
        createBat()
        
        self.makeBoxesTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "makeBoxes", userInfo: nil, repeats: true)
        self.makeChainsTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "makeChain", userInfo: nil, repeats: true)
        
        // Notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowIsNowBroken", name: "explosionNotification", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopPhysicWorld", name: "stopPhysicWorld", object: nil)
        
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
    
    func setUpGround() {
        let groundNode = SKNode()
        groundNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.width, 1))
        groundNode.physicsBody!.dynamic = false
        groundNode.physicsBody!.categoryBitMask = GameManager.sharedInstance.COLLIDER_GROUND
        groundNode.physicsBody!.contactTestBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        groundNode.physicsBody!.collisionBitMask = GameManager.sharedInstance.COLLIDER_PLAYER
        groundNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: 0)
        
        self.addChild(groundNode)
    }
    
    func setUpBackground() {
        let headerTexture = SKTexture(imageNamed: "header")
        let headerNode = SKSpriteNode(texture: headerTexture)
        headerNode.size = CGSizeMake(self.frame.width, 48)
        headerNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: self.frame.height - headerNode.size.height / 2)
        headerNode.zPosition = 2
        self.addChild(headerNode)
        
        
        let coefToScale: CGFloat = (self.frame.height - 48) / self.BACKGROUND_DIMENSION.height
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for var i: CGFloat = 0; i < 3; i++ {
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
    
    func makeBoxes() {
        
        let numberBoxes = Int((self.frame.height - 48 - GameManager.sharedInstance.GAP_SIZE) / GameManager.sharedInstance.BOX_SIZE)
        let numberBoxesTop: CGFloat = CGFloat(arc4random_uniform(UInt32(numberBoxes)) + 1)
        let numberBoxBottom: CGFloat = CGFloat(numberBoxes) - numberBoxesTop
    
        // Put box on the bottom
        for var i: CGFloat = 0; i < numberBoxBottom; i++ {
            let boxNode = Box()
            let yPos: CGFloat = boxNode.size.height / 2 + boxNode.size.height * i
            boxNode.startMoving(yPos: yPos)
            self.movingGameObjects.addChild(boxNode)
            
            if i + 1 == numberBoxBottom {
                let trapBottomNode = TrapDown()
                trapBottomNode.startMoving(yPos: yPos + trapBottomNode.size.height / 2 + boxNode.size.height / 2)
                self.movingGameObjects.addChild(trapBottomNode)
            }
        }
        
        for var j: CGFloat = 0; j < numberBoxesTop; j++ {
            let boxNode = Box()
            let yPos: CGFloat = (self.frame.height - 48 - boxNode.size.height / 2) - boxNode.size.height * j
            boxNode.startMoving(yPos: yPos)
            self.movingGameObjects.addChild(boxNode)
            
            if j + 1 == numberBoxesTop {
                let trapTopNode = TrapUp()
                trapTopNode.startMoving(yPos: yPos - boxNode.size.height / 2 - trapTopNode.size.height / 2)
                self.movingGameObjects.addChild(trapTopNode)
            }
        }
    }
    
    func createBat() {
        self.bat = Bat()
        self.bat.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(self.bat)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if !self.gameOver {
            let colliderTrap = GameManager.sharedInstance.COLLIDER_TRAP
            let colliderBomb = GameManager.sharedInstance.COLLIDER_BOMB
            let contactPoint = contact.contactPoint
            print("___________________________")
            print("contact x \(contactPoint.x)")
            print("contact y \(contactPoint.y)")
            
            if contact.bodyA.categoryBitMask == colliderTrap || contact.bodyB.categoryBitMask == colliderTrap {
                
                self.gameOver = true
                
                self.bat.playTrappedAnim()
                
                if let trap = contact.bodyA.node as? Trap {
                    trap.playTrapClosedAnimation()
                }
                
                if let trap = contact.bodyB.node as? Trap {
                    trap.playTrapClosedAnimation()
                }
                
                stopPhysicWorld()
            } else if contact.bodyA.categoryBitMask == colliderBomb || contact.bodyB.categoryBitMask == colliderBomb {
                self.stopPhysicWorld()
                
                if let box = contact.bodyA.node as? Box {
                    box.playBoxExplodedAnimation()
                }
                
                if let box = contact.bodyB.node as? Box {
                    box.playBoxExplodedAnimation()
                }
                
                if self.sfxBomb.playing {
                    self.sfxBomb.stop()
                }
                
                self.sfxBomb.play()
                
                self.bat.playExplodeAnim()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if self.gameOver == false {
            self.bat.physicsBody?.velocity = CGVectorMake(0, 0)
            self.bat.physicsBody?.applyImpulse(CGVectorMake(0, 55))
        } else {
            let scene = GameScene(fileNamed: "GameScene")
            scene!.scaleMode = .AspectFill
            let transition = SKTransition.doorsOpenHorizontalWithDuration(1.0)
            self.view?.presentScene(scene!, transition: transition)        }
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
        
        let gameOverNode = SKSpriteNode(imageNamed: "gameover")
        gameOverNode.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        gameOverNode.zPosition = 11
        
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
        
        self.addChild(gameOverNode)
    }
    
    func stopPhysicWorld() {
        self.gameOver = true
        print("STOP PHYSICS")
        self.makeChainsTimer.invalidate()
        self.makeBoxesTimer.invalidate()
        self.physicsWorld.contactDelegate = nil
//        self.movingGameObjects.speed = 0
        
        for movingNode in self.movingGameObjects.children {
            if let _ = movingNode.actionForKey("moveItForever") {
                movingNode.removeActionForKey("moveItForever")
            }
        }
        
        
        self.backgrounds.speed = 0
    }
    
    func startGame() {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
