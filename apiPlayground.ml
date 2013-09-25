(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
  | NetworkAddition     of (Info.t * ApiUser.t * ApiUser.t)
  | NewMedia            of (Info.t * ApiAchievementStatus.t * ApiMedia.t)
  | News                of (Info.t * ApiNews.t)
  | AchievementUnlocked of (Info.t * ApiAchievementStatus.t)
  | NewObjective        of (Info.t * ApiAchievementStatus.t)
  | LevelReached        of (Info.t * ApiUser.t)

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in
  let get f n =
    let option_get = function
    Some a -> a | None -> raise (Invalid_argument n) in
    option_get (c |> member n |> to_option f) in
  let info = Info.from_json c
  and achs () = get ApiAchievementStatus.from_json "achievement_status"
  and user = get ApiUser.from_json in
  match c |> member "type" |> to_string with
    | "new_media" -> NewMedia (info, achs (), get ApiMedia.from_json "media")
    | "news" -> News (info, get ApiNews.from_json "news")
    | "achievement_unlocked" -> AchievementUnlocked (info, achs ())
    | "new_objective" -> NewObjective (info, achs ())
    | "level_reached" -> LevelReached (info, user "user")
    | "network_addition" -> NetworkAddition (info, user "adder", user "added")
    | _ -> raise (Invalid_argument "type")

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get activities                                                             *)
(* ************************************************************************** *)

let get ?(page = Page.default_parameters) ?(activity_type = [])
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    () =
    Api.go
    ~path:(
        (match user with
        | Some id -> ["users"; id; "activities"]
        | None -> ["activities"])
        )
    ~page:(Some page)
    ~get:(Network.option_filter
        [("type", Some (Network.list_parameter activity_type));]
    )
    (Page.from_json from_json)




