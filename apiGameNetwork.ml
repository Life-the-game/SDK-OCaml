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
(* Get Game Network                                                           *)
(* ************************************************************************** *)

let get ?(auth = None) ?(page = Page.default_parameters) ?(term = "")
(* PRIVATE *)
    ~user
(* /PRIVATE *)
    () =
    Api.go
        ~path:(
           ["users"] @
(* PRIVATE *)
        [user] @
(* /PRIVATE *)
        ["network"])
        ~req:(opt_auth auth)
        ~page:(Some page)
        ~get:(Network.empty_filter
        [("term", term)])
        (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Get My Game Network                                                        *)
(* ************************************************************************** *)

let get_mine ~auth ?(page = Page.default_parameters) ?(term="") () =
    Api.go
    ~path:(["network"])
    ~req:(Some(Auth auth))
    ~page:(Some page)
    ~get:(Network.empty_filter
    [("term", term)])
    (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Get users who have a specified user in their Game Network                  *)
(* ************************************************************************** *)

let get_users ~req ?(page = Page.default_parameters)
(* PRIVATE *)
    ~user
(* /PRIVATE *)
    () =
        Api.go 
     ~path:(
            ["users"] @
(* PRIVATE *)
        [user] @
(* /PRIVATE *)
        ["others_network"])
    ~req:(Some req)
    ~page:(Some page)
    (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Get users who have me in their Game Network                                *)
(* ************************************************************************** *)

let get_my_users ~req ?(page = Page.default_parameters) () =
        Api.go 
     ~path:(["others_network"])
    ~req:(Some req)
    ~page:(Some page)
    (Page.from_json ApiUser.from_json)

(* ************************************************************************** *)
(* Add a user in my Game Network                                              *)
(* ************************************************************************** *)

let add ~auth
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    target_user =
        Api.go
        ~rtype:POST
        ~path:(
(* PRIVATE *)
            match user with
            | Some uid -> ["users"; uid; "network"; target_user]
            | None -> ["network"; target_user]
(* /PRIVATE *)
        )
        ~req:(Some (Auth auth))
        Api.noop

(* ************************************************************************** *)
(* Delete a user from my Game Network                                         *)
(* ************************************************************************** *)

let delete ~auth
(* PRIVATE *)
    ?(user = None)
(* /PRIVATE *)
    target_user =
        Api.go
        ~rtype:DELETE
        ~path:(
(* PRIVATE *)
            match user with
            | Some uid -> ["users"; uid; "network"; target_user]
            | None -> ["network"; target_user]
(* /PRIVATE *)
        )
        ~req:(Some (Auth auth))
        Api.noop


