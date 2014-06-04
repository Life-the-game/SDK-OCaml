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

type t = _auth

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

let client_logout ~session () =
  session.auth <- None;
  Api.disconnect session

let logout ~session () =
  match session.auth with
    | None -> Error auth_required
    | Some (auth, _) ->
      let r = Api.go
	~session:session
	~rtype:DELETE
	~path:["tokens"; auth.access_token]
	Api.noop in
      match r with
	| Result auth -> client_logout ~session:session (); r
	| _ -> r

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let _login ~session ~oauth_id ~oauth_secret ~scope parameters =
  let r = Api.go
    ~session:session
    ~httpauth:(Some (oauth_id, oauth_secret))
    ~rtype:POST
    ~path:["oauth2"; "access_token"]
    ~post:(Network.PostList ([
      ("scope", Network.list_parameter scope);
    ] @ parameters))
    from_json in
  match r with
    | Result auth ->
      session.auth <- Some (auth, ApiUser.dummy);
      (match ApiUser.get_one ~session:session "me" with
	| Error e -> session.auth <- None; Error e
	| Result user -> session.auth <- Some (auth, user); r)
    | _ -> r

let login ~session ~oauth_id ~oauth_secret ~scope login password =
  _login ~session:session ~oauth_id:oauth_id ~oauth_secret:oauth_secret ~scope:scope [
      ("grant_type", "password");
      ("username", login);
      ("password", password);
  ]

(* ************************************************************************** *)
(* OAuth Login                                                                *)
(* ************************************************************************** *)

let oauth ~session ?(refresh_token="") ~oauth_id ~oauth_secret ~scope provider token =
  _login ~session:session ~oauth_id:oauth_id ~oauth_secret:oauth_secret ~scope:scope [
      ("grant_type", "3rdparty_token");
      ("provider", provider);
      ("provider_access_token", token);
      ("provider_refresh_token", refresh_token);
  ]
