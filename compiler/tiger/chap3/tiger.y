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

%%

program: stmlist

stmlist: stm
       | stm SEMICOLON stmlist       

stm: exp

exp: ID
   | STRING
   | INT
   | NIL
   | ARRAY LBRACK exp RBRACK
   | MINUS exp
   | exp PLUS exp
   | exp MINUS exp
   | exp TIMES exp
   | exp DIVIDE exp
   | exp EQ exp
   | exp NEQ exp
   | exp LT exp
   | exp LE exp
   | exp GT exp
   | exp GE exp
   | exp AND exp
   | exp OR exp
   | exp ASSIGN exp
   | LPAREN expseq RPAREN
   | ID LPAREN explist RPAREN 
   | ID LBRACE declarelist RBRACE
   | ID LBRACK exp RBRACK OF exp
   | IF exp THEN exp  
   | IF exp THEN exp ELSE exp 
   | WHILE exp DO exp
   | FOR ID ASSIGN exp TO exp DO exp 
   | BREAK
   | LET declarelist IN expseq END

expseq: exp
      | exp SEMICOLON expseq

explist: exp
       | exp COLON explist

declarelist: ID ASSIGN exp
	   | ID ASSIGN exp SEMICOLON declarelist



	
