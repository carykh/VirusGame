# VirusGame
## Original Game
Video: [YouTube](https://www.youtube.com/watch?v=o1IheoDRdGE)
Code: [GitHub](https://github.com/carykh/VirusGame)
## About this fork

- Adding, Deleting and Drag&Drop in the genome editor

- The genome editor will scroll if a cell has too many codons to fit the screen

- Copy/Paste in and out of the genome editor. (if you paste and nothing happens, the formatting of you genome string is erroneous; note the format changes mentioned above) - use this to save you written genomes

- The coding of the Codon now is OOP, it is much easier to add more

- Lots of new Codon types. With this it is now possible to write a cell that can defend itself against viruses.

- Writing 'Epigenetics' onto the gene codons. (`MemTo` & `MemoryLocation`)

- `HandMove Degree` (0, 90, 180, 270, or any other degree)

- Debug mode to experiment with writing genomes without worrying about the cell dying. You can activate it by changing `DEBUG_WORLD = false;` to `DEBUG_WORLD = true;` It is the first line of virus.pde

- Change game speed (fixed, orig. forked from [LegendaryHeart8](https://github.com/LegendaryHeart8))

- Resizeable window size (fixed, orig. forked from [Games-Crack](https://github.com/Games-Crack))

- Various improvements by [magistermaks](https://github.com/magistermaks)

   - Mutations (WIP)

   - Better GUI (graphics, graph, divine controls, etc)

   - Rendering optimisations

   - Settings (+ map editing - world.json)

   - Keyboard controls

   - New cell types
  
 - WASD & Arrow Pad panning (by [ben9583](https://github.com/ben9583))


## Breaking changes

- if you want to move the hand to the cursor you must use `Move Hand Cursor` instead of `Move Hand RGL(0,0)`. RGL is always relative to the hand for hand specific commands

- Also the encoding of the Genome is slightly different to the original, but everything besides the way RGL are saved is the same way.


## Plans:

- Clone (reproduces the cell adjacent to the wall the hand is pointing at)

- Inject - inject a particle into a neighboring cell the hand is pointing at

- Check - see if Energy, Wall health, Codon health is over 50%

- Fix rendering bugs occurring at high simulations speeds


Tell me what other codons you want to see!

## Run Standalone
1. Download the newest version [here](https://github.com/sirati97/VirusGame/releases/)
2. Make sure you have Java installed
3. Run the file

## How to run in Processing
1. Download [Processing](https://processing.org/) (3.5.4 tested, versions after 3.3.3 might work)
2. Open the "virus.pde" file in the "/source/virus" directory.


## How to run in IntelliJ
1. Clone the project with [IntelliJ](https://www.jetbrains.com/idea/)'s Github support
2. Import the gradle project
3. Go source/virus/JavaLoader and click the green arrow

Btw, the Ultimate edition is free if you visit a school, collage or university. 


## License
Code written by me falls under the GPLv3. However, this repo contains code by other who did not provide any license for their code! bad bad
