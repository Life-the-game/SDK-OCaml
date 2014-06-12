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

type t = _user

type settings = {
  email_weekly : bool;
  email_instant : bool;
}

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  session:session
  -> ?term:string list
  -> ?page:Page.parameters
  -> unit -> t Page.t Api.t

val get_one :
  session:session
  -> login -> t Api.t

val create :
  session:session
  -> login:login
  -> email:email
  -> ?lang:Lang.t
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> either -> t Api.t

val edit :
  session:session
  -> ?email:email
  -> ?password:(string * string) option
  -> ?firstname:string
  -> ?lastname:string
  -> ?gender:Gender.t
  -> ?birthday:Date.t option
  -> login -> t Api.t

(** {6 Avatar}                                                                *)

val avatar :
  session:session
  -> login -> either_file -> Picture.t Api.t
val delete_avatar :
  session:session
  -> login -> unit Api.t

(** {6 Follow}                                                                *)

val get_followers :
  session:session
  -> ?page:Page.parameters
  -> login -> t Page.t Api.t

val get_following :
  session:session
  -> ?page:Page.parameters
  -> login -> t Page.t Api.t

val follow :
  session:session
  -> login -> unit Api.t
val unfollow :
  session:session
  -> login -> unit Api.t

(** {6 Challenge}                                                             *)
val challenge :
  session:session
  -> login -> id -> unit Api.t

(** {6 Message}                                                               *)
val message :
  session:session
  -> login -> string -> unit Api.t

(** {6 Settings}                                                              *)
val settings : session:session -> unit -> settings Api.t
val edit_settings :
  session:session
  -> ?email_weekly:bool option
  -> ?email_instant:bool option
  -> unit -> settings Api.t


(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
val equal : t -> t -> bool
val dummy : t
