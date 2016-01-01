#include "table.h"
#include <assert.h>
#include <string.h>
#include <stdio.h>

typedef struct intAndTable* ITable_;
struct intAndTable {
    int i;
    Table_ table;
};

static Table_ interpStm(A_stm s, Table_ t);
static ITable_ interpExp(A_exp e, Table_ t);

static ITable_ ITable(int i, Table_ t);

void interp(A_stm stm)
{
    Table_ t = interpStm(stm, NULL);
}

ITable_ ITable(int i, Table_ t)
{
    ITable_ it = checked_malloc(sizeof(*it));
    it->i = i;
    it->table = t;
    return it;
}


Table_ interpStm(A_stm s, Table_ t)
{
    Table_ new_t;
    ITable_ new_it;

    if (s->kind == A_compoundStm) {
	new_t = interpStm(s->u.compound.stm1, t);
	return interpStm(s->u.compound.stm2, new_t);
    } else if (s->kind == A_assignStm) {
	new_it = interpExp(s->u.assign.exp, t);
	/* update the environment */
	return update(new_it->table,
	              s->u.assign.id,
	              new_it->i);
    } else if (s->kind == A_printStm) {
	A_expList exps = s->u.print.exps;
	while(exps->kind != A_lastExpList) {
	    new_it = interpExp(exps->u.pair.head, t);
	    printf("%d ", new_it->i);

	    exps = exps->u.pair.tail;
	    t = new_it->table;
	}
	new_it = interpExp(exps->u.pair.head, t);
	printf("%d\n", new_it->i);
	return new_it->table;

    } else {
	assert(0);
	/* 
	 * not possible.
	 * must be programming error
	 */
    }
}

ITable_ interpExp(A_exp e, Table_ t)
{
    Table_ new_t;
    ITable_ new_it;
    if (e->kind == A_idExp) {
	int val = 0;
	bool ret = lookup(t, e->u.id, &val);
	/* 
	 * must be true
	 * otherwise crash the program
	 */
	assert(ret);
	return ITable(val, t);
    } else if (e->kind == A_numExp) {
	return ITable(e->u.num, t);
    } else if (e->kind == A_opExp) {
	int lhs, rhs, ret;

	new_it = interpExp(e->u.op.left, t);
	lhs = new_it->i;
	new_it = interpExp(e->u.op.right, new_it->table);
	rhs = new_it->i;
	if(e->u.op.oper == A_plus) {
	    ret = lhs + rhs;
	} else if(e->u.op.oper == A_minus) {
	    ret = lhs - rhs;
	} else if(e->u.op.oper == A_times) {
	    ret = lhs * rhs;
	} else if(e->u.op.oper == A_div) {
	    ret = lhs / rhs;
	    /*
	     * it's programmer's responsibility
	     * to test denominator not zero
	     */
	} else {
	    assert(0);
	    /* programming error */
	} 
	return ITable(ret, new_it->table);
    } else if (e->kind == A_eseqExp) {
	new_t = interpStm(e->u.eseq.stm, t);
	return interpExp(e->u.eseq.exp, new_t);
    } else {
	assert(0);
	/* programming error */
    }
}


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
    while (tptr) { 
	/* 
	 * look for the key 
	 * update if found
	 */
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
