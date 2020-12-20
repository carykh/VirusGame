# VirusGame
## Original Game
Video: [YouTube](https://www.youtube.com/watch?v=o1IheoDRdGE)
Code: [GitHub](https://github.com/carykh/VirusGame)
## About this fork



Other improvements I have made:

- Adding, Deleting and Drag&Drop in the genome editor

 - The genome editor will scroll if a cell has to many codons to fit the screen

 - Copy/Paste in and out of the genome editor. (if you paste and nothing happens, the formatting of you genome string is erroneous; note the format changes mentioned above) - use this to save you written genomes

 - The coding of the Codon now is OOP, it is much much easier to add more

 - I added a lot of new Codon types. With this it is now possible to write a cell that can defend itself against viruses. I am still working on writing the genome for one that can. If you want to try out what i got so far, this is able to find two locations in the genome and then compare the genome starting from these two locations (46-33-07k0-45-d93-993-4b-47a0-0a1-ba1-890-490-47a0-ba1-891-590-a91-9720-77a0-490-4710-890-491-4710-891-4b-47J0-893-7750-00-00-00-00-0a1-b0-00-00-00-00-ba1-46-33-33) - this is for running it in debug more, the cell cannot survive on its own yet)

 - Debug mode to experiment with writing genomes without worrying about the cell dying. You can activate it by changing DEBUG_WORLD = false; to DEBUG_WORLD = true; It is the first line of virus.pde

 - Change game speed (forked and fixed from [LegendaryHeart8](https://github.com/LegendaryHeart8))

 - Revive cells (forked from [basti564](https://github.com/basti564))

 - Resizeable window size (forked from [Games-Crack](https://github.com/Games-Crack))

## Breaking changes

- if you want to move the hand to the cursor you must useMove Hand Cursorinstead ofMove Hand RGL(0,0)RGL is always relative to the hand for hand specific commands

= Also the encoding of the Genome is slightly different to the original, but everything besides the way RGL are saved in the same way.


## Plans:

 - Clone (reproduces the cell adjaadjacent to the wall the hand is pointing at)

 - HandMove Direction(0, 90, 180, 270 degree)

 - Inject - inject a particle into a neighboring cell the hand is pointing at

 - Check - see if Energy, Wall health, Codon health is over 50%


Tell me what other codons you want to see!



## How to run
1. Download [Processing](https://processing.org/) (every version after 3.3.3 should work)
2. Open the "virus.pde" file in the "virus" directory.
