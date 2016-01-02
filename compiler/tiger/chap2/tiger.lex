%{
#include <string.h>
#include <assert.h> /* assert */
#include <stdlib.h> /* strtol */
#include <stdio.h> /* printf for debugging */
#include "util.h"
#include "tokens.h"
#include "errormsg.h"

int charPos=1;

int yywrap(void)
{
 charPos=1;
 return 1;
}


void adjust(void)
{
 EM_tokPos=charPos;
 charPos+=yyleng;
}

int comment_depth = 0;

#define MAX_BUFFER 1024
char string_buf[MAX_BUFFER+1];
char* string_buf_ptr;

int dddtoi(char str[])
{
    char *start = str+1;
    char *end = str+4; 
    return strtol(start, &end, 10);
}

char ctocontrol(char c) 
{
    switch (c) {
        case '@': return '\0'; break;
        case 'G': return '\a'; break;
        case 'H': return '\b'; break;
        case 'I': return '\t'; break;
        case 'J': return '\n'; break;
        case 'K': return '\v'; break;
        case 'L': return '\f'; break;
        case 'M': return '\r'; break;
        default: assert(FALSE);
    }
}

int chartosymbol(char c) 
{
    switch (c) {
        case ',': return COMMA; break;
        case ':': return COLON; break;
        case ';': return SEMICOLON; break;
        case '(': return LPAREN; break;
        case ')': return RPAREN; break;
        case '{': return LBRACE; break;
        case '}': return RBRACE; break;
        case '[': return LBRACK; break;
        case ']': return RBRACK; break;
        case '.': return DOT; break;
        case '+': return PLUS; break;
        case '-': return MINUS; break;
        case '*': return TIMES; break;
        case '/': return DIVIDE; break;
        case '=': return EQ; break;
        case '&': return AND; break;
        case '|': return OR; break;
        case '<': return LT; break;
        case '>': return GT; break;
        default: assert(FALSE);
    }
}

%}

NEQ <>
LE <=
GE >=
ASSIGN :=

ID [a-zA-Z][a-zA-Z0-9_]*
DIGIT [0-9]+

COMMENTL  "/*"
COMMENTR  "*/"


WHILE    while
FOR      for
TO       to
BREAK    break
LET      let
IN       in
END      end
FUNCTION function
VAR      var
TYPE     type
ARRAY    array
IF       if
THEN     then
ELSE     else
DO       do
OF       of
NIL      nil

SINGLE_SYMBOL [-,:;(){}\[\].+*/=&|<>]

%x COMMENT_BLOCK STR_BLOCK 

%%

 /* 
  * comments
  */
{COMMENTL} { adjust(); comment_depth = 1; BEGIN COMMENT_BLOCK; }

<INITIAL>{COMMENTR} { EM_error(EM_tokPos, "unbounded comment"); }

<COMMENT_BLOCK>. ; 
<COMMENT_BLOCK>\n { EM_newline(); } 
<COMMENT_BLOCK>{COMMENTL} { comment_depth++; }
<COMMENT_BLOCK>{COMMENTR} {
    if (comment_depth == 1) {
        BEGIN 0;
    }
    else comment_depth--;
}
<COMMENT_BLOCK><<EOF>> {
    EM_error(EM_tokPos, "EOF in comment");
    BEGIN 0;
}

 /* 
  * strings
  */

\" {
    adjust();
    string_buf_ptr = string_buf;
    BEGIN STR_BLOCK;
}
<STR_BLOCK>\" {
    BEGIN 0;
    *string_buf_ptr = '\0';
    yylval.sval = string_buf;
    return STRING;
}
<STR_BLOCK>\\t {
    *string_buf_ptr++ = '\b';
}
<STR_BLOCK>\\^[@GHIJKLM] {
    *string_buf_ptr++ = ctocontrol(yytext[2]);
}
<STR_BLOCK>\\[0-9]{3} {
    *string_buf_ptr++ = (char)dddtoi(yytext);
}
<STR_BLOCK>\\(.|\n) {
    *string_buf_ptr++ = yytext[1];
}
<STR_BLOCK>[^"\\\0] {
    *string_buf_ptr++ = yytext[0];
}
<STR_BLOCK>\\[ \n\r\f\t]*\\ ;

 /* 
  * keywords
  */
{WHILE}  	 {adjust(); return WHILE;}
{FOR}  	         {adjust(); return FOR;}
{TO}  	         {adjust(); return TO;}
{BREAK}  	 {adjust(); return BREAK;}
{LET}  	         {adjust(); return LET;}
{IN}  	         {adjust(); return IN;}
{END}  	         {adjust(); return END;}
{FUNCTION}       {adjust(); return FUNCTION;}
{VAR}  	         {adjust(); return VAR;}
{TYPE}  	 {adjust(); return TYPE;}
{ARRAY}  	 {adjust(); return ARRAY;}
{IF}  	         {adjust(); return IF;}
{THEN}  	 {adjust(); return THEN;}
{ELSE}  	 {adjust(); return ELSE;}
{DO}  	         {adjust(); return DO;}
{OF}  	         {adjust(); return OF;}
{NIL}  	         {adjust(); return NIL;}

{DIGIT}	 {adjust(); yylval.ival=atoi(yytext); return INT;}
{ID}	 {adjust(); yylval.sval=yytext; return ID;}

{SINGLE_SYMBOL} {adjust(); return chartosymbol(yytext[0]);}
{NEQ} {adjust(); return NEQ;}
{LE} {adjust(); return LE;}
{GE} {adjust(); return GE;}
{ASSIGN} {adjust(); return ASSIGN;}

\n	 {adjust(); EM_newline(); continue;}
[ \t\n\f\r]	 {adjust(); continue;}
.	 {adjust(); EM_error(EM_tokPos,"illegal token");}


