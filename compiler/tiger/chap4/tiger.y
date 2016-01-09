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
        A_dec dec;
        A_decList declist;
        A_expList explist;
        A_field field;
        A_fieldList fieldlist;
        A_fundec fundec;
        A_fundecList fundeclist;
        A_efield efield;
        A_efieldList efieldlist;
        A_namety namety;
        A_nametyList nametylist;
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

%type <var> lvalue
%type <exp> exp program function array record
%type <explist> exp_seq exp_list 
%type <dec> dec 
%type <declist> dec_list
%type <efield> efield
%type <efieldlist> efield_list
%type <field> field
%type <fieldlist> field_list
%type <fundec> fundec
%type <fundeclist> fundec_list
%type <namety> namety
%type <nametylist> namety_list
/* et cetera */

%start program

%nonassoc ASSIGN
%left AND OR 
%nonassoc EQ LT GT 
%nonassoc NEQ LE GE
%left PLUS MINUS
%left TIMES DIVIDE
/*%right OF ELSE DO THEN*/
%left NEG

%%

program: exp {absyn_root=$1;}

exp: lvalue {$$=A_VarExp(EM_tokPos,$1);}
   | INT {$$=A_IntExp(EM_tokPos, $1);}
   | NIL {$$=A_NilExp(EM_tokPos);}
   | STRING {$$=A_StringExp(EM_tokPos,$1);}
   | array
   | function
   | record
   | lvalue ASSIGN exp {$$=A_AssignExp(EM_tokPos, $1, $3);}
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
   | exp AND exp {$$=A_IfExp(EM_tokPos, $1, $3, A_IntExp(EM_tokPos, 0));}
   | exp OR exp {$$=A_IfExp(EM_tokPos, $1, A_IntExp(EM_tokPos, 1), $3);}
   | LPAREN exp_seq RPAREN {$$=A_SeqExp(EM_tokPos, $2);}
   | IF exp THEN exp {$$=A_IfExp(EM_tokPos, $2, $4, NULL);}
   | IF exp THEN exp ELSE exp {$$=A_IfExp(EM_tokPos, $2, $4, $6);}
   | WHILE LPAREN exp RPAREN DO exp {$$=A_WhileExp(EM_tokPos, $3, $6);}
   | FOR ID ASSIGN exp TO exp DO exp {$$=A_ForExp(EM_tokPos, S_Symbol($2), $4, $6, $8);} 
   | BREAK {$$=A_BreakExp(EM_tokPos);}
   | LET dec_list IN exp_seq END {$$=A_LetExp(EM_tokPos, $2, A_SeqExp(EM_tokPos, $4));}

lvalue: ID {$$=A_SimpleVar(EM_tokPos, S_Symbol($1));}
      | ID LBRACK exp RBRACK {$$=A_SubscriptVar(EM_tokPos, A_SimpleVar(EM_tokPos, S_Symbol($1)), $3);}
      | lvalue LBRACK exp RBRACK {$$=A_SubscriptVar(EM_tokPos, $1, $3);}
      | lvalue DOT ID {$$=A_FieldVar(EM_tokPos, $1, S_Symbol($3));}

record: ID LBRACE efield_list RBRACE {$$=A_RecordExp(EM_tokPos, S_Symbol($1), $3);}

array: ID LBRACK exp RBRACK OF exp {$$=A_ArrayExp(EM_tokPos, S_Symbol($1),$3, $6);}

function: ID LPAREN exp_list RPAREN {$$=A_CallExp(EM_tokPos, S_Symbol($1), $3);}

exp_seq: /* empty */ {$$=A_ExpList(NULL, NULL);}
       | exp {$$=A_ExpList($1, NULL);}
       | exp SEMICOLON exp_seq {$$=A_ExpList($1, $3);}

exp_list: /* empty */ {$$=A_ExpList(NULL, NULL);}
        | exp {$$=A_ExpList($1, NULL);}
        | exp COMMA exp_list {$$=A_ExpList($1, $3);}

dec: fundec_list {$$=A_FunctionDec(EM_tokPos, $1);}
   | VAR ID ASSIGN exp {$$=A_VarDec(EM_tokPos, S_Symbol($2), NULL, $4);}
   | VAR ID COLON ID ASSIGN exp {$$=A_VarDec(EM_tokPos, S_Symbol($2), S_Symbol($4), $6);}
   | namety_list {$$=A_TypeDec(EM_tokPos, $1);}

dec_list: dec  {$$=A_DecList($1, NULL);}
        | dec dec_list {$$=A_DecList($1, $2);}

efield: ID EQ exp {$$=A_Efield(S_Symbol($1), $3);} 

efield_list: /* empty */ {$$=A_EfieldList(NULL, NULL);}
        | efield {$$=A_EfieldList($1, NULL);} 
        | efield COMMA efield_list {$$=A_EfieldList($1, $3);}

field: ID COLON ID {$$=A_Field(EM_tokPos, S_Symbol($1), S_Symbol($3));} 

field_list: /* empty */ {$$=A_FieldList(NULL, NULL);}
        | field {$$=A_FieldList($1, NULL);} 
        | field COMMA field_list {$$=A_FieldList($1, $3);}

fundec: FUNCTION ID LPAREN field_list RPAREN EQ LPAREN exp_seq RPAREN {$$=A_Fundec(EM_tokPos, S_Symbol($2), $4, NULL, A_SeqExp(EM_tokPos, $8));}
      | FUNCTION ID LPAREN field_list RPAREN COLON ID EQ LPAREN exp_seq
RPAREN {$$=A_Fundec(EM_tokPos, S_Symbol($2), $4, S_Symbol($7), A_SeqExp(EM_tokPos, $10));}

fundec_list: fundec {$$=A_FundecList($1, NULL);}
	   | fundec fundec_list {$$=A_FundecList($1, $2);}

namety: TYPE ID EQ ID {$$=A_Namety(S_Symbol($2), A_NameTy(EM_tokPos, S_Symbol($4)));}
      | TYPE ID EQ ARRAY OF ID {$$=A_Namety(S_Symbol($2), A_ArrayTy(EM_tokPos, S_Symbol($6)));}
      | TYPE ID EQ LBRACE field_list RBRACE {$$=A_Namety(S_Symbol($2), A_RecordTy(EM_tokPos, $5));}

namety_list: namety {$$=A_NametyList($1, NULL);}
	   | namety namety_list {$$=A_NametyList($1, $2);}



