# Build Tools 

<a href="https://github.com/tonystone/build-tools/" target="_blank">
   <img src="https://img.shields.io/badge/platforms-Linux%20%7C%20macOS-lightgray.svg?style=flat" alt="Platforms: Linux | macOS" />
</a>
<a href="https://github.com/tonystone/build-tools/" target="_blank">
   <img src="https://img.shields.io/badge/License-Apache%202.0-lightgray.svg?style=flat" alt="License: Apache 2.0" />
</a>

---

Tools for build &amp; test on various platforms.

## Documentation

For specific documentation on each script see the links below:
- [**gyb_tool.rb**](documentation/gyb_tool.md) - A script to locate your GYB (`.gyb`) files and process them producing the `.swift` file.
- [**xctest_tool.rb**](documentation/xctest_tool.md) - A script to parse your package and source producing the required swift files to run tests on linux.

## Source

You can find the latest sources on [github](https://github.com/tonystone/build-tools).

## Communication and Contributions

- If you **found a bug**, _and can provide steps to reliably reproduce it_, [open an issue](https://github.com/tonystone/build-tools/issues).
- If you **have a feature request**, [open an issue](https://github.com/tonystone/build-tools/issues).
- If you **want to contribute**
   - Fork it! [build-tools repository](https://github.com/tonystone/build-tools)
   - Create your feature branch: `git checkout -b my-new-feature`
   - Commit your changes: `git commit -am 'Add some feature'`
   - Push to the branch: `git push origin my-new-feature`
   - Submit a pull request :-)

## Minimum Requirements

Build Environment

| Platform | Swift | Swift Build | Xcode |
|:--------:|:-----:|:----------:|:------:|
| Linux    | 4.0 | &#x2714; | &#x2718; |
| OSX      | 4.0 | &#x2714; | Xcode 9.0 |


## Author

Tony Stone ([https://github.com/tonystone](https://github.com/tonystone))

## License

build-tools is released under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)
