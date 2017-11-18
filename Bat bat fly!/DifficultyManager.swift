//
//  DifficultyManager.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 27/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

// Mark: -Enum of game levels
enum DifficultyLevel: String {
    case Easy = "Easy"
    case Medium = "Medium"
    case Hard = "Hard"
}

class DifficultyManager {
    
    fileprivate var _difficultyLevel: DifficultyLevel
    fileprivate var _initialObstacleSpeed: CGFloat!
    fileprivate var _obstacleSpeed: CGFloat!
    fileprivate var _obstacleGap: CGFloat!
    fileprivate var _hasReducedGap: Bool!
    
    let MAX_OBSTACLE_SPEED: CGFloat = -12
    
    var obstacleSpeed: CGFloat! {
        return self._obstacleSpeed
    }
    
    var obstacleGap: CGFloat! {
        return self._obstacleGap
    }
    
    var difficultyLevel: DifficultyLevel! {
        return self._difficultyLevel
    }
    
    init(difficultyLevel: DifficultyLevel) {
        self._difficultyLevel = difficultyLevel
        self._obstacleGap = GameManager.sharedInstance.GAP_SIZE
        //self._initialObstacleSpeed = GameManager.sharedInstance.OBSTACLES_SPEED
        //self._obstacleSpeed = GameManager.sharedInstance.OBSTACLES_SPEED
        self._hasReducedGap = false
        print("difficulty chosen \(self._difficultyLevel.rawValue)")
        
        switch self._difficultyLevel {
        case .Easy:
            self._initialObstacleSpeed = -6
            self._obstacleSpeed = -6
            break
        case .Medium:
            self._initialObstacleSpeed = -7
            self._obstacleSpeed = -7
            break
        case .Hard:
            self._initialObstacleSpeed = -8
            self._obstacleSpeed = -8
            break
        }
        
    }
    
    func getIncreaseSpeedRate() -> CGFloat {
        switch self._difficultyLevel {
        case DifficultyLevel.Easy:
            return 0.02
        case DifficultyLevel.Medium:
            return 0.05
        case DifficultyLevel.Hard:
            return 0.1
        }
    }
    
    func getReduceObstacleGapLimit() -> Int {
        switch self._difficultyLevel {
        case .Easy:
            return 100
        case .Medium:
            return 50
        case .Hard:
            return 20
        }
    }
    
    func increaseDifficulty(_ score: Int) {
        increaseSpeed()
        
        if score == getReduceObstacleGapLimit() {
            reduceObstacleGap()
        }
    }
    
    func reduceObstacleGap() {
        if !self._hasReducedGap {
            let boxSize = GameManager.sharedInstance.BOX_SIZE
            self._obstacleGap = self._obstacleGap - boxSize
            self._obstacleSpeed = self._initialObstacleSpeed
            self._hasReducedGap = true
        }
    }
    
    func increaseSpeed() {
        
        if self._obstacleSpeed - getIncreaseSpeedRate() < self.MAX_OBSTACLE_SPEED {
            self._obstacleSpeed = self.MAX_OBSTACLE_SPEED
        } else {
            self._obstacleSpeed = self._obstacleSpeed - getIncreaseSpeedRate()
        }
        
        
        print("speed \(self.obstacleSpeed)")
    }
    
}
