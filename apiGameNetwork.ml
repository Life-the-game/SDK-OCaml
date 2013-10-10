(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: nox                                                                *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get Game Network (People you follow)                                       *)
(* ************************************************************************** *)
(* Auth is optional but gives you more info                                   *)

let get ?(auth = None) ?(page = Page.default_parameters) ?(term = "") user =
  Api.go
    ~path:["users"; user; "network"]
    ~req:(opt_auth auth)
    ~page:(Some page)
    ~get:(Network.empty_filter
            [("term", term)])
    (Page.from_json ApiUser.from_json)

let get_mine ~auth ?(page = Page.default_parameters) ?(term="") () =
  Api.go
    ~path:(["network"])
    ~req:(Some (Auth auth))
    ~page:(Some page)
    ~get:(Network.empty_filter
	    [("term", term)])
    (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Get users who have me in their game network (People who follow you)        *)
(* ************************************************************************** *)
(* Auth is optional but gives you more info                                   *)

let get_followers ?(auth = None) ?(page = Page.default_parameters) user =
  Api.go 
    ~path:["users"; user; "others_network"]
    ~req:(opt_auth auth)
    ~page:(Some page)
    (Page.from_json ApiUser.from_json)

let get_my_followers ~auth ?(page = Page.default_parameters) () =
  Api.go 
    ~path:["others_network"]
    ~req:(Some (Auth auth))
    ~page:(Some page)
    (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Add a user in my Game Network                                              *)
(* ************************************************************************** *)

let add ~auth
(* PRIVATE *)
    ?(adder = None)
(* /PRIVATE *)
    added =
        Api.go
        ~rtype:POST
        ~path:(
(* PRIVATE *)
          (match adder with
            | Some adder -> ["users"; adder]
            | None -> []) @
(* /PRIVATE *)
        ["network"; added])
        ~req:(Some (Auth auth))
        Api.noop

(* ************************************************************************** *)
(* Delete a user from my Game Network                                         *)
(* ************************************************************************** *)

let delete ~auth
(* PRIVATE *)
    ?(remover = None)
(* /PRIVATE *)
    removed =
        Api.go
        ~rtype:DELETE
        ~path:(
(* PRIVATE *)
          (match remover with
            | Some remover -> ["users"; remover]
            | None -> []) @
(* /PRIVATE *)
        ["network"; removed])
        ~req:(Some (Auth auth))
        Api.noop


