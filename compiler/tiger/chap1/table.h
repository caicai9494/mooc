#ifndef TABLE_H
#define TABLE_H

#include "util.h"
#include "slp.h"

typedef struct table* Table_;
struct table {
    string id;
    int value;
    Table_ tail;
};

Table_ Table(string id, int value, Table_ tail);
/* constructor */

Table_ update(Table_ table, string id, int value);
/* update the value of id
 * if id is not in the table
 * insert the id*/ 

bool lookup(Table_ table, string key, int* value);
/* if key is found, set the value and
 * return true. return false otherwise*/ 

void print(Table_ table);
/* print table to stdout
 * for testing purposes */

void interp(A_stm stm);
/* evaluate the statement */



#endif
