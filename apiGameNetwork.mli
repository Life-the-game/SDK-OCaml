(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Game Network API Methods                                                  *)

open ApiTypes

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get Game Network                                                          *)
val get :
  ?auth:auth option
  -> ?page:Page.parameters
  -> ?term: string
(* PRIVATE *)
  -> user:string
(* /PRIVATE *)
  -> unit -> (ApiUser.t Page.t Api.t)

(** Get My Game Network                                                       *)
val get_mine :
  auth:auth
  -> ?page:Page.parameters
  -> ?term: string
  -> unit -> (ApiUser.t Page.t Api.t)

(** Get users who have a specified user in their Game Network                 *)

val get_users :
    req:requirements
    -> ?page:Page.parameters
(* PRIVATE *)
  -> user:string
(* /PRIVATE *)
    -> unit -> (ApiUser.t Page.t Api.t)

(** Get users who have me in their Game Network                               *)

val get_my_users :
    req:requirements
    -> ?page:Page.parameters
    -> unit -> (ApiUser.t Page.t Api.t)

(** Add a user in my Game Network                                             *)

val add :
    auth:auth
(* PRIVATE *)
  -> ?user:string option
(* /PRIVATE *)
  -> id -> unit Api.t

(** Delete a user from my Game Network                                        *)

val delete :
    auth:auth
(* PRIVATE *)
  -> ?user:string option
(* /PRIVATE *)
  -> id -> unit Api.t





