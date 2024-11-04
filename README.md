# Big-Data-Bowl-25

## Brainstorming
* Bluff %: When the defense shows blitz, how often do they actually bring it?
* Separation Added: Compare receiver separation w/motion vs without
* Expected Success Rate: Given the both teams alignments pre-snap, how many yards do we expect the offense to gain on this play?
    * Supervised classification problem (Pre-snap positions -> offensive formation, defensive pass coverage)
    * Supervised regression problem ([offensive formation, defensive passcoverage] -> expected yards)
    * Alternatively, can attempt to jump straight from pre-snap positions to expected yards
* Expected Time to Throw: Based on pre-snap alignment, how much time does QB have to throw the ball before a sack?
* Route prediction: Based on a receiver's alignments, what routes is he likely to run?
    * Routes charted in the player_plays data: {ANGLE, CORNER, CROSS, FLAT, GO, HITCH, IN, OUT, POST, SCREEN, SLANT, WHEEL}
* Motion Vulnerability: How much more EPA a team gives up on plays with motion vs comparable static plays
    * Can compare more than just EPA, look at separation, pass rush, run yards
* Effect of linemen sets on run play success
* Analyzing punt plays (block probability, return success rate)
    * Can't, dataset excludes special teams plays

## Outline/Pseudocode
1. Data Prep
    1. Select all pass plays (plays.csv[isDropback] -> gameId+playID -> filter(tracking_data))
    2. Standardize player tracking data (x relative to LOS, orientation relative to QB)
    3. Label all blitzes (5+ defenders cross LOS)
        a. Identify players who blizted
    4. Cross-check with Pro-Football-Reference blitz data
2. Blitz Prediction
    1. Supervised learning problem:
        a. Input: Pre-snap player tracking data (11x5xframes tensor)
        b. Output: Blitz probability/classification

