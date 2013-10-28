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

type t =
  | NetworkAddition     of (Info.t * ApiUser.t * ApiUser.t)
  | NewMedia            of (Info.t * ApiAchievementStatus.t * ApiMedia.t)
  | News                of (Info.t * ApiNews.t)
  | AchievementUnlocked of (Info.t * ApiAchievementStatus.t)
  | NewObjective        of (Info.t * ApiAchievementStatus.t)
  | LevelReached        of (Info.t * ApiUser.t)

(* ************************************************************************** *)
(** {3 API Methods}                                                           *)
(* ************************************************************************** *)

(** Get activities                                                            *)
val get :
  ?page:Page.parameters
  -> ?activity_type:string list
  -> id -> (t Page.t Api.t)


(* ************************************************************************** *)
(** {3 Tools}                                                                 *)
(* ************************************************************************** *)

val from_json : Yojson.Basic.json -> t
