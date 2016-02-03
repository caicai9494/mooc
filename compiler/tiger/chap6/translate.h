#ifndef TRANSLATE_H
#define TRANSLATE_H

typedef struct Tr_access_ *Tr_access;

typedef struct Tr_access_list_ *Tr_access_list;
struct Tr_access_list_ {
    Tr_access head;
    Tr_access_list tail;
};


#endif
