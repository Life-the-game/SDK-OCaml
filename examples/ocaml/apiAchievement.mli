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
      child_achievements : t List.t;
      url                : url;
    }

(* ************************************************************************** *)
(** Api Methods                                                               *)
(* ************************************************************************** *)

(** Get Achievements                                                          *)
val get :
  ?auth:auth option
  -> ?lang:Lang.t option
  -> ?term:string option
  -> ?index:int option
  -> ?limit:int option
  -> unit -> t List.t Api.t

(** Get one Achievement                                                       *)
val get_achievement :
  ?auth:auth option
  -> ?lang:Lang.t option
  -> int -> t Api.t

(** Create a new Achievement                                                  *)
val post :
  auth:auth
  -> name:string
  -> ?description:string option
  -> unit -> t Api.t

(** Edit (put) an Achievement                                                 *)
val edit :
  auth:auth
  -> ?name:string option
  -> ?description:(string option)
  -> id -> t Api.t

(** Delete an Achievement                                                     *)
val delete : auth:auth -> id -> t Api.t
