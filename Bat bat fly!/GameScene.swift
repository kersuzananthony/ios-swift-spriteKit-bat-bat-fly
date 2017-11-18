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
    
    // DifficultyManager Instance
    var difficultyManager: DifficultyManager!
    
    // Type of objects
    let colliderTrap = GameManager.sharedInstance.COLLIDER_TRAP
    let colliderBomb = GameManager.sharedInstance.COLLIDER_BOMB
    let colliderGround = GameManager.sharedInstance.COLLIDER_GROUND
    let colliderPlayer = GameManager.sharedInstance.COLLIDER_PLAYER
    let colliderScore = GameManager.sharedInstance.COLLIDER_SCORE_GATE
    
    // Timers
    var makeBoxesTimer: Timer!
    var makeChainsTimer: Timer!
    
    // Sounds
    var backgroundSound: AVAudioPlayer!
    var sfxBomb: AVAudioPlayer!
    var sfxGlass: AVAudioPlayer!
    var sfxMetal: AVAudioPlayer!
    
    // Nodes
    var bat: Bat!
    var instructionsGroup = SKNode()
    var movingGameObjects = SKNode() // Movings object such as chain and obstacle
    var backgrounds = SKNode()
    var backgroundsArray = [SKSpriteNode]()
    var obstaclesGroup: [ObstacleGroup] = [ObstacleGroup]()
    var gameOverScreen: GameOverScreen!
    var scoreNode: TextNode!
    var headerNode: SKSpriteNode!
    var headerNodeButton: SKSpriteNode?
    var soundButton: SKSpriteNode?
    var userInterfaceElements: SKNode!
    
    // Variables
    let BACKGROUND_DIMENSION = CGSize(width: 2560, height: 1136)
    var playSound: Bool!
    var gameIsStarted: Bool = false
    var modePause: Bool = false
    var gameOver: Bool = false
    var cancelTouchGestureRecognizer: Bool = false
    var score: Int = 0
    var bestScore: Int = 0
    let BG_X_RESET: CGFloat = -3000
    
    // MARK: -didMoveToView method
    override func didMove(to view: SKView) {
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -8)
        self.physicsWorld.contactDelegate = self
        
        self.addChild(self.backgrounds)
        self.addChild(self.movingGameObjects)
        self.addChild(self.instructionsGroup)
        self.userInterfaceElements = SKNode()
        self.addChild(self.userInterfaceElements)
        
        self.playSound = GameManager.sharedInstance.getPlayerSoundPreference()
        
        setUpGround()
        setUpCeil()
        setUpBackground()
        
        createBat()
        
        self.backgrounds.speed = 0
        self.bat.turnPhysicBodyDynamism(false)
        self.bat.speed = 0
        
        registerForNotifications()
        displayReady()
        initializeSounds()
    }

    // MARK: -Add observes for the following notifications
    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.windowIsNowBroken), name: NSNotification.Name(rawValue: "explosionNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameScene.removeMoveableObject(_:)), name: NSNotification.Name(rawValue: "removeMoveableObject"), object: nil)
    }
    
    // MARK: - Preload all the sound effects the game needs
    func initializeSounds() {
        // Manage sounds
        do {
            try self.backgroundSound = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "wav")!))
            
            self.backgroundSound.numberOfLoops = -1
            self.backgroundSound.prepareToPlay()
            
            self.backgroundSound.volume = 0.3
            
            try self.sfxBomb = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "bomb", ofType: "wav")!))
            self.sfxBomb.prepareToPlay()
            
            try self.sfxGlass = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "mirror", ofType: "wav")!))
            self.sfxBomb.prepareToPlay()
            
            try self.sfxMetal = AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "metal", ofType: "wav")!))
            self.sfxMetal.prepareToPlay()
            
            
        } catch _ {
            print("Error with sounds")
        }
    }
    
    // MARK: - Set up ground
    func setUpGround() {
        let groundNode = SKNode()
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        groundNode.physicsBody!.isDynamic = false
        groundNode.physicsBody!.categoryBitMask = self.colliderGround
        groundNode.physicsBody!.contactTestBitMask =  self.colliderPlayer
        groundNode.physicsBody!.collisionBitMask = self.colliderPlayer | self.colliderBomb | self.colliderTrap
        groundNode.position = CGPoint(x: self.frame.midX, y: 0)
        
        self.addChild(groundNode)
    }
    
    // MARK: - Set up ceil
    func setUpCeil() {
        let ceilNode = SKNode()
        ceilNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ceilNode.physicsBody!.isDynamic = false
        ceilNode.position = CGPoint(x: self.frame.midX, y: self.frame.height - 48)
        
        self.addChild(ceilNode)
    }

    // MARK: - Set up background
    func setUpBackground() {
        self.headerNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("header"))
        self.headerNode.anchorPoint = CGPoint(x: 0.5, y: 1)
        self.headerNode.position = CGPoint(x: self.frame.midX, y: self.frame.height)
        self.headerNode.size.height = 48
        self.headerNode.size.width = 3000
        self.headerNode.name = "header"
        self.addChild(self.headerNode)
        self.headerNode.zPosition = ZPosition.background.rawValue
        
        let titleTextNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("title-text"))
        self.headerNode.addChild(titleTextNode)
        titleTextNode.anchorPoint = CGPoint(x: 0, y: 1)
        titleTextNode.position = CGPoint(x: 0 - titleTextNode.size.width / 2, y: -titleTextNode.size.height / 2)
        titleTextNode.zPosition = ZPosition.chain.rawValue
        
        
        let coefToScale: CGFloat = (self.frame.height - 48) / self.BACKGROUND_DIMENSION.height
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        let moveByXAction = SKAction.moveBy(x: GameManager.sharedInstance.BACKGROUND_SPEED, y: 0, duration: 0.02)
        let moveBackgroundForever = SKAction.repeatForever(moveByXAction)

        for i: Int in 0 ..< 3 {
            let backgroundNode = SKSpriteNode(texture: backgroundTexture)
            backgroundNode.size.height = self.BACKGROUND_DIMENSION.height * coefToScale
            backgroundNode.size.width = (backgroundNode.size.height / self.BACKGROUND_DIMENSION.height) * self.BACKGROUND_DIMENSION.width
            backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
            backgroundNode.position = CGPoint(x: backgroundNode.size.width * CGFloat(i), y: 0)
            backgroundNode.zPosition = ZPosition.background.rawValue
            
            self.backgrounds.addChild(backgroundNode)
            self.backgroundsArray.append(backgroundNode)
        }
        
        for background in self.backgroundsArray {
            background.run(moveBackgroundForever)
        }
    }
    
    // MARK: - Create a new Bat Object
    func createBat() {
        self.bat = Bat()
        self.bat.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.bat)
    }
    
    // MARK: - Display the level selector at the beginning of the game
    func displayLevelSelector() {
        
        let levelSelector = SKSpriteNode()
        
        // Easy level
        let easyTexture = TEXTURE_ATLAS.textureNamed("easy-button")
        let easyNode = SKSpriteNode(texture: easyTexture)
        easyNode.name = "easyLevel"
        levelSelector.addChild(easyNode)
        easyNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        easyNode.position = CGPoint(x: 0, y: 0)
        levelSelector.size.height = easyNode.size.height
        levelSelector.size.width += easyNode.size.width
        
        // Medium level
        let mediumTexture = TEXTURE_ATLAS.textureNamed("medium-button")
        let mediumNode = SKSpriteNode(texture: mediumTexture)
        mediumNode.name = "mediumLevel"
        levelSelector.addChild(mediumNode)
        mediumNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        mediumNode.position = CGPoint(x: easyNode.size.width + 20, y: 0)
        levelSelector.size.width += mediumNode.size.width + 20
        
        // Hard level
        let hardTexture = TEXTURE_ATLAS.textureNamed("hard-button")
        let hardNode = SKSpriteNode(texture: hardTexture)
        hardNode.name = "hardLevel"
        levelSelector.addChild(hardNode)
        hardNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        hardNode.position = CGPoint(x: easyNode.size.width + mediumNode.size.width + 40, y: 0)
        levelSelector.size.width += hardNode.size.width + 20
        
        self.instructionsGroup.addChild(levelSelector)
        levelSelector.position = CGPoint(x: self.frame.midX - levelSelector.size.width / 2, y: 50 + levelSelector.size.height / 2)
        levelSelector.zPosition = ZPosition.userInterface.rawValue
    }
    
    // MARK: Display instructions at the begining of the game
    func displayReady() {
        
        let arrowUpNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("up-arrow"))
        self.instructionsGroup.addChild(arrowUpNode)
        arrowUpNode.zPosition = ZPosition.userInterface.rawValue
        arrowUpNode.position = CGPoint(x: self.frame.midX - 7, y: self.frame.midY - self.bat.size.height / 2 - arrowUpNode.size.height / 2 - 8)
        
        let handNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("hand"))
        self.instructionsGroup.addChild(handNode)
        handNode.zPosition = ZPosition.userInterface.rawValue
        handNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY - self.bat.size.height - arrowUpNode.size.height - handNode.size.height / 2)
        
        let tapEffectNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("tap-effect"))
        let tapEffectFadeOutAction = SKAction.fadeAlpha(to: 0.3, duration: 1)
        let tapEffectFadeInAction = SKAction.fadeAlpha(to: 1, duration: 1)
        let tapEffectFadeInOutActionSequence = SKAction.sequence([tapEffectFadeOutAction, tapEffectFadeInAction])
        let tapEffectFadeInOutForever = SKAction.repeatForever(tapEffectFadeInOutActionSequence)
        tapEffectNode.run(tapEffectFadeInOutForever)
        self.instructionsGroup.addChild(tapEffectNode)
        tapEffectNode.zPosition = ZPosition.userInterface.rawValue
        tapEffectNode.position = CGPoint(x: self.frame.midX - 8, y: self.frame.midY - self.bat.size.height - 20)
        
        let readyNode = SKSpriteNode(texture: TEXTURE_ATLAS.textureNamed("ready"))
        readyNode.name = "readyNode"
        
        self.instructionsGroup.addChild(readyNode)
        readyNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY + self.bat.size.height + readyNode.size.height / 2)
        readyNode.zPosition = ZPosition.userInterface.rawValue
        
        displayLevelSelector()
    }
    
    // MARK: - Create times for making obstacles and chain
    func createTimers() {
        self.makeBoxesTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameScene.makeObstacles), userInfo: nil, repeats: true)
        self.makeChainsTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameScene.makeChain), userInfo: nil, repeats: true)
    }
    
    // MARK: - Update the score label at the bottom of the screen
    func updateScoreText() {
        
        if let scoreNode = scoreNode {
            scoreNode.removeFromParent()
        }
        
        self.scoreNode = TextNode(score: self.score)
        self.userInterfaceElements.addChild(scoreNode)
        
        scoreNode.zPosition =  ZPosition.userInterface.rawValue
        scoreNode.position = CGPoint(x: self.frame.midX - scoreNode.size.width / 2 + 20, y: 50)
    }
    
    // MARK: -Make play/pause button and sound/mute
    func makeUserButton() {
        toggleHeaderNodeButton()
        toggleSoundButton()
    }
    
    // MARK: - Create chains.
    func makeChain() {
        let chainNode = Chain()
        chainNode.startMoving(yPos: self.frame.height - 48 - chainNode.size.height / 2)
        self.movingGameObjects.addChild(chainNode)
    }
    
    // MARK: - Create obstacles (bomb + trap). A timer calls this method
    func makeObstacles() {
        let obstacleGroup = ObstacleGroup(screenHeight: self.frame.height, difficulty: self.difficultyManager)

        for obstacle in obstacleGroup.obstacleGroupTop.obstacles {
            self.movingGameObjects.addChild(obstacle)
        }
        
        for obstacle in obstacleGroup.obstacleGroupBottom.obstacles {
            self.movingGameObjects.addChild(obstacle)
        }
        
        self.movingGameObjects.addChild(obstacleGroup.scoreGate)
        
        self.obstaclesGroup.append(obstacleGroup)
    }
    
    
    // MARK: - Objects contact method
    func didBegin(_ contact: SKPhysicsContact) {
        
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
                
                if self.sfxMetal.isPlaying {
                    self.sfxMetal.stop()
                }
                
                if self.playSound == true {
                    self.sfxMetal.play()
                }
                
                _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.displayGameOverMessage), userInfo: nil, repeats: false)

                
            } else if contact.bodyA.categoryBitMask == self.colliderBomb || contact.bodyB.categoryBitMask == self.colliderBomb {
                self.gameIsOver()
                
                if let box = contact.bodyA.node as? Box {
                    self.makeBoxCascadeExplosion(box)
                }
                
                if let box = contact.bodyB.node as? Box {
                    self.makeBoxCascadeExplosion(box)
                }
                
                if self.sfxBomb.isPlaying {
                    self.sfxBomb.stop()
                }
                
                if self.playSound == true {
                    self.sfxBomb.play()
                }
                
                self.bat.playExplodeAnim()
            
            } else if contact.bodyA.categoryBitMask == self.colliderScore || contact.bodyB.categoryBitMask == self.colliderScore {
                updateScore()
            }
        }
    }
    
    // MARK: - Function called when the user hits a bomb. Many bombs explode according to their position on the scene
    func makeBoxCascadeExplosion(_ box: Box) {
        
        for obstacleGroup in self.obstaclesGroup {
            if obstacleGroup.obstacleGroupBottom.obstacles.contains(box) {
                obstacleGroup.makeCascadeExplosion(ObstacleGroup.ObstaclePosition.bottom, box: box)
                break
            }
            
            if obstacleGroup.obstacleGroupTop.obstacles.contains(box) {
                obstacleGroup.makeCascadeExplosion(ObstacleGroup.ObstaclePosition.top, box: box)
                break
            }
        }
    }
    
    // MARK: - Touches manager
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let viewTouchLocation = touch.location(in: self.view)
        let sceneTouchPoint = scene?.convertPoint(fromView: viewTouchLocation)
        
        if !gameIsStarted {
            if let node = scene?.atPoint(sceneTouchPoint!), node.name == "easyLevel" {
                self.difficultyManager = DifficultyManager(difficultyLevel: .Easy)
                startGame()
            }
            
            if let node = scene?.atPoint(sceneTouchPoint!), node.name == "mediumLevel" {
                self.difficultyManager = DifficultyManager(difficultyLevel: .Medium)
                startGame()
            }
            
            if let node = scene?.atPoint(sceneTouchPoint!), node.name == "hardLevel" {
                self.difficultyManager = DifficultyManager(difficultyLevel: .Hard)
                startGame()
            }
        } else {
            if self.headerNode.frame.contains(sceneTouchPoint!) {
                pauseGame()
            }
            else if self.headerNodeButton!.frame.contains(sceneTouchPoint!) {
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "Pause" {
                    pauseGame()
                } else if let node = scene?.atPoint(sceneTouchPoint!), node.name == "Play" {
                    restartGame()
                }
            } else if self.soundButton!.frame.contains(sceneTouchPoint!) {
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "Mute" {
                    toggleSound()
                } else if let node = scene?.atPoint(sceneTouchPoint!), node.name == "Sound" {
                    toggleSound()
                }
            } else if self.gameOver == false && self.modePause == false {
                self.bat.impulse()
            } else if self.gameOver == true && self.cancelTouchGestureRecognizer == false {
                
                // User wants to rate the app
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "rateButton" {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "rateButton"), object: nil))
                }
                
                // User wants to check classment
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "classmentButton" {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "classmentButton"), object: nil))
                }
                
                // User wants to share score to his friends
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "shareButton" {
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "shareButton"), object: self.score, userInfo: nil))
                }
                
                // User wants to restart the game
                if let node = scene?.atPoint(sceneTouchPoint!), node.name == "restartButton" {
                    
                    self.gameOverScreen.removeGameOverScreen()
        
                    for child in self.movingGameObjects.children {
                        child.removeFromParent()
                    }
                    
                    self.obstaclesGroup = [ObstacleGroup]()
                    
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "gameOver"), object: nil))
                }
            }
        }
    }
    
    
    func toggleSound() {
        self.playSound = !self.playSound
        
        GameManager.sharedInstance.setPlayerSoundPreference(self.playSound)
        
        if self.playSound == false {
            self.backgroundSound.stop()
        } else {
            self.backgroundSound.play()
        }
        
        toggleSoundButton()
    }
    
    // MARK: - Function called when the user hits a bomb and animations of bomb and bat have already been played.
    func windowIsNowBroken() {
        
        let windowBrokenNode = SKSpriteNode(imageNamed: "cracking-glass")
        windowBrokenNode.position = self.bat.position
        windowBrokenNode.zPosition = ZPosition.windowBroken.rawValue
        
        let scaleDownAction = SKAction.scale(to: 0, duration: 0)
        let scaleUpAction = SKAction.scale(to: 1.5, duration: 0.5)
        let scaleSequence = SKAction.sequence([scaleDownAction, scaleUpAction])
        windowBrokenNode.run(scaleSequence)
        
        self.addChild(windowBrokenNode)
        
        if self.sfxGlass.isPlaying {
            self.sfxGlass.stop()
        }
        
        if self.playSound == true {
            self.sfxGlass.play()
        }
        
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameScene.displayGameOverMessage), userInfo: nil, repeats: false)
    }
    
    // MARK: - Function called when user loses and animations have been played
    func displayGameOverMessage() {
    
        self.backgroundSound.stop()
        let screenWidth = UIScreen.main.bounds.width * 0.70
        
        self.gameOverScreen = GameOverScreen(screenWidth: screenWidth, frame: self.frame, playerScore: self.score, bestScore: GameManager.sharedInstance.getPlayerBestScore(self.difficultyManager.difficultyLevel))
        
        self.addChild(self.gameOverScreen)
        self.gameOverScreen.displayGameOverScreen()
        
        for child in self.userInterfaceElements.children {
            child.removeFromParent()
        }
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameScene.canReplay), userInfo: nil, repeats: false)
    }
    
    // MARK: - Function called when the user starts the game (= first tap on the game)
    func startGame() {
        self.gameIsStarted = true
        
        for child in self.instructionsGroup.children {
            child.removeFromParent()
        }
        
        updateScoreText()
        makeUserButton()
        
        self.backgrounds.speed = 1
        self.bat.speed = 1
        self.bat.turnPhysicBodyDynamism(true)
        
        if self.playSound == true {
            self.backgroundSound.play()
        }
        
        self.createTimers()
    }
    
    // MARK: - Function called when the user pauses the game
    func pauseGame() {
        if !self.gameOver {
            self.makeBoxesTimer.invalidate()
            self.makeChainsTimer.invalidate()
            
            self.backgrounds.speed = 0
            self.movingGameObjects.speed = 0
            self.bat.speed = 0
            
            self.modePause = true
            self.bat.turnPhysicBodyDynamism(false)
            toggleHeaderNodeButton()
            
            self.playSound = false
            self.backgroundSound.stop()
        }
    }
    
    // MARK: - Function called when user unpauses the game
    func restartGame() {
        if !gameOver {
            createTimers()
            
            self.backgrounds.speed = 1
            self.movingGameObjects.speed = 1
            self.bat.speed = 1
            
            self.modePause = false
            self.bat.turnPhysicBodyDynamism(true)
            toggleHeaderNodeButton()
            
            self.playSound = true
            self.backgroundSound.play()
        }
    }
    
    // MARK: - Toogle headerButton: It can be a pause-button or a play-button
    func toggleHeaderNodeButton() {
        
        let pauseNodeTexture = TEXTURE_ATLAS.textureNamed("pause-button")
        let playNodeTexture = TEXTURE_ATLAS.textureNamed("play-button")
        
        if self.headerNodeButton == nil || self.headerNodeButton?.name == "Play" {
            self.headerNodeButton?.removeFromParent()
            self.headerNodeButton = SKSpriteNode(texture: pauseNodeTexture)
            self.headerNodeButton!.name = "Pause"
        } else {
            self.headerNodeButton!.removeFromParent()
            self.headerNodeButton = SKSpriteNode(texture: playNodeTexture)
            self.headerNodeButton!.name = "Play"
        }
        
        var diffWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth / 2 >= 480 && (UIScreen.main.bounds.size != CGSize(width: 1024, height: 1366)) {
            diffWidth = 480
        } else {
            if screenWidth / 2 >= 256 {
                diffWidth = 256
            } else {
                if screenWidth / 2 <= 200 {
                    diffWidth = 200
                } else {
                    diffWidth = screenWidth / 2
                }
            }
        }
    
        self.userInterfaceElements.addChild(headerNodeButton!)
        self.headerNodeButton!.size.height = 48 * 0.8
        self.headerNodeButton!.size.width = pauseNodeTexture.size().width * (self.headerNodeButton!.size.height / pauseNodeTexture.size().height)
        self.headerNodeButton!.position = CGPoint(x: self.frame.midX - diffWidth + self.headerNodeButton!.size.width / 2, y: self.frame.height - 80 - self.headerNodeButton!.size.height)
        self.headerNodeButton!.zPosition = ZPosition.userInterface.rawValue
    }
    
    func toggleSoundButton() {
        
        let soundNodeTexture = TEXTURE_ATLAS.textureNamed("sound-button")
        let muteNodeTexture = TEXTURE_ATLAS.textureNamed("mute-button")
        
        if self.playSound == true {
            self.soundButton?.removeFromParent()
            self.soundButton = SKSpriteNode(texture: muteNodeTexture)
            self.soundButton!.name = "Mute"
        } else {
            self.soundButton?.removeFromParent()
            self.soundButton = SKSpriteNode(texture: soundNodeTexture)
            self.soundButton!.name = "Sound"
        }
        
        var diffWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth / 2 >= 480 && (UIScreen.main.bounds.size != CGSize(width: 1024, height: 1366)) {
            diffWidth = 480
        } else {
            if screenWidth / 2 >= 256 {
                diffWidth = 256
            } else {
                if screenWidth / 2 <= 200 {
                    diffWidth = 200
                } else {
                    diffWidth = screenWidth / 2
                }
            }
        }

        self.userInterfaceElements.addChild(self.soundButton!)
        self.soundButton!.size.height = 48 * 0.8
        self.soundButton!.size.width = soundNodeTexture.size().width * (self.soundButton!.size.height / soundNodeTexture.size().height)
        self.soundButton!.position = CGPoint(x: self.frame.midX + diffWidth - self.soundButton!.size.width / 2, y: self.frame.height - 80 - self.soundButton!.size.height)
        self.soundButton!.zPosition = ZPosition.userInterface.rawValue

        
    }
    
    // MARK: - Game is over and we invalidate the two timers and stop movings objects
    func gameIsOver() {
        self.gameOver = true
        self.cancelTouchGestureRecognizer = true
        self.makeChainsTimer.invalidate()
        self.makeBoxesTimer.invalidate()
        
        self.makeChainsTimer = nil
        self.makeBoxesTimer = nil
        
        for movingNode in self.movingGameObjects.children {
            if let _ = movingNode.action(forKey: "moveItForever") {
                movingNode.removeAction(forKey: "moveItForever")
            }
        }
        self.backgrounds.speed = 0
        self.physicsWorld.contactDelegate = nil
        
        // Set bestScore
        GameManager.sharedInstance.setPlayerBestScore(self.score, difficulty: self.difficultyManager.difficultyLevel)
    }
    
    // MARK: - Update user's score
    func updateScore() {
        self.score += 1
        self.updateScoreText()
        self.difficultyManager.increaseDifficulty(self.score)
    }
   
    // MARK: - Function called each time per frame, it calculates the position of each moving objects and remove it from the parent if it exceeds bounds
    override func update(_ currentTime: TimeInterval) {
        if self.gameOver || self.modePause {
            return
        } else {
            for object in self.movingGameObjects.children {
                object.update()
            }
            
            for x in 0 ..< 3 {
                
                if self.backgroundsArray[x].position.x <= BG_X_RESET {
                    var index: Int!
                    
                    if x == 0 {
                        index = self.backgroundsArray.count - 1
                    } else {
                        index = x - 1
                    }
                    
                    let newPos = CGPoint(x: self.backgroundsArray[index].position.x + self.backgroundsArray[x].size.width, y: self.backgroundsArray[x].position.y)
                    
                    self.backgroundsArray[x].position = newPos
                }
            }
        }
    }
    
    // MARK: - Function called 2 seconds after gameOverScreen has appeared. It allows the user to replay
    func canReplay() {
        self.cancelTouchGestureRecognizer = false
    }
    
    // MARK: - Function called when this gameScene receives notification from Moveable class. Moveable object has been removed and we need to clean moveableObjects child array
    func removeMoveableObject(_ sender: Notification) {
        if let obstacle = sender.object as? Obstacle {
            obstacle.removeFromParent()
        }
    }
    
}
