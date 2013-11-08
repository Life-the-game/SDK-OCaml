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

type activity =
  | NetworkAddition     of ApiUser.t
  | NewMedia            of (ApiAchievementStatus.t * ApiMedia.t list)
  | News                of ApiNews.t
  | AchievementUnlocked of ApiAchievementStatus.t
  | NewObjective        of ApiAchievementStatus.t
  | LevelReached        of int
  | Other               of (string
			    * ApiUser.t list
			    * ApiAchievementStatus.t list
			    * ApiMedia.t list
			    * ApiNews.t list
			    * string option)

type t = {
  info : Info.t;
  owner : ApiUser.t;
  template : string;
  activity : activity;
}

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
  let open Yojson.Basic.Util in

  let users = ("users", Api.convert_each c "users" ApiUser.from_json)
  and achievement_statuses : (string * ApiAchievementStatus.t list) =
    ("achievement_status",
     Api.convert_each c "achievement_statuses" ApiAchievementStatus.from_json)
  and medias = ("medias", Api.convert_each c "medias" ApiMedia.from_json)
  and news = ("news", Api.convert_each c "news" ApiNews.from_json)

  and get_list (_, l) = l

  and get_first (name, l) = try List.hd l
    with _ -> raise (Invalid_argument ("Empty list of " ^ name))

  and get_nth n (name, l) = try List.nth l n
    with _ -> raise (Invalid_argument ("Not enough element in list " ^ name))

  in {
    info = Info.from_json c;
    owner = ApiUser.from_json (c |> member "owner");
    template = c |> member "template" |> to_string;
    activity =  match c |> member "type" |> to_string with

      | "new_media" -> NewMedia (get_first achievement_statuses,
				 get_list medias)

      | "news" -> News (get_first news)

      | "achievement_unlocked" -> AchievementUnlocked
	(get_first achievement_statuses)

      | "new_objective" -> NewObjective (get_first achievement_statuses)

      | "level_reached" -> LevelReached (c |> member "metadata" |> to_int)

      | "network_addition" -> NetworkAddition (get_first users)

      | stype -> Other (stype, get_list users, get_list achievement_statuses,
			get_list medias, get_list news,
			c |> member "metadata" |> to_string_option)
  }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get activities                                                             *)
(* ************************************************************************** *)

let get ?(auth = None) ?(page = Page.default_parameters)
    ?(activity_type = []) id =
    Api.go
    ~path:(["users"; id; "activities"])
    ~page:(Some page)
    ~get:(Network.option_filter
        [("type", Some (Network.list_parameter activity_type));]
    )
    (Page.from_json from_json)
