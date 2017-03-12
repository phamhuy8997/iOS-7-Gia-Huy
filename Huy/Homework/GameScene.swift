//
//  GameScene.swift
//  SwiftLearning
//
//  Created by Huy Pham on 2/25/17.
//  Copyright © 2017 Huy Pham. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Physicscategory {
    static let fly : UInt32 = 1
    static let player : UInt32 = 2
    static let playerBullets : UInt32 = 3
    static let flyBullets : UInt32 = 4
    
}


class GameScene: SKScene , SKPhysicsContactDelegate {
    
    let playerNode  = SKSpriteNode(imageNamed: "player-1.png")
    let flyNode = SKSpriteNode(imageNamed: "fly-1-1.png")
    let xFly : CGFloat = 100
    let flyWidth : CGFloat = 20
    let flySpace : CGFloat = 20
    let screenSize = UIScreen.main.bounds
    var flies : [SKSpriteNode] = []
    
    var starfield:SKEmitterNode!
    var scoreLabel:SKLabelNode!
    var healthLabel:SKLabelNode!
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
//    var health:Int = 100 {
//        didSet {
//            healthLabel.text = "Health: \(health)"
//        }
//    }
    
    
    var playerBullets: [SKSpriteNode] = []
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        
        addPlayer()
        addFlies()
        configPhysics()
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: 65, y: self.frame.size.height - 40)
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = UIColor.red
        
        healthLabel = SKLabelNode(text: "Health: 100")
        healthLabel.position = CGPoint(x: 65, y: self.frame.size.height - 70)
        healthLabel.fontSize = 25
        healthLabel.fontColor = UIColor.red
        
        score = 0
        //health = 100
        
        self.addChild(scoreLabel)
        //self.addChild(healthLabel)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(playerShoot), SKAction.wait(forDuration: 1.0)])))
        
    }
    func configPhysics() -> Void {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let nodeA = bodyA.node
        let nodeB = bodyB.node
        
        if ((bodyA.categoryBitMask == Physicscategory.fly) && (bodyB.categoryBitMask == Physicscategory.playerBullets) || (bodyA.categoryBitMask == Physicscategory.playerBullets) && (bodyB.categoryBitMask == Physicscategory.fly))   {
            nodeA?.removeFromParent()
            nodeB?.removeFromParent()
            score += 2
        } else {
        
            if ((bodyA.categoryBitMask == Physicscategory.flyBullets) && (bodyB.categoryBitMask == Physicscategory.player) || (bodyA.categoryBitMask == Physicscategory.player) && (bodyB.categoryBitMask == Physicscategory.flyBullets)) {
            //health -= 1
            self.view?.presentScene(SKScene(fileNamed: "galaga-logo.png"))
            }
        }
        
    }
    
    func addPlayer() -> Void {
        playerNode.size = CGSize(width: self.size.width / 10, height: self.size.height / 15)
        playerNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 10)
        playerNode.physicsBody?.collisionBitMask = 0
        playerNode.physicsBody?.linearDamping = 0
        playerNode.physicsBody?.categoryBitMask = Physicscategory.player
        playerNode.physicsBody?.contactTestBitMask = Physicscategory.flyBullets
        
        addChild(playerNode)
    }
    
    func addFlies() -> Void {
        let flyXMid : CGFloat = size.width / 2
        let flyIndexMid : CGFloat = 2
        flyNode.size = CGSize(width: self.size.width / 12, height: self.size.height / 17)
        
        for flyIndex in 0..<5 {
            for flyIndex1 in 0..<2 {
                let SPACE = flyWidth + flySpace
                let flyX : CGFloat = flyXMid + (CGFloat(flyIndex) - flyIndexMid) * SPACE
                let flyY : CGFloat = size.height
                
                let flyNode = SKSpriteNode(imageNamed: "fly-1-1.png")
                flyNode.anchorPoint = CGPoint(x: 0.5, y: 1)
                flyNode.position = CGPoint(x: flyX, y: flyY - CGFloat(flyIndex1)*50)
                
                var action = [SKAction]()
                action.append(SKAction.run {
                    self.flyShoot(flyShootX: flyNode.position.x, flyShootY: flyNode.position.y)
                })
                action.append(SKAction.moveTo(x:  flyNode.position.x + 50, duration: 3))
                action.append(SKAction.run {
                    self.flyShoot(flyShootX: flyNode.position.x, flyShootY: flyNode.position.y)
                })
                action.append(SKAction.moveTo(x: flyNode.position.x - 50, duration: 3))
                action.append(SKAction.run {
                    self.flyShoot(flyShootX: flyNode.position.x, flyShootY: flyNode.position.y)
                })
                flyNode.run(SKAction.repeatForever(SKAction.sequence(action)))
                
                flyNode.physicsBody = SKPhysicsBody(rectangleOf: flyNode.size)
                flyNode.physicsBody?.collisionBitMask = 0
                flyNode.physicsBody?.linearDamping = 0
                flyNode.physicsBody?.categoryBitMask = Physicscategory.fly
                flyNode.physicsBody?.contactTestBitMask = Physicscategory.playerBullets
                flyNode.physicsBody?.velocity = CGVector(dx: 0, dy: -40)
                
                addChild(flyNode)
                flies.append(flyNode)
            }
        }
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let location = firstTouch.location(in: self)
            print(location)
            playerNode.position = location
        }
        
    }
    
    var startTime: TimeInterval = -1
    var startTime1: TimeInterval = -1
    
    override func update(_ currentTime: TimeInterval) {
        
        if startTime == -1 {
            startTime = currentTime
        }
        
        if startTime1 == -1.5 {
            startTime1 = currentTime
        }
        
        if currentTime - startTime1 > 6 {
            addFlies()
            startTime1 = currentTime
        }
        
        if currentTime - startTime > 0.4 {
            playerShoot()
            startTime = currentTime
        }
        
        self.enumerateChildNodes(withName: FLY_BULLET_NAME) {
            node, pointer in
            if node.position.y > self.size.height {
                node.removeFromParent()
            }
        }
        
        
        for playerBullets in self.playerBullets {
            if playerBullets.position.y > self.size.height {
                playerBullets.removeFromParent()
            }
        }
        
        self.playerBullets = playerBullets.filter {
            node in
            return node.parent != nil
        }
        self.flies = flies.filter {
            node in
            return node.parent != nil
        }
        
        
    }
    
    let PLAYER_BULLET_NAME = "Player bullets"
    let FLY_BULLET_NAME = "Fly bullets"
    
    func playerShoot() -> Void {
        let bulletNode = SKSpriteNode(imageNamed: "bullet-2.png")
        bulletNode.size = CGSize(width: 8, height: 13)
        bulletNode.name = PLAYER_BULLET_NAME
        bulletNode.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + playerNode.size.height)
        bulletNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        bulletNode.physicsBody = SKPhysicsBody(rectangleOf: bulletNode.size)
        bulletNode.physicsBody?.categoryBitMask = Physicscategory.playerBullets
        bulletNode.physicsBody?.contactTestBitMask = Physicscategory.fly
        bulletNode.physicsBody?.collisionBitMask = 0
        bulletNode.physicsBody?.velocity = CGVector(dx: 0, dy: 500)
        bulletNode.physicsBody?.linearDamping = 0
        bulletNode.physicsBody?.mass = 0
        
        addChild(bulletNode)
        playerBullets.append(bulletNode)
    }
    func flyShoot(flyShootX: CGFloat, flyShootY: CGFloat) -> Void {
        let bulletNodeOfFly = SKSpriteNode(imageNamed: "bullet-1.png")
        bulletNodeOfFly.size = CGSize(width: 10, height: 12)
        bulletNodeOfFly.zRotation = CGFloat(M_PI / 1)
        bulletNodeOfFly.position = CGPoint(x: flyShootX, y: flyShootY)
        bulletNodeOfFly.physicsBody = SKPhysicsBody(rectangleOf: bulletNodeOfFly.size)
        bulletNodeOfFly.physicsBody?.collisionBitMask = 0
        bulletNodeOfFly.physicsBody?.categoryBitMask = Physicscategory.flyBullets
        bulletNodeOfFly.physicsBody?.contactTestBitMask = Physicscategory.player
        bulletNodeOfFly.physicsBody?.velocity = CGVector(dx: 0, dy: -100)
        bulletNodeOfFly.physicsBody?.linearDamping = 0
        bulletNodeOfFly.physicsBody?.mass = 0
        //bulletNodeOfFly.run(SKAction.move(to: playerNode.position, duration: 1))
        
        addChild(bulletNodeOfFly)
        flies.append(bulletNodeOfFly)
    }
    
}
