(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit user's conversations                        *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(** Types                                                                     *)
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
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Get the conversation                                                      *)
val get : auth:auth -> ?index:int option -> ?limit:int option -> id -> t Api.t

(** Post a message in the conversation                                        *)
val post : auth:auth -> string -> id -> message Api.t

(** Delete a message in the conversation                                      *)
val delete : auth:auth -> id_message:id -> id -> unit Api.t
