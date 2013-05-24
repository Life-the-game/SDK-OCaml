(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit user's activities                           *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      activity      : string;
      activity_type : int;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing an activity and return an activity element   *)
let from_json c =
  let open Yojson.Basic.Util in
      {
	info          = Info.from_json c;
	activity      = c |> member "activity"      |> to_string;
	activity_type = c |> member "activity_type" |> to_int;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get activities                                                             *)
(* ************************************************************************** *)

let get ?(auth = None) ?(lang = None) ?(index = None) ?(limit = None) user_id =
  let url = Api.url ~parents:["users"; user_id; "activities"]
    ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url (ApiTypes.List.from_json from_json)

(* ************************************************************************** *)
(* Delete an activity                                                         *)
(* ************************************************************************** *)

let delete ~auth user_id activity_id =
  Api.noop ~auth:(Some auth) ~rtype:DELETE
    (Api.url ~parents:["users"; user_id; "activities"; activity_id]
       ~auth:(Some auth) ())
