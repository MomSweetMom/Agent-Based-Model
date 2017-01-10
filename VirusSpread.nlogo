breed [people individual]  ; creates people
breed [spreads spread] ; creates the spread of virus 
spreads-own [age]
people-own [
  health
  infected ]


to setup
  clear-all
  reset-ticks
  ask patches [set pcolor 48] 
  set-disease-point
  set-default-shape people "person"
  create-people nPeople
  [ setxy random-xcor random-ycor
    set health MaxHealth + random 2000
    set color blue
    set infected false
    create-links-with n-of Family_links other people
  ]  
  if show-link? = false [
    ask people [ask my-links [hide-link] ] ]
  
end


to go
 ask people [ move
              if health < 0 [die] ]
 
 ask patches with [pcolor = red - 1] [ if spread? [ make-spread ] ]
 ask spreads [ spread-move spread-attach grow-up ]
 ifelse show-spread? [ ask spreads [ show-turtle ] ]
                     [ ask spreads [ hide-turtle ] ]
                
 tick
 if ticks > 1000 [stop]
 
end


to set-disease-point ; disease places
  ; ask n-of npatches patches [set pcolor red - 1]
  ; ask n-of nPlace patches [ask n-of nVirus patches [set pcolor red - 1]]
  if Area-radius = 0 [
    ask n-of nVirus patches [set pcolor red - 1] ] 
  ask n-of nPlace patches [ask n-of nVirus patches in-radius Area-radius [set pcolor red - 1]]  
   
end


to move
  rt random-float 360
  lt random-float 360
  fd 0.5
  if (pcolor = red - 1) or (pcolor = red + 1) [ 
    set health health - 1 
    if random 100 > notInfected  [
       if (antibiotic * random 2 > 100) [ set infected false ]    
       set infected true 
       set color green 
    ] 
  ]
  
  if infected = true [ set health health - 100 * lethal-amount ]
  let ptt patch-here
  ask link-neighbors with [color != blue] [move-to one-of patch-set ptt]

end

to make-spread  
    sprout-spreads spread-production
    [
      set color magenta
      set size .5
      set age 0
    ]
end

to spread-move  
  if color = magenta
  [
     right random 360 forward spread-speed
  ]
end

to spread-attach 
  if pcolor = 48  
  [
    if random 100 < attachment-probability
    [
      set pcolor red + 1
    ]
  ]   
   
end

to grow-up ; 
  ifelse age = degradation-time [ die ]
                                [ set age age + 1 ]
  
end
@#$#@#$#@
GRAPHICS-WINDOW
421
10
839
449
25
25
8.0
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
18
22
94
88
SETUP
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
109
22
184
88
GO
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

SLIDER
17
103
189
136
nPeople
nPeople
1
2000
1109
1
1
NIL
HORIZONTAL

SLIDER
15
287
187
320
nVirus
nVirus
1
149
107
1
1
NIL
HORIZONTAL

PLOT
857
10
1057
160
Infected People
NIL
NIL
0.0
40.0
0.0
400.0
true
false
"" ""
PENS
"pen-1" 1.0 0 -14439633 true "" "plot count people with [color = green]"

SWITCH
207
52
303
85
spread?
spread?
0
1
-1000

MONITOR
857
188
914
233
People
count people
0
1
11

MONITOR
926
188
984
233
Green
count people with [color = green]
17
1
11

MONITOR
999
187
1056
232
Blue
count people with [color = blue]
17
1
11

SLIDER
15
333
187
366
Family_links
Family_links
0
5
1
1
1
NIL
HORIZONTAL

SLIDER
15
241
187
274
Area-radius
Area-radius
0
10
0
1
1
NIL
HORIZONTAL

SLIDER
16
194
188
227
nPlace
nPlace
0
10
0
1
1
NIL
HORIZONTAL

SWITCH
206
98
350
131
show-spread?
show-spread?
0
1
-1000

SLIDER
206
149
378
182
lethal-amount
lethal-amount
0
10
4
1
1
NIL
HORIZONTAL

SLIDER
206
195
378
228
spread-speed
spread-speed
0
1.0
0.115
0.001
1
NIL
HORIZONTAL

SLIDER
206
240
378
273
spread-production
spread-production
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
206
286
378
319
degradation-time
degradation-time
0
20
11
1
1
NIL
HORIZONTAL

SLIDER
206
331
402
364
attachment-probability
attachment-probability
0
100
17
1
1
NIL
HORIZONTAL

SLIDER
15
148
187
181
MaxHealth
MaxHealth
1000
100000
100000
1000
1
NIL
HORIZONTAL

SWITCH
15
425
139
458
show-link?
show-link?
1
1
-1000

TEXTBOX
208
424
358
480
Set nPlace = 0 & Area-radius = 0 to have a point of desease rather than areas of intial infection
11
32.0
1

SLIDER
15
376
187
409
Antibiotic
Antibiotic
0
100
45
1
1
NIL
HORIZONTAL

SLIDER
206
376
378
409
notInfected
notInfected
1
100
80
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The purpose of the model is to describe the spreading of virus or disease among a population

## HOW IT WORKS

The virus or disease can be initiated with a accumulated area or specific point 
according to the initial setup as RED tile. Then the virus or disease starts to spread out the whole area with factors related to the virus or disease such as spread-spead, spread-production, degradation-time (as disease becomes less effective or die out due to its nature or climate or better antibiotics) ... This spreading can be seen as PURPLE arrow. This arrow then enter surrounding area and spread the disease, making these area lighter RED.  

People within that population can move freely. Each one attached to a family of his or her own. He or she may have contact with the disease and then become infected. BLUE person is not infected. GREEN person is infected

The plot shown the the growth disease and population decrease overtime

## HOW TO USE IT

Using sliders to set number of people inside the population
The desease can be clustered into number of place (nPlace) , area (AreaRadius) and the number of virus in each place (nVirus)

Each person has a number of family members (family_link), this one can increase chances of infection. The link can be show or not (show-link?). The (Antibiotic) means the percentage of using antibiotic of each person.

(Lethal-amount) of the virus can kill people faster
(Spread-speed), (Spread-production) can be adjust with various options

(Degradation time) The living time of the spread (PURPLE)

(Attachement-probability) is the ability of virus can be infected to surrounding area (from the RED tile to lighter RED tile)

(notInfected) is the chance a person cannot be infected by the disease.

## THINGS TO NOTICE

Set nPlace = 0 & Area-radius = 0 to have a point of desease rather than areas of intial infection

## THINGS TO TRY

Difference combination of the setup will produce very different outcome
 
## EXTENDING THE MODEL

Disease can be infected by different ways (water, air, animals) to combine 
the effect of infection   

## NETLOGO FEATURES


## RELATED MODELS

Bacterial competition, Job hunt 

## CREDITS AND REFERENCES

Trung Hoang
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
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hunters with [color = blue]</metric>
    <enumeratedValueSet variable="Maxenergy">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nhunters">
      <value value="1500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="npatches">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dist">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MaxLink">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="Maxenergy">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nhunters">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="npatches">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dist">
      <value value="2"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hunters with [color = blue]</metric>
    <enumeratedValueSet variable="dist">
      <value value="65"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="collaborate?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="npatches">
      <value value="46"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nhunters">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Maxenergy">
      <value value="1000"/>
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
