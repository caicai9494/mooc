#include "semant.h"
#include "enventry.h"
#include "errormsg.h"

#include <stdlib.h>
#include <stdio.h>


/* begin static functions declarations */

static Ty_ty Ty_actualTy(Ty_ty ty);
/* for nametype, find the actual underlying type */

static Tr_expty transSimpleVar(S_table venv, S_table tenv, A_var v);
static Tr_expty transFieldVar(S_table venv, S_table tenv, A_var v);
static Tr_expty transSubscriptVar(S_table venv, S_table tenv, A_var v);

static Tr_expty transVarExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transNilExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transIntExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transStringExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transCallExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transOpExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transRecordExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transSeqExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transAssignExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transIfExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transWhileExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transForExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transBreakExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transLetExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transArrayExp(S_table venv, S_table tenv, A_exp e);

static void transFunctionDec(S_table venv, S_table tenv, A_dec d);
static void transVarDec(S_table venv, S_table tenv, A_dec d);
static void transTypeDec(S_table venv, S_table tenv, A_dec d); 

static Ty_ty transNameTy(S_table tenv, A_ty t); 
static Ty_ty transRecordTy(S_table tenv, A_ty t); 
static Ty_ty transArrayTy(S_table tenv, A_ty t); 

/* end static functions declarations */

/* constructor */
Tr_expty Tr_ExpTy(Tr_exp exp, Ty_ty ty)
{
    Tr_expty e = checked_malloc(sizeof(Tr_expty));
    e->exp = exp;
    e->ty = ty;
    return e;
}

Tr_expty transVar(S_table venv, S_table tenv, A_var v)
{
    switch(v->kind) {
	case A_simpleVar: 
	    return transSimpleVar(venv, tenv, v); 
	case A_fieldVar: 
	    return transFieldVar(venv, tenv, v); 
	case A_subscriptVar: 
	    return transSubscriptVar(venv, tenv, v); 
	default: assert(0);
    }
}

Tr_expty transExp(S_table venv, S_table tenv, A_exp e)
{
    switch(e->kind) {
        case A_varExp:
	    return transVarExp(venv, tenv, e);
        case A_nilExp:
	    return transNilExp(venv, tenv, e);
        case A_intExp:
	    return transIntExp(venv, tenv, e);
        case A_stringExp:
	    return transStringExp(venv, tenv, e);
        case A_callExp:
	    return transCallExp(venv, tenv, e);
        case A_opExp:
	    return transOpExp(venv, tenv, e);
        case A_recordExp:
	    return transRecordExp(venv, tenv, e);
        case A_seqExp:
	    return transSeqExp(venv, tenv, e);
        case A_assignExp:
	    return transAssignExp(venv, tenv, e);
        case A_ifExp:
	    return transIfExp(venv, tenv, e);
        case A_whileExp:
	    return transWhileExp(venv, tenv, e);
        case A_forExp:
	    return transForExp(venv, tenv, e);
        case A_breakExp:
	    return transBreakExp(venv, tenv, e);
        case A_letExp:
	    return transLetExp(venv, tenv, e);
	case A_arrayExp:
	    return transArrayExp(venv, tenv, e);
	default: assert(0);
    }
}


void transDec(S_table venv, S_table tenv, A_dec d)
{
    switch(d->kind) {
        case A_functionDec:
            transFunctionDec(venv, tenv, d);
	    break;
        case A_varDec:
            transVarDec(venv, tenv, d);
	    break;
        case A_typeDec:
            transTypeDec(venv, tenv, d); 
	    break;
	default: assert(0);
    }
}

Ty_ty transTy(S_table tenv, A_ty t)
{
    switch(t->kind) {
        case A_nameTy:
            return transNameTy(tenv, t); 
        case A_recordTy:
            return transRecordTy(tenv, t); 
        case A_arrayTy:
            return transArrayTy(tenv, t); 
	default: assert(0);
    }
}

/* begin static functions */

static Ty_ty Ty_actualTy(Ty_ty ty)
{
    assert(NULL != ty);

    if(ty->kind != Ty_name) {
	return ty;
    } else {
	return Ty_actualTy(ty->u.name.ty);
    }
}

/* variable checkers */

static Tr_expty transSimpleVar(S_table venv, S_table tenv, A_var v)
{
    assert(A_simpleVar == v->kind);

    E_enventry x = S_look(venv, v->u.simple);
    if (x && E_varEntry == x->kind) {
	return Tr_ExpTy(NULL, Ty_actualTy(x->u.var.ty));
    } else {
	EM_error(v->pos, "undefined variable %s\n", 
		 S_name(v->u.simple));
	return Tr_ExpTy(NULL, Ty_Int());
    }
}


static Tr_expty transFieldVar(S_table venv, S_table tenv, A_var v)
{
    assert(A_fieldVar == v->kind);

    /*
    E_enventry x = S_look(venv, v->u.field.sym);
    if (x && E_varEntry == x->kind) {
	Tr_expty list = transVar(venv, tenv, v->u.field.var);
	return Tr_ExpTy(NULL, Ty_Record());
    } else {
	EM_error(v->pos, "undefined field variable %s\n", 
		 S_name(v->u.field.sym));
	return Tr_ExpTy(NULL, Ty_Int());
    }
    */
}

static Tr_expty transSubscriptVar(S_table venv, S_table tenv, A_var v)
{
    assert(A_subscriptVar == v->kind);

    Tr_expty lhs_var = transVar(venv, tenv, v->u.subscript.var);
    Tr_expty rhs_exp = transExp(venv, tenv, v->u.subscript.exp);
    return Tr_ExpTy(lhs_var->ty, rhs_exp->exp);
}

/* expression checkers */
static Tr_expty transVarExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_varExp == e->kind);
    return transVar(venv, tenv, e->u.var);
}

static Tr_expty transNilExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_nilExp == e->kind);
    return Tr_ExpTy(NULL, Ty_Nil());
}

static Tr_expty transIntExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_intExp == e->kind);
    return Tr_ExpTy(NULL, Ty_Int());
}

static Tr_expty transStringExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_stringExp == e->kind);
    return Tr_ExpTy(NULL, Ty_String());
}

static Tr_expty transOpExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_opExp == e->kind);

    A_oper oper = e->u.op.oper;
    Tr_expty lhs = transExp(venv, tenv, e->u.op.left);
    Tr_expty rhs = transExp(venv, tenv, e->u.op.right);

    // if statement will be needed for future labs
    //if (A_plusOp == oper) {

	if (Ty_int != lhs->ty->kind) {
	    EM_error(e->pos, "integer required\n");
	} else if (Ty_int != rhs->ty->kind) {
	    EM_error(e->pos, "integer required\n");
	}
	return Tr_ExpTy(NULL, Ty_Int());

    //}
}

static Tr_expty transCallExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_callExp == e->kind);

    E_enventry x = S_look(venv, e->u.call.func);
    if (x && E_funEntry == x->kind) {
	return Tr_ExpTy(NULL, x->u.fun.result);

	/* check args
	A_expList args = e->u.call.args;
	for(; args->head != NULL; args = args.tail) {
	    Tr_expty expty = transExp(venv, tenv, args->head);
	} 
	*/

    } else {
	EM_error(e->pos, "undefined function %s\n", 
		 S_name(e->u.call.func));
	return Tr_ExpTy(NULL, Ty_Int());
    }
}

static Tr_expty transRecordExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_recordExp == e->kind);
}

static Tr_expty transSeqExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_seqExp == e->kind);
    assert(NULL != e->u.seq);

    A_expList seq = e->u.seq;
    Tr_expty expty = NULL;
    for (; seq->tail != NULL; seq = seq->tail) {
	if (NULL == seq->head) {
	    return Tr_ExpTy(NULL, Ty_Void());
	}
	expty = transExp(venv, tenv, seq->head);
    }	
    if (NULL != expty) {
	return Tr_ExpTy(NULL, expty->ty);
    } else {
	return Tr_ExpTy(NULL, Ty_Void());
    }
}

static Tr_expty transAssignExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_assignExp == e->kind);
    return Tr_ExpTy(NULL, Ty_Void());
}
static Tr_expty transIfExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_ifExp == e->kind);
    
    if (NULL == e->u.iff.elsee) {
	return Tr_ExpTy(NULL, Ty_Void());
    } else {

    }
}
static Tr_expty transWhileExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_whileExp == e->kind);
}
static Tr_expty transForExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_forExp == e->kind);
}
static Tr_expty transBreakExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_breakExp == e->kind);
    return Tr_ExpTy(NULL, Ty_Void());
}
static Tr_expty transLetExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_letExp == e->kind);

    Tr_expty expty;
    A_decList declist;
    S_beginScope(venv);
    S_beginScope(tenv);

    for (declist = e->u.let.decs; declist; declist = declist->tail) {
	transDec(venv, tenv, declist->head);
    }
    expty = transExp(venv, tenv, e->u.let.body);

    S_beginScope(venv);
    S_beginScope(tenv);
    return expty;

    /*
    if (NULL == e->u.let.body) {
	return Tr_ExpTy(NULL, Ty_Void());
    } else {
	return transExp(venv, tenv, e->u.let.body);
    }
    */
}
static Tr_expty transArrayExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_arrayExp == e->kind);
}

/* declaration checkers */
static void transFunctionDec(S_table venv, S_table tenv, A_dec d)
{
    assert(A_functionDec == d->kind);
}
static void transVarDec(S_table venv, S_table tenv, A_dec d)
{
    assert(A_varDec == d->kind);

    Tr_expty exp = transExp(venv, tenv, d->u.var.init);
    S_enter(venv, d->u.var.var, E_VarEntry(exp->ty));
}
static void transTypeDec(S_table venv, S_table tenv, A_dec d) 
{
    assert(A_typeDec == d->kind);

    A_nametyList nlist;
    for (nlist = d->u.type; nlist; nlist = nlist->tail) {
	S_enter(tenv, nlist->head->name,
		transTy(tenv, nlist->head->ty));
    }
}

/* type checkers */
static Ty_ty transNameTy(S_table tenv, A_ty t) 
{
}

static Ty_ty transRecordTy(S_table tenv, A_ty t) 
{
}

static Ty_ty transArrayTy(S_table tenv, A_ty t) 
{
}

/* end static functions */

#ifdef TEST
void test_Ty_actualTy()
{
    Ty_ty int_type = Ty_Int();
    Ty_print(Ty_actualTy(int_type)); putchar('\n');

    Ty_print(Ty_actualTy(
        Ty_Name(S_Symbol("a"), 
	    Ty_Name(S_Symbol("b"), 
		Ty_Name(S_Symbol("c"), Ty_Int()))))); putchar('\n');
}
#endif
