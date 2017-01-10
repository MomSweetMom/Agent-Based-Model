turtles-own [
  homdom?             ;; Person is homozygous dominant for the disease.
  het?                ;; Person is heterozygous for the disease.
  homrec?             ;; Person is homozygous recessive for the disease.
  coupled?            ;; Person is in a relationship.
  partner             ;; The person that is our current partner in a couple.
  num-children        ;; Number of children a couple has already had.
  couple-length       ;; How long a couple will stay together before separating.
  num-couples         ;; Number of couples a person has been in.
  age                 ;; Created to determine mother's age when giving birth.
]

to setup
  clear-all
  reset-ticks
  create-turtles numpeople
  ask turtles [set shape "person"
    setxy random-xcor random-ycor
    set coupled? false
    set partner nobody
    set num-children 0
    set couple-length 0
    set num-couples 0
        ifelse random 2 = 0
      [set shape "girl"]
      [set shape "boy"]
    assign-genotypes
    assign-colors
    ]

ask turtles [if (shape = "girl") [set age 0]]

end



to assign-genotypes

    ifelse (who < ( random-near .33 * numpeople)) [set homdom? true]
      [set homdom? false]
    ifelse ((homdom? = false) and (who < ( random-near .66 * numpeople))) [set het? true]
      [set het? false]
    ifelse ((homdom? = false) and (het? = false) and (who < numpeople)) [set homrec? true]
      [set homrec? false]
    if ((homdom? = false) and (het? = false) and (homrec? = false)) [die]


end



to assign-colors

 ask self [ if (homdom? = true) [set color blue]
          if (het? = true) [set color green]
          if (homrec? = true) [set color yellow]


 ]
end



to-report random-near [center]
  let result 0
  repeat 40
    [ set result (result + random-float center) ]
  report result / 20

end



to go
  ask turtles [if not coupled? [move]]
  ask turtles [if (not coupled? and shape = "girl" and random 100 = 0) [couple]]
  ask turtles [if coupled? [set couple-length couple-length + 1]]
  ask turtles [if (coupled? and shape = "girl" and num-children <= avg-num-children and random 75 = 0) [assign-child-genotype]]
  ask turtles [if (coupled? and shape = "girl" and num-children >= avg-num-children) [uncouple]]
  ask turtles [ assign-colors ]
  ask turtles [set age (age + .05 )]
  mutate
  if (count turtles > 2000) [ask n-of 50 turtles [if not coupled? [die]]]
  if %homdom >= 100 [stop]
  if %homrec >= 100 [stop]
  tick

end

to move
  let dice random 2
    let change (dice - 1)
    forward 2
    set heading (heading + change * 2)

end

to couple
  let potential-partner one-of (turtles-at -1 0)
                          with [(not coupled?) and shape = "boy"]
  if potential-partner != nobody
      [ set partner potential-partner
        set coupled? true
        set num-couples num-couples + 1
        ask partner [set num-couples num-couples + 1 ]
        ask partner [ set coupled? true ]
        ask partner [ set partner myself ]
        move-to patch-here
        ask potential-partner [move-to patch-here]
        set pcolor gray - 3
        ask (patch-at -1 0) [ set pcolor gray - 3 ] ]

end



to assign-child-genotype
 ask self [
  if (homdom? and coupled? and age < mothers-age) [ask partner [if (homdom? and coupled?)                     ;; BB x BB pairing
    [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
  if (homdom? and coupled? and age > mothers-age)
    [ifelse (random 100 = 0)
     [hatch 1 [set homrec? true
         set het? false
         set homdom? false
         set shape "person"
         setxy random-xcor random-ycor
         set coupled? false
         set partner nobody
         set num-children 0
         set couple-length 0
         set age 0
         ifelse random 2 = 0 [set shape "girl"]
         [set shape "boy"]]]
     [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]

  let dice random 4
   ask self [
     if het? and coupled? and age < mothers-age [ask partner [if (homdom? and coupled? and dice > 2)           ;; BB x Bb pairing
    [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
     if het? and coupled? and age > mothers-age
     [ifelse (random 100 = 0) [ask partner [if (homdom? and coupled? and dice > 2)
    [hatch 1 [set homdom? false
        set het? false
        set homrec? true
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (homdom? and coupled? and dice > 2)
        [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]]]

     if het? and coupled? and age < mothers-age [ask partner [if (homdom? and coupled? and dice < 2)
    [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
   if het? and coupled? and age > mothers-age
    [ifelse (random 100 = 0) [ask partner [if (homdom? and coupled? and dice < 2)
    [hatch 1 [set het? false
        set homdom? false
        set homrec? true
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (homdom? and coupled? and dice < 2) [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]]

     if homrec? and coupled? and age < mothers-age [ask partner [if homdom? and coupled?                    ;; BB x bb pairing
   [hatch 1 [set het? true
       set homdom? false
       set homrec? false
       set shape "person"
       setxy random-xcor random-ycor
       set coupled? false
       set partner nobody
       set num-children 0
       set couple-length 0
       set age 0
       ifelse random 2 = 0 [set shape "girl"]
       [set shape "boy"]]]]]
if homrec? and coupled? and age > mothers-age
   [ifelse (random 100 = 0) [ask partner [if homdom? and coupled?
   [hatch 1 [set het? false
       set homdom? false
       set homrec? true
       set shape "person"
       setxy random-xcor random-ycor
       set coupled? false
       set partner nobody
       set num-children 0
       set couple-length 0
       set age 0
       ifelse random 2 = 0 [set shape "girl"]
       [set shape "boy"]]]]]
   [ask partner [if homdom? and coupled? [hatch 1 [set het? true
       set homdom? false
       set homrec? false
       set shape "person"
       setxy random-xcor random-ycor
       set coupled? false
       set partner nobody
       set num-children 0
       set couple-length 0
       set age 0
       ifelse random 2 = 0 [set shape "girl"]
       [set shape "boy"]]]]]


  let chance random 2
  ask self [
   if het? and coupled? and age < mothers-age [ask partner [if (het? and coupled? and chance = 0)            ;; Bb x Bb pairing
    [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    if het? and coupled? and age > mothers-age
    [ifelse (random 100 = 0) [ask partner [if (het? and coupled? and chance = 0)
    [hatch 1 [set homdom? false
        set het? false
        set homrec? true
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (het? and coupled? and chance = 0) [hatch 1 [set homdom? true
        set het? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]]]

   if het? and coupled? and age < mothers-age [ask partner [if (het? and coupled? and chance = 1)
    [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
   if het? and coupled? and age > mothers-age
    [ifelse (random 100 = 0) [ask partner [if (het? and coupled? and chance = 1)
    [hatch 1 [set het? false
        set homdom? false
        set homrec? true
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (het? and coupled? and chance = 1) [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]]]

let chance random 2
   if het? and coupled? and age < mothers-age [ask partner [if (het? and coupled? and chance = 2)
    [hatch 1 [set homrec? true
        set homdom? false
        set het? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
   if het? and coupled? and age > mothers-age
   [ifelse (random 100 = 0) [ask partner [if (het? and coupled? and chance = 2)
    [hatch 1 [set homrec? true
        set homdom? false
        set het? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (het? and coupled? and chance = 2) [hatch 1 [set homrec? true
        set homdom? false
        set het? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]]

   if het? and coupled? and age < mothers-age [ask partner [if (homrec? and coupled? and chance > 1)         ;; Bb x bb pairing
    [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
   if het? and coupled? and age > mothers-age
   [ifelse (random 100 = 0) [ask partner [if (homrec? and coupled? and chance > 1)
    [hatch 1 [set het? false
        set homdom? false
        set homrec? true
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]
    [ask partner [if (homrec? and coupled? and chance > 1) [hatch 1 [set het? true
        set homdom? false
        set homrec? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]

   if het? and coupled? [ask partner [if (homrec? and coupled? and chance < 1)
    [hatch 1 [set homrec? true
        set homdom? false
        set het? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]

   if homrec? and coupled? [ask partner [if homrec? and coupled?                    ;; bb x bb pairing
    [hatch 1 [set homrec? true
        set homdom? false
        set het? false
        set shape "person"
        setxy random-xcor random-ycor
        set coupled? false
        set partner nobody
        set num-children 0
        set couple-length 0
        set age 0
        ifelse random 2 = 0 [set shape "girl"]
        [set shape "boy"]]]]]

  ]


set num-children num-children + 1
ask partner [set num-children num-children + 1]


end


to uncouple
  if coupled? and (shape = "girl")
    [if ((num-children >= avg-num-children) or (couple-length >= avg-couple-length))
        [ set coupled? false
          set couple-length 0
          ask partner [set couple-length 0]
          set pcolor black
          ask (patch-at -1 0) [ set pcolor black ]
          ask partner [ set partner nobody ]
          ask partner [ set coupled? false
            ifelse num-couples >= avg-num-couples [die]
            [move]]
          set partner nobody]]
    ifelse num-couples >= avg-num-couples [die]
           [move]

end

to mutate
  if random-float 1000 < mutation-rate [ask one-of turtles [if (homdom? = true)
    [set homdom? false
      set het? false
    set homrec? true]]]
end


to-report count-girls
  report count turtles with [shape = "girl"]
end



to-report count-boys
  report count turtles with [shape = "boy"]
end



to-report %homdom
  report count turtles with [homdom? = true] / count turtles
end



to-report %het
  report count turtles with [het? = true] / count turtles

end



to-report %homrec
  report count turtles with [homrec? = true] / count turtles
end



to-report num-dom-allele
  report ( ((count turtles with [homdom? = true]) * 2 ) + (count turtles with [het? = true])) / (count turtles * 2)
end



to-report num-rec-allele
 report ( ((count turtles with [homrec? = true]) * 2) + (count turtles with [het? = true])) / (count turtles * 2)
end
@#$#@#$#@
GRAPHICS-WINDOW
386
23
864
522
12
12
18.72
1
10
1
1
1
0
1
1
1
-12
12
-12
12
1
1
1
weeks
30.0

SLIDER
95
54
282
87
avg-num-children
avg-num-children
0
5
3
1
1
NIL
HORIZONTAL

SLIDER
104
96
276
129
numpeople
numpeople
0
500
230
10
1
NIL
HORIZONTAL

BUTTON
911
106
977
139
NIL
setup\n
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
914
156
977
189
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
8
377
331
595
Genotype
time
people
0.0
100.0
0.0
100.0
true
true
"" ""
PENS
"Hom Rec" 1.0 0 -1184463 true "" "plot count turtles with [homrec? = true]"
"Heterozygous" 1.0 0 -13840069 true "" "plot count turtles with [het? = true]"
"Hom Dom" 1.0 0 -13345367 true "" "plot count turtles with [homdom? = true]"

MONITOR
133
258
190
303
NIL
ticks
17
1
11

MONITOR
20
318
99
363
% Hom Rec
((count turtles with [homrec? = true]) / count turtles) * 100
4
1
11

MONITOR
135
319
201
364
% Hetero
(count turtles with [het? = true] / count turtles) * 100
4
1
11

MONITOR
237
320
323
365
% Hom Dom
(count turtles with [homdom? = true] / count turtles) * 100
4
1
11

SLIDER
191
10
363
43
avg-couple-length
avg-couple-length
20
1400
1000
10
1
NIL
HORIZONTAL

MONITOR
487
540
761
585
coupled?
count turtles with [coupled? = true]
17
1
11

MONITOR
235
609
321
654
# Hom Dom
count turtles with [homdom? = true]
17
1
11

MONITOR
138
608
204
653
# Hetero
count turtles with [het? = true]
17
1
11

MONITOR
21
608
100
653
# Hom Rec
count turtles with [homrec? = true]
17
1
11

MONITOR
488
607
601
652
Dom Allele Freq.
num-dom-allele
3
1
11

MONITOR
655
607
761
652
Rec Allele Freq.
num-rec-allele
3
1
11

SLIDER
107
139
279
172
avg-num-couples
avg-num-couples
0
5
3
1
1
NIL
HORIZONTAL

MONITOR
774
540
867
585
NIL
count turtles
17
1
11

SLIDER
5
10
177
43
mutation-rate
mutation-rate
0
50
9
1
1
%
HORIZONTAL

SLIDER
106
182
278
215
mothers-age
mothers-age
18
50
32
1
1
years
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is a simplistic simulation of the spread of a genetic disease with an autosomal recessive inheritance pattern in a small, isolated human population. It illustrates how allelic frequencies vary from generation to generation.

Genetic inheritance has risen to prominence as medical professionals have realized the implications of family health knowledge. Genetic diseases, indicators of heart, blood. and addiction problems, and even certain cancers can be predicted and measures can be taken to prevent their onset. Although genetic diseases are considered rare, twenty percent of all infant deaths are due to birth defects and genetic conditions.There are between 6,000 and 18,000 known single-gene disorders, affecting one in every 200 births, and only a small fraction of these have treatments. Additional study in this field could lead to the production of a wider range of more effective treatments and perhaps even cures for genetic diseases.

The model examines the effects of certain variables on the allelic frequencies of the gene pool. The user controls several aspects of the child-bearing relationships modeled. Exploration of these variables can provide insight into the genetic trends scientists have observed in natural populations and show why recessive genes cannot become completely extinct.

## HOW IT WORKS

The model uses "couples" to represent two people in a committed relationship. Individuals wander around the world when they are not in couples. Upon coming into contact with a partner, the two individuals "couple" together. When this happens, the two individuals no longer move about, and instead stand next to each other holding hands as a representation of their child-bearing relationship.

Once in a couple, the two genotypes of the "parents" are considered before a child is born, and the child is then assigned a genotype based on Punnett square predictions of the parents' offspring. It is a 50/50 chance between the child being born a girl or boy.

The genotypes of the individuals in the population are represented by the colors of the individuals. Three colors are used: blue individuals are homozygous dominant (AA), green individuals are heterozygous (Aa), and yellow individuals are homozygous recessive (aa).

## HOW TO USE IT

The SETUP button creates individuals with certain genotypes and randomly distributes them throughout the world. Once the simulation has been setup, it is now ready to run. The GO button starts the simulation and runs it continuously, with a carrying capacity set at 2,000 individuals.

Monitors show the percentage of individuals with each genotype as well as the frequency of each allele in the population. In this model each timestep is considered one month; the number of months that have passed is shown in the toolbar.

Here is a summary of the sliders in the model. They are explained in more detail below.

	- numpeople
	- avg-num-children
	- avg-couple-length
	- mutation-rate
	- avg-num-couples
	- mothers-age

Numpeople is used to determine the initial population at the start of the simulation. Smaller populations occasionally exhibit genetic drift (tendency towards either homozygous dominant or recessive).

Avg-num-children is used to determine the average number of children a couple will have before splitting up. More children means more variety.

Avg-couple-length is used to determine the amount of time a couple has spent in a relationship.

Mutation rate is used to determine how often a de novo mutation arises in a "healthy" individual, causing them to contract the disease.

Avg-num-couples is used to determine how many child-bearing relationships one person will be in before they die.

Mothers-age is used to determine the risk of chromosomal abnormalities depending on the age of the mother at the time of birth.

The model's plot shows the total number of individuals (color), the number of homozygous dominant individuals (blue), the number of heterozygous individuals (green), and the number of homozygous recessive individuals (yellow).

## THINGS TO NOTICE

If certain variables are set at low values, the population could eventually die out.
As in real life, the dominant allele usually becomes more frequent in the gene pool than the recessive allele unless the mutation rate is unnaturally high. However, the recessive allele never truly becomes extinct due to de novo mutations and preservation through heterozygous carriers.
One year is considered 20 ticks in the simulation.

## THINGS TO TRY

Run a number of experiments with the GO button to find out the effects of different variable on the dominant and recessive allele frequencies. In addition to changing one variable at a time, try changing multiple variables together to see if those factors interact at all.

Form hypotheses about how allelic frequencies will change with the adjustment of different variables and then test these to see if the results match your expectations.

A few real-world values for some of the variables are included below:

avg-num-children:
	U.S.A - between 1 and 2
        Latin America - between 2 and 3
        Middle East - between 3 and 5

avg-num-couples: roughly 1

avg-couple-length (USA): 45 years (1080 ticks)

mutation-rate: 2.22%

## EXTENDING THE MODEL

Like all computer simulations of human behaviors, this model has necessarily simplified its subject area substantially. The model therefore provides numerous opportunities for extension:

The model depicts a very simplistic gene at one locus controlled entirely by two alleles which exhibit complete dominance. In the real world, many genetic diseases are caused by a myriad of different factors.

The model depicts an autosomal genetic disease. To extend the model further, one could model an x-linked disease or a case of genomic imprinting (expression of allele in offspring depends on whether allele is inherited from male or female parent).

## CREDITS AND REFERENCES

All statistics in the Info tab come from the Centers for Disease Control and Prevention.
The AIDS model in the NetLogo library was particularly helpful in setting up the coupling procedure:
	Wilensky, U. (1997). NetLogo AIDS model. http://ccl.northwestern.edu/netlogo/models/AIDS. Center for Connected Learning and Computer-Based Modeling, Northwestern Unversity, Evanston, IL.
None of this would have been possible without the internship opportunity provided by the SEAP program and my mentor, Prof. Sanchez.
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

boy
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 195 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 135 79 165 90
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

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

girl
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 165 75 270 75 285 135 285 165 285 225 285 225 270 180 165 195 90
Rectangle -7500403 true true 135 75 165 90
Polygon -7500403 true true 195 90 240 150 240 180 165 105
Polygon -7500403 true true 105 90 60 150 60 180 135 105

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
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="4000"/>
    <metric>count turtles</metric>
    <metric>num-dom-allele</metric>
    <metric>num-rec-allele</metric>
    <metric>%homdom</metric>
    <metric>%het</metric>
    <metric>%homrec</metric>
    <enumeratedValueSet variable="avg-couple-length">
      <value value="100"/>
      <value value="1000"/>
      <value value="2000"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-couples">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-children">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numpeople">
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
      <value value="400"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 2" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>%homdom</metric>
    <metric>%het</metric>
    <metric>%homrec</metric>
    <metric>num-dom-allele</metric>
    <metric>num-rec-allele</metric>
    <enumeratedValueSet variable="avg-couple-length">
      <value value="100"/>
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-children">
      <value value="2"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-couples">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="2"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numpeople">
      <value value="100"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mothers-age">
      <value value="25"/>
      <value value="32"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 3" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>%homdom</metric>
    <metric>%het</metric>
    <metric>%homrec</metric>
    <metric>num-dom-allele</metric>
    <metric>num-rec-allele</metric>
    <enumeratedValueSet variable="avg-couple-length">
      <value value="600"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-children">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="avg-num-couples" first="1" step="1" last="5"/>
    <enumeratedValueSet variable="mutation-rate">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numpeople">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mothers-age">
      <value value="32"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 4" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2000"/>
    <metric>%homdom</metric>
    <metric>%het</metric>
    <metric>%homrec</metric>
    <metric>num-dom-allele</metric>
    <metric>num-rec-allele</metric>
    <enumeratedValueSet variable="avg-couple-length">
      <value value="100"/>
      <value value="600"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-couples">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numpeople">
      <value value="100"/>
      <value value="300"/>
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-rate">
      <value value="2"/>
      <value value="5"/>
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-children">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mothers-age">
      <value value="25"/>
      <value value="29"/>
      <value value="32"/>
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
