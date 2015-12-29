(* Dan Grossman, CSE341 Spring 2013, HW3 Provided Code *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

(* f1 -> default value for Wildcard
 * f2 -> function to compute Variable 
 * p -> pattern list 
 * Return score for pattern list*)
fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = Anything
	     | UnitT
	     | IntT
	     | TupleT of typ list
	     | Datatype of string

(**** you can put all your code here ****)

(* q1 *)
fun first_is_capital str = Char.isUpper(let val first = 0 in String.sub(str, first)end)

fun only_capitals lst = List.filter first_is_capital lst
(* q1 *)

(* q2 *)
fun str_size_cmpr1(lhs, rhs) = if String.size lhs > String.size rhs then lhs else rhs
fun longest_string1 [] = ""
  | longest_string1 lst = List.foldl str_size_cmpr1 (hd lst) lst
(* q2 *)

(* q3 *)
fun str_size_cmpr2(lhs, rhs) = if String.size lhs >= String.size rhs then lhs else rhs
fun longest_string2 [] = ""
  | longest_string2 lst = List.foldl str_size_cmpr2 (hd lst) lst
(* q3 *)


(* q4 *)
fun longest_string_helper f [] = ""
  | longest_string_helper f lst = List.foldl (fn (lhs, rhs) => if f(String.size lhs, String.size rhs) then lhs else rhs) (hd lst) lst

val longest_string3 = longest_string_helper (fn(a,b) => a > b)
val longest_string4 = longest_string_helper (fn(a,b) => a >= b)
(* q4 *)

(* q5 *)
val longest_capitalized = longest_string1 o only_capitals  
(* q5 *)

(* q6 *)
fun rev_string str = String.implode (rev (String.explode str))
val rev_string2 = String.implode o rev o String.explode
(* q6 *)

(* q7 *)
fun first_answer f [] = raise NoAnswer  
  | first_answer f (x::xs) = case (f x) of
                                SOME v => v
                              | NONE => first_answer f xs
(* q7 *)

(* q8 *)
fun combine lst = List.foldl (fn (a, b) => a @ b) [] lst
fun all_answers f [] = SOME []
  | all_answers f (x::xs) = case (f x) of
                                 NONE => all_answers f xs
                               | SOME l1 => SOME (l1 @ valOf (all_answers f xs))
                                 
(* q8 *)

(* q9 *)
val count_wildcards = g (fn x => 1) (fn x => 0) 
val count_wild_and_variable_lengths = g (fn x=>1) String.size 
fun count_some_var str = g (fn x=>0) (fn x => if x = str then 1 else 0) 
(* q9 *)

(* q10 *)
fun get_all_variables p = 
  case p of 
       Variable v => [v]
     | TupleP tp => List.foldl (fn (p',acc)=> acc @ (get_all_variables p')) [] tp
     | _ => []

fun is_unique [] = true
  | is_unique (x::xs) = is_unique xs andalso not (List.exists (fn a=>a=x) xs)
val check_pat = is_unique o get_all_variables
(* q10 *)

(* q11 *)
fun match1 (_, Wildcard) = SOME []
  | match1 (v, Variable str) = SOME [(str, v)]
  | match1 (Unit, UnitP) = SOME []
  | match1 (Const a, ConstP b) = if a = b then SOME [] else NONE
  | match1 (Tuple vl, TupleP pl) = all_answers match1 (ListPair.zipEq(vl, pl))
  | match1 (Constructor(s1,v), ConstructorP(s2,p)) = if s1 = s2 then match1(v,p) else NONE
  | match1 (_, _) = NONE
(* q11 *)


(* q12 *)
fun first_match v lst = SOME (first_answer (fn p => match1(v,p)) lst)
  handle NoAnswer => NONE
(* q12 *)


