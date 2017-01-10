breed [primaries primary]                      ; creates the four breeds for trophic levels 2-5
breed [secondaries secondary]
breed [tertiaries tertiary]
breed [quaternaries quaternary]

globals [eat-energy]                           ; global variable to store the energy transferred between trophic levels
turtles-own [energy]                           ; stores long-term energy on each turtle
patches-own [countdown]                        ; variable to count ticks for grass respawn rate

to setup
  ca
  reset-ticks
  create-world
  trophic-setup
end

to create-world                                ; sets up the geography
  ask patches [
    set pcolor green]                          ; creates grass
  ask patches with                             ; visuals for the sky and sun 
    [pycor > 45]
    [set pcolor white]
  ask patches with 
    [(pycor >= 55) and (pxcor <= -55)]
    [set pcolor yellow]
end 

to trophic-setup                               ; creates trophic levels 2-5
  set-default-shape primaries "rabbit"         ; sets default shape of all primaries to rabbit
  ask n-of primary-amount patches with         ; sprouts primaries only on grass
  [(pcolor = green) 
    and (pycor > -64) and (pycor < 45)]        ; and far enough away from borders of grass 
    [sprout-primaries 1
      [set color white 
       set size 3] 
    ] 
  
  set-default-shape secondaries "wolf"         ; sets default shape of all secondaries to wolf
  ask n-of secondary-amount patches with       ; sprouts secondaries only on grass
  [(pcolor = green)
    and (pycor > -64) and (pycor < 45)]
    [sprout-secondaries 1
      [set color blue - 3
        set size 3]
    ]          

  set-default-shape tertiaries "cat"           ; default shape of all tertiaries to cat
  ask n-of tertiary-amount patches with        ; sprouts only on grass 
  [(pcolor = green)
    and (pycor > -64) and (pycor < 45)]
    [sprout-tertiaries 1
      [set color red - 3
        set size 2]
    ]
  
  set-default-shape quaternaries "hawk"        ; default shape of all quaternaties to hawk
  ask n-of quaternary-amount patches with      ; sprouts only on grass
  [(pcolor = green)
    and (pycor > -64) and (pycor < 45)]
    [sprout-quaternaries 1
      [set color magenta
        set size 2]
    ]

  ask turtles [set energy 1000]                ; sets baseline energy level for all turtles  
end  





to go
  movement                                     ; bounce and move procedure
  trophic-primary                              ; controls the four animal trophic levels 
  trophic-secondary
  trophic-tertiary
  trophic-quaternary
  reproduction                                 ; controls reproduction rates
  ask patches [grow-grass]                     ; begins grass regrowth 
  death                                        ; procedure for death of turtles
  wait .2
  tick 
  if count primaries = 0 [stop]                ; stops simulation if all primaries die
end

to kill-grass                                  ; button to set all grass patches to dead
  ask patches with 
    [pcolor = green]
    [set pcolor brown]                         ; sets all green patches to brown 
end 

to movement
  ask turtles [                                ; sets random heading for all turtles during each tick
    ifelse (ycor > 44) or (ycor < -62)
  [set heading (heading + 150 + random 60)] 
  [rt 150
   lt 150
   ] ]
  
  ask primaries [fd 1]                         ; primaries' movement
  
  ask secondaries [                            ; secondaries' movement
    fd 1 + random 2                            ; moves them sometimes faster to catch primaries
      if pcolor = yellow                       ; prevents extended movement from bringing turtles off grass
      [set ycor ycor + 20]
      if pcolor = white
      [set ycor ycor + 20]
      ]
  
  ask tertiaries [                             ; tertiaries' movement
    fd 2 + random 2                            ; faster movement for catching tertiaries
      if pcolor = yellow                       ; prevents extended movement from bringing turtles off grass
      [set ycor ycor + 20]
      if pcolor = white
      [set ycor ycor + 20]
  ]
  ask quaternaries [                           ; quaternaries' movement
    fd 3                                       ; faster movement to catch tertiaries
      if pcolor = yellow                       ; prevents extended movement from bringing turtles off grass
      [set ycor ycor + 20]                     
      if pcolor = white
      [set ycor ycor + 20]
  ]
end 

to trophic-primary                         
   ask primaries [
   set energy energy - 50                      ; reduces energy for metabolism
   ]  
   ask primaries [                    
    if pcolor = green                          ; if pcolor is green
    [set pcolor brown                          ; kill the grass 
      set energy energy + 150]                 ; and increase energy 
   ]
end 

to trophic-secondary
   ask secondaries [
     catch-primary                             ; initiates predation procedure 
   set energy energy - 50                      ; metabolism rate over time
  ] 
end 

to trophic-tertiary
  ask tertiaries [
    catch-secondary                            ; initiates predation procedure
  set energy energy - 50                       ; metabolism rate over time
  ]
end

to trophic-quaternary            
  ask quaternaries [
    catch-tertiary                             ; initiates predation procedure
    set energy energy - 50                     ; metabolism rate over time
  ]
end


to catch-primary      
  let prey one-of primaries in-radius 3                        ; grabs a random primary close by 
  set eat-energy sum [energy] of primaries in-radius 3         ; sets energy transfer variable to energy of that primary
  if prey != nobody                                            ; was one found? if yes, 
    [ ask prey [ die ]                                         ; kill it
      set energy energy + (eat-energy / 10) ]                  ; get energy from eating - division creates the ten percent rule
end

to catch-secondary
  if any? secondaries in-radius 6                              ; predation chase feature 
    [face one-of secondaries in-radius 6]                      ; chases secondaries further than eating radius 
    
  let prey2 one-of secondaries in-radius 3                     ; grabs random secondary close by         
  set eat-energy sum [energy] of secondaries in-radius 3       ; sets energy transfer variable to energy of that secondary
  if prey2 != nobody                                           ; was one found? if yes, 
    [ ask prey2 [ die ]                                        ; kill it
      set energy energy + (eat-energy / 7) ]                   ; and gain energy from eating - division is approximate for ten percent
end 

to catch-tertiary                                              ; same procedure for catching teriaries
  if any? tertiaries in-radius 6                               ; chasing feature
    [face one-of tertiaries in-radius 6]
    
  let prey2 one-of tertiaries in-radius 3                      ; look for tertiaries close by
  set eat-energy sum [energy] of tertiaries in-radius 3        ; set energy transfer varaible
  if prey2 != nobody                                           ; checks if there is a tertiary
    [ ask prey2 [ die ]                                        ; if so, kills it and
      set energy energy + (eat-energy / 8) ]                   ; gives the quaternary energy
end 


to grow-grass                                                  ; patch procedure to regrow grass
  if pcolor = brown [                                          ; countdown for brown patches (dead grass)
    ifelse countdown <= 0
      [ set pcolor green  
        set countdown grass-respawn-rate ]                     ; countdown is based on grass-respawn-rate slider
      [ set countdown countdown - 1 ]
  ]
end

to reproduction                                         
  ask primaries [if random-float 100 < primary-reproduce [     ; throw "dice" to see if you will reproduce
    set energy (energy * 2 / 3)                                ; divide energy between parent and offspring
    hatch-primaries 1 [ rt random-float 360 fd 1 ]             ; hatch an offspring and move it forward 1 step
  ] ]
  ask secondaries [if random-float 100 < secondary-reproduce [ ; throw "dice" to see if you will reproduce
    set energy (energy * 2 / 3)                                ; divide energy between parent and offspring
    hatch-secondaries 1 [ rt random-float 360 fd 1 ]           ; hatch an offspring and move it forward 1 step
  ] ]
  ask tertiaries [if random-float 100 < tertiary-reproduce [   ; throw "dice" to see if you will reproduce
    set energy (energy * 2 / 3)                                ; divide energy between parent and offspring
    hatch-tertiaries 1 [ rt random-float 360 fd 1 ]            ; hatch an offspring and move it forward 1 step
  ] ]
  ask quaternaries [if random-float 100 < quaternary-reproduce [     ; throw "dice" to see if you will reproduce
    set energy (energy * 2 / 3)                                      ; divide energy between parent and offspring
    hatch-quaternaries 1 [ rt random-float 360 fd 1 ]                ; hatch an offspring and move it forward 1 step
  ] ]
end 
  
to death
  ask turtles [if energy < 100 [die]]                          ; if energy is below a threshold, the turtle dies 
end 




;; Model created by Joshua Abraham
;; joshpabraham@gmail.com

;; Based on Wolf Sheep Predation Model in Models Library

;; Created at Tracy High School
@#$#@#$#@
GRAPHICS-WINDOW
247
10
711
495
64
64
3.52
1
10
1
1
1
0
1
1
1
-64
64
-64
64
1
1
1
ticks
30.0

BUTTON
9
10
72
43
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
9
48
72
81
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
10
219
43
NIL
kill-grass
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
11
87
183
120
grass-respawn-rate
grass-respawn-rate
1
24
6
1
1
NIL
HORIZONTAL

SLIDER
13
152
185
185
primary-amount
primary-amount
0
500
500
2
1
NIL
HORIZONTAL

SLIDER
14
342
186
375
primary-reproduce
primary-reproduce
0
100
30
1
1
NIL
HORIZONTAL

SLIDER
13
188
185
221
secondary-amount
secondary-amount
0
500
300
2
1
NIL
HORIZONTAL

SLIDER
14
379
186
412
secondary-reproduce
secondary-reproduce
0
100
15
1
1
NIL
HORIZONTAL

PLOT
727
28
1235
371
Population v. Time
Ticks
Turtles
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Primaries" 1.0 0 -12895429 true "" "plot count primaries"
"Secondaries" 1.0 0 -14730904 true "" "plot count secondaries"
"Tertiaries" 1.0 0 -5298144 true "" "plot count tertiaries"
"Quaternaries" 1.0 0 -5825686 true "" "plot count quaternaries"
"Producers" 1.0 0 -10899396 true "" "plot count patches with [pcolor = green]"

SLIDER
14
416
186
449
tertiary-reproduce
tertiary-reproduce
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
13
225
185
258
tertiary-amount
tertiary-amount
0
500
62
2
1
NIL
HORIZONTAL

MONITOR
827
408
901
453
Primary
count primaries
17
1
11

MONITOR
905
408
982
453
Secondary
count secondaries
17
1
11

MONITOR
986
408
1056
453
Tertiary
Count tertiaries
0
1
11

MONITOR
728
408
797
453
Producers
count patches with [pcolor = green]
17
1
11

TEXTBOX
14
135
164
153
Select amounts to spawn: 
11
0.0
1

TEXTBOX
16
322
197
350
Then select reproduction rates (%): 
11
0.0
1

TEXTBOX
728
374
878
392
Trophic Levels: 
11
0.0
1

TEXTBOX
754
391
1150
419
1                                2                         3                        4                       5 
11
0.0
1

MONITOR
1060
408
1130
453
Quaternary
count quaternaries
17
1
11

SLIDER
14
264
186
297
quaternary-amount
quaternary-amount
0
500
10
2
1
NIL
HORIZONTAL

SLIDER
14
455
187
488
quaternary-reproduce
quaternary-reproduce
0
100
1
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The purpose of this model is to simulate the ten percent energy rule in a food chain. In food chains, the predator only gains about ten percent of the prey's energy. This pyramid effect leads to lower populations of upper-trophic-level predators. The goal of this simulation is to show how population fluxuates based on the ten percent energy rule and display the viability of a fifth trophic level in a simple food chain. 

## HOW IT WORKS

This model is based in Net Logo, and therefore uses a system of turtles (moving organisms that represent the population) and patches (background pixels of the environment). In this specific model, each trophic level is defined as a seperate breed or patch as follows:

Trophic Level......Description
1.......................(Producer) Green patches that represent grass
2.......................(Primary) White turtles with the "rabbit" shape 
3.......................(Secondary) Blue turtles with the "wolf" shape
4.......................(Tertiary) Red turtles with the "cat" shape
5.......................(Quaternary) Magenta turtles with the "hawk" shape

This model simulates the energy transfer between trophic levels using a simple one-sto predation system. If an organism/turtle of one trophic level encounters an organism of a trophic level below it, then the prey dies and roughly ten percent of its energy is given to the predator. 

Each organism begins the simulation with 1000 energy - an arbitrary amount with no corresponding scientific unit - and lose 50 energy per tick (unit of time in NetLogo). If an organism drops below 100 energy, then it dies. 

Also, each trophic level has the ability to reproduce. If reproduction occurs, then one identical turtle is hatched at a location near to the organism and the organism loses one third of its energy. 

In addition to the animal trophic levels, this model simulates the producer level using green, or grass, patches. These are consumed by the second trophic level and "die" or turn brown. After a selected amount of time (ticks), the grass regrows and becomes green and edible again. 

Together, the predation, energy, death and reproduction features allow simulation of population change in a food chain with the ten percent energy rule applied. However, because this is a rough simulation, it is important to run the model several times to ensure more accurate prediction. 

## HOW TO USE IT

There are various items on the interface tab that can manipulate the simulation:

SETUP : this button resets the model and creates the world. It is necessary to set your values for each trophic level before hitting setup

GO : this toggle able button can continuously run the simulation

KILL-GRASS : this button kills all the grass

GRASS-RESPAWN RATE : this variable set the rate at which grass respawns. One value is equal to one tick that it takes for grass to respawn

XXX-AMOUNT : this sets the the amount of organisms to be spawned at the start of the simulation. These four values (one for each animal trophic level) must be set before hitting the SETUP button. 

XXX-REPRODUCE : these four values correspond to each of the upper four trophic levels and is the percent chance for reproduction at a single tick. For example, if primary-reproduce is set at 50, then, at each tick, the primaries (rabbits) each have a 50% change to reproduce. 

To the right of the world display, there is a graph that illustrates the amount of each breed of turtle and grass producers present over time. Also, monitors are located below the graph to display the amount of each breed and grass at a specific time.   

## THINGS TO TRY AND NOTICE

Since this model is aimed at multiple-tier predation, it is important to notice how population changes over time and, for each breed, in relation to other breeds. 

Using this model, certain questions can be answered:

1. After the initial growth of the rabbits, what happens? For what two reasons might this occur?

2. Observe the simulation for a period of time. What do you notice about the population of each trophic level?  

3. What happens over time to the population of Tertiary and Secondary predators if you set the Tertiary-amount to a value significantly greater that Secondary-amount? In ecology, is having more tertiary predators than secondary organisms possible? 

4. After observing the simulation and population change, try finding values for XXX-AMOUNT and XXX-REPRODUCE at which population of trophic levels 2 through 4 begin to balance. How do these values relate to the ten percent energy rule? 

5. Based on this model, is a fifth trophic level possible?

6. Using the KILL-GRASS button repeatedly, how does removing all the grass affect the population of rabbit? How does a change in the rabbit population affect other trophic levels?  

## EXTENDING THE MODEL

There are several additional features possible to extend this model:

1. Adding factors of long-term and short-term weather patterns on producers (for example, seasons). 

2. Adding multiple organisms in one trophic level to create a complex food web rather than a simple food chain. 

3. Creating a more comprehensive reproduction system in which two organisms are required to reproduce. 
 
## RELATED MODELS

Wolf Sheep Predation Model (in the Biology Section of Models Library)

## CREDITS AND REFERENCES

This simulation was created by Joshua Abraham as part of Tracy High School's Biology curriculum. 

Credit to: 
Del Pabalan for advising this modeling project. 

Uri Wilensky for his "Wolf Sheep Predation" model that acted as a basis for this model. 


This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
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

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

hawk
true
0
Polygon -7500403 true true 151 170 136 170 123 229 143 244 156 244 179 229 166 170
Polygon -16777216 true false 152 154 137 154 125 213 140 229 159 229 179 214 167 154
Polygon -7500403 true true 151 140 136 140 126 202 139 214 159 214 176 200 166 140
Polygon -16777216 true false 151 125 134 124 128 188 140 198 161 197 174 188 166 125
Polygon -7500403 true true 152 86 227 72 286 97 272 101 294 117 276 118 287 131 270 131 278 141 264 138 267 145 228 150 153 147
Polygon -7500403 true true 160 74 159 61 149 54 130 53 139 62 133 81 127 113 129 149 134 177 150 206 168 179 172 147 169 111
Circle -16777216 true false 144 55 7
Polygon -16777216 true false 129 53 135 58 139 54
Polygon -7500403 true true 148 86 73 72 14 97 28 101 6 117 24 118 13 131 30 131 22 141 36 138 33 145 72 150 147 147

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

rabbit
false
0
Polygon -7500403 true true 61 150 76 180 91 195 103 214 91 240 76 255 61 270 76 270 106 255 132 209 151 210 181 210 211 240 196 255 181 255 166 247 151 255 166 270 211 270 241 255 240 210 270 225 285 165 256 135 226 105 166 90 91 105
Polygon -7500403 true true 75 164 94 104 70 82 45 89 19 104 4 149 19 164 37 162 59 153
Polygon -7500403 true true 64 98 96 87 138 26 130 15 97 36 54 86
Polygon -7500403 true true 49 89 57 47 78 4 89 20 70 88
Circle -16777216 true false 37 103 16
Line -16777216 false 44 150 104 150
Line -16777216 false 39 158 84 175
Line -16777216 false 29 159 57 195
Polygon -5825686 true false 0 150 15 165 15 150
Polygon -5825686 true false 76 90 97 47 130 32
Line -16777216 false 180 210 165 180
Line -16777216 false 165 180 180 165
Line -16777216 false 180 165 225 165
Line -16777216 false 180 210 210 240

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
