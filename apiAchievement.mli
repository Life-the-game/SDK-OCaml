(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)
(** Achievements API methods                                                  *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      name               : string;
      description        : string option;
      badge              : ApiMedia.Picture.t option;
      category           : bool;
      child_achievements : t Page.t;
      secret             : bool;
      discoverable       : bool;
      keywords           : string list;
      url                : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get Achievements                                                          *)
val get :
  req:requirements
  -> ?page:Page.parameters
  -> ?term:string list
  -> unit -> t Page.t Api.t

(** Get one Achievement                                                       *)
val get_one :
  req:requirements
  -> id -> t Api.t

(* (\** Create a new Achievement                                                  *\) *)
(* val post : *)
(*   auth:auth *)
(*   -> name:string *)
(*   -> ?description:string option *)
(*   -> unit -> t Api.t *)

(* (\** Edit (put) an Achievement                                                 *\) *)
(* val edit : *)
(*   auth:auth *)
(*   -> ?name:string option *)
(*   -> ?description:(string option) *)
(*   -> id -> t Api.t *)

(* (\** Delete an Achievement                                                     *\) *)
(* val delete : auth:auth -> id -> unit Api.t *)

(* (\** Get an achievement parents                                                *\) *)
(* val get_parents : *)
(*   ?index:int option *)
(*   -> ?limit:int option *)
(*   -> ?auth:auth option *)
(*   -> ?lang:Lang.t option *)
(*   -> id -> t List.t Api.t *)

(* (\** Get an achievement children                                               *\) *)
(* val get_children : *)
(*   ?index:int option *)
(*   -> ?limit:int option *)
(*   -> ?auth:auth option *)
(*   -> ?lang:Lang.t option *)
(*   -> id -> t List.t Api.t *)

(* (\** Add a child to a parent                                                   *\) *)
(* val add_child : auth:auth -> id -> id -> unit Api.t *)

(* (\** Remove a child from a parent                                              *\) *)
(* val delete_child : auth:auth -> id -> id -> unit Api.t *)

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

(** Take a json tree representing an achievement and return achievement       *)
val from_json : Yojson.Basic.json -> t
