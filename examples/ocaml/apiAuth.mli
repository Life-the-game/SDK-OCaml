(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

type login = string
type password = string
type token = string

type t =
    {
      user   : login;
      token  : token;
      expire : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Login (create token)                                                      *)
val login : login -> password -> t Api.t

(** Get information about a token                                             *)
val get : token -> t Api.t

(** Logout (delete token)                                                     *)
val logout : t -> unit Api.t
