# -*- coding: utf-8 -*-
"""
Created on Wed Aug 12 10:24:51 2020

@author: morte

basic testing
"""


filepath = "C:\\playground\\"
filename = "population.txt"

lines = open(filepath + filename, "r").readlines()


def split_data(lines_in):
    """Read in a text file and split on texts, producing list of lists."""
    rows = []
    for line in lines_in:
        field = []

        for i in line.split("\t"):
            field.append(i)
        rows.append(field)

    rows = rows[1:]  # strip header

    return rows


output_lines = split_data(lines)
