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
    
    init(numberOfBoxes: Int, difficulty: DifficultyManager) {
        // Put box on the bottom
        for i: Int in 0 ..< numberOfBoxes {
            let boxNode = Box()
            let yPos: CGFloat = boxNode.size.height / 2 + boxNode.size.height * CGFloat(i)
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
    
    func makeCascadeExplosion(_ box: Box) {
        if let boxIndex = self.obstacles.index(of: box) {
            for obstacle in self.obstacles {
                obstacle.makeItDynamic()
            }
            
            var loopCount: Int = 0
            // We got the index
            for i in boxIndex ..< self.obstacles.count {
                if let boxInObstaclesArray = self.obstacles[i] as? Box {
                    let time = TimeInterval(0.3 * Double(loopCount))
                    _ = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(ObstacleGroupBottom.makeItemExplode(_:)), userInfo: boxInObstaclesArray, repeats: false)
                    loopCount += 1
                }
            }
        }
    }
    
    @objc func makeItemExplode(_ sender: Timer) {
        if let box = sender.userInfo as? Box {
            box.playBoxExplodedAnimation()
        }
    }
    
}
