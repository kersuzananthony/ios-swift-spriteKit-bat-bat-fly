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
    init(numberOfBoxes: Int, screenHeight: CGFloat, difficulty: DifficultyManager) {
        
        for j: Int in 0 ..< numberOfBoxes {
            let boxNode = Box()
            let yPos: CGFloat = (screenHeight - 48 - boxNode.size.height / 2) - boxNode.size.height * CGFloat(j)
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
    func makeCascadeExplosion(_ box: Box) {
        if let boxIndex = self.obstacles.index(of: box) {
            var loopCount: Int = 0
            // We got the index
            for i in boxIndex ..< self.obstacles.count {
                if let boxInObstaclesArray = self.obstacles[i] as? Box {
                    let time = TimeInterval(0.4 * Double(loopCount))
                    _ = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(ObstacleGroupTop.makeItemExplode(_:)), userInfo: boxInObstaclesArray, repeats: false)

                    if obstacles.count >= i + 2 {
                        let obstacle = self.obstacles[i + 1]
                        obstacle.makeItDynamic()
                    }
                    
                    loopCount += 1
                }
            }
        }
    }
    
    // MARK: - This function is called by the NSTimeInterval in makeCascadeExplosion
    func makeItemExplode(_ sender: Timer) {
        if let box = sender.userInfo as? Box {
            box.playBoxExplodedAnimation()
        }
    }

    
}
