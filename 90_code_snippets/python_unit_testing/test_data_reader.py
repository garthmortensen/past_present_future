import pytest
from data_reader import split_data


# pytest test_data_reader.py
def test_split_data():
    filepath = "C:\\playground\\"
    filename = "population_short.txt"
    lines = open(filepath + filename, "r").readlines()

    output_lines = split_data(lines)
    expected_lines = [['Rank', 'Country (or dependent territory)', 'Population', '% of world\n'],
                    ['1', 'China[b]', '"1,403,946,800"', '18.00%\n'],
                    ['2', 'India[c]', '"1,365,851,196"', '17.50%\n'],
                    ['3', 'United States[d]', '"330,115,486"', '4.23%\n'],
                    ['4', 'Indonesia', '"269,603,400"', '3.45%\n'],
                    ['5', 'Pakistan[e]', '"220,892,331"', '2.83%\n'],
                    ['6', 'Brazil', '"211,919,229"', '2.71%\n'],
                    ['7', 'Nigeria', '"206,139,587"', '2.64%\n'],
                    ['8', 'Bangladesh', '"169,114,552"', '2.17%\n'],
                    ['9', 'Russia[f]', '"146,748,590"', '1.88%\n'],
                    ['10', 'Mexico', '"127,792,286"', '1.64%\n']]

    assert len(output_lines) == 11
    assert expected_lines == output_lines

