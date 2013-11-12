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
      firstname                : string option;
      lastname                 : string option;
      name                     : string option;
      avatar                   : ApiMedia.Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      (* lang                     : Lang.t; *)
(* PRIVATE *)
      email                    : email option;
(* /PRIVATE *)
      score                    : int;
      level                    : int;
      in_game_network          : bool option;
      game_network_total       : int;
      other_game_network_total : int;
      url                      : url;
    }

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get users                                                                *)
val get :
  auth:auth
  -> ?term:string list
  -> ?page:Page.parameters
  -> ?with_avatar: bool option
  -> ?genders: Gender.t list
  -> ?lang: Lang.t list
  -> ?min_score: int option
  -> ?max_score: int option
  -> ?min_level: int option
  -> ?max_level: int option
  -> ?is_in_network: bool option
  -> unit -> t Page.t Api.t

(** Get a user                                                               *)
val get_one : ?auth:auth option -> id -> t Api.t

(** Create a user                                                            *)
val create :
  login:login
  -> password:string
  -> email:email
  -> lang:Lang.t
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> ?avatar:file
  -> unit -> t Api.t

(** Edit a user                                                              *)
val edit :
  auth:auth
  -> ?email:email
  -> ?old_password:string
  -> ?password:string
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> ?avatar:file
  -> id -> t Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
val equal : t -> t -> bool
