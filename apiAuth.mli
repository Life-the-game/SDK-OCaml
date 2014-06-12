(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Authentication API methods                                                *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t = _auth

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login :
  session:session
  -> oauth_id:login
  -> oauth_secret:password
  -> scope:string list
  -> login -> password -> (session * t Api.t)

(** OAuth Login                                                               *)
val oauth :
  session:session
  -> ?refresh_token:token
  -> oauth_id:login
  -> oauth_secret:password
  -> scope:string list
  -> oauth_provider -> oauth_token -> (session * t Api.t)

(** Logout (delete token), default : the one in ApiConf                       *)
val logout :
  session:session -> unit -> (session * unit Api.t)

(** Will only remove the token client-side and not ask the API to revoke it   *)
val client_logout : session:session -> unit -> session

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
