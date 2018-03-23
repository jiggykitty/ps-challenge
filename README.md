# Readme
## What works?
Hamburger menu, search completion, mapview annotations, data encoding, writing, decoding and reading.
## Improvements
MapKit sometimes can't find queries that it autocompletes itself.\
https://stackoverflow.com/a/3927029  
It would diminish the perceived integrity of the application to show an alert view saying that the location cannot be found, because the application has just autocompleted it as a suggestion. Maybe the suggestions can be searched one by one and the ones giving an error can be filtered out. This will, however, use more data.