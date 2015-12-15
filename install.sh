#!/bin/bash

echo "library(devtools); check_doc(); install()" | R --no-save
