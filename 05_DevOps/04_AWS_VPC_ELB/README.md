Overview

This was an exercise on setting up a VPC, private and public subnets, a NAT and an internet gateway. A private subnet RDS database was created, but I couldn't get it communicating outside (querying the endpoint timed-out).

A simple script was written to query endpointds.

## Scripts (1)

### metadata.sh
This script is an automation process with 2 endpoint queries.
1. Display version
2. Display the command help
3. Create files
    a. return the results of querying RDS endpoint
    b. return the results of querying a site, output to .json file.
