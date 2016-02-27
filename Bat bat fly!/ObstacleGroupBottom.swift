//
//  ObstacleGroupBottom.swift
//  Bat bat fly!
//
//  Created by Kersuzan on 23/01/2016.
//  Copyright © 2016 Kersuzan. All rights reserved.
//

import SpriteKit

class ObstacleGroupBottom: NSObject {
 
    var obstacles: [Obstacle] = [Obstacle]()
    
    init(numberOfBoxes: CGFloat, difficulty: DifficultyManager) {
        // Put box on the bottom
        for var i: CGFloat = 0; i < numberOfBoxes; i++ {
            let boxNode = Box()
            let yPos: CGFloat = boxNode.size.height / 2 + boxNode.size.height * i
            boxNode.setObstacleSpeed(difficulty.obstacleSpeed)
            boxNode.startMoving(yPos: yPos)
            self.obstacles.append(boxNode)
            
            if i + 1 == numberOfBoxes {
                let trapBottomNode = TrapDown()
                trapBottomNode.setObstacleSpeed(difficulty.obstacleSpeed)
                trapBottomNode.startMoving(yPos: yPos + boxNode.size.height / 2)
                self.obstacles.append(trapBottomNode)
            }
        }
    }
    
    func makeCascadeExplosion(box: Box) {
        if let boxIndex = self.obstacles.indexOf(box) {
            for obstacle in self.obstacles {
                obstacle.makeItDynamic()
            }
            
            var loopCount: Int = 0
            // We got the index
            for var i = boxIndex; i < self.obstacles.count; i++ {
                if let boxInObstaclesArray = self.obstacles[i] as? Box {
                    let time = NSTimeInterval(0.3 * Double(loopCount))
                    _ = NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "makeItemExplode:", userInfo: boxInObstaclesArray, repeats: false)
                    loopCount++
                }
            }
        }
    }
    
    func makeItemExplode(sender: NSTimer) {
        if let box = sender.userInfo as? Box {
            box.playBoxExplodedAnimation()
        }
    }
    
}
