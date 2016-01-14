#include "semant.h"
#include "enventry.h"
#include "errormsg.h"
#include "util.h"

#include <stdlib.h>
#include <stdio.h>


/* begin static functions declarations */
static int cmpTy(Ty_ty lhs, Ty_ty rhs); 

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
	Ty_ty typ = x->u.var.ty;
	assert(Ty_record == typ->kind);

	Ty_fieldList field;
	for (field = typ->u.record; field; field = field -> tail) {

	    if (v->u.field.var == field->head->name) {
		return Tr_ExpTy(NULL, Ty_Field(field->head->name, field->head->ty));
	    }
	}
	Tr_expty list = transVar(venv, tenv, v->u.field.var);
    } else {
	EM_error(v->pos, "undefined record variable %s\n", 
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

	Ty_tyList formals = x->u.fun.formals;

	/* check args */
	Tr_expty expr = NULL;
	A_expList args = e->u.call.args;
	int count;
	for(count = 0; args && formals; formals = formals->tail, args = args->tail, count++) {
	    expr = transExp(venv, tenv, args->head);

	    if (0 != cmpTy(formals->head, expr->ty)) {
		EM_error(e->pos, "function 's args doesn't match at position %d\n", count);

		return Tr_ExpTy(NULL, Ty_Int());
	    }
	} 

	if (formals || args) {
	    EM_error(e->pos, "function 's args length doesn't match\n");
	    return Tr_ExpTy(NULL, Ty_Int());
	}

	Ty_ty result = x->u.fun.result;
	return Tr_ExpTy(NULL, result);

    } else {
	EM_error(e->pos, "undefined function %s\n", 
		 S_name(e->u.call.func));
	return Tr_ExpTy(NULL, Ty_Int());
    }
}

static Tr_expty transRecordExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_recordExp == e->kind);

    E_enventry x = S_look(venv, e->u.record.typ);
    if (x && E_varEntry == x->kind) {

	A_efieldList field = e->u.record.fields;
	for (; field; field = field->tail) {
	}

    } else {
	EM_error(e->pos, "undefined record %s\n", 
		 S_name(e->u.call.func));
	return Tr_ExpTy(NULL, Ty_Int());
    }
}

static Tr_expty transSeqExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_seqExp == e->kind);

    A_expList seq = e->u.seq;
    if (NULL == seq) {
	return Tr_ExpTy(NULL, Ty_Void());
    }

    Tr_expty expty = NULL;
    for (; seq; seq = seq->tail) {
	expty = transExp(venv, tenv, seq->head);
	if (NULL == seq->tail) {
	    return expty;
	}
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

    E_enventry x = S_look(tenv, e->u.array.typ);
    if (x && E_varEntry == x->kind) {

	if (Ty_array != x->u.var.ty->kind) {
	    EM_error(e->pos, "array %s's type is not array\n", 
		     S_name(e->u.array.typ));

	    return Tr_ExpTy(NULL, Ty_Int());
	}

	Tr_expty size = transExp(venv, tenv, e->u.array.size);
	if (Ty_int != size->ty->kind) {
	    EM_error(e->pos, "array %s's size is not int\n", 
		     S_name(e->u.array.typ));

	    return Tr_ExpTy(NULL, Ty_Int());
	}

	Tr_expty init = transExp(venv, tenv, e->u.array.init);
	if (0 != cmpTy(x->u.var.ty->u.array, init->ty)) {
	    EM_error(e->pos, "array 's type is not consistent\n", 
		     S_name(e->u.array.typ));

	    return Tr_ExpTy(NULL, Ty_Int());
	}

	return Tr_ExpTy(NULL, Ty_Array(x->u.var.ty));

    } else {
	EM_error(e->pos, "undefined array type %s\n", 
		 S_name(e->u.array.typ));
	return Tr_ExpTy(NULL, Ty_Int());
    }
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

    E_enventry x = S_look(tenv, d->u.var.typ);
    if (x && E_varEntry == x->kind) {
	if (0 == cmpTy(x->u.var.ty, exp->ty)) {   
	    S_enter(venv, d->u.var.var, E_VarEntry(exp->ty));
	} else {
	    EM_error(d->pos, "types mismatch %s\n", 
		     S_name(d->u.var.typ));
	}
    } else {
	EM_error(d->pos, "undefined type %s\n", 
		 S_name(d->u.var.typ));
    }
}

static void transTypeDec(S_table venv, S_table tenv, A_dec d) 
{
    assert(A_typeDec == d->kind);

    A_nametyList nlist;
    for (nlist = d->u.type; nlist; nlist = nlist->tail) {
	S_enter(tenv, nlist->head->name,
		E_VarEntry(transTy(tenv, nlist->head->ty)));
    }
}

/* type checkers */
static Ty_ty transNameTy(S_table tenv, A_ty t) 
{
    assert(A_nameTy == t->kind);

    E_enventry x = S_look(tenv, t->u.name);
    if (x && E_varEntry == x->kind) {
	return x->u.var.ty;
    } else {
	EM_error(t->pos, "undefined type %s\n", 
		 S_name(t->u.name));
	return Ty_Void();
    }
}

static Ty_ty transRecordTy(S_table tenv, A_ty t) 
{
    assert(A_recordTy == t->kind);

    A_fieldList field;
    Ty_fieldList flist = NULL;
    for (field = t->u.record; field; field = field->tail) {
	if (field->head->escape) {

	    E_enventry x = S_look(tenv, field->head->typ);
	    if (x && E_varEntry == x->kind) {
		flist = Ty_FieldList(Ty_Field(field->head->name, x->u.var.ty), flist);
	    } else {
		EM_error(t->pos, "undefined record type %s\n", 
			 S_name(field->head->typ));
	    }
	    
	}
    }
    return Ty_Record(flist);
}

static Ty_ty transArrayTy(S_table tenv, A_ty t) 
{
    assert(A_arrayTy == t->kind);

    E_enventry x = S_look(tenv, t->u.array);
    if (x && E_varEntry == x->kind) {
	return Ty_Array(x->u.var.ty);
    } else {
	EM_error(t->pos, "undefined array type %s\n", 
		 S_name(t->u.name));
	return Ty_Void();
    }
}

/* end static functions */

static int cmpTy(Ty_ty lhs, Ty_ty rhs) 
{
    assert(lhs);
    assert(rhs);

    if (lhs->kind != rhs->kind) {
	return -1;
    } 

    switch (lhs->kind) {
	case Ty_array:
	case Ty_record:
	    return lhs == rhs;
	case Ty_name:
	    return cmpTy(Ty_actualTy(lhs), Ty_actualTy(rhs));
	default:
	    return 0;
    }
}

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
