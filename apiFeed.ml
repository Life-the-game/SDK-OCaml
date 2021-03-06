(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get feed                                                                   *)
(* ************************************************************************** *)

let get ~auth ?(page = Page.default_parameters) ?(activity_type = [])
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    () =
  Api.go
    ~path:(
(* PRIVATE *)
    (match user with
      | Some user_id -> ["users"; user_id]
      | None         -> ["users"; "self"]) @
(* /PRIVATE *)
      ["feed"])
    ~req:(Some (Auth auth))
    ~page:(Some page)
    ~get:(Network.empty_filter
	    [("type", Network.list_parameter activity_type)])
    (Page.from_json (ApiPlayground.from_json ~req:(Auth auth)))

let global ?(auth = None) ?(page = Page.default_parameters) () =
  let req = Auto (auth, Lang.default) in
  Api.go
    ~path:["feed"]
    ~req:(Some req)
    ~page:(Some page)
    (Page.from_json (ApiPlayground.from_json ~req:req))
