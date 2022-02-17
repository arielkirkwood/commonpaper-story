# commonpaper-story
My submission for the [Common Paper](https://commonpaper.com/) [engineering candidate assessment](https://github.com/CommonPaper/story-prompt).

## Setup
To run the applications in this repo, you'll need to have Ruby 3.0 installed.

With Ruby installed, you should have access to Bundler via `bundle`; execute `bundle` to install the dependencies for this project.

## Running the application
Included in the `bin` folder is a `story` executable. Run it to see available commands:
```
Ariels-Retina-MacBook-Pro:commonpaper-story arielkirkwood$ bin/story
Commands:
  story generate STRING  # compose a story with a STRING that should be valid JSON (escaped if necessary for wrapping in a single set of quotes)
  story help [COMMAND]   # Describe available commands or one specific command
  story statistics       # view summary statistics of the data in public/stories.csv
```

To `generate` a story, pass escaped JSON wrapped in double quotes to the appropriate command:
```
bin/story generate "{\"number\": 2, \"unit_of_measure\": \"mile\", \"place\": \"school\", \"adjective\": \"blue\", \"noun\": \"rock\"}"`
```

To view `statistics`, just run the command:
```
bin/story statistics
```

## Running the test suite
```
bundle exec rspec --format doc
```
