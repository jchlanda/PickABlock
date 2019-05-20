# PickABlock
I do a lot of climbing at a section of the wall that is completely covered with holds. While there are some problems set there, I spend most of the time climbing my own problems/circuits. I find it hard to remember individual problems, especially, as the time passes and the number of problems grows. As a solution (or workaround, if you like), I was taking pictures of the wall and [doodling the problems on them](https://github.com/jchlanda/PickABlock/blob/readme_assets/readme_assets/LT_11.jpg). Being a programmer I am, I soon came to the conclusion that there must be a better way and PickABlock was born. Now is the right time for a little disclaimer, this is a poor man's version of [Stokt](https://www.getstokt.com/) and if you can use it (they will be adding support for home walls soon) you probably should; Stokt is infinitely better than a humble PickABlock. And while I do programming for living app design and working with swift saw me venturing into the unknown (give me a shout if you ever need a compiler backend for your new generation of a chip and I'll shine). With that out of the way, here are more details on PickABlock.

## Intended use case
<img align="right" width="404" height="720" src="https://github.com/jchlanda/PickABlock/blob/readme_assets/readme_assets/PickABlock.gif">

PickABlock provides three main views:
* `Set`,
* `Browse`,
* `Settings`.
### Set view
The idea is simple, tap a hold to enroll it to the current problem. Long press on it to bring a set special menu, that allows for adding a special labels:
* `Begin`,
* `End`,
* `Feet only`,
* or back to `Normal`.

The window also lets for `Sticky` switch to be set, handy if you have a whole bunch of, say `Feet only` holds to set and you don't want to long press each of them.
When the problem is ready, click `Submit`. The app asks if you would like to `Add overlays?`. When I set a longer problem/circuit I often do it in a way in which it goes up and down the wall a couple of times, in order to know the flow of the problem I add a doodle on top of the problem - an `overlay`. Overlays are scribbled with a finger, as you add them the app maintains a stack, so it is possible to undo/redo in case of an error. There is an algorithm that simplifies overlay's path, so the total number of points per overlay is manageable. When done hit `Submit` one more time, enter the problem's name and you are done, ta-da! your climb added to user defined problems (more on it later).
### Browse view
This view loops over the array of known problems, displaying them one at a time. Under the hood PickABlock knows about two different groups of problems: `Built In Problems` and `User Defined Problems`. The split is intentional, built-in ones come with the app and are baked into the binary as you build it (they live [here](https://github.com/jchlanda/PickABlock/blob/master/app/PickABlock/PickABlock/KnownProblems.json)). Users can not remove those. User defined ones are stored only on your device (the app does not synchronise with a global server); those can be freely removed. It is possible to edit each problem, just tap on `Edit` button and it will take you to the `Set view` with holds/overlays pre-populated with the correct problem.
### Settings view
This is the place to manage the problems. At the top there is a box showing all of the built-in problems (encoded as a json string), followed bu user defined ones (again in json). Next a box to paste any predefined problems do be added manually. Something worth noticing, each view has a share button in the top right corner (for `Set` ans `Browse` only current problem is exported, `Settings` view exports all known problems), that generates a text based representation that can be pasted into `Add manually` box. If you happen to have a friend and that friend happen to be climbing on the same wall as you that's the way you would share the climbs. Intended use is that once you get a problem of you friend (say by receiving a text message containing json string), you paste it to `Add manually` box and it gets added to the list of user defined problems. If you maintain the app for a group of people I suggest keeping the list of global problems [in the built in section](https://github.com/jchlanda/PickABlock/blob/master/app/PickABlock/PickABlock/KnownProblems.json), so they can't be removed by mistake. The last button, as the name suggests, purges duplicates from the list of known problems.

And that, essentially, is it, PickABlock at a glance!

## Building your own PickABlock
Before you set of, make sure that you have access to the following:
* [Gimp](https://www.gimp.org/),
* [svgpathtools](https://github.com/mathandy/svgpathtools) python module (available for both python 2 and 3),
* [XCode](https://developer.apple.com/xcode/).

The integration of your own wall can be done in 5 simple steps:
1. Add wall picture.
Take a picture of the wall that you intend to climb on. It's a good idea to crop it to have the same ratio as the area dedicated for the picture in `Set` and `Browse` views (on iPhone 7 it is `638 × 1024`). This picture lives in [AlienRock2.jpg](https://github.com/jchlanda/PickABlock/blob/master/app/PickABlock/PickABlock/Assets.xcassets/AlienBlockAR2.imageset/AlienBlockAR2.jpeg) (if you decide to change the name of that file make sure to update it in the source code as well).
2. Create paths representing the holds.
This is done in order to let the app know where the holds on the wall are. There is very little fancy about this, in fact it is dead simple (and a bit laborious). Open your image in Gimp select: `Path Tool: Create and edit paths B` form the toolbox menu and create a path for each and every hold on your wall, make sure that each path forms a loop. When done right click on your path layer in the `Paths` tab and select `Export Path...`, provide the name, say `AlienRock2.svg`.
See the picture for details:
![Gimp help](https://github.com/jchlanda/PickABlock/blob/readme_assets/readme_assets/gimp_help.png)
3. Parse svg file.
Gimp creates an `svg` file of the following form:

    ```xml
    <?xml version="1.0" encoding="UTF-8" standalone="no"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
                  "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
    
    <svg xmlns="http://www.w3.org/2000/svg"
         width="2.12667in" height="3.41333in"
         viewBox="0 0 638 1024">
      <path id="AlienBlockAR2SVG"
            fill="none" stroke="black" stroke-width="1"
            d="M 431.73,524.72
               C 431.73,524.72 428.77,523.77 428.77,523.77
               ...
                 108.38,418.75 107.50,413.50 107.50,413.50 Z" />
    </svg>
    ```
    We need to convert it so the app can understand it. In order to do so, run provided [script](https://github.com/jchlanda/PickABlock/blob/master/scripts/svgparser.py) as follows:

    ```sh
    python svgparser.py -i <path>/name_of_the_file_from_step_2
    ```
    By default this will generate `ShapesCoords.swift` file that has to be pasted [here](https://github.com/jchlanda/PickABlock/blob/master/app/PickABlock/PickABlock/ShapesCoords.swift) (or replace the content of existing file with what has been generated by the script).
4. Build the app.
Navigate to [PickABlock.xcodeproj](https://github.com/jchlanda/PickABlock/tree/master/app/PickABlock) and double click it. In Xcode make sure that `Release` build is set (go to: `Producrt`->`Scheme`->`Edit Scheme...`, on the `Run` tab set the `Build Configuration` drop down to `Release`). From the same menu choose `Destination` and set it to your device. Finally, choose `Run`, again from `Product` menu. This should result in PickABlock being launched in XCode's simulator.
5. Self sign the app and sideload it to your device.
The final step is to bring your version of PickABlock to the device of your choice, a good guide, that shows all the steps lives [here](https://www.appdevchannel.com/2018/11/side-load-xcode-iphone.html).

Enjoy your climbing!
