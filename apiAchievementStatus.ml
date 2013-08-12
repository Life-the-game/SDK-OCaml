(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users' achievements personal lists          *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
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
      approvers        : ApiUser.t Page.t;
      non_approvers    : ApiUser.t Page.t;
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
	approvers        = (Page.from_json ApiUser.from_json
			      (c |> member "approvers"));
	non_approvers    = (Page.from_json ApiUser.from_json
			      (c |> member "non_approvers"));
	attached_picture = (ApiMedia.Picture.from_json
			      (c |> member "attached_picture"));
	score            = c |> member "score" |> to_int;
      }

(* (\* ************************************************************************** *\) *)
(* (\* Api Methods                                                                *\) *)
(* (\* ************************************************************************** *\) *)

(* (\* ************************************************************************** *\) *)
(* (\* Get user's achievement status                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let get ?(auth = None) ?(lang = None) ?(index = None) ?(limit = None) user_id = *)
(*   let url = Api.url ~parents:["users"; user_id; "achievement_statuses"] *)
(*     ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in *)
(*   Api.any ~auth:auth ~lang:lang url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Add a new achievement in a user's list                                     *\) *)
(* (\*   The upload_picture argument is an optional string wich is the path of    *\) *)
(* (\*   file corresponding to the picture you would like to upload.              *\) *)
(* (\* ************************************************************************** *\) *)

(* let add ~auth ~achievement ~state_code ~message *)
(*     ?(upload_picture = None) user_id = *)
(*   let go with_picture picture_content = *)
(*     let url = Api.url ~parents:["users"; user_id; "achievement_statuses"] *)
(*       ~get:[("achievement_id", achievement); *)
(* 	      ("state_code", string_of_int state_code); *)
(* 	      ("message", message); *)
(* 	      ("upload_picture", string_of_bool with_picture); *)
(* 	      ] ~auth:(Some auth) () in *)
(*     Api.go ~auth:(Some auth) ~rtype:POST url from_json in *)
(*   match upload_picture with *)
(*     | None         -> go false "" *)
(*     | Some picture -> go true  "" *)
(* (\* todo: send a post data with the file, check file exists *\) *)

(* (\* ************************************************************************** *\) *)
(* (\* Delete an achievement status                                               *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth user_id as_id = *)
(*     let url = Api.url ~parents:["user"; user_id; "achievement_statuses"; as_id] *)
(*         ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Get the details of one achievement status                                  *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_one ~auth id = *)
(*   let url = Api.url ~parents:["achievement_statuses"; id] *)
(*     ~auth:(Some auth) () in *)
(*   Api.go ~auth:(Some auth) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Delete user's achievement status                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth id = *)
(*   let url = Api.url ~parents:["achievement_statuses"; id] ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Edit (put) an achievement status                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* let edit ~auth ?(state_code = None) ?(message = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id] ~auth:(Some auth) *)
(*         ~get:(Api.option_filter *)
(*         [("state_code", Option.map string_of_int state_code); *)
(*         ("message", message); *)
(*         ]) () in *)
(*     Api.go ~auth:(Some auth) ~rtype:PUT url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Get approvers for an achievement status                                    *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_approvers ~auth ?(index = None) ?(limit = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "approvers"]  *)
(*         ~auth:(Some auth) *)
(*         ~get:(Api.pager index limit []) () in *)
(*     Api.go ~auth:(Some auth) url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Approve an achievement status                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let approve ~auth ?(src_user = None) id = *)
(*     let url = *)
(*         Api.url ~parents:["achievement_statuses"; id; "approvers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:POST *)
(*         ~post:(PostList (Api.option_filter [("src_user_id", src_user)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove approving from an achievement status                                *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_approve ~auth id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "approvers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove an approver from an achievement status                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_approver ~auth as_id user_id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; as_id; "approvers"; *)
(*         user_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)


(* (\* ************************************************************************** *\) *)
(* (\* Get disapprovers for an achievement status                                 *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_disapprovers ~auth ?(index = None) ?(limit = None) id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "disapprovers"]  *)
(*         ~auth:(Some auth) *)
(*         ~get:(Api.pager index limit []) () in *)
(*     Api.go ~auth:(Some auth) url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Disapprove an achievement status                                           *\) *)
(* (\* ************************************************************************** *\) *)

(* let disapprove ~auth ?(src_user = None) id = *)
(*     let url = *)
(*         Api.url ~parents:["achievement_statuses"; id; "disapprovers"] ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:POST *)
(*         ~post:(PostList (Api.option_filter [("src_user_id", src_user)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove disapproving from an achievement status                             *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_disapprove ~auth id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; id; "disapprovers"] *)
(*     ~auth:(Some *)
(*         auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a disapprover from an achievement status                            *\) *)
(* (\* ************************************************************************** *\) *)

(* let remove_disapprover ~auth as_id user_id = *)
(*     let url = Api.url ~parents:["achievement_statuses"; as_id; "disapprovers"; *)
(*         user_id] ~auth:(Some auth) () in *)
(*     Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

