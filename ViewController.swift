//
//  ViewController.swift
//  Mastermind
//
//  Created by Platt, Daniel on 31/10/2019.
//  Copyright © 2019 Platt, Daniel. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var gamesWonLabel: UILabel!
    @IBOutlet weak var gamesLostLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext?
    
    var score: Score?
    
    /**
     Called by GameViewController upon user winning
     */
    func handleWin() {
        addToWinsOrLoses(didWin: true)
        messageLabel.text = "You Win! Play again?"
    }
    
    /**
     Called by GameViewController upon user losing
     */
    func handleLoss(){
        addToWinsOrLoses(didWin: false)
        messageLabel.text = "You Lose! Try again?"
    }
    
    /**
     Will add 1 and update the corresponding score in memory and display
     - Parameter didWin: The tag on the corresponding button to the peg
     */
    func addToWinsOrLoses(didWin: Bool) {
        let key: String
        if didWin {
            key = "wins"
        } else {
            key = "loses"
        }
        if let oldScore = score?.value(forKey: key) as! Int16? {
            // Increment the score and save in memory context
            let newScore = oldScore.advanced(by: 1)
            score?.setValue(
                newScore,
                forKey: key
            )
            saveMemoryContext()
        } else {
            // There is no score entity created in memory yet
            if didWin {
                createScoreInMemory(wins: 1)
            } else {
                createScoreInMemory(loses: 1)
            }
        }
        updateScoreDisplay()
    }
    
    /**
     Creates the initial score entity in memory with the values passed
     - Parameter wins: The initial number of wins to create the score with
     - Parameter loses: The initial number of loses to create the score with
     */
    func createScoreInMemory(wins: Int = 0, loses: Int = 0) {
        print("Creating initial score entity in memory")
        score = NSEntityDescription
            .insertNewObject(
                forEntityName: "Score",
                into: context!
            ) as? Score
        score?.wins = Int16(wins)
        score?.loses = Int16(loses)
        saveMemoryContext()
    }
    
    /**
     Saves the memory context meaning any updated or create entities are saved
     */
    func saveMemoryContext() {
        do {
            try context?.save()
            print("Context saved")
        } catch {
            print("Failed to save context")
        }
    }
    
    /**
     Updates the display to reflect the new values from the score object
     */
    func updateScoreDisplay() {
        let wins = score?.wins ?? 0
        let loses = score?.loses ?? 0
        gamesWonLabel.text = "\(wins) game\(wins != 1 ? "s" : "")"
        gamesLostLabel.text = "\(loses) game\(loses != 1 ? "s" : "")"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = appDelegate.persistentContainer.viewContext
        // Create the request
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context?.fetch(request)
            if (results?.count)! > 0 {
                score = results?[0] as? Score
                updateScoreDisplay()
                print("Loaded saved score.")
            } else {
                print("No score stored yet")
            }
        } catch {
            print("Couldn't fetch results")
        }
    }

}

