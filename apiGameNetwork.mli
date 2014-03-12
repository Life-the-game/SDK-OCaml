(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Game Network API Methods                                                  *)

(* open ApiTypes *)

(* (\* ************************************************************************** *\) *)
(* (\** {3 API Methods}                                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* (\** Get Game Network (People you follow)                                      *\) *)
(* val get : *)
(*   ?auth:auth option *)
(*   -> ?page:Page.parameters *)
(*   -> ?term: string *)
(*   -> id -> (ApiUser.t Page.t Api.t) *)
(* val get_mine : *)
(*   auth:auth *)
(*   -> ?page:Page.parameters *)
(*   -> ?term: string *)
(*   -> unit -> (ApiUser.t Page.t Api.t) *)

(* (\** Get users who have me in their game network (People who follow you)       *\) *)
(* val get_followers : *)
(*   ?auth:auth option *)
(*   -> ?page:Page.parameters *)
(*   -> id -> (ApiUser.t Page.t Api.t) *)
(* val get_my_followers : *)
(*   auth:auth *)
(*   -> ?page:Page.parameters *)
(*   -> unit -> (ApiUser.t Page.t Api.t) *)

(* (\** Add a user in my Game Network                                             *\) *)
(* val add : *)
(*     auth:auth *)
(* (\* PRIVATE *\) *)
(*   -> ?adder:string option *)
(* (\* /PRIVATE *\) *)
(*   -> id -> unit Api.t *)

(* (\** Delete a user from my Game Network                                        *\) *)
(* val delete : *)
(*     auth:auth *)
(* (\* PRIVATE *\) *)
(*   -> ?remover:string option *)
(* (\* /PRIVATE *\) *)
(*   -> id -> unit Api.t *)





