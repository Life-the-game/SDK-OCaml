(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)
(** User's conversations API methods                                          *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Types}                                                                 *)
(* ************************************************************************** *)

type message =
    {
      sender_ref : int;
      content    : string;
    }

type t =
    {
      info             : Info.t;
      referenced_users : ApiUser.t list;
      messages         : message List.t;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get the conversation                                                      *)
val get : auth:auth -> ?index:int option -> ?limit:int option -> id -> t Api.t

(** Post a message in the conversation                                        *)
val post : auth:auth -> string -> id -> message Api.t

(** Delete a message in the conversation                                      *)
val delete : auth:auth -> id_message:id -> id -> unit Api.t
