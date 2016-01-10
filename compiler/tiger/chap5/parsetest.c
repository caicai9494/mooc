#include "util.h"
#include "errormsg.h"
#include "parse.h"
#include "prabsyn.h"
#include "enventry.h"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#define TEST

void test_enventry_assert_print(string symbol, int line);
void test_enventry();

int main(int argc, char** argv) 
{
#ifdef TEST

    test_enventry();

    return 0;

#else

    if (argc != 2) {
        fprintf(stderr, "usage: a.out filename\n");
        exit(1);
    }
    pr_exp(stdout, parse(argv[1]), 4);
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

