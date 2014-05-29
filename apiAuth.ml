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
      access_token  : token;
      token_type    : string;
      expires_in    : int;
      refresh_token : token;
      scope         : string list;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json content =
  let open Yojson.Basic.Util in
      {
	access_token  = content |> member "access_token" |> to_string;
	token_type    = content |> member "token_type" |> to_string;
	expires_in    = content |> member "expires_in" |> to_int;
	refresh_token = content |> member "access_token" |> to_string;
	scope         = Str.split (Str.regexp " ")
	  (content |> member "scope" |> to_string);
      }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let client_logout () =
  ApiConf.auth_token := ""

let logout ?(token = !ApiConf.auth_token) () =
  let r = Api.go
    ~rtype:DELETE
    ~path:["tokens"; token]
    Api.noop in
  if token = !ApiConf.auth_token
  then match r with
    | Result auth -> client_logout (); r
    | _ -> r
  else r

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let _login ~oauth_id ~oauth_secret ~scope parameters =
  let r = Api.go
    ~httpauth:(Some (oauth_id, oauth_secret))
    ~rtype:POST
    ~path:["oauth2"; "access_token"]
    ~post:(Network.PostList ([
      ("scope", Network.list_parameter scope);
    ] @ parameters))
    from_json in
  match r with
    | Result auth -> ApiConf.auth_token := auth.access_token; r
    | _ -> r

let login ~oauth_id ~oauth_secret ~scope login password =
  _login ~oauth_id:oauth_id ~oauth_secret:oauth_secret ~scope:scope [
      ("grant_type", "password");
      ("username", login);
      ("password", password);
  ]

(* ************************************************************************** *)
(* OAuth Login                                                                *)
(* ************************************************************************** *)

let oauth ?(refresh_token="") ~oauth_id ~oauth_secret ~scope provider token =
  _login ~oauth_id:oauth_id ~oauth_secret:oauth_secret ~scope:scope [
      ("grant_type", "3rdparty_token");
      ("provider", provider);
      ("provider_access_token", token);
      ("provider_refresh_token", refresh_token);
  ]

let facebook ?(refresh_token="") ~oauth_id ~oauth_secret ~scope token =
  oauth ~refresh_token:refresh_token ~oauth_id:oauth_id
    ~oauth_secret:oauth_secret ~scope:scope "facebook" token
