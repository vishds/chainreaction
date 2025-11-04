package main

import rl "vendor:raylib"
import "core:fmt"

field :: struct {
    owner : int,
    level : int,
    max_level: int,
}

main :: proc() {
    screenWidth     : i32 = 1280
    screenHeight    : i32 = 720

    pottiyondirikka : bool = false

    numRows : i32 = 16
    numCols : i32 = 32

    state : [16][32]field

    for i in 0..<numRows {
        for j in 0..<numCols {
            state[i][j].max_level = 3
            if i == 0 || i == numRows-1 {
                state[i][j].max_level -= 1
            }
            if j == 0 || j == numCols-1 {
                state[i][j].max_level -= 1
            }
        }
    }

    numPlayers := 3
    colors := [?]rl.Color{rl.WHITE, rl.RED, rl.GREEN, rl.BLUE}
    currentPlayer := 1

    row : i32 = 0
    col : i32 = 0

    rl.SetConfigFlags({.WINDOW_RESIZABLE})
    rl.InitWindow(screenWidth, screenHeight, "Chain Reaction")
    rl.SetTargetFPS(60)
    for !rl.WindowShouldClose() {
        screenWidth = rl.GetScreenWidth()
        screenHeight = rl.GetScreenHeight()

        rowHeight   := screenHeight / (numRows+2)
        rowWidth    := screenWidth / (numCols+2)

        rl.BeginDrawing()
        rl.ClearBackground(rl.BLACK)

        xmargin := rowWidth
        ymargin := rowHeight

        for i in 0..=numRows {
            yidx := ymargin+(i*rowHeight)
            rl.DrawLine(xmargin, yidx, xmargin+(numCols*rowWidth), yidx, rl.WHITE)
        }
        for i in 0..=numCols {
            xidx := xmargin+(i*rowWidth)
            rl.DrawLine(xidx, ymargin, xidx, ymargin+(numRows*rowHeight), rl.WHITE)
        }
        
        mousePos := rl.GetMousePosition()
        cp := fmt.caprintf("Current Player: %d", currentPlayer)
        rl.DrawText(cp, 0, 0, 20, colors[currentPlayer])
        if rl.IsMouseButtonPressed(.LEFT) {
            mousePos := rl.GetMousePosition()
            col = (i32(mousePos.x) / rowWidth) - 1
            row = (i32(mousePos.y) / rowHeight) - 1
            if row < numRows && row >= 0 && col < numCols && col >= 0 {
                if state[row][col].owner == currentPlayer || state[row][col].owner == 0 {
                    state[row][col].owner = currentPlayer
                    state[row][col].level += 1
                    currentPlayer += 1
                    if currentPlayer > numPlayers {
                        currentPlayer = 1
                    }
                }
            }
        }

        radius := f32(min(rowWidth, rowHeight)) / 2 - 2
        radius  = radius/2
        for i in 0..<numRows {
            for j in 0..<numCols {
                if state[i][j].owner > 0 {
                    x := (j+1)*rowWidth + rowWidth/2
                    y := (i+1)*rowHeight + rowHeight/2
                    pColor := colors[state[i][j].owner]
                    switch state[i][j].level {
                    case 1:
                        rl.DrawCircle(x, y, radius, pColor)
                    case 2:
                        rl.DrawCircle(x-rowWidth/4, y, radius, pColor)
                        rl.DrawCircle(x+rowWidth/4, y, radius, pColor)
                    case 3:
                        rl.DrawCircle(x, y - rowHeight/4, radius, pColor)
                        rl.DrawCircle(x-rowWidth/4, y + rowHeight/4, radius, pColor)
                        rl.DrawCircle(x+rowWidth/4, y + rowHeight/4, radius, pColor)
                    }
                }
            }
        }

        for i in 0..<numRows {
            for j in 0..<numCols {
                if state[i][j].level > state[i][j].max_level {
                    player := state[i][j].owner
                    state[i][j].level = 0
                    state[i][j].owner = 0
                    switch state[i][j].max_level {
                    case 1: // corner cases
                        i1, i2, j1, j2: i32
                        if i == 0 {
                            i1, i2 = 0, 1
                        } else {
                            i1, i2 = numRows-1, numRows-2
                        }
                        if j == 0 {
                            j1, j2 = 1, 0
                        } else {
                            j1, j2 = numCols-2, numCols-1
                        }
                        state[i1][j1].level += 1
                        state[i1][j1].owner = player
                        state[i2][j2].level += 1
                        state[i2][j2].owner = player
                    case 2:
                        i1, i2, i3, j1, j2, j3: i32
                        if i == 0 {
                            i1, i2, i3 = 0, 1, 0
                            j1, j2, j3 = j-1, j, j+1
                        } else if i == numRows - 1 {
                            i1, i2, i3 = numRows-1, numRows-2, numRows-1
                            j1, j2, j3 = j-1, j, j+1
                        } else if j == 0 {
                            i1, i2, i3 = i-1, i, i+1
                            j1, j2, j3 = 0, 1, 0
                        } else {
                            i1, i2, i3 = i-1, i, i+1
                            j1, j2, j3 = numCols-1, numCols-2, numCols-1
                        }
                        state[i1][j1].level += 1
                        state[i1][j1].owner = player
                        state[i2][j2].level += 1
                        state[i2][j2].owner = player
                        state[i3][j3].level += 1
                        state[i3][j3].owner = player
                    case 3:
                        state[i][j+1].level += 1
                        state[i][j+1].owner = player
                        state[i][j-1].level += 1
                        state[i][j-1].owner = player

                        state[i+1][j].level += 1
                        state[i+1][j].owner = player
                        state[i-1][j].level += 1
                        state[i-1][j].owner = player
                    }
                }
            }
        }


        rl.EndDrawing()
    }
    rl.CloseWindow()
}
