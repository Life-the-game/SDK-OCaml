(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Activities API methods                                                    *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type user_activity =
  | NetworkAddition     of ApiUser.t
  | NewMedia            of (ApiAchievementStatus.t * ApiMedia.t list)
  | AchievementUnlocked of ApiAchievementStatus.t
  | NewObjective        of ApiAchievementStatus.t
  | LevelReached        of int
  | Other               of (string
			    * ApiUser.t list
			    * ApiAchievementStatus.t list
			    * ApiMedia.t list
			    * string option)
  | Failure             of (string * user_activity)

type ('a, 'b) t = {
  info : Info.t;
  owner : 'a;
  stype : string;
  template : string;
  activity : 'b;
}

type user = (ApiUser.t, user_activity) t

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get user activities                                                       *)
val user :
  ?page:Page.parameters
  -> ?owners:login list
  -> unit -> user Page.t Api.t

val feed :
  ?page:Page.parameters
  -> unit -> user Page.t Api.t

val delete_user : id -> unit Api.t

(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val user_from_json : Yojson.Basic.json -> user
