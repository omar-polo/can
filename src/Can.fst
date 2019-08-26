(*

@summary A library to manage CANs.
*)

module Can

open FStar.List.Tot // fold_left

(* Assume these types are provided by the consumer. *)
assume new type point : eqtype
assume new type region : eqtype
assume new type address : eqtype

(* represents a peer *)
type peer =
  | Peer : addr:address -> r:region -> peer

(* handy *)
type peers = list peer

type message =
  | Heartbeat   : from:point -> env:peers -> message
  | Join        : from:address -> to:point -> message
  | Split       : r:region -> message
// TODO: Split should also carry the list of peers
// TODO: Put & Get!

noeq // due to functions
type state =
  { myregion        : region;
    environ         : peers;
    join_region     : region -> region -> region;
    split_region    : region -> region * region; // r = join_region r1 r2
    area_region     : region -> nat;
    distance_region : point -> region -> nat;
    is_within       : point -> region -> bool;
    joined          : bool; // TODO: a bool or a `option myregion` ?
  }

(* neighbour with the biggest region *)
val biggest_peer : state -> Tot (option peer)
let biggest_peer s =
  let { area_region = fn; environ = ps } = s in
  match ps with
  | [] -> None
  | [x] -> Some x
  | x::y -> let f = (fun p1 p2 -> let s1, s2 = fn (Peer?.r p1), fn (Peer?.r p2) in
                             if s1 > s2 then p1 else p2) in
          Some (fold_left f x y)

(* return the peer that's closest to the given point *)
val closest_peer : state -> point -> Tot (option peer)
let closest_peer s p =
  let { distance_region; environ } = s in
  match environ with
  | [] -> None
  | [x] -> Some x
  | x::y -> let f = (fun p1 p2 -> let d1 = distance_region p (Peer?.r p1) in
                             let d2 = distance_region p (Peer?.r p2) in
                             if d1 < d2 then p1 else p2) in
          Some (fold_left f x y)

type action =
  | Nothing
  | SendJoin of address
  | Reply of message
  | ForwardJoin of address * point (* from, to *)

let split_region_action s =
  let {myregion = r; split_region } = s in
  let m, y = split_region r in
  { s with myregion = m }, Reply (Split y)

val handle_message : state -> message -> state * action
let handle_message s m =
  let {myregion = r; environ = env; area_region; is_within} = s in
  match m with
  | Heartbeat from env -> (s, Nothing) // TODO: update list of peer
  | Join from to ->
    if is_within to r
    // Invece che splittare la nostra regione, controlliamo se
    // qualcuno dei nostri vicini è più grande di noi. In tal caso si
    // reindirizzi la Join a quest'ultimo.
    then (match (biggest_peer s) with
          | None -> split_region_action s
          | Some x -> if (area_region r) < (area_region (Peer?.r x))
                     then s, ForwardJoin (Peer?.addr x, to)
                     else split_region_action s)
    // altrimenti reindirizzamo al nostro peer più vicino
    else (match (closest_peer s to) with
          | None -> split_region_action s // se non abbiamo peer splittiamo noi
          | Some x -> s, ForwardJoin (Peer?.addr x, to))
  | Split r -> let {joined} = s in
              if joined
              then s, Nothing // someone just sent us a junk message
              else {s with myregion = r}, Nothing

