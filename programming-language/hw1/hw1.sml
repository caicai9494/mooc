fun date (year : int, month : int, day : int) =
  (year, month, day)

(* test date *)
val today = date (2015, 2, 6)
val yesterday = date (2015, 11, 5)
val today2 = date (2015, 11, 8)
val tomorrow = date (2015, 11, 9)
val bc = date (0, 0, 0)
val leap_one_day = date (2000, 2, 28)
(* test date *)

(* lhs is older then rhs? *)
fun is_older (lhs : int * int * int, rhs : int * int * int) = 
  (#1 lhs < #1 rhs orelse #2 lhs < #2 rhs orelse #3 lhs < #3 rhs)

(* test is_older *)
(*is_older ((2015, 11, 6), (2015,11,12))*) 
(* test is_older *)

fun number_in_month (number : int, date_lists : (int * int * int) list) = 
  if number < 1 orelse number > 12
  then 0
  else let fun number_in_valid_month (xs : (int * int * int) list) =
             if null xs
             then 0
             else let val later = number_in_valid_month (tl xs)
                  in if number = #2 (hd xs)
                     then 1 + later
                     else later
                  end
       in 
         number_in_valid_month date_lists
       end
       
(* test number_in_month *)
val dates = [today2, tomorrow, bc, today, yesterday]
(* test number_in_month *)

(* assume no duplicates in number *)
fun number_in_months (number : int list, date_lists : (int * int * int) list) = 
  if null number
  then 0
  else number_in_month (hd number, date_lists) + 
       number_in_months (tl number, date_lists)

(* test number_in_months *)
val months = [0, 1, 11, 2]
(* test number_in_months *)


fun dates_in_month (number : int, date_lists : (int * int * int) list) = 
  if number < 1 orelse number > 12
  then []
  else let fun dates_in_valid_month (xs : (int * int * int) list) =
             if null xs
             then []
             else let val later = dates_in_valid_month (tl xs)
                      val head = hd xs
                  in if number = #2 head
                     then head :: later
                     else later
                  end
       in 
         dates_in_valid_month date_lists
       end

(* assume no duplicates in number *)
fun dates_in_months (number : int list, date_lists : (int * int * int) list) = 
  if null number
  then []
  else dates_in_month (hd number, date_lists) @ 
       dates_in_months (tl number, date_lists)

(* return NONE if number exceeds length of the list *)
fun get_nth_string (number : int, xs : string list) = 
  if null xs 
  then NONE
  else 
    if number = 1
    then SOME (hd xs)
    else get_nth_string (number - 1, tl xs)

val tstrings = ["first", "second", "third"]

(* convert date to string *)
fun date_to_string (date : int * int * int) = 
let val year = Int.toString (#1 date)
    val month = #2 date
    val day = Int.toString (#3 date)
    val mstrings = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    val month_in_string = valOf (get_nth_string(month, mstrings))

in month_in_string ^ " " ^ day ^ ", " ^ year
end

fun number_before_reaching_sum (sum : int, xs : int list) = 
    if not (null xs) andalso hd xs < sum
    then 1 + number_before_reaching_sum (sum - (hd xs), tl xs)
    else 0

fun what_month (day : int) = 
  let val days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  in number_before_reaching_sum (day, days)
  end

(* will sanity check "day" *)
fun what_month_save (day : int) = 
  if day < 1 orelse day > 365
  then NONE
  else SOME (what_month day)

(* if day_from > day_to, return [] *)
fun month_range (day_from : int, day_to : int) = 
  if day_from > day_to 
  then []
  else 
    let 
      val month_from = what_month (day_from)
      val month_to = what_month (day_to) 
      fun count (from : int, to : int) = 
        if from < to
        then from :: count (from + 1, to)
        else []
    in count (month_from, month_to)
    end


fun month_range (day_from : int, day_to : int) = 
  if day_from > day_to 
  then []
  else 
    (what_month day_from) :: (month_range (day_from + 1, day_to))

fun month_range_safe (day_from : int, day_to : int) = 
  if day_from < 1 orelse day_to < 1 orelse day_from > 365 orelse day_to > 365
  then NONE
  else SOME (month_range (day_from, day_to))

fun oldest (dates : (int * int * int) list) = 
  if null dates
  then NONE
  else let val later = oldest (tl dates)
       in if isSome later andalso is_older (hd dates, valOf later)
          then later 
          else SOME (hd dates)
       end

fun is_valid_date (dates : int * int * int) = 
    (* is_valid is inclusive *)
let 
    val year = #1 dates
    val month = #2 dates
    val day = #3 dates
    val days_leap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    val days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    fun is_valid (from : int, to : int, target : int) = 
      target <= to andalso target >= from

    fun is_valid_year () = 
      is_valid (1, 9999, year)
    fun is_valid_month () = 
      is_valid (1, 12, month)

    fun get_nth_int (n : int, xs : int list) = 
      if n = 1
      then hd xs
      else get_nth_int (n - 1, tl xs)

    fun is_valid_day (days_in_month : int list) = 
    let val max_day = get_nth_int (month, days_in_month)
    in is_valid (1, max_day, day)
    end

    fun is_leap () = 
     year mod 4 = 0 

in 
  if is_valid_year() andalso is_valid_month() 
  then 
    if is_leap()
    then is_valid_day days_leap
    else is_valid_day days
  else false
end
     

fun remove_duplicate (n : int, xs : int list) =
  if null xs
  then []
  else 
    let val left = remove_duplicate (n, tl xs)
    in if n = hd xs
       then left
       else hd xs :: left
    end

fun remove_duplicates (ns : int list, xs : int list) = 
  if null ns
  then xs
  else 
    let val after = remove_duplicate (hd ns, xs)
    in if null after
       then []
       else remove_duplicates (tl ns, after)
    end
