(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ExtLib

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info               : ApiTypes.Info.t;
      name               : string;
      description        : string;
      badge              : ApiMedia.Picture.t;
      child_achievements : t ApiTypes.List.t;
      url                : ApiTypes.url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing an achievement and return anachievement      *)
let rec from_json c =
  let open Yojson.Basic.Util in
      {
	info               = ApiTypes.Info.from_json c;
	name               = c |> member "name" |> to_string;
	description        = c |> member "description" |> to_string;
	badge              = c |> member "badge" |> ApiMedia.Picture.from_json;
	child_achievements = ApiTypes.List.from_json
	  from_json (c |> member "child_achievements");
	url                = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ?(auth = None) ?(lang = None) ?(term = None) ?(index = None)
    ?(limit = None) () =
  let url = Api.url ~parents:["achievements"] ~auth:auth ~lang:lang
    ~get:(Api.option_filter
	    [("term", term);
	     ("index", Option.map string_of_int index);
	     ("limit", Option.map string_of_int limit)]) () in
  Api.any ~auth:auth ~lang:lang url (ApiTypes.List.from_json from_json)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_achievement ?(auth = None) ?(lang = None) id =
  let url = Api.url ~parents:["achievements"; string_of_int id]
    ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url from_json

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let post ~auth ~name ?(description = None) () =
  let get = Api.option_filter
    [("name", Some name);
     ("description", description);
    ] in
  let url = Api.url ~parents:["achievements"]
    ~get:get ~auth:(Some auth) () in
  Api.go ~auth:(Some auth) ~rtype:POST url from_json

(* ************************************************************************** *)
(* Edit (put) an Achievement                                                  *)
(* ************************************************************************** *)

let edit ~auth ?(name = None) ?(description = None) id =
  let get = Api.option_filter
    [("name", name);
     ("description", description);
    ] in
  let url = Api.url ~parents:["achievements"; id]
    ~get:get ~auth:(Some auth) () in
  Api.go ~auth:(Some auth) ~rtype:PUT url from_json

(* ************************************************************************** *)
(* Delete an Achievement                                                      *)
(* ************************************************************************** *)

let delete ~auth id =
  let url = Api.url ~parents:["achievements"; id]
    ~auth:(Some auth) () in
  Api.noop ~auth:(Some auth) ~rtype:DELETE url
