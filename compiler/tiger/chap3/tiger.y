%{
#include <stdio.h>
#include "util.h"
#include "errormsg.h"

int yylex(void); /* function prototype */

void yyerror(char *s)
{
    EM_error(EM_tokPos, "%s", s);
}
%}


%union {
	int pos;
	int ival;
	string sval;
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

%start program

%nonassoc ASSIGN
%left AND OR 
%nonassoc EQ LT GT 
%nonassoc NEQ LE GE
%left PLUS MINUS
%left TIMES DIVIDE
%left NEG

%%

program: exps

exps: /* empty */
    | exp
    | exp SEMICOLON exps       

exp: lvalue
   | STRING
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
   | VAR lvalue ASSIGN exp
   | LPAREN expr_seq RPAREN
   | ID LPAREN expr_list RPAREN 
   | ID LBRACE field_list RBRACE
   | ID LBRACK exp RBRACK OF exp
   | IF exp THEN exp  
   | IF exp THEN exp ELSE exp 
   | WHILE exp DO exp
   | FOR ID ASSIGN exp TO exp DO exp 
   | BREAK
   | LET declare_list IN expr_seq END

lvalue: ID
      | lvalue DOT ID
      | lvalue LBRACK exp RBRACK

expr_seq: /* empty */
      | exp
      | exp SEMICOLON expr_seq

expr_list: /* empty */
       | exp
       | exp COMMA expr_list

field_list: /* empty */
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

type_fields: /* empty */
           | type_field
           | type_field COMMA type_fields
	
type_field: ID

variable_declare: VAR ID ASSIGN exp
                | VAR ID COLON ID ASSIGN exp

function_declare: FUNCTION ID LPAREN type_fields RPAREN EQ expr_seq
                | FUNCTION ID LPAREN type_fields RPAREN COLON ID EQ expr_seq
