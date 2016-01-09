%{
#include "util.h"
#include "absyn.h"
#include "symbol.h" 
#include "errormsg.h"
#include <stdio.h>

int yylex(void); /* function prototype */

A_exp absyn_root;

void yyerror(char *s)
{
 EM_error(EM_tokPos, "%s", s);
}
%}


%union {
	int pos;
	int ival;
	string sval;
	A_var var;
	A_exp exp;
        A_expList explist;
	/* et cetera */
	}

%token <sval> ID STRING
%token <ival> INT

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  PLUS MINUS TIMES DIVIDE EQ NEQ LT LE GT GE
  AND OR ASSIGN
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR TYPE 

%type <exp> exp program
%type <explist> explist
/* et cetera */

%start program

%nonassoc ASSIGN
%left AND OR 
%nonassoc EQ LT GT 
%nonassoc NEQ LE GE
%left PLUS MINUS
%left TIMES DIVIDE
%left NEG
%right OF ELSE DO THEN

%%

program: exp {absyn_root=$1;}

exp: ID {$$=A_VarExp(EM_tokPos,A_SimpleVar(EM_tokPos,S_Symbol($1)));}
   | INT {$$=A_IntExp(EM_tokPos, $1);}
   | NIL {$$=A_NilExp(EM_tokPos);}
   | STRING {$$=A_StringExp(EM_tokPos,$1);}
   | MINUS exp %prec NEG {$$=A_OpExp(EM_tokPos, A_minusOp, A_IntExp(EM_tokPos, 0), $2);}
   | exp PLUS exp {$$=A_OpExp(EM_tokPos, A_plusOp, $1, $3);}
   | exp MINUS exp {$$=A_OpExp(EM_tokPos, A_minusOp, $1, $3);}
   | exp TIMES exp {$$=A_OpExp(EM_tokPos, A_timesOp, $1, $3);}
   | exp DIVIDE exp {$$=A_OpExp(EM_tokPos, A_divideOp, $1, $3);}
   | exp EQ exp {$$=A_OpExp(EM_tokPos, A_eqOp, $1, $3);}
   | exp NEQ exp {$$=A_OpExp(EM_tokPos, A_neqOp, $1, $3);}
   | exp LT exp {$$=A_OpExp(EM_tokPos, A_ltOp, $1, $3);}
   | exp GT exp {$$=A_OpExp(EM_tokPos, A_gtOp, $1, $3);}
   | exp LE exp {$$=A_OpExp(EM_tokPos, A_leOp, $1, $3);}
   | exp GE exp {$$=A_OpExp(EM_tokPos, A_geOp, $1, $3);}
/*   | exp AND exp {$$=A_OpExp(EM_tokPos, A_andOp, $1, $3);}
   | exp OR exp {$$=A_OpExp(EM_tokPos, A_orOp, $1, $3);} */
   | LPAREN explist RPAREN {$$=A_SeqExp(EM_tokPos, $2);}
   | IF exp THEN exp {$$=A_IfExp(EM_tokPos, $2, $4, NULL);}
   | IF exp THEN exp ELSE exp {$$=A_IfExp(EM_tokPos, $2, $4, $6);}
   | WHILE exp DO exp {$$=A_WhileExp(EM_tokPos, $2, $4);}
   | BREAK {$$=A_BreakExp(EM_tokPos);}

explist: /* empty */ {$$=A_ExpList(NULL, NULL);}
       | exp {$$=A_ExpList($1, NULL);}
       | exp SEMICOLON explist {$$=A_ExpList($1, $3);}

/*
exps: 
    | exp
    | exp SEMICOLON exps       

exp: lvalue
   | STRING {$$=A_Exp(EM_tokPos,A_StringVar(EM_tokPos,S_Symbol($1)));}
   | INT
   | NIL
   | ARRAY LBRACK exp RBRACK
   | MINUS exp %prec NEG
   | exp PLUS exp
   | exp MINUS exp
   | exp TIMES exp
   | exp DIVIDE exp
   | exp EQ exp
   | exp NEQ exp
   | exp LT exp
   | exp GT exp
   | exp LE exp
   | exp GE exp
   | exp AND exp
   | exp OR exp
   | LPAREN expr_seq RPAREN
   | function 
   | array
   | record
   | IF exp THEN exp 
   | IF exp THEN exp ELSE exp 
   | WHILE exp DO exp
   | FOR ID ASSIGN exp TO exp DO exp 
   | BREAK
   | LET declare_list IN expr_seq END

function: ID LPAREN expr_list RPAREN

array: ID LBRACE field_list RBRACE

record: ID LBRACK exp RBRACK OF exp 

lvalue: ID
      | lvalue DOT ID
      | lvalue LBRACK exp RBRACK

expr_seq: 
      | exp
      | exp SEMICOLON expr_seq

expr_list: 
       | exp
       | exp COMMA expr_list

field_list: 
	 | TYPE ID EQ exp
	 | TYPE ID EQ exp SEMICOLON field_list

declare_list: declare
	    | declare declare_list

declare: type_declare
       | variable_declare
       | function_declare

type_declare: TYPE ID EQ type

type: ID
    | LBRACE type_fields RBRACE
    | ARRAY OF ID

type_fields: 
           | type_field
           | type_field COMMA type_fields
	
type_field: ID

variable_declare: VAR ID ASSIGN exp
                | VAR ID COLON ID ASSIGN exp

function_declare: FUNCTION ID LPAREN type_fields RPAREN EQ expr_seq
                | FUNCTION ID LPAREN type_fields RPAREN COLON ID EQ expr_seq
*/
