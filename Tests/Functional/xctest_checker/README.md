# xctest_checker

This tool is invoked by the swift-corelibs-xctest functional tests when they use the `{xctest_checker}` lit substitution. For more usage details, execute it from this directory using:

```sh
./xctest_checker.py -h
```

It includes unit tests which can be run with the following command in this directory:

```sh
python -m unittest discover
```
