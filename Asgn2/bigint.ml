(* $Id: bigint.ml,v 1.5 2014-11-11 15:06:24-08 - - $ *)
(* AUTHORS: 
   Sam Song(sasong@ucsc.edu)
   Edward Nguyen(ejnguyen@ucsc.edu)
*)
open Printf

module Bigint = struct

    type sign     = Pos | Neg
    type bigint   = Bigint of sign * int list
    let  radix    = 10
    let  radixlen =  1


    let car       = List.hd
    let cdr       = List.tl
    let map       = List.map
    let reverse   = List.rev
    let strcat    = String.concat
    let strlen    = String.length
    let strsub    = String.sub
    let zero      = Bigint (Pos, [])
    (* flips the sign of a number *)
    let flip_sign x = match x with 
      | Pos -> Neg
      | Neg -> Pos


    let charlist_of_string str = 
        let last = strlen str - 1
        in  let rec charlist pos result =
            if pos < 0
            then result
            else charlist (pos - 1) (str.[pos] :: result)
        in  charlist last []

    let bigint_of_string str =
        let len = strlen str
        in  let to_intlist first =
                let substr = strsub str first (len - first) in
                let digit char = int_of_char char - int_of_char '0' in
                map digit (reverse (charlist_of_string substr))
            in  if   len = 0
                then zero
                else if   str.[0] = '_'
                     then Bigint (Neg, to_intlist 1)
                     else Bigint (Pos, to_intlist 0)

    let string_of_bigint (Bigint (sign, value)) =
        match value with
        | []    -> "0"
        | value -> let reversed = reverse value
                   in  strcat ""
                       ((if sign = Pos then "" else "-") ::
                        (map string_of_int reversed))

    (*
* Trim off zeros from the end of a list.  If the list is a number
* represented in reveerse order, this trims high-order digits, as
* would be needed after a subtraction.
*)

    let trimzeros list =
        let rec trimzeros' list' = match list' with
        | []       -> []
        | [0]      -> []
        | car::cdr ->
             let cdr' = trimzeros' cdr
             in  match car, cdr' with
                 | 0, [] -> []
                 | car, cdr' -> car::cdr'
        in trimzeros' list

    (* compares the absolute values of two numbers*)
    let rec cmp val1 val2 = match (val1, val2) with
        | [], []     -> 0       (*Both lists empty (equal) return 0*)
        | [], value2 -> -1
        | value1, [] -> 1
        | car1::cdr1, car2::cdr2 ->
        let recval = cmp cdr1 cdr2
            in recval * 10 + car1 - car2

    (* recuresive adds digit by digit*)
    let rec add' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
          let sum = car1 + car2 + carry
          in  sum mod radix :: add' cdr1 cdr2 (sum / radix)

    (* Note will not work properly unles val1 > val2 *)
    (* recursive subtraction digit by digit *)
    let rec sub' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, borrow  -> list2
        | list1, [] , borrow -> (car list1) - borrow :: cdr list1
        | car1::cdr1, car2::cdr2, carry ->
            let res = car1 - car2 - carry
            in if res < 0
            (* needs to borrow 10 for the subtraction *)
            then (res + 10) :: (trimzeros (sub' cdr1 cdr2 1))
            else (abs res) :: (trimzeros (sub' cdr1 cdr2 0))

    let double number = 
        let res = add' number number 0
        in res

    (* recursivley multiplies using egyptian multiplication *)
    let rec mul' multiplier powerof2 multiplicand' =
    if (cmp powerof2 multiplier) > 0
    then multiplier, [0]
    else let remainder, product =
             mul' multiplier (double powerof2) (double multiplicand')
         in  if (cmp remainder powerof2) < 0
             then remainder, product
             else 
             (trimzeros(sub' remainder powerof2 0)),
             (add' product multiplicand' 0)

    (* recursivley divides using egyptiab division *)
    let rec divrem' dividend powerof2 divisor' =
    if (cmp divisor' dividend) > 0
    then [0], dividend
    else let quotient, remainder =
             divrem' dividend (double powerof2) (double divisor')
         in  if (cmp remainder divisor') < 0
             then quotient, remainder
             else
             (add' quotient powerof2 0),
             (trimzeros (sub' remainder divisor' 0)) 

    (* checks to see it number is even or not 
       by moding the number by 2*)
    let even number = 
        let _, remainder = divrem' number [1] [2]
        in if remainder = [0]
            then true
        else
            false

    (* absolute value operations mostly for power *)
    (* divide and multiply as absolute values *)
    let absdiv val1 val2 =
        let quotient, _ = divrem' val1 [1] val2 
        in quotient

    let absmul val1 val2 = 
        let _, product = mul' val1 [1] val2
        in product



    (* imported from mathfns-trace *)
    let rec power' base expt result = 
        match expt with
            | [0]                 -> result

            | expt when even expt -> power' 
                                     (absmul base base)
                                     (absdiv expt [2]) 
                                     result
            | expt                -> power' base
                                     (sub' expt [1] 0)
                                     (absmul base result)

    
    let add (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        if neg1 = neg2
            then Bigint (neg1, add' value1 value2 0)
        
        else if (cmp value1 value2) > 0 
            (* value 1 is larger use sign of value1 *)
            then Bigint (neg1, sub' value1 value2 0)
        else 
            (* value 2 is larger as such take the sign of value2 *)
            Bigint (neg2, sub' value2 value1 0)

    let sub (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        (* the subtraction of two numbers when 
        signs are opposite is addition *)
        if neg1 != neg2
            (* first value will always take priority *)
            then Bigint(neg1, add' val1 val2 0) 
        else if (cmp val1 val2) > 0
            (* no sign switch if val1 > val2 *)
            then Bigint(neg1, sub' val1 val2 0)
        else
            (* flips sign *) 
            Bigint(flip_sign neg1, sub' val2 val1 0) (* flips sign *)



    let mul (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        let _, product = mul' val1 [1] val2
        in  if neg1 = neg2
            then Bigint(Pos, product)
        else
            Bigint(Neg, product)


    let div (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        let quotient, _ = divrem' val1 [1] val2
        in if neg1 = neg2 
            then Bigint(Pos, quotient)
        else
            Bigint(Neg, quotient)

    let rem (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        let _, remainder = divrem' val1 [1] val2
        in Bigint(Pos, remainder)

    let pow (Bigint (neg1, base)) (Bigint (neg2, expt)) = 
        let res = power' base expt [1]
        in Bigint(Pos, res)


end

