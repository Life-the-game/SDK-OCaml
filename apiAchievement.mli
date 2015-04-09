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
      description        : string;
      mutable icon       : Picture.t option;
      color              : color option;
      tags               : string list;
      achievement_status : achievement_status option;
      location           : Location.t option;
      secret             : bool option;
      visibility         : Visibility.t;
      total_comments     : int;
      difficulty         : int;
      url                : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  session:session
  -> ?page:Page.parameters
  -> ?terms:string list
  -> ?tags:string list
  -> ?location:Location.parameters option
  -> unit -> t Page.t Api.t

val get_one :
  session:session
  -> id -> t Api.t

val create :
  session:session
  -> name:string
  -> description:string
  -> ?icon:either_file
  -> ?color:color
  -> ?secret:bool
  -> ?tags:string list
  -> ?location:Location.parameters option
  -> ?radius:int
  -> ?difficulty:int
  -> unit -> t Api.t

val edit :
  session:session
  -> ?name:string
  -> ?description:string
  -> ?icon:either_file
  -> ?color:color
  -> ?secret:bool option
  -> ?add_tags:string list
  -> ?delete_tags:string list
  -> ?difficulty: int
  -> id -> t Api.t

val delete :
  session:session
  -> id -> unit Api.t

(** {6 Tags}                                                                *)

val tags :
  session:session
  -> id -> string list Api.t
val add_tags :
  session:session
  -> string list -> id -> t Api.t
val delete_tags :
  session:session
  -> string list -> id -> t Api.t
val all_tags :
  session:session
  -> unit -> (string * int) list Api.t

(** {6 Icon}                                                                *)

val icon :
  session:session
  -> id -> either_file -> Picture.t Api.t
val delete_icon :
  session:session
  -> id -> unit Api.t

(** {6 Vote}                                                                  *)

val vote :
  session:session
  -> id -> Vote.vote -> unit Api.t
val cancel_vote :
  session:session
  -> id -> unit Api.t

(** {6 Comments}                                                              *)

val comments       :
  session:session
  -> ?page: Page.parameters -> id -> ApiComment.t Page.t Api.t
val add_comment    :
  session:session
  -> content:string -> id -> ApiComment.t Api.t
val edit_comment   :
  session:session
  -> content:string -> id -> ApiComment.t Api.t
val delete_comment :
  session:session
  -> id -> unit Api.t
val vote_comment   :
  session:session
  -> id -> Vote.vote -> unit Api.t
val cancel_vote_comment :
  session:session
  -> id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
