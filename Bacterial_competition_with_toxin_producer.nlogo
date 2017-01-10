globals [red-nearby green-nearby red-toxin-area green-toxin-area toxin-area setup-size target feeding-radius radius nearby ]
breed [toxins toxin] ;; creates a breed of turtles called "toxins" pluaral and "toxin" singular
toxins-own [age] ;; toxin specific variable used to calculate how old the molecule is
patches-own [ cells energy dormant time nutrient] ; variables for the patches

; Color Coding:
;toxins: Magenta- normal toxin that can move and attach 
;       Blue- toxins that have attached to cell and can no longer move
;Patches: Shades of Green and Red- normal bacterial cells, lighter shades represent more cells at a location, 
;         Yellow- Unoccupied patch, Brown- unoccupied after previously being occupied (shows clearing of red cells by toxin)
;      
;
;
;
to setup
  clear-all
  reset-ticks
  set red-nearby circle-neighborhood red-radius
  set green-nearby circle-neighborhood green-radius
  
  set setup-size circle-neighborhood colony-initial-size
  set feeding-radius circle-neighborhood 3
  
  if mode = "1 colony" ; 1 colony mode sets up a single green colony in the middle
  [
    ask patches [set pcolor 48] 
    ask patch (0) (0)
    [
      ask patches at-points setup-size [
        set pcolor 57
        set energy 0
        set cells 3
      ]
    ]
  ]
  if mode = "random positions" ; this mode spreads a specified number of green and red cells across the grid
  [
    ask patches 
    [
      set pcolor 48
      set cells 0
      set nutrient nutrient-amount
    ] 
    while [count patches with [pcolor = 55] < number-of-green] [ask patch random-xcor random-ycor 
      [
        if pcolor = 48  
        [
          set pcolor 55
          set cells 1
          set nutrient nutrient-amount
        ]
      ]
    ]
    while [count patches with [pcolor = 15] < number-of-red] [ask patch random-xcor random-ycor [
      if pcolor = 48  
      [
        set pcolor 15
        set cells 1
        
        set nutrient nutrient-amount]
    ]
    ]
    
    
  ]
  if mode = "2 colonies" ; this mode makes a green colony and a red colony a specific distance apart
  [
    ask patches [set pcolor 48] 
    ask patch ((distance-apart / 2)) (0)
    [
      ask patches at-points setup-size 
      [
        set pcolor 57
        set energy 0
        set cells 3
      ]
    ]
    ask patch ((distance-apart / -2)) (0)
    [
      ask patches at-points setup-size 
      [
        set pcolor 17
        set energy 0
        set cells 3
        
      ]
    ]
  ]

 
end

to go
  
  if growth? [
    ask patches with [ (pcolor = 55) or (pcolor = 56) or (pcolor = 57)]  
    [
      eating-green grow-green 
      if toxin? [   make-toxin] 
      set time time + 1 
    ]
    ask patches with [(pcolor = 15) or (pcolor = 16) or (pcolor = 17)]  
    [
       eating-red grow-red  
      set time time + 1
    ]
  ]
  ask turtles ;; asks the turtles to run their commands
  [
    
    if mode = "2 colonies" ;; this command delays the phage from doing anything until after 200 ticks. This give the bacteria time to grow first
    [
     if ticks = 200
     [
      
      
       if color = orange
       [
        set color blue 
       ] 
      
     ] 
    ]
  ]
  ask toxins ; asks the toxins to run their commands
  [
   toxin-move toxin-attach grow-up
  ]
  
 
  ifelse show-toxin? ; this will show all the toxins if the switch is turned on
  [
    ask toxins
    [
      show-turtle 
    ]
  ]
  [
   ask toxins
   [
    hide-turtle 
   ] 
  ]
  
  tick
end

to grow-green
  ;; if a cell has energy it can grow, cells with more open spaces near them ( yellow patches) will have a higher chance of reproducing. 
  ;; probability is (number of yellow in von-neuman neighborhood / total number of patches in vonneumann neigbborhood) * 90% + 10%
  ;; added a 10% base probability to all cells to make colonies more symmetrical
  ;; the grow command works by asking a patch if its energy is less than 1. It is it will "roll a dice" with a higher chance of success based on the number of yellow patches nearby. 
  ;;If the roll is succesfull the patch will ask itself if it has less than the maximum number of patches (2) if it does it will roll another dice. If that number is less than 5 it will place
  ;; the new cell on itself and increase the number of cells on that patch. If the roll is greater than 5 it will put the newly formed cell in a neighboring patch.
  ;; the cell will ask one-of neighbors with cells < 3 (if it can't find a cell with cells < 3 it will return "nobody" and stop the reproduction event) after finding a cell with cells < 3 that's the right color
  ;; it will add a new cell to that location and change cells number and color accordingly.
 if time > reproduction-time-green ;; this is how you change the growth rate !!!!! start with competitor being faster
 [ 
  if energy >= reproduction-energy-green
    [
      
        ifelse cells < 3
        [
          ifelse add-to-parent-site > random 100
          [
            set cells cells + 1
            set energy energy - 1
            if cells = 2 
            [
              set pcolor 56
            ]
            if cells = 3
            [
              set pcolor 57
            ]
          ]
          [ set target one-of neighbors with [cells < 3]
            
            if target != nobody
            [ 
              ask target
              [
                if ( pcolor = 55) or ( pcolor = 56) or ( pcolor = 57) or ( pcolor = black) or ( pcolor = 48) or (pcolor = brown)
                [
                  if cells = 0 
                  [ 
                    
                    set energy 0
                    set cells 1
                    set pcolor green
                    set time 0
                    ask myself [set energy energy - 1]
                    stop
                  ]
                  if cells = 1
                  [
                    set cells cells + 1
                    set pcolor 56
                    ask myself [set energy energy - 1]
                    stop
                  ]
                  if cells = 2
                  [
                    set cells cells + 1
                    set pcolor 57
                    ask myself [set energy energy - 1]
                    stop
                  ]
                ]
              ]
            ]
          ]
        ]
        [
          set target one-of neighbors with [cells < 3]
          
          if target != nobody 
          [
            ask target
            [
              if (pcolor = 55) or (pcolor = 56) or (pcolor = 57) or (pcolor = black) or (pcolor = 48) or (pcolor = brown)
              [
                if cells = 0 
                [ 
                  set energy 0
                  set cells 1
                  set time 0
                  set pcolor green
                  ask myself [set energy energy - 1]
                  stop
                ]
                if cells = 1
                [
                  set cells cells + 1
                  set pcolor 56
                  ask myself [set energy energy - 1]]
                stop
                if cells = 2
                [
                  set cells cells + 1
                  set pcolor 57
                  ask myself [set energy energy - 1]
                  stop
                ]
              ]
            ]
          ]
        ]
        set time 0
      ]
    ]
 
end

to grow-red
  ;; same as green command but with colors switched
  if time > reproduction-time-red
  [ 
    if energy >= reproduction-energy-red
    [
     
        ifelse cells < 3
        [
          ifelse add-to-parent-site > random 100
          [
            set cells cells + 1
            set energy energy - 1
            if cells = 2 
            [
              set pcolor 16
            ]
            if cells = 3
            [
              set pcolor 17
            ]
          ]
          [ set target one-of neighbors with [cells < 3]
            
            if target != nobody
            [ 
              ask target
              [
                if ( pcolor = 15) or ( pcolor = 16) or ( pcolor = 17) or ( pcolor = black) or ( pcolor = 48) or (pcolor = brown)
                [
                  if cells = 0 
                  [ 
                    
                    set energy 0
                    set cells 1
                    set pcolor red
                    set time 0
                    ask myself [set energy energy - 1]
                    stop
                  ]
                  if cells = 1
                  [
                    set cells cells + 1
                    set pcolor 16
                    ask myself [set energy energy - 1]
                    stop
                  ]
                  if cells = 2
                  [
                    set cells cells + 1
                    set pcolor 17
                    ask myself [set energy energy - 1]
                    stop
                  ]
                ]
              ]
            ]
          ]
        ]
        [
          set target one-of neighbors with [cells < 3]
          
          if target != nobody 
          [
            ask target
            [
              if (pcolor = 15) or (pcolor = 16) or (pcolor = 17) or (pcolor = black) or (pcolor = 48) or (pcolor = brown)
              [
                if cells = 0 
                [ 
                  set energy 0
                  set cells 1
                  set time 0
                  set pcolor red
                  ask myself [set energy energy - 1]
                  stop
                ]
                if cells = 1
                [
                  set cells cells + 1
                  set pcolor 16
                  ask myself [set energy energy - 1]]
                stop
                if cells = 2
                [
                  set cells cells + 1
                  set pcolor 17
                  ask myself [set energy energy - 1]
                  stop
                ]
              ]
            ]
          ]
        ]
        set time 0
      ]
    ]
  

end

;; this is the reporter used to take a radius number (n) and create a list of all the cells in the neighborhood of the radius n and can store the list as a variable (ex. "red-nearby")
to-report circle-neighborhood [n]
  let result [list pxcor pycor] of patches with [(abs pxcor) ^ 2 + (abs pycor) ^ 2 <= n ^ 2]
  report result 
  
end
to eating-green
  ;;a cell can eat at any site with nutrient  and it will consume a set amount of energy.
  ;; this command works by looking for a patch to eat in a set radius.
  ;;based on the neighborhood used by the bacteria (ex: red-nearby). As soon as the patch finds a suitable patch to eat it will move on.
 
  
   if energy < green-hunger
    [
      
      ask one-of patches at-points feeding-radius
      [
        if nutrient > 0
        [
          set nutrient nutrient - 1
          ask myself 
          [
            set energy energy + 1 
          ] 
        ] 
      ] 
    ]
    
    
    
  
  
end

to eating-red
 ;; this is the same as eating-green but works for the red bacteria
  
  if energy < red-hunger
  [
      
      ask one-of patches at-points feeding-radius
      [
        if nutrient > 0
        [
          set nutrient nutrient - 1
          ask myself 
          [
            set energy energy + 1 
          ] 
        ] 
      ] 
    ]
  
end





   

to make-toxin ;; a command for a patch to create and release toxin particles
 if energy > 0 [
   
    sprout-toxins toxin-production
    [
      set color magenta
      set size .5
      set age 0
    ] ]
  
end

to toxin-move  ; command to let the toxins move, only magenta toxins can move
  if color = magenta
  [
     right random 360 forward toxin-speed
  ]
end

to toxin-attach ; toxin can attach and turn pink, once the number of toxin attached is equal to the lethal-amount the cell dies and clears all attached toxin molecules
  if (pcolor = 15) or (pcolor = 16) or (pcolor = 17)  
  [
    if random 100 < probability-of-toxin-attachment
    [
      
      set color blue
      ask patch-here
        [
          if count toxins-here with [color = blue] = lethal-amount
            [
              set pcolor pcolor - 1 
            
              set cells cells - 1 
              set nutrient nutrient + corpse-energy
              
                if cells = 0 [ set pcolor brown ]
              ask toxins-here
              [
                if color = blue
                [
                  die 
                ] 
              ]
            ] 
        ]
    ]
  ]
  
end

to grow-up ; toxins grow older each tick once they reach degradation-time they die
  
  ifelse age = degradation-time
  [
   die 
  ]
  [
  set age age + 1
  ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
853
57
1344
569
30
30
7.9
1
10
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
100.0

BUTTON
30
32
105
83
NIL
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
134
33
220
83
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
140
106
215
139
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
247
266
440
299
red-radius
red-radius
1
30
3
1
1
NIL
HORIZONTAL

SLIDER
24
200
196
233
energy-gained
energy-gained
1
10
2
1
1
NIL
HORIZONTAL

SLIDER
485
427
657
460
number-of-green
number-of-green
0
600
200
1
1
NIL
HORIZONTAL

SLIDER
244
423
416
456
number-of-red
number-of-red
0
600
200
1
1
NIL
HORIZONTAL

MONITOR
243
38
315
83
Green Cells
(count patches with [pcolor = green]) + \n((count patches with [pcolor = 56]) * 2) + \n((count patches with [pcolor = 57]) * 3)
17
1
11

MONITOR
338
39
407
84
Red Cells
(count patches with [pcolor = red]) + \n((count patches with [pcolor = 16]) * 2) + \n((count patches with [pcolor = 17]) * 3)
17
1
11

SLIDER
488
265
660
298
green-radius
green-radius
0
30
3
1
1
NIL
HORIZONTAL

TEXTBOX
300
233
450
255
Red Bacteria
18
15.0
1

TEXTBOX
519
232
669
254
Green Bacteria
18
55.0
1

PLOT
245
103
405
223
Bacterial Cells
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot\n(\n(count patches with [pcolor = green]) + \n((count patches with [pcolor = 56]) * 2) + \n((count patches with [pcolor = 57]) * 3)\n)"
"pen-1" 1.0 0 -2674135 true "" "plot\n(\n(count patches with [pcolor = red]) + \n((count patches with [pcolor = 16]) * 2) + \n((count patches with [pcolor = 17]) * 3)\n)"

SLIDER
23
239
197
272
corpse-energy
corpse-energy
0
5
0.5
.25
1
NIL
HORIZONTAL

SLIDER
23
276
196
309
colony-initial-size
colony-initial-size
0
100
6
1
1
NIL
HORIZONTAL

CHOOSER
24
151
166
196
mode
mode
"1 colony" "2 colonies" "random positions"
2

TEXTBOX
246
409
392
427
Random Positions
11
0.0
1

TEXTBOX
488
412
638
430
Random Positions
11
0.0
1

TEXTBOX
63
449
213
467
2 Colonies
11
0.0
1

SLIDER
12
467
184
500
distance-apart
distance-apart
10
100
28
2
1
NIL
HORIZONTAL

TEXTBOX
20
389
170
431
Probability to add a new cell to parent site rather than neighboring site
11
0.0
1

SLIDER
21
353
193
386
add-to-parent-site
add-to-parent-site
0
100
50
10
1
%
HORIZONTAL

SWITCH
33
505
136
538
growth?
growth?
0
1
-1000

PLOT
469
103
686
223
Dead Cells
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Dead" 1.0 0 -6459832 true "" "plot ( count patches with [ pcolor = brown])"

SWITCH
241
494
344
527
toxin?
toxin?
0
1
-1000

SLIDER
379
566
551
599
toxin-production
toxin-production
0
20
2
1
1
NIL
HORIZONTAL

SWITCH
241
534
376
567
show-toxin?
show-toxin?
0
1
-1000

SLIDER
379
529
551
562
toxin-speed
toxin-speed
0
5
1
0.5
1
NIL
HORIZONTAL

SLIDER
381
488
553
521
lethal-amount
lethal-amount
0
10
2
1
1
NIL
HORIZONTAL

TEXTBOX
348
456
498
478
Toxin
18
125.0
1

SLIDER
564
490
736
523
degradation-time
degradation-time
0
20
3
1
1
NIL
HORIZONTAL

SLIDER
564
531
820
564
probability-of-toxin-attachment
probability-of-toxin-attachment
0
100
34
1
1
NIL
HORIZONTAL

SLIDER
245
376
443
409
reproduction-time-red
reproduction-time-red
0
30
7
1
1
NIL
HORIZONTAL

SLIDER
485
375
700
408
reproduction-time-green
reproduction-time-green
0
30
10
1
1
NIL
HORIZONTAL

SLIDER
21
315
193
348
nutrient-amount
nutrient-amount
0
20
6
1
1
NIL
HORIZONTAL

SLIDER
246
302
461
335
reproduction-energy-red
reproduction-energy-red
0
3
1
.1
1
NIL
HORIZONTAL

SLIDER
484
303
715
336
reproduction-energy-green
reproduction-energy-green
0
3
1
.1
1
NIL
HORIZONTAL

SLIDER
247
339
419
372
red-hunger
red-hunger
0
5
1
.1
1
NIL
HORIZONTAL

SLIDER
485
338
657
371
green-hunger
green-hunger
0
5
1
.1
1
NIL
HORIZONTAL

MONITOR
417
39
490
84
Dead Cells
count patches with [ pcolor = brown]
17
1
11

@#$#@#$#@
## WHAT IS IT?
A spatial model of competition between two bacterial species (green and red), with green cells producing a toxin that kills red cells.


## Color Coding

 Color Coding:
 

Turtles: Magenta- normal toxin molecule that can diffuse and attach to red cells
       Blue- toxin molecule that has attached to (red) cell and can no longer move

Patches: Shades of Green and Red- bacterial cells, lighter shades represent more           cells at a location 
         Yellow- unoccupied patch; Brown- unoccupied after previously being occupied (shows clearing of red cells by toxin)
         
## HOW BACTERIA WORK

Each patch begins with some allocation of nutrient and can be occupied by up to 3 cells. Reproduction occurs at a specified rate, which depends on cell type, as long as the cell has acquired sufficient energy by consuming nutrient. A unit of nutrient that is consumed confers a specified amount of energy. Each reproduction event costs the reproducing cell energy. A cell that does not have sufficient energy to reproduce will attempt to consume nutrient from its `nutrient neighborhood' (patches that are within a Moore neighborhood with radius three). This is an efficient method for simulating the effects of nutrient diffusion without excessive computational cost. The offspring cell is placed at the patch of the parent or at one of the 8 neighboring patches, with pre-specified probabilities, as long as there is space available and the other species is not present at that patch. Reproduction is suppressed whenever all these local patches are at their carrying capacity. A red cell that is killed by toxin releases a specified amount of nutrient to that patch.

## HOW TOXINS WORK

Toxin molecules (turtles) are produced by green cells at each tick, as long as they have sufficient energy. Toxin molecules diffuse and can attach to red cells. Toxins kill red cells if enough attach; they do not attach to or harm green cells. A toxin molecule will degrade after a specified time. 

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

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
<experiments>
  <experiment name="experiment 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="700"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <enumeratedValueSet variable="green-radius">
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="0"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="4"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="red-radius" repetitions="2" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="number-of-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="1"/>
      <value value="4"/>
      <value value="8"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="corpse-energy" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="number-of-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="red-toxin" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="500"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="number-of-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>count patches with ( pcolor = red ) or (pcolor = red + 1) or (pcolor = red + 2)</metric>
    <metric>count patches with ( pcolor = green ) or (pcolor = green + 1) or (pcolor = green + 2)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="25"/>
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="25"/>
      <value value="33"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-toxicity">
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Initial amount of bacteria 8-7" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="400"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
      <value value="250"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reprocution time" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="degradation" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="lethal amount" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="lysin birth size" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="adsorption" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Nutrient and degradation" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxin-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-toxin-radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="1"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1.25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-toxicity">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="lysin speed" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="90"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Toxicity Deg 5 Speed 2 More Lysin" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="degradation 5.5%" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="360"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Degradation two densities" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="40"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="360"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="reproduction-energy" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-birth-size">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-lysin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lysin-speed">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
      <value value="1.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-lysin?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Degradation-Toxinspeed-number" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Degradation" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="700"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
      <value value="400"/>
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Toxin Production-Degradation" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="700"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="1"/>
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Toxicity-degradation-toxinproduced" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="700"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="700"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="5"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-2014Adsorption-Diffusionrate-Birthsize2" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="0"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-14-Toxicity-Birthsize-Diffusionrate2" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="0.1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="0"/>
      <value value="5"/>
      <value value="4"/>
      <value value="3"/>
      <value value="2"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-14-Degradation-DiffInitialamounts" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="40"/>
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-2014Adsorption-Diffusionrate-Birthsize3" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="0"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-14-Toxicity-Birthsize-Diffusionrate3" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="0.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="0"/>
      <value value="5"/>
      <value value="4"/>
      <value value="3"/>
      <value value="2"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-19-14-Degradation-DiffInitialamounts2" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="0"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="40"/>
      <value value="200"/>
      <value value="400"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="3"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="12-27-2014Adsorption-Diffusionrate-Birthsize3" repetitions="3" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="350"/>
    <metric>(count patches with [pcolor = green]) + ((count patches with [pcolor = 56]) * 2) + ((count patches with [pcolor = 57]) * 3)</metric>
    <metric>(count patches with [pcolor = red]) + ((count patches with [pcolor = 16]) * 2) + ((count patches with [pcolor = 17]) * 3)</metric>
    <enumeratedValueSet variable="green-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="green-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="growth?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-label?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-red">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mode">
      <value value="&quot;random positions&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hide-turtles?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="attachment-chance">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="birth-size">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-energy-green">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-red">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-red">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="colony-initial-size">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproduction-time-green">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distance-apart">
      <value value="28"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-hunger">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="probability-of-toxin-attachment">
      <value value="0"/>
      <value value="10"/>
      <value value="25"/>
      <value value="50"/>
      <value value="75"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="corpse-energy">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-speed">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nutrient-amount">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="degradation-time">
      <value value="5"/>
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy-gained">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="toxin-production">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-green">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="red-radius">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="add-to-parent-site">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="phage?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-reproduction">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-toxin?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="lethal-amount">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
