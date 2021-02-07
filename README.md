# ABAP quiz and paint game

## Rules of the game

The game runs over several rounds. You have to choose from three answers to a question per round. One answer is correct. If you give the right answer you are allowed to paint something in 8-bit retro style on ALV cells. At the end the painting will be saved as a screenshot to your desktop. So you can show you colleagues your skills and highscores :-)

## Technical stuff

### Development system

SAP NetWeaver v7.52

### Development objects

The game consists of a bunch of local classes in one report:

* LCX_ERROR: for exception handling
* LCL_SCREENSHOT: creates and saves screenshots
* LCL_QUESTIONS: provides questions from from [include](https://github.com/Keller-Michael/ABAP_quiz_and_paint_game/blob/main/src/zqpg_questions_and_answers.prog.abap) 
* LCL_SCREEN: screen handling is made with CL_SALV_TABLE
* LCL_LOGIC: implements game logic
* LCL_GAME: holds everything together

### More questions and answers

Just enhance this [include](https://github.com/Keller-Michael/ABAP_quiz_and_paint_game/blob/main/src/zqpg_questions_and_answers.prog.abap). 
