(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit achievements                                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info               : ApiTypes.Info.t;
      name               : string;
      description        : string;
      badge              : ApiMedia.Picture.t;
      parent_id          : string;
      child_achievements : t ApiTypes.List.t;
      url                : ApiTypes.url;
    }

type parent =
  | ParentId of int
  | Parent   of t

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
	parent_id          = c |> member "parent_id" |> to_string;
	child_achievements = ApiTypes.List.from_json
	  from_json (c |> member "child_achievements");
	url                = c |> member "" |> to_string;
      }

let string_of_parent = function
  | None -> None
  | Some p -> Some
    (string_of_int
       (match p with
	 | ParentId id -> id
	 | Parent p    -> p.info.ApiTypes.Info.id))

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ?(auth = None) ?(lang = None) () =
  let url = Api.url ~parents:["achievements"] ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url
    (fun c -> ApiTypes.List.from_json from_json c)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_achievement ?(auth = None) ?(lang = None) id =
  let url = Api.url ~parents:["achievements"; string_of_int id]
    ~auth:auth ~lang:lang () in
  Api.any ~auth:auth ~lang:lang url from_json

(* ************************************************************************** *)
(* Post a new Achievement                                                     *)
(* ************************************************************************** *)

let post ?(parent = None) auth name description =
  let get = Api.option_filter
    [("parent", string_of_parent parent);
     ("name", (Some name));
     ("description", (Some description));
    ] in
  let url = Api.url ~parents:["achievements"]
    ~get:get ~auth:(Some auth) () in
  Api.go ~auth:(Some auth) ~rtype:POST url from_json

(* ************************************************************************** *)
(* Edit (put) an Achievement                                                  *)
(* ************************************************************************** *)

let put ?(name = None) ?(description = None) ?(parent = None) auth id =
  let get = Api.option_filter
    [("name", name);
     ("description", description);
     ("parent", string_of_parent parent);
    ] in
  let url = Api.url ~parents:["achievements"; string_of_int id]
    ~get:get ~auth:(Some auth) () in
  Api.go ~auth:(Some auth) ~rtype:PUT url from_json

(* ************************************************************************** *)
(* Delete an Achievement                                                      *)
(* ************************************************************************** *)

let delete auth id =
  let url = Api.url ~parents:["achievements"; string_of_int id]
    ~auth:(Some auth) () in
  Api.go ~auth:(Some auth) ~rtype:DELETE url from_json
