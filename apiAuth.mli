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
      user           : ApiUser.t;
(* PRIVATE *)
      (* ip             : ip; *)
      (* user_agent     : string; *)
(* /PRIVATE *)
      token          : token;
      expiration     : ApiTypes.DateTime.t;
      (* facebook_token : string option; *)
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login :
(* PRIVATE *)
    ?ip: ip ->
(* /PRIVATE *)
  login -> password -> t Api.t

(** OAuth                                                                     *)
val oauth : string -> token -> t Api.t
val facebook : token -> t Api.t

(** Logout (delete token)                                                     *)
val logout : t -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t

(** Transform an API object returned by the login function into an api type
   required by most of the API methods                                        *)
val auth_to_api : t -> ApiTypes.auth
val opt_auth_to_api : t option -> ApiTypes.auth option
