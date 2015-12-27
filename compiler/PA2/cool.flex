/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

#include <string.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

%x COMMENT
%x STRING

/*
 * Define names for regular expressions here.
 */
LOWER           [a-z]
UPPER           [A-Z]
LETTER          ({LOWER}|{UPPER})
DIGIT           [0-9]
LEGAL           ({LETTER}|{DIGIT}|_)

DARROW          =>
ASSIGN          <-
LE              <=

CLASS           (?i:class)
ELSE            (?i:else)
FI              (?i:fi)
IF              (?i:if)
IN              (?i:in)
INHERITS        (?i:inherits)
LET             (?i:let)
LOOP            (?i:loop)
POOL            (?i:pool)
THEN            (?i:then)
WHILE           (?i:while)
CASE            (?i:case)
ESAC            (?i:esac)
OF              (?i:of)
NEW             (?i:new)
ISVOID          (?i:isvoid)
NOT             (?i:not)
LET_STMT        (?i:let_stmt)

TRUE            t(?i:rue)            
FALSE           f(?i:alse)
BOOL            {TRUE}|{FALSE}

TYPEID          {UPPER}{LEGAL}*
OBJID           {LOWER}{LEGAL}*
INT             {DIGIT}+

WHITESPACE      [ \n\f\r\t\v]


%%

 /*
  *  Nested comments
  */


 /*
  *  The multiple-character operators.
  */

\n                      { curr_lineno++;  }

\"                      {
  BEGIN(STRING);
  string_buf_ptr = string_buf;
}

<STRING>\n            {
  if (string_buf_ptr - string_buf >= MAX_STR_CONST) {
    cool_yylval.error_msg = "String constant too long";
    return ERROR;  
  } else {
    *string_buf_ptr++ = '\n';
  }
}
<STRING>[^"]            {
  if (string_buf_ptr - string_buf >= MAX_STR_CONST) {
    cool_yylval.error_msg = "String constant too long";
    return ERROR;  
  } else {
    *string_buf_ptr++ = yytext[0];
  }
}
  
<STRING>\"               {
  BEGIN(INITIAL);
  cool_yylval.symbol = stringtable.add_string(string_buf);
  printf("yoyo%d\n", strlen(string_buf));
  return STR_CONST;  
}

 /* 
  * comments syntax
  */

--.*                    ;

"(*"                    { BEGIN(COMMENT); }
<COMMENT>"*)"           { BEGIN(INITIAL); }
<COMMENT>\n             { curr_lineno++;  } 
<COMMENT><<EOF>>        {
  cool_yylval.error_msg = "EOF in comment";
  BEGIN(INITIAL);
  return ERROR;  
}
<COMMENT>.              ;

"*)"                    {
  cool_yylval.error_msg = "Unmatched *)";
  return ERROR;  
}
  

{CLASS}		        { return (CLASS); }
{ELSE}                  { return (ELSE);  } 
{FI}                    { return (FI);    } 
{IF}                    { return (IF);    } 
{IN}                    { return (IN);    } 
{INHERITS}		{ return (INHERITS); }
{LET}                   { return (LET);   } 
{LOOP}                  { return (LOOP);  } 
{POOL}                  { return (POOL);  } 
{THEN}                  { return (THEN);  } 
{WHILE}                 { return (WHILE); } 
{CASE}                  { return (CASE);  } 
{ESAC}                  { return (ESAC);  } 
{OF}                    { return (OF);    } 
{DARROW}		{ return (DARROW);}
{NEW}                   { return (NEW);   } 
{ISVOID}		{ return (ISVOID);}
{ASSIGN}                { return (ASSIGN);}
{NOT}                   { return (NOT);   } 
{LE}                    { return (LE);    } 
{LET_STMT}              { return (LET_STMT); } 

error                   ;

{DIGIT}                 { 
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;  
} 
{BOOL}                 { 
  cool_yylval.boolean = (yytext[0] == 't' ? true : false);
  return BOOL_CONST;  
} 
{TYPEID}                 { 
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;  
} 
{OBJID}                 { 
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;  
} 

";"		return ';';
"{"		return '{';
"}"		return '}';
":"		return ':';
"."		return '.';
"("		return '(';
")"		return ')';
"="		return '=';
"+"		return '+';
"-"		return '-';
"*"		return '*';
"/"		return '/';
"<"		return '<';
","		return ',';
"~"		return '~';
"@"		return '@';

WHITESPACE      ;

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
