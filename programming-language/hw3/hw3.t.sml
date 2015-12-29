use "hw3provided.sml";

val L1 = ["jack", "tom", "Mary", "Detlef", "Linzhe"]
val L2 = ["jack", "tom", "Mary", "Detlef", "Linzhe", "Ddd", "12345qdafd"]
val L3 = ["aaa", "aaa", "aaa"]

val P1 = Wildcard
val P2 = TupleP [Wildcard, Variable "yes", Wildcard, ConstP 5] 
val P3 = TupleP [Wildcard, Variable "no", Wildcard, ConstP 5, 
                 TupleP [Wildcard, UnitP]]
val P4 = TupleP [Wildcard, Variable "dfdf", Wildcard, ConstP 5, 
                 TupleP [Wildcard, UnitP, Variable "no"]]

val t1 = only_capitals L1

val t2a = longest_string1 [] 
val t2b = longest_string1 L1 

val t3a = longest_string2 [] 
val t3b = longest_string2 L1 

val t4a = longest_string3 [] 
val t4b = longest_string3 L1 
val t4c = longest_string4 [] 
val t4d = longest_string4 L1 

val t5a = longest_capitalized [] 
val t5b = longest_capitalized L1 
val t5c = longest_capitalized L2 

val t6a = rev_string (hd L2) 
val t6b = rev_string2 (hd L2) 
val t6c = rev_string2 (hd (tl L2)) 

val t9a = count_wildcards P1
val t9b = count_wildcards P2
val t9c = count_wildcards P3
val t9d = count_wild_and_variable_lengths P4
val t9e = count_some_var "yes" P3 
val t9f = count_some_var "no" P3 
val t9g = count_some_var "no" P4 

val t10a = get_all_variables P4
val t10b = is_unique []
val t10c = is_unique L2
val t10d = is_unique L3
val t10e = check_pat P4

val PATTERN1 = Wildcard
val PATTERN2 = Variable "p1"
val PATTERN3 = UnitP 
val PATTERN4 = TupleP [PATTERN1, PATTERN2] 
val PATTERN5 = ConstructorP ("c1", PATTERN4) 
val VALUE1 = Unit
val VALUE2 = Const 5
val VALUE3 = Tuple [Const 5, Unit]
val VALUE4 = Constructor ("c1", VALUE3) 
val VALUE5 = Constructor ("c2", VALUE3) 
val t11a = match1 (VALUE1, PATTERN1)
val t11b = match1 (VALUE2, PATTERN2)
val t11c = match1 (VALUE2, PATTERN3)
val t11d = match1 (VALUE1, PATTERN3)
val t11e = match1 (VALUE3, PATTERN4)
val t11f = match1 (VALUE3, PATTERN5)
val t11g = match1 (VALUE4, PATTERN5)
val t11h = match1 (VALUE5, PATTERN5)

val PATTERN_LIST = [PATTERN5, PATTERN2, PATTERN3, PATTERN4, PATTERN1]

val t12a = first_match VALUE3 PATTERN_LIST


