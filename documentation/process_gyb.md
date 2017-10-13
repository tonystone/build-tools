# Build Tools
## process_gyb.rb
Using Swift's gyb (generate your boilerplate) can help remove redundancy and reduce copy-paste errors as well as generally reducing the amount of code you have to write.  Running the gyb command on every `.gyb` file you create can be tedious, or if you create your own shell command to run it from one command, you have to maintain that shell every time you add/rename/move/delete a gyb file in your project.  

This script will walk your entire project structure processing `.gyb` files found and outputting the `.swift` file for each.

##### Usage

```
process_gyb.rb [--recursive] [--gyb-path Path] [--input-path path] [--output-path path]
```

Options:
  * `--recursive`   Process the `--input-path` recursively (default is non-recursive)
  * `--gyb-path`    Path to the gyb program (defaults to using the search path)
  * `--input-path`  Path to directory containing the gyb files (defaults to the current directory if not specified)
  * `--output-path` Path to place processed file (files will be placed in the same directory they are found if not specified)

