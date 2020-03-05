//
//  GameViewController.swift
//  Mastermind
//
//  Created by Platt, Daniel on 31/10/2019.
//  Copyright © 2019 Platt, Daniel. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let feedbackSymbolWidth = 15
    let pegWidth = 50
    let feedbackSymbolPositions = [
        (x: 250, y: 10),
        (x: 270, y: 10),
        (x: 250, y: 30),
        (x: 270, y: 30)
    ]
    
    enum colourPeg: String {
        case blue = "blue-peg"
        case green = "green-peg"
        case grey = "grey-peg"
        case orange = "orange-peg"
        case red = "red-peg"
        case yellow = "yellow-peg"
    }
    
    typealias Feedback = (
        pegs: [colourPeg],
        // Number of pegs that are the correct colour and position
        numCorrectColAndPos: Int,
        // Number of pegs that are the correct colour but wrong position
        numCorrectColWrongPos: Int
    )
    
    // The computer generated set of 4 pegs the user has to guess
    var pegsToGuess: [colourPeg] = []
    // The current pegs the user has inputted
    var pushedPegs: [colourPeg] = []
    // The UIImageViews for the current pegs the user has inputted
    var pushedPegImages: [UIImageView] = []
    // Array containing the feedback displayed in the table cells
    var feedbackArray: [Feedback] = []

    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var feedbackTableView: UITableView!
    
    /**
     Gets the selected peg by it's tag and pushes it
     */
    @IBAction func colourButtonClick(_ sender: UIButton) {
        let myPeg = getColourPeg(tag: sender.tag)
        pushPeg(peg: myPeg)
    }
    
    /**
     Pops the most recently entered peg
     */
    @IBAction func deleteButtonClick(_ sender: UIButton) {
        popPeg()
    }
    
    /**
     Upon clicking ok the inputted guess is processed
     */
    @IBAction func oKButtonClick(_ sender: Any) {
        processGuess()
    }
    
    /**
     Handles the user's guess and updates game to reflect the guess
     */
    func processGuess() {
        guard pushedPegs.count == 4 else {return}
        
        let result = calcGuessResult()

        // Add feedback to array of feedback so that it can
        // be rendered by the tableView
        feedbackArray.append((
            pegs: pushedPegs,
            numCorrectColAndPos: result.numCorrectColAndPos,
            numCorrectColWrongPos: result.numCorrectColWrongPos
        ))
        
        addNewRowToTable()
        clearGuessInput()
        
        if (result.numCorrectColAndPos == 4) {
            // If the result has 4 correctly postioned pegs
            winGame()
        } else if (feedbackArray.count >= 10) {
            // If the user has guessed 10 times
            loseGame()
        }
    }
    
    /**
     Add new row to the tableView and scroll down to view it
     */
    func addNewRowToTable() {
        feedbackTableView.beginUpdates()
        feedbackTableView.insertRows(at: [
            IndexPath(
                row: feedbackArray.count - 1,
                section: 0
            )
        ], with: .automatic)
        feedbackTableView.endUpdates()
        scrollToBottomOfTable()
    }
    
    /**
     Clear the current guessed peg input imageViews and array
     */
    func clearGuessInput() {
        pushedPegs = [];
        pushedPegImages.forEach { (imageView) in
            imageView.removeFromSuperview()
        }
        pushedPegImages = []
    }
    
    /**
     Reads the user's guess and returns the result
     - Returns: A tuple with the number of pegs in the correct position and colour
                and the number of pegs in the correct colour but wrong position
     */
    func calcGuessResult() -> (
        numCorrectColAndPos: Int,
        numCorrectColWrongPos: Int
    ) {
        var numCorrectColAndPos = 0
        var numCorrectColWrongPos = 0
        // Duplicating arrays so they aren't altered
        var guessedPegs = pushedPegs
        var correctPegs = pegsToGuess
        
        // Count all pegs that the user has guessed the position
        // and colour of correctly and remove them from both arrays
        var position = 0
        while position < guessedPegs.count {
            if correctPegs[position] == guessedPegs[position] {
                numCorrectColAndPos += 1
                guessedPegs.remove(at: position)
                correctPegs.remove(at: position)
                position -= 1
            }
            position += 1
        }
        
        // For the remaining pegs, check each guess and see if
        // the colour is included anywhere in the correct pegs array.
        // If it is, add to the count and remove the peg from the
        // correct pegs array and move onto the next guessed peg
        for guessedPeg in guessedPegs {
            var position = 0
            while position < correctPegs.count {
                 if guessedPeg == correctPegs[position] {
                     numCorrectColWrongPos += 1
                     correctPegs.remove(at: position)
                     break
                 }
                 position += 1
             }
        }
        
        return (
            numCorrectColAndPos: numCorrectColAndPos,
            numCorrectColWrongPos: numCorrectColWrongPos
        )
    }
    
    /**
     Returns the number of feedback rows which decides the length of the table
     */
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return feedbackArray.count
    }
    
    /**
     Returns the cell to display in the table with the
     corresponding feedback images given the index of the cell
     */
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = UITableViewCell(
            style: UITableViewCell.CellStyle.default,
            reuseIdentifier: "feedbackCell"
        )
        
        // Adding the guessed peg images to the cell
        for position in 0...3 {
            let pegAssetName = feedbackArray[indexPath.row].pegs[position].rawValue
            _ = addPegToView(
                assetName: pegAssetName,
                position: position,
                view: cell
            )
        }
        
        // Adding the feedback black and white symbols to the cell
        var position = 0
        // Adding correct postion and colour black symbols
        for _ in 0..<feedbackArray[indexPath.row].numCorrectColAndPos {
            _ = addFeedbackSymbolToView(
                assetName: "black-symbol",
                position: position,
                view: cell
            )
            position += 1
        }
        // Adding correct colour, wrong postion white symbols
        for _ in 0..<feedbackArray[indexPath.row].numCorrectColWrongPos {
            _ = addFeedbackSymbolToView(
                assetName: "white-symbol",
                position: position,
                view: cell
            )
            position += 1
        }

        return cell
    }
    
    /**
     Adds a specified peg image to the given view at the given position
     - Parameter assetName: The name of the peg asset to display
     - Parameter position: The position (0-3) the peg should be displayed at
     - Parameter view: The view to add the peg to
     - Returns: The created imageView of the peg
     */
    func addPegToView(
        assetName: String,
        position: Int,
        view: UIView
    ) -> UIImageView {
        let image = UIImage(named: assetName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(
            x: 10 * (position + 1) + pegWidth * position,
            y: 5,
            width: pegWidth,
            height: pegWidth
        )
        view.addSubview(imageView)
        return imageView
    }
    
    /**
     Adds a specified symbol image to the given view at the given position
     - Parameter assetName: The name of the symbol asset to display
     - Parameter position: The position (0-3) the symbol should be displayed at
     - Parameter view: The view to add the symbol to
     - Returns: The created imageView of the peg
     */
    func addFeedbackSymbolToView(
        assetName: String,
        position: Int,
        view: UIView
    ) -> UIImageView {
        let image = UIImage(named: assetName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(
            x: feedbackSymbolPositions[position].x,
            y: feedbackSymbolPositions[position].y,
            width: feedbackSymbolWidth,
            height: feedbackSymbolWidth
        )
        view.addSubview(imageView)
        return imageView
    }
    
    /**
     Scrolls the table view down to dispay the lowest cell
     */
    func scrollToBottomOfTable() {
        let indexPath = IndexPath(
            row: feedbackArray.count-1,
            section: 0
        )
        feedbackTableView.scrollToRow(
            at: indexPath,
            at: .bottom, animated: true
        )
    }
    
    /**
     Adds the peg to the array of inputted pegs and the image to the input view
     - Parameter peg: coolourPeg enum of the peg to be added
     */
    func pushPeg(peg: colourPeg) {
        let position = pushedPegs.count
        guard position < 4 else {return}
        
        let imageView = addPegToView(
            assetName: peg.rawValue,
            position: position,
            view: typeView
        )
        pushedPegImages.append(imageView)
        pushedPegs.append(peg)
    }
    
    /**
     Removes the most recently inputted peg from the logic and view
     */
    func popPeg() {
        _ = pushedPegs.popLast()
        pushedPegImages.popLast()?.removeFromSuperview()
    }
    
    /**
     Gets a colourPeg enum corresponding to the button's tag
     - Parameter tag: The tag on the corresponding button to the peg
     - Returns: The enum corresponding to the button's tag
     */
    func getColourPeg(tag: Int) -> colourPeg {
        switch (tag) {
        case 0:
            return colourPeg.blue
        case 1:
            return colourPeg.green
        case 2:
            return colourPeg.grey
        case 3:
            return colourPeg.orange
        case 4:
            return colourPeg.red
        default:
            return colourPeg.yellow
        }
    }
    
    /**
     Closes the game and informs the menu view controller that the user won the game
     */
    func winGame() {
        if let presenter = presentingViewController as? ViewController {
             presenter.handleWin()
        }
        exitGame()
    }
    
    /**
     Closes the game and informs the menu view controller that the user lost the game
     */
    func loseGame() {
        if let presenter = presentingViewController as? ViewController {
            presenter.handleLoss()
        }
        exitGame()
    }
    
    /**
     Dismisses the modal
     */
    func exitGame() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generating the array of colourPeg enums the user must guess
        for _ in 1...4 {
            let rand = Int.random(in: 0...5)
            pegsToGuess.append(getColourPeg(tag: rand))
        }
        
        print(pegsToGuess) // For testers and cheaters
    }
    
}
