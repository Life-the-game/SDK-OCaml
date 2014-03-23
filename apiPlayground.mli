(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)
(** Playground API methods                                                    *)

open ApiTypes

(* ************************************************************************** *)
(** {3 Type}                                                                  *)
(* ************************************************************************** *)

type activity =
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
  | Failure             of (string * activity)

type t = {
  info : Info.t;
  owner : ApiUser.t;
  stype : string;
  template : string;
  activity : activity;
}

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get activities                                                            *)
val get :
  ?auth:auth option
  -> ?page:Page.parameters
  -> ?activity_type:string list
  -> id -> (t Page.t Api.t)


(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : req:requirements -> Yojson.Basic.json -> t
