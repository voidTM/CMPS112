(* $Id: bigint.ml,v 1.5 2014-11-11 15:06:24-08 - - $ *)

open Printf

module Bigint = struct

    type sign     = Pos | Neg
    type bigint   = Bigint of sign * int list
    let  radix    = 10
    let  radixlen =  1
    let even number = number mod 2 = 0


    let car       = List.hd
    let cdr       = List.tl
    let map       = List.map
    let reverse   = List.rev
    let strcat    = String.concat
    let strlen    = String.length
    let strsub    = String.sub
    let zero      = Bigint (Pos, [])
    let double number = number + number

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
    let rec cmp list1 list2 = match (list1, list2) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
            let equality = car1 - car2 + (cmp cdr1 cdr2)
*)
    let rec add' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
          let sum = car1 + car2 + carry
          in  sum mod radix :: add' cdr1 cdr2 (sum / radix)

    (* broken algorithm unknown *)
    let rec sub' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, borrow  -> list2
        | list1, [] , borrow -> (car list1) - borrow :: cdr list1
        | car1::cdr1, car2::cdr2, carry ->
            let res = car1 - car2 - carry
            in if res < 0
            then (res + 10) :: sub' cdr1 cdr2 1
            else abs(res) :: sub' cdr1 cdr2 0

    let rec mul' list1 list2 carry = match (list1, list2, carry) with
        | list1, [], 0       -> list1
        | [], list2, 0       -> list2
        | list1, [], carry   -> add' list1 [carry] 0
        | [], list2, carry   -> add' [carry] list2 0
        | car1::cdr1, car2::cdr2, carry ->
          let res = car1 * car2 + carry
          in  res mod radix :: mul' cdr1 cdr2 (res / radix)

(*
    let rec mul' (multiplier, powerof2, multiplicand') =
    if powerof2 > multiplier
    then multiplier, 0
    else let remainder, product =
             mul' (multiplier, double powerof2, double multiplicand')
         in  if remainder < powerof2
             then remainder, product
             else remainder - powerof2, product + multiplicand'
*)

    (* imported from mathfns-trace *)
    let rec power' (base, expt, result) = match expt with
        | 0                   -> result
        | expt when even expt -> power' (base *. base, expt / 2, result)
        | expt                -> power' (base, expt - 1, base *. result)


    let add (Bigint (neg1, value1)) (Bigint (neg2, value2)) =
        if neg1 = neg2
        then Bigint (neg1, add' value1 value2 0)
        else Bigint (neg2, sub' value1 value2 0)
        (* implement code over here to account for addiction of values with different signs *)

    let sub (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        (* the subtraction of two numbers when 
        signs are opposite is addition *)
        if neg1 = neg2
        then Bigint(neg1, sub' val1 val2 0)
        else Bigint(neg1, add' val1 val2 0)

    let mul (Bigint (neg1, val1)) (Bigint (neg2, val2)) =
        if neg1 = neg2
            then Bigint (Pos, mul' val1 val2 0)
            (* positive * negative = negative *)
        else if neg1 = Neg (* - * - = + *) 
            then Bigint (Pos, mul' val1 val2 0)
        else
            Bigint (neg1, mul' val1 val2 0)

    let div = add

    let rem = add

    let pow = add

end

