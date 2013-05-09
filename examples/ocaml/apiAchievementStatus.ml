(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users' achievements personal lists          *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ApiTypes

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info             : Info.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      state            : string;
      state_code       : int;
      message          : string;
      approvers        : ApiUser.t ApiTypes.List.t;
      non_approvers    : ApiUser.t ApiTypes.List.t;
      attached_picture : ApiMedia.Picture.t;
      score            : int;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing a user and return an object user             *)
let from_json c =
  let open Yojson.Basic.Util in
      {
	info        = Info.from_json c;
	owner            = ApiUser.from_json (c |> member "owner");
	achievement      = ApiAchievement.from_json (c |> member "achievement");
	state            = c |> member "state" |> to_string;
	state_code       = c |> member "state_code" |> to_int;
	message          = c |> member "message" |> to_string;
	approvers        = (ApiTypes.List.from_json ApiUser.from_json
			      (c |> member "approvers"));
	non_approvers    = (ApiTypes.List.from_json ApiUser.from_json
			      (c |> member "non_approvers"));
	attached_picture = (ApiMedia.Picture.from_json
			      (c |> member "attached_picture"));
	score            = c |> member "score" |> to_int;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get user's achievement status'                                             *)
(* ************************************************************************** *)

let get ?(auth = None) ?(lang = None) ?(index = None) ?(limit = None) user_id =
  let url = Api.url ~parents:["users"; user_id; "achievement_status"]
    ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url (ApiTypes.List.from_json from_json)

