# python_unit_testing

## Pytest Overview

This folder establishes a basic setup for unit testing, using pytest.

```cmd
pip install pytest
```

To execute the unit test, launch terminal/cmd/git bash and type:

```bash
pytest test_data_reader.py
```

This will run pytest on all functions inside test_data_reader.py whose names start with test_.

## Pytest Notes

If you'd like to run all test_something.py scripts in a directory, use the following:

```bash
pytest .
```

Where . stands for current directory.

Also, all def functions should start with test_, e.g. test_row_counter. 

The name of the test scripts should be named after the script they test, prepended by _test, e.g. test_thisscript.py.

## Data

The data in populations.txt was the first few columns from [here](https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population).