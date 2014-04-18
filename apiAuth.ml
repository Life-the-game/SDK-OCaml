(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      info           : Info.t;
      mutable owner  : ApiUser.t;
      token          : token;
      expiration     : DateTime.t;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json content =
  let open Yojson.Basic.Util in
      {
        info       = Info.from_json content;
        owner       = ApiUser.from_json (content |> member "owner");
        token      = content |> member "token" |> to_string;
        expiration = DateTime.of_string
          (content |> member "expiration" |> to_string);
      }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let login_ params =
  let r = Api.go
    ~rtype:POST
    ~path:["tokens"]
    ~post:(Network.PostList params)
    from_json in
  match r with
    | Result auth -> ApiConf.auth_token := auth.token; r
    | _ -> r

let login login password =
  login_ [
    ("login", login);
    ("password", password);
  ]

(* ************************************************************************** *)
(* OAuth Login                                                                *)
(* ************************************************************************** *)

let oauth oauth_provider oauth_token =
  login_ [
    ("oauth_provider", oauth_provider);
    ("oauth_token", oauth_token)
  ]

let facebook = oauth "facebook"

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let logout ?(token = !ApiConf.auth_token) () =
  Api.go
    ~rtype:DELETE
    ~path:["tokens"; token]
    Api.noop

