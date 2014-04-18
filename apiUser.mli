(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Users API methods                                                         *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type t =
    {
      info                     : Info.t;
      login                    : login;
      firstname                : string;
      lastname                 : string;
      name                     : string;
      avatar                   : ApiMedia.Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      email                    : email option;
      (* score                    : int; *)
      (* level                    : int; *)
      following                : bool option;
      url                      : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  ?term:string list
  -> ?page:Page.parameters
  (* -> ?with_avatar: bool option *)
  (* -> ?genders: Gender.t list *)
  (* -> ?lang: Lang.t list *)
  (* -> ?min_score: int option *)
  (* -> ?max_score: int option *)
  (* -> ?min_level: int option *)
  (* -> ?max_level: int option *)
  (* -> ?is_in_network: bool option *)
  -> unit -> t Page.t Api.t

val get_one : login -> t Api.t

val create :
  login:login
  -> email:email
  -> ?lang:Lang.t
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> ?avatar:either_file
  -> either -> t Api.t

val edit :
  ?email:email
  -> ?password:(string * string) option
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> ?avatar:either_file
  -> login -> t Api.t

(** {6 Follow}                                                                *)

val get_followers :
  ?page:Page.parameters
  -> login -> t Page.t Api.t

val get_following :
  ?page:Page.parameters
  -> login -> t Page.t Api.t

val follow : login -> unit Api.t
val unfollow : login -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
val equal : t -> t -> bool
