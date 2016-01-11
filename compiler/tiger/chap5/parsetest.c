#include "util.h"
#include "errormsg.h"
#include "parse.h"
#include "prabsyn.h"
#include "enventry.h"
#include "semant.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

//#define TEST

void test_enventry_assert_print(string symbol, int line);
void test_enventry();
void test_transvar();

int main(int argc, char** argv) 
{
#ifdef TEST

    //test_enventry();
    test_transvar();
    return 0;

#else

    if (argc != 2) {
        fprintf(stderr, "usage: a.out filename\n");
        exit(1);
    }
    A_exp exp = parse(argv[1]);
    pr_exp(stdout, exp, 4);

    S_table type_table = E_base_tenv();
    S_table val_table = E_base_venv();
    transExp(val_table, type_table, exp);

    putchar('\n');
    return 0;

#endif
}

void test_enventry_assert_print(string symbol, int line)
{
    S_table val_table = E_base_venv();
    assert(NULL != val_table);

    E_enventry func = S_look(val_table, S_Symbol(symbol));
    assert(NULL != func);
    printf("test \" %s \" at line %d\n", symbol, line);
    printf("parameters: "); TyList_print(func->u.fun.formals); putchar('\n');
    printf("return: "); Ty_print(func->u.fun.result);  putchar('\n'); putchar('\n');
}

void test_enventry()
{
    printf("test enventry at line %d\n", __LINE__);
    S_table type_table = E_base_tenv();
    S_table val_table = E_base_venv();

    assert(NULL != type_table);
    assert(NULL != val_table);

    E_enventry not_exist_func = S_look(val_table, S_Symbol("foo"));
    assert(NULL == not_exist_func);

    Ty_ty int_type = S_look(type_table, S_Symbol("int"));
    assert(NULL != int_type);
    Ty_print(int_type); putchar('\n');

    Ty_ty string_type = S_look(type_table, S_Symbol("string"));
    assert(NULL != string_type);
    Ty_print(string_type); putchar('\n');

    test_enventry_assert_print("print", __LINE__);
    test_enventry_assert_print("printi", __LINE__);
    test_enventry_assert_print("flush", __LINE__);
    test_enventry_assert_print("getchar", __LINE__);
    test_enventry_assert_print("ord", __LINE__);
    test_enventry_assert_print("chr", __LINE__);
    test_enventry_assert_print("size", __LINE__);
    test_enventry_assert_print("substring", __LINE__);
    test_enventry_assert_print("concat", __LINE__);
    test_enventry_assert_print("not", __LINE__);
    test_enventry_assert_print("exit", __LINE__);
}

void test_transvar()
{
    printf("test transvar at line %d\n", __LINE__);

    S_table type_table = E_base_tenv();
    S_table val_table = E_base_venv();

    /* a isn't in the base environment initially */
    Tr_expty expty = transVar(val_table, type_table, A_SimpleVar(0, S_Symbol("a")));
    Ty_print(expty->ty); putchar('\n');

    /* a is in the base environment now */
    S_enter(val_table, S_Symbol("a"), E_VarEntry(Ty_Int()));
    expty = transVar(val_table, type_table, A_SimpleVar(0, S_Symbol("a")));
    Ty_print(expty->ty); putchar('\n');

}
