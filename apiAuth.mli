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

type t =
    {
      access_token  : token;
      token_type    : string;
      expires_in    : int;
      refresh_token : token;
      scope         : string list;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login :
  oauth_id:login
  -> oauth_secret:password
  -> scope:string list
  -> login -> password -> t Api.t

(** OAuth Login                                                               *)
val oauth :
  ?refresh_token:token
  -> oauth_id:login
  -> oauth_secret:password
  -> scope:string list
  -> oauth_provider -> oauth_token -> t Api.t

val facebook :
  ?refresh_token:token
  -> oauth_id:login
  -> oauth_secret:password
  -> scope:string list
  -> oauth_token -> t Api.t

(** Logout (delete token), default : the one in ApiConf                       *)
val logout : ?token:token -> unit -> unit Api.t

(** Will only remove the token client-side and not ask the API to revoke it   *)
val client_logout : unit -> unit

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
