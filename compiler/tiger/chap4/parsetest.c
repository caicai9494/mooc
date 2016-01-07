#include "util.h"
#include "errormsg.h"
#include "parse.h"

#include <stdio.h>
#include <stdlib.h>


int main(int argc, char** argv) 
{

    FILE* yyin = {stdin}; 
    FILE* yyout = {stdout};

    if (argc != 2) {
        fprintf(stderr, "usage: a.out filename\n");
        exit(1);
    }
    parse(argv[1]);
    return 0;
}
