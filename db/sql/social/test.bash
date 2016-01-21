#!/bin/bash

INIT="social.sql"
QUERY="query.sql"
MODIFY="modify.sql"
TRIGGER="trigger.sql"

if [ ! -e ${INIT} ]; then
    echo "no init file. exiting..."
    exit 1
fi

if [ ! -e ${QUERY} ]; then
    echo "no query file. exiting..."
    exit 1
fi

if [ ! -e ${MODIFY} ]; then
    echo "no modify file. exiting..."
    exit 1
fi

if [ ! -e ${TRIGGER} ]; then
    echo "no trigger file. exiting..."
    exit 1
fi

sqlite3 -init ${INIT} < ${TRIGGER}
