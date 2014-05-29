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
      vote               : Vote.t;
      owner              : ApiUser.t;
      comments           : int;
      name               : string;
      description        : string option;
      icon               : ApiMedia.Picture.t option;
      color              : color option;
      tags               : string list;
      achievement_status : achievement_status option;
      location           : Location.t option;
      secret             : bool option;
      visibility         : Visibility.t;
      url                : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  ?page:Page.parameters
  -> ?terms:string list
  -> ?tags:string list
  -> ?location:Location.parameters option
  -> unit -> t Page.t Api.t

val get_one : id -> t Api.t

val create :
  name:string
  -> description:string
  -> ?icon:either_file
  -> ?color:color
  -> ?secret:bool
  -> ?location:Location.parameters option
  -> ?radius:int
  -> unit -> t Api.t

val edit :
  ?name:string
  -> ?description:string
  -> ?icon:either_file
  -> ?color:color
  -> ?secret:bool option
  -> id -> t Api.t

val delete : id -> unit Api.t

(** {6 Tags}                                                                *)

val add_tags : string list -> id -> t Api.t
val delete_tags : string list -> id -> t Api.t

(** {6 Icon}                                                                *)

val icon : id -> either_file -> url Api.t
val delete_icon : id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote : id -> Vote.vote -> unit Api.t
val cancel_vote : id -> unit Api.t

(** {6 Comments}                                                              *)

val comments       : ?page: Page.parameters -> id -> ApiComment.t Page.t Api.t
val add_comment    : content:string -> id -> ApiComment.t Api.t
val edit_comment   : content:string -> id -> ApiComment.t Api.t
val delete_comment : id -> unit Api.t
val vote_comment   : id -> Vote.vote -> unit Api.t
val cancel_vote_comment : id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
