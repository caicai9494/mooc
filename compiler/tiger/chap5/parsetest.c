#include "util.h"
#include "errormsg.h"
#include "parse.h"
#include "prabsyn.h"

#include <stdio.h>
#include <stdlib.h>


int main(int argc, char** argv) 
{

    if (argc != 2) {
        fprintf(stderr, "usage: a.out filename\n");
        exit(1);
    }
    pr_exp(stdout, parse(argv[1]), 4);
    putchar('\n');
    return 0;
}
