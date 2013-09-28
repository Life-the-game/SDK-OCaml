(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ExtLib
open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      info               : Info.t;
      name               : string;
      description        : string option;
      badge              : ApiMedia.Picture.t option;
      color              : color option;
      category           : bool;
      secret             : bool;
      discoverable       : bool;
      (* keywords           : string list; *)(*42*)
      url                : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let rec from_json c =
  let open Yojson.Basic.Util in
      {
        info               = Info.from_json c;
        name               = c |> member "name" |> to_string;
        description        = c |> member "description" |> to_string_option;
        badge              = (c |> member "badge"
                                |> to_option ApiMedia.Picture.from_json);
	color              = c |> member "color" |> to_string_option;
        category           = c |> member "category" |> to_bool;
        secret             = c |> member "secret" |> to_bool;
        discoverable       = c |> member "discoverable" |> to_bool;
        (* keywords           = convert_each to_string (c |> member "keywords"); *)
        url                = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Achievements                                                           *)
(* ************************************************************************** *)

let get ~req ?(page = Page.default_parameters)
    ?(term = []) ?(with_badge = None) ?(is_category = None)
    ?(is_secret = None) ?(is_discoverable = None) () =
  Api.go
    ~path:["achievements"]
    ~req:(Some req)
    ~page:(Some page)
    ~get:(Network.option_filter
            [("term", Some (Network.list_parameter term));
             ("with_badge", Option.map string_of_bool with_badge);
             ("is_category", Option.map string_of_bool is_category);
             ("is_secret", Option.map string_of_bool is_secret);
             ("is_discoverable", Option.map string_of_bool is_discoverable);
            ])
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one Achievement                                                        *)
(* ************************************************************************** *)

let get_one ~req id =
  Api.go
    ~path:["achievements"; id]
    ~req:(Some req)
    from_json

(* PRIVATE *)

(* ************************************************************************** *)
(* Create a new Achievement                                                   *)
(* ************************************************************************** *)

let create ~auth ~name ~description ?(parents = []) ?(badge = [])
    ?(category = false) ?(secret = false) ?(discoverable = true)
    ?(keywords = []) () =
  let post_parameters =
    Network.empty_filter
      [("name", name);
       ("description", description);
       ("parents", Network.list_parameter parents);
       ("category", string_of_bool category);
       ("secret", string_of_bool secret);
       ("discoverable", string_of_bool discoverable);
       ("keywords", Network.list_parameter keywords);
      ] in
  let post =
    Network.PostMultiPart
      (post_parameters, Network.files_filter [("badge", badge)],
      ApiMedia.Picture.path_to_contenttype) in
  Api.go
    ~rtype:POST
    ~path:["achievements"]
    ~req:(Some (Auth auth))
    ~post:post
    from_json

(* /PRIVATE *)

(* let post ~auth ~name ?(description = None) () = *)
(*   let url = Api.url ~parents:["achievements"] *)
(*     ~auth:(Some auth) () in *)
(*   Api.go ~auth:(Some auth) ~rtype:POST *)
(*     ~post:(PostList (Api.option_filter *)
(*                        [("name", Some name); *)
(*                         ("description", description); *)
(*                        ])) url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Edit (put) an Achievement                                                  *\) *)
(* (\* ************************************************************************** *\) *)

(* let edit ~auth ?(name = None) ?(description = None) id = *)
(*   let get = Api.option_filter *)
(*     [("name", name); *)
(*      ("description", description); *)
(*     ] in *)
(*   let url = Api.url ~parents:["achievements"; id] *)
(*     ~get:get ~auth:(Some auth) () in *)
(*   Api.go ~auth:(Some auth) ~rtype:PUT url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Delete an Achievement                                                      *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth id = *)
(*   let url = Api.url ~parents:["achievements"; id] *)
(*     ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Get an achievement parents                                                 *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_parents ?(index = None) ?(limit = None) *)
(*     ?(auth = None) ?(lang = None) id = *)
(*   let url = Api.url ~parents:["achievements"; id; "parents"] *)
(*     ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in *)
(*   Api.any ~auth:auth ~lang:lang url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Get an achievement children                                                *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_children ?(index = None) ?(limit = None) *)
(*     ?(auth = None) ?(lang = None) id = *)
(*   let url = Api.url ~parents:["achievements"; id; "children"] *)
(*     ~get:(Api.pager index limit []) ~auth:auth ~lang:lang () in *)
(*   Api.any ~auth:auth ~lang:lang url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Add a child to a parent                                                    *\) *)
(* (\* ************************************************************************** *\) *)

(* let add_child ~auth child_id parent_id = *)
(*   let url = Api.url ~parents:["achievements"; parent_id; "children"] *)
(*     ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:POST *)
(*     ~post:(PostList [("achievement_id", child_id)]) url *)

(* (\* ************************************************************************** *\) *)
(* (\* Remove a child from a parent                                               *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete_child ~auth child_id parent_id = *)
(*   let url = Api.url ~parents:["achievements"; parent_id; "children"; child_id] *)
(*     ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)
