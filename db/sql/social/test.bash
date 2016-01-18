#!/bin/bash

INIT="social.sql"
QUERY="query.sql"

if [ ! -e ${INIT} ]; then
    echo "no init file. exiting..."
    exit 1
fi

if [ ! -e ${QUERY} ]; then
    echo "no query file. exiting..."
    exit 1
fi

sqlite3 -init ${INIT} < ${QUERY}


