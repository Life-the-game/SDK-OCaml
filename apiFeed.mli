(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Feed API methods                                                          *)

open ApiTypes

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get feed                                                                  *)
val get :
  auth:auth
  -> ?page:Page.parameters
  -> ?activity_type: string list
  -> ?user:id option
  -> unit -> ApiPlayground.t Page.t Api.t
