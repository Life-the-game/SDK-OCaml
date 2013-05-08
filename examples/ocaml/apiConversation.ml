(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ApiTypes
open ExtLib

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type message =
    {
      sender_ref : int;
      content    : string;
    }

type t =
    {
      info             : Info.t;
      referenced_users : ApiUser.t list;
      messages         : message ApiTypes.List.t;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing a message and return a message object        *)
let message_from_json c =
  let open Yojson.Basic.Util in
      {
	sender_ref = c |> member "sender_ref" |> to_int;
	content    = c |> member "content"    |> to_string;
      }

(* Take a json tree representing an achievement and return anachievement      *)
let from_json c =
  let open Yojson.Basic.Util in
      {
	info             = Info.from_json c;
	referenced_users = convert_each ApiUser.from_json
	  (c |> member "referenced_users");
	messages         = ApiTypes.List.from_json
	  message_from_json (c |> member "child_achievements");

      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get the conversation                                                       *)
(* ************************************************************************** *)

let get ~auth ?(index = None) ?(limit = None) id_user =
  let url =
    Api.url ~parents:["users"; id_user; "conversation"] ~auth:(Some auth)
      ~get:(Api.pager index limit []) () in
  Api.go ~auth:(Some auth) url from_json

(* ************************************************************************** *)
(* Post a message in the conversation                                         *)
(* ************************************************************************** *)

let post ~auth message id_user =
  let url =
    Api.url ~parents:["users"; id_user; "conversation"] ~auth:(Some auth)
      ~get:[("message", message)] () in
  Api.go ~auth:(Some auth) ~rtype:POST url message_from_json

(* ************************************************************************** *)
(* Delete a message in the conversation                                       *)
(* ************************************************************************** *)

let delete ~auth ~id_message id_user =
  let url =
    Api.url ~parents:["users"; id_user; "conversation"; id_message]
      ~auth:(Some auth) () in
  Api.noop ~auth:(Some auth) ~rtype:DELETE url

