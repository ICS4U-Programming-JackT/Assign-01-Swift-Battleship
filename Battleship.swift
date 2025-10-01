import Foundation

/**
 Simple Battleship game in Swift.
 Player vs computer on a 4x4 board.
 
 Not taught:
 Arrays (1D & 2D): https://docs.swift.org/swift-book/documentation/the-swift-programming-language/arrays/
 ANSI escape color codes (for colored output): https://en.wikipedia.org/wiki/ANSI_escape_code
 */

// Constants

// Symbols for game board
let EMPTY = "0"   // Empty water
let SHIP  = "S"   // Ship
let HIT   = "X"   // Hit marker
let MISS  = "M"   // Miss marker

// ANSI color codes
let RESET  = "\u{001B}[0m"
let RED    = "\u{001B}[31m" // Hits
let GREEN  = "\u{001B}[32m" // Ships
let YELLOW = "\u{001B}[33m" // Misses
let CYAN   = "\u{001B}[36m" // Empty cells

// Game Functions

/**
 Sets up a grid of given size with a given number of ships.
 Uses a 2D array.
 */
func setupGrid(size: Int, ships: Int) -> [[String]] {
    // Create empty 2D array filled with "0"
    var grid = Array(repeating: Array(repeating: EMPTY, count: size), count: size)
    
    var placed = 0
    while placed < ships {
        // Generate random ship coordinates
        let x = Int.random(in: 0..<size)
        let y = Int.random(in: 0..<size)
        
        // Make sure ship isn't already there
        if grid[x][y] == EMPTY {
            grid[x][y] = SHIP
            placed += 1
        }
    }
    return grid
}

/**
 Displays a grid in the console.
 */
func displayGrid(_ grid: [[String]], showShips: Bool) {
    for row in grid {
        var line = ""
        for cell in row {
            var out = ""
            if !showShips && cell == SHIP {
                // Hide ships on enemy board
                out = CYAN + EMPTY + RESET
            } else if cell == SHIP {
                out = GREEN + SHIP + RESET
            } else if cell == HIT {
                out = RED + HIT + RESET
            } else if cell == MISS {
                out = YELLOW + MISS + RESET
            } else {
                out = CYAN + EMPTY + RESET
            }
            line += out + " "
        }
        print(line)
    }
}

/**
 Handles user input for row/column guesses.
 Includes validation (loops until user enters a valid number).
 */
func handleInput() -> (Int, Int) {
    var row = -1
    var col = -1
    var valid = false
    
    // Get user input repeatedly until its valid.
    // Finally with valid coordinates, valid is
    // set to true and the row + col are returned.
    while !valid {
        print("Enter row (1-4): ", terminator: "")
        if let rowStr = readLine(), let rowInt = Int(rowStr) {
            row = rowInt - 1
        }
        
        print("Enter column (1-4): ", terminator: "")
        if let colStr = readLine(), let colInt = Int(colStr) {
            col = colInt - 1
        }
        
        if row >= 0 && row < 4 && col >= 0 && col < 4 {
            valid = true
        } else {
            print("Invalid coordinates. Try again.")
        }
    }
    return (row, col)
}

/**
 Handles an attack on a given grid.
 Updates both the target grid and the view grid.
 
 Returns true if all ships on the target grid have been sunk.

 We use inout for passing by reference so that the arrays
 are changed in the scope of the function call.

 -> defines the return value datatype.
 */
func handleAttacks(targetGrid: inout [[String]], viewGrid: inout [[String]], row: Int, col: Int) -> Bool {
    if targetGrid[row][col] == SHIP {
        print(RED + "Hit!" + RESET)
        targetGrid[row][col] = HIT
        viewGrid[row][col] = HIT
    } else if targetGrid[row][col] == EMPTY {
        print(YELLOW + "Miss!" + RESET)
        targetGrid[row][col] = MISS
        viewGrid[row][col] = MISS
    }
    
    // Check if ships remain
    for row in targetGrid {
        for cell in row {
            if cell == SHIP {
                return false
            }
        }
    }
    return true
}

// Main Game Loop
func mainGame() {
    print("Welcome to Battleship!")
    print("Would you like to see the tutorial? (y/n): ", terminator: "")
    if let choice = readLine(), choice.lowercased() == "y" {
        print("""
        
        Tutorial:
        You and the computer each get a 4x4 grid.
        \(GREEN)S = Ship\(RESET), \(RED)X = Hit\(RESET), \(YELLOW)M = Miss\(RESET), \(CYAN)0 = Empty\(RESET).
        Take turns guessing enemy positions until all ships are sunk.
        Good luck!
        """)
    }
    
    // Create player + enemy grids
    var playerGrid = setupGrid(size: 4, ships: 4)
    var enemyGrid = setupGrid(size: 4, ships: 4)
    
    // Players view of enemy board (starts all empty)
    var playerViewOfEnemy = Array(repeating: Array(repeating: EMPTY, count: 4), count: 4)
    
    var gameOver = false
    
    while !gameOver {
        print("\nYour grid:")
        displayGrid(playerGrid, showShips: true)
        
        print("\nEnemy grid:")
        displayGrid(playerViewOfEnemy, showShips: false)
        
        // Player fires
        let (row, col) = handleInput()

        // We use & to pass by reference
        gameOver = handleAttacks(targetGrid: &enemyGrid, viewGrid: &playerViewOfEnemy, row: row, col: col)
        
        if gameOver {
            print(GREEN + "You win!" + RESET)
            break
        }
        
        // Computer fires randomly
        let compRow = Int.random(in: 0..<4)
        let compCol = Int.random(in: 0..<4)
        print("Enemy fires at (\(compRow + 1), \(compCol + 1))")
        
        // Using a dummy view avoids passing the same variable
        // twice as 'inout' which causes a linter error.
        var dummyView = playerGrid
        gameOver = handleAttacks(targetGrid: &playerGrid, viewGrid: &dummyView, row: compRow, col: compCol)
        
        // The dummyView copy is immediately discarded
        // after the function call as it isn't useful anymore.
        
        if gameOver {
            print(RED + "The enemy has sunk all your ships. Game over!" + RESET)
        }
    }
}

// Run the game
mainGame()
