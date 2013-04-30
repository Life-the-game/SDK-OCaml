(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type login = string
type password = string
type token = string

type t =
    {
      info   : ApiTypes.Info.t;
      user   : login;
      token  : token;
      expire : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing an auth element and return an auth element   *)
let from_json content =
  let open Yojson.Basic.Util in
      {
	info   = ApiTypes.Info.from_json content;
        user   = content |> member "user"  |> to_string;
        token  = content |> member "token" |> to_string;
        expire = ApiTypes.DateTime.of_string
          (content |> member "expire" |> to_string);
      }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let login login password =
  Api.go ~rtype:POST
    (Api.url ~parents:["tokens"]
       ~get:[("login", login); ("password", password)] ())
    from_json

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let logout token =
  Api.noop ~rtype:DELETE (Api.url ~parents:["tokens"; token.token] ())

(* ************************************************************************** *)
(* Get information about a token                                              *)
(* ************************************************************************** *)

let get_token token =
  Api.go (Api.url ~parents:["tokens"; token] ()) from_json

(* ************************************************************************** *)
(* Get your current active connection tokens                                  *)
(* ************************************************************************** *)

let get auth =
  let auth = Some auth in
  Api.go ~auth:auth (Api.url ~parents:["tokens"] ~auth:auth ())
    (fun c -> ApiTypes.List.from_json from_json c)
