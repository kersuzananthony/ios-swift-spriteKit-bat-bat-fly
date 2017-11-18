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
    
    let textureAtlas = TEXTURE_ATLAS
    
    //Colliders
    let COLLIDER_GROUND: UInt32 = 1 << 0
    let COLLIDER_TRAP: UInt32 = 1 << 1
    let COLLIDER_BOMB: UInt32 = 1 << 2
    let COLLIDER_PLAYER: UInt32 = 1 << 3
    let COLLIDER_SCORE_GATE: UInt32 = 1 << 4
    
    // speed
    let BACKGROUND_SPEED: CGFloat = -2
    let CHAIN_SPEED: CGFloat = -4
    
    // Sizes
    let BOX_SIZE: CGFloat = 90
    let GAP_SIZE: CGFloat = 300
    
    // Constants
    let PLAYER_BEST_SCORE_EASY = "playerBestScoreEasy"
    let PLAYER_BEST_SCORE_MEDIUM = "playerBestScoreMedium"
    let PLAYER_BEST_SCORE_HARD = "playerBestScoreHard"
    let PLAYER_SOUND_PREFERENCE = "playerSoundPreference"
    let PLAYER_PLAY_GAME_TIME = "playerPlayGameNumberTime"
    let LEADERBOARD_EASY = "grp.batBatFlyLeaderboardId"
    let LEADERBOARD_MEDIUM = "grp.batBatFlyLeaderboardMedium"
    let LEADERBOARD_HARD = "grp.batBatFlyLeaderboardHard"
    
    // MARK: - Return how many times the player has played to the game
    func getHowManyPlayerPlayedGame() -> Int {
        if let numberTime = UserDefaults.standard.value(forKey: self.PLAYER_PLAY_GAME_TIME) as? Int {
            return numberTime
        } else {
            return 0
        }
    }
    
    // MARK: - Store the number of times the player has played
    func setHowManyPlayerPlayerGame(_ playTime: Int) {
        UserDefaults.standard.setValue(playTime, forKey: self.PLAYER_PLAY_GAME_TIME)
    }
    
    // MARK: - Store the user's preference concerning the sounds
    func getPlayerSoundPreference() -> Bool {
        if let playerSoundPreference = UserDefaults.standard.value(forKey: self.PLAYER_SOUND_PREFERENCE) as? Bool {
            return playerSoundPreference
        } else {
            return true
        }
    }
    
    // MARK: - Set the user preference
    func setPlayerSoundPreference(_ soundPreference: Bool) {
        UserDefaults.standard.setValue(soundPreference, forKey: self.PLAYER_SOUND_PREFERENCE)
    }
    
    // MARK: -Get local best score
    func getPlayerBestScore(_ difficulty: DifficultyLevel) -> Int {
        if difficulty == DifficultyLevel.Easy {
            if let playBestScore = UserDefaults.standard.value(forKey: self.PLAYER_BEST_SCORE_EASY) as? Int {
                return playBestScore
            } else {
                return 0
            }
        } else if difficulty == DifficultyLevel.Medium {
            if let playBestScore = UserDefaults.standard.value(forKey: self.PLAYER_BEST_SCORE_MEDIUM) as? Int {
                return playBestScore
            } else {
                return 0
            }
        } else if difficulty == DifficultyLevel.Hard {
            if let playBestScore = UserDefaults.standard.value(forKey: self.PLAYER_BEST_SCORE_HARD) as? Int {
                return playBestScore
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    // MARK: - if the current score is greater than the previous best score, we store it locally and we send a request to the GameCenter
    func setPlayerBestScore(_ score: Int, difficulty: DifficultyLevel) {
        let currentBestScore: Int = self.getPlayerBestScore(difficulty)
        
        if score > currentBestScore {
            var leaderboardId: String = ""
            if difficulty == DifficultyLevel.Easy {
                UserDefaults.standard.setValue(score, forKey: self.PLAYER_BEST_SCORE_EASY)
                leaderboardId = self.LEADERBOARD_EASY
            } else if difficulty == DifficultyLevel.Medium {
                UserDefaults.standard.setValue(score, forKey: self.PLAYER_BEST_SCORE_MEDIUM)
                leaderboardId = self.LEADERBOARD_MEDIUM
            } else if difficulty == DifficultyLevel.Hard {
                UserDefaults.standard.setValue(score, forKey: self.PLAYER_BEST_SCORE_HARD)
                leaderboardId = self.LEADERBOARD_HARD
            }
            
            //let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
            //let sScore = GKScore(leaderboardIdentifier: leaderboardID, player: localPlayer)
            
            let sScore = GKScore(leaderboardIdentifier: leaderboardId)
            
            sScore.value = Int64(score)
        
            GKScore.report([sScore], withCompletionHandler: { (error: Error?) -> Void in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Score submitted")
                    
                }
            })
        }
    }
    
    
    var chainTexture: SKTexture {
        let chainNumber = arc4random_uniform(3) + 1
        return self.textureAtlas.textureNamed("chain-\(chainNumber)")
    }
    
    var trapDown: SKTexture!
    var trapTop: SKTexture!
    var boxTexture: SKTexture!
    var batTexture: SKTexture!
    var trapDownCloseAnimationTexture: [SKTexture] = [SKTexture]()
    var trapTopCloseAnimationTexture: [SKTexture] = [SKTexture]()
    var boxExplodeAnimationTexture: [SKTexture] = [SKTexture]()
    var batExplodeAnimationTexture: [SKTexture] = [SKTexture]()
    var batFlyingAnimationTexture: [SKTexture] = [SKTexture]()
    
    // MARK: -Function called when the user launch the app.
    func preloadTextures(_ completed: Completed) {
    
        self.trapDown = textureAtlas.textureNamed("trap-bottom")
        self.trapTop = textureAtlas.textureNamed("trap-top")
    
        for i in 1...2 {
            self.trapDownCloseAnimationTexture.append(textureAtlas.textureNamed("trap-bottom-animation-\(i)"))
        }
        
        for i in 1...2 {
            self.trapTopCloseAnimationTexture.append(textureAtlas.textureNamed("trap-top-animation-\(i)"))
        }
        
        for i in 0...7 {
            self.boxExplodeAnimationTexture.append(self.textureAtlas.textureNamed("box-explode-\(i)"))
        }
        
        for i in 0...6 {
            self.batExplodeAnimationTexture.append(self.textureAtlas.textureNamed("bat-explode-\(i)"))
        }
        
        for i in 1...6 {
            self.batFlyingAnimationTexture.append(self.textureAtlas.textureNamed("bat-fly-\(i)"))
        }
        
        self.boxTexture = self.textureAtlas.textureNamed("box-explode-0")
        self.batTexture = self.textureAtlas.textureNamed("bat-fly-1")
        
        completed()
    }
    
}
