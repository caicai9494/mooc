#include "table.h"
#include <assert.h>
#include <string.h>
#include <stdio.h>

Table_ Table(string id, int value, Table_ tail)
{
    Table_ t = checked_malloc(sizeof(*t));
    t->id = id;
    t->value = value;
    t->tail = tail;
    return t;
}

void print(Table_ table) 
{
    Table_ ptr = table;
    if (!ptr) {
	return;
    } else {
	printf("%s : %d\n", ptr->id, ptr->value);
	print(ptr->tail);
    }
}

Table_ update(Table_ table, string id, int value)
{
    Table_ tptr = table;
    while (tptr) { /* look for the key 
                      update if found*/
	if (0 == strcmp(id, tptr->id)) {
	    tptr->value = value;
	    return table;
	}
	tptr = tptr->tail;
    }

    if (!table) { /* if table is NULL */
	return Table(id, value, NULL);
    } else {
	return Table(id, value, table);
    }
}

bool lookup(Table_ table, string key, int* value)
{
    if(!table) {
	return FALSE;
    }

    if (0 == strcmp(table->id, key)) {
	*value = table->value;
	return TRUE;
    } else {
	return lookup(table->tail, key, value);
    }

}
