//
//  ObstacleGroupTop.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 23/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class ObstacleGroupTop: NSObject {
    
    var obstacles: [Obstacle] = [Obstacle]()
    
    // MARK: - Initialize all item for ObstacleGroupTop
    init(numberOfBoxes: CGFloat, screenHeight: CGFloat, difficulty: DifficultyManager) {
        
        for var j: CGFloat = 0; j < numberOfBoxes; j++ {
            let boxNode = Box()
            let yPos: CGFloat = (screenHeight - 48 - boxNode.size.height / 2) - boxNode.size.height * j
            boxNode.setObstacleSpeed(difficulty.obstacleSpeed)
            boxNode.startMoving(yPos: yPos)
            self.obstacles.append(boxNode)
            
            if j + 1 == numberOfBoxes {
                let trapTopNode = TrapUp()
                trapTopNode.setObstacleSpeed(difficulty.obstacleSpeed)
                trapTopNode.startMoving(yPos: yPos - boxNode.size.height / 2)
                self.obstacles.append(trapTopNode)
            }
        }

    }

    // MARK: - This function is called by ObstacleGroup:makeCascadeExplosion() method
    func makeCascadeExplosion(box: Box) {
        if let boxIndex = self.obstacles.indexOf(box) {
            var loopCount: Int = 0
            // We got the index
            for var i = boxIndex; i < self.obstacles.count; i++ {
                if let boxInObstaclesArray = self.obstacles[i] as? Box {
                    let time = NSTimeInterval(0.4 * Double(loopCount))
                    _ = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "makeItemExplode:", userInfo: boxInObstaclesArray, repeats: false)

                    
                    if let obstacle = self.obstacles[i + 1] as? Obstacle {
                        obstacle.makeItDynamic()
                    }
                    
                    loopCount++
                }
            }
        }
    }
    
    // MARK: - This function is called by the NSTimeInterval in makeCascadeExplosion
    func makeItemExplode(sender: NSTimer) {
        if let box = sender.userInfo as? Box {
            box.playBoxExplodedAnimation()
        }
    }

    
}
