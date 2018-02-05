# WhereInTheWorld

Sample app for a 4 part Girl Develop It Swift course

Where in the World?

Class 1
- create an array of countries
- randomly choose 1 country from the array
- create a url string using that country 
- have a view controller with a button and text label
- tap on the play button and the label should change to the next randomly selected country

Class 2
- make network call to flickr to get photo search results for that country
- display a photo for that country
- tap on the answer button and the label will reveal the name of the country
* extra tweaks *
- disable the play button after you get make the call to get results, and enable the answer button, disable the answer button after they tap it, enable play button
- display 5 photos that you can swipe through for each country

Troubleshooting:
when you add the tap gesture recognizer, make sure to turn user interaction on for the image view in the storyboard
you need to add height constraints to the buttons or they can disappear and not work

Class 3
- add a tableview to display multiple choice selection for the selected country
- make an array of 4 guesses (while loop that adds 3 random countries to a set that has the selected country in it)
- show correct guess as green, incorrect as red
- have a label saying Congratulations or You are incorrect
* extra tweaks *
- get random photos instead of the same ones each time

Class 4
- Turn into a 20 question quiz and add score keeping 
Keep track of highest score and display  (NSUserDefaults good enough or Core data)?
* extra tweaks * 
- add background colors
- add more advanced score keeping based on number of images needed for a guess etc...
- UIDynamics
