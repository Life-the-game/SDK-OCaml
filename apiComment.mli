(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** User's commenting API methods                                             *)

open ApiTypes

(* ************************************************************************** *)
(** {Type}                                                                    *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      creator       : ApiUser.t;
      content       : string;
      likers_count  : int;
    }

(* ************************************************************************** *)
(** {API Methods}                                                             *)
(* ************************************************************************** *)

(* Get comments on an achievement status                                      *)
val get :
    auth:auth
    -> ?index:int option
    -> ?limit:int option
    -> id -> t ApiTypes.List.t Api.t

(* Comments an achievement status                                             *)
val comment :
    auth:auth
    -> ?user_id:string option
    -> ?comment:string option
    -> id -> t Api.t

(* Get a comment on an achievement status                                     *)
val get_comment :
    auth:auth -> id -> id -> t Api.t

(* Edit (put) a comment on an achievement status                              *)
val edit    :
    auth:auth
    -> ?comment:string option
    -> id -> id -> t Api.t

(* Remove a comment from an achievement status                                *)
val remove  :
    auth:auth -> id -> id -> unit Api.t

(* Get likers for a comment                                                   *)
val get_likers  :
    auth:auth
    -> ?index:int option
    -> ?limit:int option
    -> id -> id -> t List.t Api.t

(* Like a comment                                                             *)
val like    :
    auth:auth
    -> ?user_id:string option
    -> id -> id -> unit Api.t

(* Remove a like from a comment                                               *)
val remove_like :
    auth:auth -> id -> id -> unit Api.t

(* Remove a liker from a comment                                              *)
val remove_liker    :
    auth:auth -> id -> id -> id -> unit Api.t


(* ************************************************************************** *)
(** {Tools}                                                                   *)
(* ************************************************************************** *)

(** Take a json tree representing a comment element                           *)
(** and return a comment element                                              *)
val from_json : Yojson.Basic.json -> t
