(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      info          : Info.t;
      vote          : Vote.t;
      author        : ApiUser.t;
      content       : string;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json c =
    let open Yojson.Basic.Util in
    {
        info         = Info.from_json c;
        vote         = Vote.from_json c;
        author       = ApiUser.from_json (c |> member "author");
        content      = c |> member "content" |> to_string;
    }

(* ************************************************************************** *)
(* {API Methods}                                                              *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get comments                                                               *)
(* ************************************************************************** *)

let get resource ?(page = Page.default_parameters) id =
  Api.go
    ~path:[resource; id_to_string id; "comments"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Add a comment                                                              *)
(* ************************************************************************** *)

let create resource ~content id =
  Api.go
    ~auth_required:true
    ~rtype:POST
    ~path:[resource; id_to_string id; "comments"]
    ~post:(PostList [("content", content)])
    from_json

(* ************************************************************************** *)
(* Edit a comment                                                             *)
(* ************************************************************************** *)

let edit ~content id =
  Api.go
    ~auth_required:true
    ~rtype:PUT
    ~path:["comments"; id_to_string id]
    ~post:(PostList [("content", content)])
    from_json

(* ************************************************************************** *)
(* Delete a comment                                                           *)
(* ************************************************************************** *)

let delete id =
  Api.go
    ~auth_required:true
    ~rtype:DELETE
    ~path:["comments"; id_to_string id]
    Api.noop

(* ************************************************************************** *)
(* Vote                                                                       *)
(* ************************************************************************** *)

let vote = Api.vote "comments" from_json
let cancel_vote = Api.cancel_vote "comments" from_json
