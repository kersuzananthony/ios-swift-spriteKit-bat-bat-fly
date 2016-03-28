//
//  ObstacleGroup.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 23/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class ObstacleGroup {
    
    var obstacleGroupBottom: ObstacleGroupBottom!
    var obstacleGroupTop: ObstacleGroupTop!
    var scoreGate: ScoreGate!
    
    enum ObstaclePosition: Int {
        case Top = 1
        case Bottom = 2
    }
    
    init(screenHeight: CGFloat, difficulty: DifficultyManager) {
        let numberBoxes = Int((screenHeight - 48 - difficulty.obstacleGap) / GameManager.sharedInstance.BOX_SIZE)
        let numberBoxesTop: Int = Int(arc4random_uniform(UInt32(numberBoxes)) + 1)
        let numberBoxesBottom: Int = numberBoxes - numberBoxesTop
        
        self.obstacleGroupBottom = ObstacleGroupBottom(numberOfBoxes: numberBoxesBottom, difficulty: difficulty)
        self.obstacleGroupTop = ObstacleGroupTop(numberOfBoxes: numberBoxesTop, screenHeight: screenHeight, difficulty: difficulty)
        self.scoreGate = ScoreGate(screenHeight: screenHeight)
        self.scoreGate.setObstacleSpeed(difficulty.obstacleSpeed)
        self.scoreGate.startMoving(yPos: self.scoreGate.size.height / 2)
    }
    
    func makeCascadeExplosion(position: ObstaclePosition, box: Box) {
        if position == ObstaclePosition.Bottom {
            self.obstacleGroupBottom.makeCascadeExplosion(box)
        } else if position == ObstaclePosition.Top {
            self.obstacleGroupTop.makeCascadeExplosion(box)
        }
    }
    
    
}
