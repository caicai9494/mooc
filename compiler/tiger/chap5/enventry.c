#include "enventry.h"
#include "util.h"

E_enventry E_VarEntry(Ty_ty ty)
{
    E_enventry env = checked_malloc(sizeof(E_enventry));
    env->kind = E_varEntry;
    env->u.var.ty = ty;
    return env;
}

E_enventry E_FunEntry(Ty_tyList formals, Ty_ty result)
{
    E_enventry env = checked_malloc(sizeof(E_enventry));
    env->kind = E_funEntry;
    env->u.fun.formals = formals;
    env->u.fun.result = result;
    return env;
}

static S_table base_tenv = NULL; /* for Ty_ty */ 
static S_table base_venv = NULL; /* for E_enventry */

S_table E_base_tenv(void) 
{
    if (NULL == base_tenv) {
	base_tenv = S_empty();
	S_enter(base_tenv, S_Symbol("int"), E_VarEntry(Ty_Int()));
	S_enter(base_tenv, S_Symbol("string"), E_VarEntry(Ty_String()));
    }

    return base_tenv;
}

S_table E_base_venv(void)
{
    if (NULL == base_venv) {
	base_tenv = S_empty();

	S_enter(base_tenv, S_Symbol("print"), 
	    E_FunEntry(Ty_TyList(Ty_String(), NULL), Ty_Void()));

	S_enter(base_tenv, S_Symbol("printi"), 
	    E_FunEntry(Ty_TyList(Ty_Int(), NULL), Ty_Void()));

	S_enter(base_tenv, S_Symbol("flush"), 
	    E_FunEntry(NULL, Ty_Void()));

	S_enter(base_tenv, S_Symbol("getchar"), 
	    E_FunEntry(NULL, Ty_String()));

	S_enter(base_tenv, S_Symbol("ord"), 
	    E_FunEntry(Ty_TyList(Ty_String(), NULL), Ty_Int()));

	S_enter(base_tenv, S_Symbol("chr"), 
	    E_FunEntry(Ty_TyList(Ty_Int(), NULL), Ty_String()));

	S_enter(base_tenv, S_Symbol("size"), 
	    E_FunEntry(Ty_TyList(Ty_String(), NULL), Ty_Int()));

	S_enter(base_tenv, S_Symbol("substring"), 
	    E_FunEntry(
	        Ty_TyList(Ty_String(), 
	            Ty_TyList(Ty_Int(), 
		        Ty_TyList(Ty_Int(), NULL))), Ty_String()));

	S_enter(base_tenv, S_Symbol("concat"), 
	    E_FunEntry(
	        Ty_TyList(Ty_String(), 
	            Ty_TyList(Ty_String(), NULL)), Ty_String())); 

	S_enter(base_tenv, S_Symbol("not"), 
	    E_FunEntry(Ty_TyList(Ty_Int(), NULL), Ty_Int()));

	S_enter(base_tenv, S_Symbol("exit"), 
	    E_FunEntry(Ty_TyList(Ty_Int(), NULL), Ty_Void()));
    }

    return base_tenv;
}

