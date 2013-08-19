(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml    *)
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
      ip             : ip;
      user_agent     : string;
(* /PRIVATE *)
      token          : token;
      expiration     : ApiTypes.DateTime.t;
      facebook_token : string option;
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

(** Logout (delete token)                                                     *)
val logout : t -> unit Api.t

(* (\** Get information about a token                                             *\) *)
(* val get_token : token -> t Api.t *)

(* (\** Get your current active connection tokens. *)
(*     {i Note: To get the tokens of another user, use {! ApiAuth.get_user}}     *\) *)
(* val get : *)
(*   ?index:int option *)
(*   -> ?limit:int option *)
(*   -> ApiTypes.auth *)
(*   -> t ApiTypes.Page.t Api.t *)

(* (\** Get user's authentication tokens *)
(*     {i Note: This method is for administrative purpose only}                  *\) *)
(* val get_user : *)
(*   auth:auth *)
(*   -> ?index:int option *)
(*   -> ?limit:int option *)
(*   -> id -> t ApiTypes.Page.t Api.t *)

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

(** Take a json tree representing an auth element and return an auth element  *)
val from_json : Yojson.Basic.json -> t

(** Transform an API object returned by the login function into an api type
   required by most of the API methods                                        *)
val auth_to_api : t -> ApiTypes.auth
val opt_auth_to_api : t option -> ApiTypes.auth option
