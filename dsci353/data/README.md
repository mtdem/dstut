# This is the `data` folder in the standard SDLE git repository structure

The `data` folder is meant to contain "curated data" for Rscripts/RMDs/Rpres, not raw data files.

A sample of raw data can be uploaded to highlight the steps taken to reach the curated files.

Curated data might look like a CSV file with a well defined structure, where sturcture itself is an attribute of the file.

All the curated files should follow a naming scheme.

For example: 1604-Invertor-topic.csv
            - 1604: represents the year and month 
            - Invertor: associated machine/tool/technique used for the collection of data
            - topic: attribute for which the structure of the file was tailored   

Each CSV file should have an associated databook (in the form of a second CSV) containing metadata.

Databooks contain one row for every data column in the master CSV, with a column for variable name, units, brief written description, etc.

They can be related back to their master CSV files by following a simple naming scheme:
            - "filename-docs.csv"
            - where filename is the name of the master CSV file
            - "-docs" highlight that the file is a databook


This work is legally bound by the following software license: [CC-A-NS-SA-4.0][1] [^1]  
Please see the LICENSE.txt file, in the root of this repository, for further details.

[1]: https://creativecommons.org/licenses/by-nc-sa/4.0/ "CC-A-NS-SA-4.0"


[^1]: [CC-A-NS-SA-4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
