val MONTHS = ["January", "February", "March", "April", "May", "June", "July",
"August", "September", "October", "November", "December"]

val NAMES = [["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]];

val LINZHE = {first = "Jeff", middle = "L", last= "Cai"};

fun same_string(s1 : string, s2 : string) =
    s1 = s2

fun all_except_option(str, strs) = 
  case strs of
       [] => NONE
     | x::xs => if same_string(str, x)
                then SOME xs
                else case all_except_option(str, xs) of
                          NONE => NONE
                        | SOME xs' => SOME(x :: xs')

(* test 1*)
val ret11 = all_except_option("May", MONTHS)
val ret12 = all_except_option("June", MONTHS)
val ret13 = all_except_option("Jane", MONTHS)
(* test 1*)

fun get_substitution1([], _) = []
  | get_substitution1(x::xs, str) = 
      case all_except_option (str, x) of
           NONE => get_substitution1(xs, str) 
         | SOME strings => strings @ get_substitution1(xs, str) 

(* test 2*)
val ret21 = get_substitution1(NAMES, "Fred")
val ret22 = get_substitution1(NAMES, "Jeff")
(* test 2*)

fun get_substitution2 (lists, str) = 
let 
  fun helper (lists, ret) = 
    case (lists, ret) of 
         ([], ret) => ret
       | (x :: xs, ret) => 
           case all_except_option (str, x) of
                NONE => helper(xs, ret)
              | SOME new_lists => helper(xs, ret @ new_lists) 
in helper (lists, [])
end

(* test 3*)
val ret31 = get_substitution2(NAMES, "Fred")
val ret32 = get_substitution2(NAMES, "Jeff")
(* test 3*)

fun similar_names (lists, {first = f, middle = m, last = l}) = 
    let 
      val sub = get_substitution2 (lists, f)
      fun helper (sub, ret) =
       case (sub, ret) of
           ([], r) => [r]
          |(x::xs, r) => {first = x, middle = m, last = l}::
             helper(xs, r)
    in helper(sub, {first = f, middle = m, last = l})
    end

(* test 4*)
val ret41 = similar_names(NAMES, LINZHE)
(* test 4*)

(* end of 1*)
