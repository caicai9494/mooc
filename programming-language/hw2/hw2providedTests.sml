(* Dan Grossman, CSE341 Spring 2013, HW2 Provided Code *)

(* if you use this function to compare two strings (returns true if the same
   string), then you avoid several of the functions in problem 1 having
   polymorphic types that may be confusing *)
fun same_string(s1 : string, s2 : string) =
    s1 = s2

val mstrings = ["January", "February", "March", "April", "May", "June", "July",
"August", "September", "October", "November", "December"];


fun all_except_option (str, strs) = 
let fun inner (strs, ret) =
  case strs of
       [] => ret
     | x :: xs' => if same_string (str, x)
                   then inner (xs', ret)
                   else inner (xs', ret @ [x])
in if null strs
   then NONE
   else let val ret = inner (strs, [])
        in if ret = strs
           then NONE
           else SOME ret
        end

end

fun get_substitution1 ([], _) = []
  | get_substitution1 (x :: xs, str) = let val new_lists = all_except_option (str, x) 
                                       in if isSome new_lists
                                          then valOf new_lists @
                                          get_substitution1 (xs, str)
                                          else get_substitution1 (xs, str)
                                       end

                                       (*
fun get_substitution3 ([], _) = []
  | get_substitution3 (x :: xs, str) = case all_except_option (str, x) of
                                            NONE => get_substitution3 (xs, str)
                                          | SOME xs => SOME (x :: get_substitution3
                                              (xs, str))  
                                              *)


val names = [["Fred","Fredrick"],["Jeff","Jeffrey"],["Geoff","Jeff","Jeffrey"]];

fun get_substitution2 (lists, str) = 
let 
  fun helper (lists, ret) = 
    case (lists, ret) of 
         ([], ret) => ret
       | (x :: xs, ret) => let val new_lists = all_except_option (str, x)
                           in if isSome new_lists
                              then helper (xs, ret @ valOf new_lists)
                              else helper (xs, ret)
                           end
in helper (lists, [])
end

fun similar_names ([], full_name) = [full_name]
  | similar_names (lists, {first = f, middle = m, last = l}) = 
        let 
          val sub = get_substitution2 (lists, f)
          fun helper (sub, ret) =
           case (sub, ret) of
               ([], r) => [r] 
              |(x :: xs, r) => {first = x, middle = m, last = l} ::  
                 helper (xs, r)
        in helper (sub, {first = f, middle = m, last = l})
        end

val linzhe = {first = "Jeff", middle = "L", last= "Cai"};

(* put your solutions for problem 1 here *)

(* you may assume that Num is always used with values 2, 3, ..., 10
   though it will not really come up *)
datatype suit = Clubs | Diamonds | Hearts | Spades
datatype rank = Jack | Queen | King | Ace | Num of int 

type card = suit * rank

datatype color = Red | Black
datatype move = Discard of card | Draw 

exception IllegalMove

(* put your solutions for problem 2 here *)

fun card_color (Clubs, _) = Black
  | card_color (Diamonds, _) = Red
  | card_color (Hearts, _) = Red
  | card_color (Spades, _) = Black

(* presume Num is valid *)
fun card_value (_, Num i) = i
  | card_value (_, Ace) = 11
  | card_value (_, _) = 10


fun remove_card (cards, c, e) = 
  case cards of
       [] => raise e
     | x::xs => if x = c
                  then xs
                  else x :: remove_card (xs, c, e)

val HAND = [(Clubs, Num 1), (Diamonds, Num 4), (Spades, Jack), (Clubs, Ace),
(Hearts, Ace), (Hearts, Jack)]
val C1 = (Clubs, Num 1)

(* test 2-c *)
val ret31 = remove_card(HAND, C1, IllegalMove)
(* test 2-c *)

fun all_same_color [] = false
  | all_same_color (_ :: []) = true
  | all_same_color (x :: y :: xs) = (card_color x = card_color y andalso all_same_color (y :: xs))


(* test 2-d *)
val ret41 = all_same_color(HAND)
(* test 2-d *)

fun sum_cards cards = 
let 
  fun sum ([], n) = n
    | sum (x :: xs, n) = sum (xs, n + card_value x)
in 
  sum (cards, 0)
end

(* test 2-e *)
val ret51 = sum_cards(HAND)
(* test 2-e *)

fun score (cards, g) = 
  let val s = sum_cards cards
      val diff = if s > g then 3 * (s - g) else (g - s) 
  in if all_same_color cards
     then diff div 2
     else diff
  end

(* test 2-f *)
val ret61 = score(HAND, 110)
val ret62 = score(HAND, 15)
val ret63 = score(HAND, 5)
(* test 2-f *)


(*
fun sum_cards_challenge cards = 
let 
  fun sum ([], n) = n
    | sum ((_, Ace) :: xs, n) = Int.min (sum (xs, 11 + n), 
                                         sum (xs, 1 + n)) 
    | sum (x :: xs, n) = sum (xs, n + card_value x)
                               
in 
  sum (cards, 0)
end
*)

fun score_challenge(cards, g) = 
let 
  fun helper([], rhs) = score(rhs, g)
    | helper((s, Ace)::xs, rhs) = Int.min(helper(xs, (s, Ace)::rhs), 
                                          helper(xs, (s, Num 1)::rhs))
    | helper(x::xs, rhs) = helper(xs, x::rhs)
in helper(cards, [])
end

(* test 2-fx *)
val ret61x = score_challenge(HAND, 110)
val ret62x = score_challenge(HAND, 15)
val ret63x = score_challenge(HAND, 5)
(* test 2-fx *)



fun officiate (cards, moves, g) = 
let 
  (* (held, cards, moves) = *)
  fun inner (held, _, []) = score (held, g)  
    | inner (held, [], Draw :: _) = score (held, g)
    | inner (held, c :: cards', Draw :: moves') = 
      let 
        val new_held = c :: held
        val new_sum = sum_cards new_held 
      in if new_sum > g 
         then score (new_held, g)
         else inner (new_held, cards', moves')
      end
    | inner (held, cards', (Discard c) :: moves') = inner (
            remove_card (held, c, IllegalMove), cards', moves')
in inner ([], cards, moves)
end

val pile = [(Clubs, Ace), (Clubs, Num 10), (Diamonds, Num 5), (Hearts, Num 3)];
val moves = [Draw, Draw, Draw];

officiate (pile, moves, 10);
officiate ([], moves, 10);
officiate (pile, [], 10);

(*
fun careful_player (cards, goal) = 
(* card-lis * held * score => move-list *)
let fun inner (_, _, 0) = []
  | fun inner (_, _, score) = if score > goal   
                              then []
                              else inner (
                              *)

