#include "semant.h"
#include "enventry.h"
#include "errormsg.h"
#include "util.h"
#include "string.h"

#include <stdlib.h>
#include <stdio.h>


/* begin static functions declarations */
static int cmpTy(Ty_ty lhs, Ty_ty rhs); 

static Ty_ty Ty_actualTy(Ty_ty ty);

static Ty_tyList makeFormalTyList(S_table tenv, A_fieldList param);

static int loop_depth = 0;
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
static Tr_expty transArrayExp(S_table venv, S_table tenv, A_exp e);
static Tr_expty transLetExp(S_table venv, S_table tenv, A_exp e);

static Ty_ty transNameTy(S_table tenv, A_ty t); 
static Ty_ty transRecordTy(S_table tenv, A_ty t); 
static Ty_ty transArrayTy(S_table tenv, A_ty t); 

static void transTypeDec(S_table venv, S_table tenv, A_dec d); 

static void transFunctionDec(S_table venv, S_table tenv, A_dec d);
static void transVarDec(S_table venv, S_table tenv, A_dec d);


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

    A_var fvar = v->u.field.var;
    assert(A_simpleVar == fvar->kind);
    // test record type match or not 
    E_enventry x = S_look(venv, fvar->u.simple);
    if (x && E_varEntry == x->kind) {
	Ty_ty typ = x->u.var.ty;
	assert(Ty_record == typ->kind);

	Ty_fieldList field;
	for (field = typ->u.record; field; field = field -> tail) {

	    if (0 == strcmp(S_name(v->u.field.sym), S_name(field->head->name))) {
		return Tr_ExpTy(NULL, field->head->ty);
	    }
	}
	//not found
	EM_error(v->pos, "undefined record field %s\n", 
		 S_name(v->u.field.sym));
	return Tr_ExpTy(NULL, Ty_Int());
    } else {
	EM_error(v->pos, "undefined record variable %s\n", 
		 S_name(v->u.field.sym));
	return Tr_ExpTy(NULL, Ty_Int());
    }
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
 
    // TODO: FIX:: record definition can have less fields than the prototype
    E_enventry x = S_look(tenv, e->u.record.typ);
    if (x && E_varEntry == x->kind) {

	Ty_ty rtype = x->u.var.ty; 

	if (Ty_record != rtype->kind) {
	    EM_error(e->pos, "%s not of record type \n", S_name(e->u.record.typ));
	    return Tr_ExpTy(NULL, Ty_Int());
	} 

	A_efieldList efield = e->u.record.fields;
	for (; efield; efield = efield->tail) {

	    // 1. check field exists

	    Ty_fieldList field = NULL;
	    for (field = rtype->u.record; field; field = field->tail) {
		if (0 == strcmp(S_name(field->head->name), 
			        S_name(efield->head->name))) {

		    // 2. exp not match with field type
		    Tr_expty expty = transExp(venv, tenv, efield->head->exp);
		    // Nil can match any type in record
		    if (Ty_nil != expty->ty->kind && 0 != cmpTy(field->head->ty, 
				   expty->ty)) {
			EM_error(e->pos, "%s field expression not match with record field type\n", S_name(efield->head->name));
			return Tr_ExpTy(NULL, Ty_Int());
		    }
		    break;
		}
	    }
	    if (NULL == field) { // not found

		EM_error(e->pos, "%s field not defined in record type\n", S_name(efield->head->name));
		return Tr_ExpTy(NULL, Ty_Int());
	    }
	}

	return Tr_ExpTy(NULL, Ty_Record(rtype->u.record));

    } else {
	EM_error(e->pos, "undefined record %s\n", 
		 S_name(e->u.record.typ));
	return Tr_ExpTy(NULL, Ty_Int());
    }
}

static Tr_expty transSeqExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_seqExp == e->kind);

    A_exp last = NULL;
    A_expList seq = e->u.seq;
    while (seq) {
	last = seq->head;
	seq = seq->tail;
    }
    return NULL == last ? 
	Tr_ExpTy(NULL, Ty_Void()) :
	transExp(venv, tenv, last);
}

static Tr_expty transAssignExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_assignExp == e->kind);
    Tr_expty lhs = transVar(venv, tenv, e->u.assign.var);
    Tr_expty rhs = transExp(venv, tenv, e->u.assign.exp);

    if (0 != cmpTy(lhs->ty, rhs->ty)) {
	EM_error(e->pos, "assign lhs and rhs type mismatch\n"); 
	return Tr_ExpTy(NULL, Ty_Int());
    }

    return Tr_ExpTy(NULL, Ty_Void());
}

static Tr_expty transIfExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_ifExp == e->kind);
    assert(NULL != e->u.iff.then);

    // check test integer 
    Tr_expty etest = transExp(venv, tenv, e->u.iff.test);
    int test_ret = 0;
    if (Ty_int != etest->ty->kind) {

	EM_error(e->pos, "if stm test is not int\n"); 
	return Tr_ExpTy(NULL, Ty_Int());

    } else {
	test_ret = e->u.intt;
    }

    // if then stm
    if (NULL == e->u.iff.elsee) {
	return transExp(venv, tenv, e->u.iff.then); 
    }

    // if then else stm
    Tr_expty ethen = transExp(venv, tenv, e->u.iff.then);
    Tr_expty eelsee = transExp(venv, tenv, e->u.iff.elsee);
    // test branch
    if (0 != cmpTy(ethen->ty, eelsee->ty)) {
	EM_error(e->pos, "if stm branches of different types \n"); 
	return Tr_ExpTy(NULL, Ty_Int());
    } else {
	if (0 == test_ret) {
	    return eelsee;
	} else {
	    return ethen;
	}
    }
}

static Tr_expty transWhileExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_whileExp == e->kind);

    loop_depth++;

    // check test integer 
    Tr_expty etest = transExp(venv, tenv, e->u.whilee.test);
    int test_ret = 0;
    if (Ty_int != etest->ty->kind) {

	loop_depth--;

	EM_error(e->pos, "while stm test is not int\n"); 
	return Tr_ExpTy(NULL, Ty_Int());

    } else {
	test_ret = e->u.intt;
    }

    Tr_expty ebody = NULL;
    //while(0 != test_ret) {
	ebody = transExp(venv, tenv, e->u.whilee.body);
    //}
    loop_depth--;
    return ebody;
}
static Tr_expty transForExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_forExp == e->kind);
    Tr_expty elow = transExp(venv, tenv, e->u.forr.lo);
    if (Ty_int != elow->ty->kind) {
	EM_error(e->pos, "for stm low is not int\n"); 
	return Tr_ExpTy(NULL, Ty_Int());
    }

    Tr_expty ehigh = transExp(venv, tenv, e->u.forr.hi);
    if (Ty_int != ehigh->ty->kind) {
	EM_error(e->pos, "for stm high is not int\n"); 
	return Tr_ExpTy(NULL, Ty_Int());
    }

    S_beginScope(venv);
    S_beginScope(tenv);

    // assign the iterator only in the scope of loop
    S_enter(venv, e->u.forr.var, E_VarEntry(elow->ty));

    S_endScope(venv);
    S_endScope(tenv);
    
}
static Tr_expty transBreakExp(S_table venv, S_table tenv, A_exp e)
{
    assert(A_breakExp == e->kind);
    if (0 == loop_depth) {
	EM_error(e->pos, "break stm outside loop\n"); 
    }
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

    S_endScope(venv);
    S_endScope(tenv);
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

    A_fundecList fundec_iter;
    for (fundec_iter = d->u.function; fundec_iter; fundec_iter = fundec_iter->tail) {
	A_fundec f = fundec_iter->head;

	Ty_ty ret_type = NULL;
	// procedure call, no return value (only side effects)
	if (NULL == f->result) {
	    ret_type = Ty_Void();
	} else {
	    E_enventry resultTy = S_look(tenv, f->result);
	    if (NULL == resultTy || E_varEntry != resultTy->kind) {
		EM_error(d->pos, "function body types undefined %s\n", 
			 S_name(f->name));
		return;
	    } else {
		ret_type = resultTy->u.var.ty;
	    }
	}
	Ty_tyList formalTys = makeFormalTyList(tenv, f->params);
	// 'formalTys' could be NULL if parameter list is NULL or
	//  the first parameter is undefined
	S_enter(venv, f->name, E_FunEntry(formalTys, ret_type));

	S_beginScope(venv);
	{
	    A_fieldList l; Ty_tyList t;
	    for(l = f->params, t = formalTys; l && t; l = l->tail, t = t->tail) {
		S_enter(venv, l->head->name, E_VarEntry(t->head));
	    }

	    Tr_expty tr_body = transExp(venv, tenv, d->u.function->head->body);
	    if (0 != cmpTy(tr_body->ty, ret_type)) {
		EM_error(d->pos, "function body types mismatch %s\n", 
			 S_name(f->name));
	    }
	}
	S_endScope(venv);

    }
}

static void transVarDec(S_table venv, S_table tenv, A_dec d)
{
    assert(A_varDec == d->kind);

    Tr_expty exp = transExp(venv, tenv, d->u.var.init);

    // if type not specified, 
    // use init's type
    if (!d->u.var.typ) {
	S_enter(venv, d->u.var.var, E_VarEntry(exp->ty));
	return;
    }

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
	E_enventry temp_entry = E_VarEntry(Ty_Name(nlist->head->name, NULL));
	S_enter(tenv, nlist->head->name, temp_entry);
	Ty_ty body_ty = transTy(tenv, nlist->head->ty);
	temp_entry->u.var.ty = body_ty;
	
	//printf("%dfdf\n", nlist->head->ty->kind);
	//printf("%sfdf\n", S_name(nlist->head->name));
//	S_enter(tenv, nlist->head->name,
//		E_VarEntry(transTy(tenv, nlist->head->ty)));
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

	E_enventry x = S_look(tenv, field->head->typ);
	if (x && E_varEntry == x->kind) {
	    flist = Ty_FieldList(Ty_Field(field->head->name, x->u.var.ty), flist);
	} else {
	    EM_error(t->pos, "undefined record type %s\n", 
		     S_name(field->head->typ));
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

static Ty_tyList makeFormalTyList(S_table tenv, A_fieldList param)
{
    Ty_tyList tlist = NULL;

    if (NULL == param) {
	return NULL;
    } else {
	E_enventry x = S_look(tenv, param->head->typ);

	if (x && E_varEntry == x->kind) {
	    return Ty_TyList(x->u.var.ty, makeFormalTyList(tenv, param->tail));
	} else {
	    EM_error(param->head->pos, "undefined function parameter type %s\n", S_name(param->head->typ)); 
	    return NULL;
	}
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
