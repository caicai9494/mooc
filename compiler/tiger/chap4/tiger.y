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

program:   exp    {absyn_root=$1;}

exp:   ID         {$$=A_VarExp(EM_tokPos,A_SimpleVar(EM_tokPos,S_Symbol($1)));}

