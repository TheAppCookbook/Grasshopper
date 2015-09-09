Story = require "../models/story"
Parse = require("parse").Parse


Parse.initialize "MAJ7aKEx6PNiDxONOIzwSP29QEeZ3i9dkz5tkj2o",
"SFrizfmgICHbDha7OsJD30GLxACYUYkBWa9omGBO"

Story.mostRecent (story) ->
    story.fallbackImageURL (url, query) ->
        console.log(url, query)