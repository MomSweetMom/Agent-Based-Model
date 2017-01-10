breed [ squares square ]     ;; your basic elements
breed [ numbers number ]     ;; invisible turtles utilized to center labels
breed [ frames  frame  ]     ;; used to grid the playing field at setup
breed [ popups  popup  ]     ;; invisible turtles utilized to difplay popup messages

globals [
  score                      ;; cumulative game score
  won?                       ;; filter variable, blocks gameplay after the player creates 2048
  displayed-victory-message? ;; if a victory message has already been displayed
]

patches-own [
  occupied?                  ;; if there already is a square on the patch
]

turtles-own [
  value                      ;; value of a square
  combined?                  ;; if a square was already combined in this turn, used to prevent double-collapsing of fully same-number rows
  moveable                   ;; shows if a turtle can move, used in turn logic
]

to setup
 setup-field
 spawn 2
 setup-color
end

to setup-grid            ;; creates a grid on the playing field
  set-default-shape frames "frame"
  ask patches [
    sprout-frames 1 [
      set color 37
      set heading 0
    ]
  ]
  ask frames [ stamp die ]
  reset-ticks
  ask patches [ set occupied? FALSE ]
end 

to setup-field
 clear-all
 set-patch-size 80
 ask patches [ set pcolor 38 ]
 set-default-shape squares "2048square"
 setup-grid
 reset-ticks
 ask patches [ set occupied? FALSE ]
 set score 0
 set displayed-victory-message? FALSE
end

to setup-color           ;; assigns color to numeric values 
  ask squares [ 
    if value = 2    [ set color white ]
    if value = 4    [ set color 28.5  ]
    if value = 8    [ set color 27.8  ]
    if value = 16   [ set color 26    ]
    if value = 32   [ set color 25    ]
    if value = 64   [ set color 15.8  ]
    if value = 128  [ set color 15    ]
    if value = 256  [ set color 14.2  ]
    if value = 512  [ set color 125   ]
    if value = 1024 [ set color 126   ]
    if value = 2048 [ set color 114   ] 
    if value = 4096 [ set color black ]
  ]   
end

to attach-number [x]     ;; command from "Label Position Example" model, creates a 'number' turtle with zero size and label
  hatch-numbers 1 [
    set size 0
    set label x
    ifelse x = 2 or x = 4 [ set label-color black ] [ set label-color white ]
    create-link-from myself [
      tie
      hide-link
    ]
    center
  ]
end 

to center                ;; centers the labels with different numbers 
  if label >= 1    and label <= 9    [ setxy pxcor + 0.07 pycor - 0.12 ]
  if label >= 10   and label <= 99   [ setxy pxcor + 0.12 pycor - 0.12 ]
  if label >= 100  and label <= 999  [ setxy pxcor + 0.17 pycor - 0.12 ]
  if label >= 1000 and label <= 9999 [ setxy pxcor + 0.22 pycor - 0.12 ]
end

to reposition            ;; command from "Label Position Example" model, positions number turtles related to squares
  move-to one-of in-link-neighbors
  ask numbers [ center ]
end

to spawn [ x ]          ;; this command spawns x squares witn numbers in unoccupied patches
  if any? patches with [ occupied? = FALSE ] [
    ask n-of x patches with [ occupied? = FALSE ] [
      sprout-squares 1 [
        ifelse random 99 > 89 [ set value 4 attach-number 4 ] [ set value 2 attach-number 2 ]
        set combined? FALSE
      ]
    set occupied? TRUE
  ]
  setup-color
]
end


;;  Four following commands correspond to directional buttons

to move-up
  ifelse won? = TRUE and play-after-victory? = FALSE [] [ 
  ask squares [ set heading 0 set combined? FALSE ]
  assess-moves
  if any? squares with [ moveable = TRUE ] [ go ]
  check-result
  ]
end

to move-right
  ifelse won? = TRUE and play-after-victory? = FALSE [] [ 
  ask squares [ set heading 90 set combined? FALSE ]
  assess-moves
  if any? squares with [ moveable = TRUE ] [ go ]
  check-result
    ]
end

to move-down
  ifelse won? = TRUE and play-after-victory? = FALSE [] [ 
  ask squares [ set heading 180 set combined? FALSE ]
  assess-moves
  if any? squares with [ moveable = TRUE ] [ go ]
  check-result
  ]
end

to move-left
  ifelse won? = TRUE and play-after-victory? = FALSE [] [
  ask squares [ set heading 270 set combined? FALSE ]
  assess-moves
  if any? squares with [ moveable = TRUE ] [ go ]
  check-result
  ]
end

to move                ;; moves and combines turtles 
    ifelse can-move? 1 and not any? squares-on patch-ahead 1 [ fd 1 ] [
      if heading = 0   and combined? = FALSE [ if any? squares at-points [ [  0  1 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ fd 1 combine ] ] 
      if heading = 90  and combined? = FALSE [ if any? squares at-points [ [  1  0 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ fd 1 combine ] ] 
      if heading = 180 and combined? = FALSE [ if any? squares at-points [ [  0 -1 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ fd 1 combine ] ]
      if heading = 270 and combined? = FALSE [ if any? squares at-points [ [ -1  0 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ fd 1 combine ] ]
    ]
end

to assess-moves        ;; checks if a turtle can move or collapse in a certain direction
  ask squares [ set moveable FALSE ]
  ask squares [ ifelse can-move? 1 and not any? squares-on patch-ahead 1 [ set moveable TRUE ] [
    if heading = 0   and combined? = FALSE [ if any? squares at-points [ [  0  1 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ set moveable TRUE ] ] 
    if heading = 90  and combined? = FALSE [ if any? squares at-points [ [  1  0 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ set moveable TRUE ] ] 
    if heading = 180 and combined? = FALSE [ if any? squares at-points [ [  0 -1 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ set moveable TRUE ] ]
    if heading = 270 and combined? = FALSE [ if any? squares at-points [ [ -1  0 ] ] with [ value = [ value ] of myself and combined? = FALSE ] [ set moveable TRUE ] ]
  ]
  ]
end

to go                  ;; three-stage operation is utilized to ensure that correct order of actions is performed
  ask squares [
    if heading = 0   [ 
      ask squares with [ ycor = 2 ] [ repeat 1 [ move ] ]
      ask squares with [ ycor = 1 ] [ repeat 2 [ move ] ]
      ask squares with [ ycor = 0 ] [ repeat 3 [ move ] ]
    ]
    if heading = 90  [
      ask squares with [ xcor = 2 ] [ repeat 1 [ move ] ]
      ask squares with [ xcor = 1 ] [ repeat 2 [ move ] ]
      ask squares with [ xcor = 0 ] [ repeat 3 [ move ] ]
    ]
    if heading = 180 [
      ask squares with [ ycor = 1 ] [ repeat 1 [ move ] ]
      ask squares with [ ycor = 2 ] [ repeat 2 [ move ] ]
      ask squares with [ ycor = 3 ] [ repeat 3 [ move ] ]
      ]
    if heading = 270 [
      ask squares with [ xcor = 1 ] [ repeat 1 [ move ] ]
      ask squares with [ xcor = 2 ] [ repeat 2 [ move ] ]
      ask squares with [ xcor = 3 ] [ repeat 3 [ move ] ]
      ]
  ]
  ask patches [ ifelse any? squares-here [ set occupied? TRUE ] [ set occupied? FALSE ] ]
  spawn 1
  tick
end

to combine             ;; this function creates a new square in place of the two collapsed ones and increases score
  if any? other squares-here with [ value = [ value ] of myself ] [
    ask one-of other squares-here with [ value = [ value ] of myself ] [ die ]
    ask numbers-here [ die ]
    hatch-squares 1 [ 
      set value [ value ] of myself * 2
      set score score + value 
      attach-number value 
      set combined? TRUE 
    ]
    die
    ]
end

to check-result         ;; this function checks the game state (won / lost / playing after victory)
  if any? squares with [ value = 2048 ] [ set won? TRUE ]
  if won? = TRUE and play-after-victory? = FALSE [ win-game ]
  if won? = TRUE and play-after-victory? = TRUE and displayed-victory-message? = TRUE  [ ask popups [ die ] ]
  if won? = TRUE and play-after-victory? = TRUE and displayed-victory-message? = FALSE [ win-game ]
  ask squares [ set combined? FALSE ]
  ask squares [ set heading 0   ]
  assess-moves
  if not any? squares with [ moveable = TRUE ] [
    ask squares [ set heading 90  ]
    assess-moves
    if not any? squares with [ moveable = TRUE ] [
      ask squares [ set heading 180 ]
      assess-moves
      if not any? squares with [ moveable = TRUE ] [
        ask squares [ set heading 270 ]
        assess-moves
        if not any? squares with [ moveable = TRUE ] [ lose-game ]
      ]
    ]
  ]
  ask numbers [ reposition ]
end

to win-game            ;; shows victory message
  create-popups 1 [
    set size 0
    set label "YOU WIN!"
    set label-color grey
    setxy 2 1.4
    ]
  set displayed-victory-message? TRUE
end 

to lose-game           ;; shows gameover message
  create-popups 1 [
    set size 0
    set label "GAME OVER"
    set label-color grey
    setxy 2 1.4
    ]
end


;; Debug tools
;; These commands let you "cheat" by placing and removing squares from the field.
;; In order to use them you have to check the debug? switch 

to place [ x ]
  if debug? [
    if place-randomly? [ if any? patches with [ occupied? = FALSE ] [ ask one-of patches with [ occupied? = FALSE ] [ 
        sprout-squares 1 [
          set value x
          attach-number x
          set combined? FALSE
          set occupied? TRUE ] 
    ]
    ]
    setup-color
    stop
    ]
    if not place-randomly? [
      if mouse-down? [
      ask patches with [ pxcor = round mouse-xcor and pycor = round mouse-ycor and occupied? = FALSE ] [
        sprout-squares 1 [
          set value x
          attach-number x
          set combined? FALSE
          set occupied? TRUE
        ]
      ]
    ]
    ]
    setup-color
  ]
end

to kill
  if debug? [
    if kill-randomly? [ ask one-of squares [ ask turtles-here [ die ] ] ask patches [ ifelse any? squares-here [ set occupied? TRUE ] [ set occupied? FALSE ] ] stop ]
    if not kill-randomly? [ if mouse-down? [ 
        ask turtles with [ pxcor = round mouse-xcor and pycor = round mouse-ycor ] [ die ] 
        ask patches [ ifelse any? squares-here [ set occupied? TRUE ] [ set occupied? FALSE ] ] ] ]
    ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
540
361
-1
-1
80.0
1
20
1
1
1
0
0
0
1
0
3
0
3
0
0
1
turns
30.0

MONITOR
547
10
719
91
NIL
score
0
1
20

BUTTON
16
10
203
82
New Game
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
608
183
664
233
UP
move-up
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
663
231
718
281
RIGHT
move-right
NIL
1
T
OBSERVER
NIL
D
NIL
NIL
1

BUTTON
608
281
664
330
DOWN
move-down
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
553
231
609
281
LEFT
move-left
NIL
1
T
OBSERVER
NIL
A
NIL
NIL
1

SWITCH
549
123
721
156
play-after-victory?
play-after-victory?
1
1
-1000

BUTTON
17
115
202
157
Setup field
setup-field
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
65
456
208
491
Place square
place n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
7
456
66
523
n
2
1
0
Number

SWITCH
65
490
208
523
place-randomly?
place-randomly?
0
1
-1000

TEXTBOX
37
424
158
449
DEBUG FEATURES
14
0.0
0

BUTTON
208
456
350
490
Kill square
kill
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
208
490
350
523
kill-randomly?
kill-randomly?
1
1
-1000

SWITCH
178
415
276
448
debug?
debug?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This is a mathematical puzzle slider. Your objective is to combine identical tiles on a 4x4 grid, doubling their value until you finally get to 2048.

## HOW IT WORKS

When you press any of the four directional buttons, all the numbered tiles try to move to the corresponding edge of the playing field, and a new minor tile spawns in a random unoccupied tile of the field. If there is an identical tile in the way, the tiles combine and form a new tile with twice the value.

## HOW TO USE IT

- Press the New Game button to start the game with two minor numbers.
- You can also empty the field with "Setup field" command.
- Swipe by clicking the directional buttons or use WASD (in order to do so, you have to first click in the white background of the Interface tab).
- When you reach 2048, the game shows a victory message and a trigger in the code won't let you swipe anymore. If you wish to continue playing, you can check the play-after-victory? switch.

## THINGS TO NOTICE

- If you collapse a line with more than two tiles of the same value, 'forward-most' tiles get priority in combining
- There is a 10% probability that a 4 will spawn after a turn, and a 90% probability of getting a 2
- For every tile created, its value is added to score. After completing the objective of the game you will have a score of around 20000 points 

## THINGS TO TRY

An effective strategy is to always maintain a readily-collapsible row of biggest numbers 'glued' to one of the edges of the field and never swipe in the opposite direction. Be careful, though - there are situations when swiping in that direction is the only legitimate move. try to anticiate and prevent such situatuons - an unlucky spawn there can ruin half an hour of meticulous play!
You can also try manipulationg the cheat-ish debug menu under the playing field. It was originally used for managing colors or checking the code for mistakes with victory conditions and the like, but now you can use it to experiment with epic field layouts and combo chains.

## EXTENDING THE MODEL

This version of the game would benefit from some kind of gradual turtle movement animation, as well as a combination animation. This would require reforming the code, though, as at this moment movement and merging of tiles are made step-by-step in a chain of separate operations. 
Another thing to add could be an automatic save game feature, like the one in the browser version of the game.

## NETLOGO FEATURES

As netLogo does not yet allow convenient label management, I had to rely on a tied turtle solution from Uri Wilensky's model "Label Position Example" to position numbers in the center of squares.
I also had to create two special turtle shapes - a "frame" with an edge of 1 pixel used to create a grid and a "2048square", which is 2 pixels wider than the standard NetLogo square and fits in the "frame'.

## CREDITS AND REFERENCES

2048 was originally created in March 2014 by an Italian web developer Gabriele Cirulli.

You can pay an online version of the game at http://gabrielecirulli.github.io/2048/

## COPYRIGHT AND LICENSE

Copyright 2014 Roman Driamov.

![CC BY-NC-SA 4.0](http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

2048square
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -7500403 true true 30 30 270 270
Rectangle -7500403 true true 30 15 285 285
Rectangle -7500403 true true 15 15 30 285

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

frame
true
0
Rectangle -7500403 true true 15 285 300 300
Rectangle -7500403 true true 0 0 15 300
Rectangle -7500403 true true 15 15 285 15
Rectangle -7500403 true true 15 0 300 15
Rectangle -7500403 true true 285 15 300 285

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
