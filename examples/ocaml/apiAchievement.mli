(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(** Types                                                                     *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      name               : string;
      description        : string;
      badge              : ApiMedia.Picture.t;
      parent_id          : string;
      child_achievements : t List.t;
      url                : url;
    }

type parent =
  | ParentId of int
  | Parent   of t

(* ************************************************************************** *)
(** Tools                                                                     *)
(* ************************************************************************** *)

(** Take a json tree representing an achievement and return anachievement     *)
val from_json : Yojson.Basic.json -> t

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Get Achievements                                                          *)
val get :
  ?auth:auth option
  -> ?lang:Lang.t option
  -> unit -> t List.t Api.t

(** Get one Achievement                                                       *)
val get_achievement :
  ?auth:auth option
  -> ?lang:Lang.t option
  -> int -> t Api.t

(** Post a new Achievement                                                    *)
val post :
  ?parent:(parent option)
  -> auth -> string -> string -> t Api.t

(** Edit (put) an Achievement                                                 *)
val put :
  ?name:(string option)
  -> ?description:(string option)
  -> ?parent:(parent option)
  -> auth -> id -> t Api.t

(** Delete an Achievement                                                     *)
val delete : auth -> id -> t Api.t
