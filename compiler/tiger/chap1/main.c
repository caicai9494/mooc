#include "slp.h"
#include "prog1.h"
#include "table.h"
#include <stdio.h>

#define max(a, b) (a) > (b) ? (a) : (b)

int maxargs(A_stm stm);
int maxargs_exp(A_exp exp);
int maxargs_explist(A_expList exps);


/* testing table*/
void test_table1();

int main() 
{
    printf("%d\n", maxargs(prog()));
    test_table1();

    interp(prog());

    return 0;
}

int maxargs(A_stm stm)
{
    int lhs, rhs;
    lhs = rhs = 0;

    if (stm->kind == A_compoundStm) {
	lhs = maxargs(stm->u.compound.stm1);
	rhs = maxargs(stm->u.compound.stm2);
	return max(lhs, rhs);
    } else if (stm->kind == A_assignStm) {
	A_exp rhs_exp = stm->u.assign.exp;
	return maxargs_exp(rhs_exp);
    } else if (stm->kind == A_printStm) {
	A_expList es = stm->u.print.exps;
	return maxargs_explist(es);
    }
}

int maxargs_exp(A_exp exp) 
{
    int lhs, rhs;
    lhs = rhs = 0;

    if (exp->kind == A_opExp) {
	lhs = maxargs_exp(exp->u.op.left);
	rhs = maxargs_exp(exp->u.op.right);
	return max(lhs, rhs);
    } else if (exp->kind == A_eseqExp) {
	lhs = maxargs(exp->u.eseq.stm);
	rhs = maxargs_exp(exp->u.eseq.exp);
	return max(lhs, rhs);
    } else {
	return 0;
    }
}

int maxargs_explist(A_expList exps)
{
    if (exps->kind == A_lastExpList) {
	return 1;
    } else if (exps->kind == A_pairExpList) {
	return 1 + maxargs_explist(exps->u.pair.tail);
    }
}

/*
int maxargs_explist(A_expList exps)
{
    if (exps->kind == A_lastExpList) {
	g_max = max(g_max, maxargs_exp(exps->u.last)); 
	return 1;
    } else if (exps->kind == A_pairExpList) {
	g_max = max(g_max, maxargs_exp(exps->u.pair.head));
	return 1 + maxargs_explist(exps->u.pair.tail);
    }
}
*/

void test_table1()
{
    Table_ table = Table(String("linzhe"), 1, 
	             Table(String("yuyan"), 2,
		       Table(String("bb"), 3, NULL)));
    print(table);
    printf("*****\n");
    print(update(table, String("tom"), 4));
    printf("*****\n");
    print(update(table, String("linzhe"), 5));
    printf("*****\n");
    int val = 0;
    bool find_linzhe = lookup(table, String("linzhe"), &val); 
    if (find_linzhe) {
	printf("linzhe is %d\n", val);
    }

    bool find_tom = lookup(table, String("tom"), &val); 
    if (!find_tom) {
	printf("tom not found\n");
    }
}
