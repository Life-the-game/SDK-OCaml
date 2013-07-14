(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users' achievements personal lists          *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

module type STATUS =
sig
  type t =
    | Objective
    | Achieved
  val to_string : t -> string
  val of_string : string -> t
end
module Status : STATUS =
struct
  type t =
    | Objective
    | Achieved
  let to_string = function (* todo: update the api to use the correct words *)
    | Objective -> "planned"
    | Achieved  -> "done"
  let of_string = function
    | "planned" -> Objective
    | "done"    -> Achieved
    | _         -> Objective
end

type t =
    {
      info             : Info.t;
      owner            : ApiUser.t;
      achievement      : ApiAchievement.t;
      state            : Status.t;
      state_code       : int; (* todo: wtf is that *)
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
	state            = Status.of_string (c |> member "state" |> to_string);
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
  let url = Api.url ~parents:["users"; user_id; "achievement_statuses"]
    ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url (ApiTypes.List.from_json from_json)

(* ************************************************************************** *)
(* Add a new achievement in a user's list                                     *)
(*   The upload_picture argument is an optional string wich is the path of    *)
(*   file corresponding to the picture you would like to upload.              *)
(* ************************************************************************** *)

let add ~auth ~achievement ~state_code ~message
    ?(upload_picture = None) user_id =
  let go with_picture picture_content =
    let url = Api.url ~parents:["users"; user_id; "achievement_statuses"]
      ~get:[("achievement_id", achievement);
	      ("state_code", string_of_int state_code);
	      ("message", message);
	      ("upload_picture", string_of_bool with_picture);
	      ] ~auth:(Some auth) () in
    Api.go ~auth:(Some auth) ~rtype:POST url from_json in
  match upload_picture with
    | None         -> go false ""
    | Some picture -> go true  ""
(* todo: send a post data with the file, check file exists *)
