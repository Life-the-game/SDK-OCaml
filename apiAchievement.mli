(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Achievements API methods                                                  *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type achievement_status =
    {
      id     : id;
      status : Status.t;
    }

type t =
    {
      info               : Info.t;
      name               : string;
      description        : string option;
      badge              : ApiMedia.Picture.t option;
      color              : color option;
      category           : bool;
      secret             : bool;
      discoverable       : bool;
      (* keywords           : string list; *)(*42*)
      achievement_status : achievement_status option;
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
  -> ?with_badge: bool option
  -> ?is_category: bool option
  -> ?is_secret: bool option
  -> ?is_discoverable: bool option
  -> unit -> t Page.t Api.t

(** Get one Achievement                                                       *)
val get_one :
  req:requirements
  -> id -> t Api.t

(* PRIVATE *)

(** Create a new Achievement                                                  *)
val create :
  auth:auth
  -> name:string
  -> description:string
  -> ?color:color
  -> ?parents:id list
  -> ?badge:path
  -> ?category:bool
  -> ?secret:bool
  -> ?discoverable:bool
  -> ?keywords:string list
  -> unit -> t Api.t

(* /PRIVATE *)

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

val from_json : Yojson.Basic.json -> t
