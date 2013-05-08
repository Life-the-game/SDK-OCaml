(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

type t =
    {
      info   : ApiTypes.Info.t;
      user   : login;
      token  : token;
      expire : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login : login -> password -> t Api.t

(** Logout (delete token)                                                     *)
val logout : t -> unit Api.t

(** Get information about a token                                             *)
val get_token : token -> t Api.t

(** Get your current active connection tokens                                 *)
(**   Info: To get the tokens of another user, use ApiUser.get_tokens         *)
val get :
  ?index:int option
  -> ?limit:int option
  -> ApiTypes.auth
  -> t ApiTypes.List.t Api.t

(* ************************************************************************** *)
(** Tools                                                                     *)
(* ************************************************************************** *)

(** Take a json tree representing an auth element and return an auth element  *)
val from_json : Yojson.Basic.json -> t
