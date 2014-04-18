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
      info           : ApiTypes.Info.t;
      mutable owner   : ApiUser.t;
      token          : token;
      expiration     : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login : login -> password -> t Api.t

(** OAuth Login                                                               *)
val oauth : oauth_provider -> oauth_token -> t Api.t
val facebook : oauth_token -> t Api.t

(** Logout (delete token), default : the one in ApiConf                       *)
val logout : ?token:token -> unit -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
