//
//  GameManager.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 20/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit
import GameKit

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
    let COLLIDER_SCORE_GATE: UInt32 = 1 << 4
    
    // Obstacles speed
    let OBSTACLES_SPEED: CGFloat = -6
    let CHAIN_SPEED: CGFloat = -4
    
    // Sizes
    let BOX_SIZE: CGFloat = 90
    let GAP_SIZE: CGFloat = 300
    
    // Constants
    let PLAYER_BEST_SCORE = "playerBestScore"
    
    // MARK: -Get local best score
    func getPlayerBestScore() -> Int {
        if let playBestScore = NSUserDefaults.standardUserDefaults().valueForKey(self.PLAYER_BEST_SCORE) as? Int {
            return playBestScore
        } else {
            return 0
        }
    }
    
    func setPlayerBestScore(score: Int) {
        let currentBestScore: Int = self.getPlayerBestScore()
        
        if score > currentBestScore {
            NSUserDefaults.standardUserDefaults().setValue(score, forKey: self.PLAYER_BEST_SCORE)
            
            let leaderboardID = "batBatFlyScore"
            let sScore = GKScore(leaderboardIdentifier: leaderboardID)
            sScore.value = Int64(score)
            
            let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
            
            GKScore.reportScores([sScore], withCompletionHandler: { (error: NSError?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Score submitted")
                    
                }
            })

        }
    }
    
    var boxTexture : SKTexture {
        return SKTexture(imageNamed: "box-explode-0")
    }
    
    var boxExplodeAnimationTexture: [SKTexture] {
        
        var boxExplosionFrames = [SKTexture]()
        
        for var i = 0; i <= 7; i++ {
            boxExplosionFrames.append(SKTexture(imageNamed: "box-explode-\(i)"))
        }
        
        return boxExplosionFrames
    }
    
    var trapDown : SKTexture {
        return SKTexture(imageNamed: "trap-bottom")
    }
    
    var trapDownCloseAnimationTexture: [SKTexture] {
        var animationTextures = [SKTexture]()
        
        for var i = 1; i <= 2; i++ {
            animationTextures.append(SKTexture(imageNamed: "trap-bottom-animation-\(i)"))
        }
        
        return animationTextures
    }
    
    struct Texture {
        
        
        
        
    }
    
}
