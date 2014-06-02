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
        author       = ApiUser.from_json (c |> member "owner");
        content      = c |> member "content" |> to_string;
    }

(* ************************************************************************** *)
(* {API Methods}                                                              *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get comments                                                               *)
(* ************************************************************************** *)

let get resource ~session ?(page = Page.default_parameters) id =
  Api.go
    ~session:session
    ~path:[resource; id_to_string id; "comments"]
    ~page:(Some page)
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Add a comment                                                              *)
(* ************************************************************************** *)

let create resource ~session ~content id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:POST
    ~path:[resource; id_to_string id; "comments"]
    ~post:(PostList [("content", content)])
    from_json

(* ************************************************************************** *)
(* Edit a comment                                                             *)
(* ************************************************************************** *)

let edit ~session ~content id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:PATCH
    ~path:["comments"; id_to_string id]
    ~post:(PostList [("content", content)])
    from_json

(* ************************************************************************** *)
(* Delete a comment                                                           *)
(* ************************************************************************** *)

let delete ~session id =
  Api.go
    ~session:session
    ~auth_required:true
    ~rtype:DELETE
    ~path:["comments"; id_to_string id]
    Api.noop

(* ************************************************************************** *)
(* Vote                                                                       *)
(* ************************************************************************** *)

let vote = Api.vote "comments" from_json
let cancel_vote = Api.cancel_vote "comments" from_json
