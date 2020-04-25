# -*- coding: utf-8 -*-
"""
Emulating MapReduce's functionality, where:
Subdirectories in directory are nodes in cluster.

It seems like MapReduce performs the following sql statement:
    select department, count(*)
    from employees
    group by department
"""

# %%

import os

# three directories, each containing text files
# think of these directories as nodes, which contain their own key value pairs
node_1 = 'C:/gdrive/96_shared/Big_Data/nodes/1/'
node_2 = 'C:/gdrive/96_shared/Big_Data/nodes/2/'
node_3 = 'C:/gdrive/96_shared/Big_Data/nodes/3/'


def read_all_lines(path_in: str) -> list:
    """read all text in directory and return as sentance list"""

    all_lines = []

    # for every file in directory
    for file in os.listdir(path_in):

        # process only the texts
        if file.endswith(".txt"):

            # open each
            file = open(path_in + file)

            # read all lines into one list of strings
            lines = file.readlines()

            # step through each line and append to master list
            for line in lines:
                all_lines.append(line)

    return all_lines


def produce_list_from_lines(lines_in: list) -> list:
    """this produces a cleaned list of words found in the text"""

    all_words = []

    # Not going to use Counter()
    for line in lines_in:

        # replace all the unwanted characters, using easy to read method
        line = line.strip()
        line = line.lower()
        line = line.replace('"', '')
        line = line.replace("'", "")
        line = line.replace(",", "")
        line = line.replace(".", "")
        line = line.replace("!", "")
        line = line.replace("?", "")
        line = line.replace(":", "")
        line = line.replace(";", "")
        line = line.replace("—", "")
        line = line.replace("\n", "")

        # split each sentance string by space, resulting in list
        for word in line.split():
            all_words.append(word)

    return all_words


def word_freq_map(word_list: list) -> dict:
    """
    takes in word list and converts to frequency list.
    each node in the cluster calculates its own freq pair.
    There are many aggregation techniques (sum, avg, ...)
    """

    seen = []

    # convert list to dict
    word_dict = dict.fromkeys(word_list, 1)

    # loop through list of all words
    for word in word_list:

        # if the word has been seen
        if word in seen:
            # print and +1 to key's value
            # print("repeat: " + word)
            word_dict[word] += 1
        # if not seen, print
        else:  # first instance seen
            # print("unseen: " + word)
            next

        # add word to seen list for next iteration
        seen.append(word)

    return word_dict


def reduce(word_dict_1, word_dict_2, word_dict_3: dict) -> dict:
    """
    combine all word dictionaries
    This is the step where the master aggregates all key value pairs
    """

    dict_all = {**word_dict_1, **word_dict_2, **word_dict_3}

    return dict_all


# read all lines in nodes
node_content_out_1 = read_all_lines(node_1)
node_content_out_2 = read_all_lines(node_2)
node_content_out_3 = read_all_lines(node_3)

# produce word lists
word_list_out_1 = produce_list_from_lines(node_content_out_1)
word_list_out_2 = produce_list_from_lines(node_content_out_2)
word_list_out_3 = produce_list_from_lines(node_content_out_3)

# produce dictionaries
word_dict_out_1 = word_freq_map(word_list_out_1)
word_dict_out_2 = word_freq_map(word_list_out_2)
word_dict_out_3 = word_freq_map(word_list_out_3)

reduce_out = reduce(word_dict_out_1, word_dict_out_2, word_dict_out_3)

# tidy up
del node_1
del node_2
del node_3
del node_content_out_1
del node_content_out_2
del node_content_out_3
del word_list_out_1
del word_list_out_2
del word_list_out_3
del word_dict_out_1
del word_dict_out_2
del word_dict_out_3
