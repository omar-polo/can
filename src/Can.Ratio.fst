(*

@summary Implementation of a rationale type to work around the lack of floating points.
*)

module Can.Ratio

open FStar.Int

type t = a:int * b:nat{b <> 0}

val gcd : a:nat{a <> 0} -> b:nat -> Tot (c:nat{c <> 0}) (decreases %[b])
let rec gcd a b =
  if b > 0
  then gcd b (a%b)
  else a

val gcd_divides : a:nat{a <> 0} -> b:nat -> Lemma (requires True)
                                           (ensures b/(gcd a b) <> 0)
let gcd_divides a b =
  admit () // TODO!

val minimize : t -> t
let rec minimize a =
  let (a, b) = a in 
  if a <> 0
  then (gcd_divides (abs a) b; let d = gcd (abs a) b in (a/d, b/d))
  else (0, b)

let times = op_Multiply

val mul : t -> t -> t
let mul a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  minimize (times a1 b1, times a2 b2)

let div a b =
  let (b1, b2) = b in
  mul a (b2, b1)

val nat_mul_aux : a:nat{a <> 0} -> b:nat{b <> 0} -> c:nat{c <> 0}
let nat_mul_aux a b = op_Multiply a b

let add a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  minimize ((times a1 b2) + (times b1 a2), nat_mul_aux a2 b2)
  
(* Comparison operators -- like FStar.Int *)
val eq : t -> t -> Tot bool
let eq a b =
  let (a1, a2) = minimize a in
  let (b1, b2) = minimize b in
  a1 = b1 && a2 = b2

val gt : t -> t -> Tot bool
let gt a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  times a1 b2 < (times b1 a2)

val gte : t -> t -> Tot bool
let gte a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  times a1 b2 <= (times b1 a2)

val lt : t -> t -> Tot bool
let lt a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  times a1 b2 < (times b1 a2)

val lte : t -> t -> Tot bool
let lte a b =
  let (a1, a2) = a in
  let (b1, b2) = b in
  times a1 b2 <= (times b1 a2)
