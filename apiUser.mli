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

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

val get :
  session:session
  -> ?term:string list
  -> ?page:Page.parameters
  (* -> ?with_avatar:
  session:session
  -> bool option *)
  (* -> ?genders:
  session:session
  -> Gender.t list *)
  (* -> ?lang:
  session:session
  -> Lang.t list *)
  (* -> ?min_score:
  session:session
  -> int option *)
  (* -> ?max_score:
  session:session
  -> int option *)
  (* -> ?min_level:
  session:session
  -> int option *)
  (* -> ?max_level:
  session:session
  -> int option *)
  (* -> ?is_in_network:
  session:session
  -> bool option *)
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
  -> login -> either_file -> url Api.t
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

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
val equal : t -> t -> bool
