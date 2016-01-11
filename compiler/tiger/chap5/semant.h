#ifndef SEMANT_H
#define SEMANT_H

#include "symbol.h"
#include "absyn.h"
#include "types.h"
#include "util.h"

/* 
 * translated expression and 
 * its corresponding type 
 */
typedef void *Tr_exp; 
typedef struct Tr_expty_ {
    Tr_exp exp;
    Ty_ty ty;
} *Tr_expty;

Tr_expty Tr_ExpTy(Tr_exp exp, Ty_ty ty);

Tr_expty transVar(S_table venv, S_table tenv, A_var v);
Tr_expty transExp(S_table venv, S_table tenv, A_exp e);
void transDec(S_table venv, S_table tenv, A_dec d);
Ty_ty transTy(S_table tenv, A_ty t);

#ifdef TEST
void test_Ty_actualTy();
#endif


#endif
