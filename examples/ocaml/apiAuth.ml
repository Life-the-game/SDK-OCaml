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
  let url = Api.url ~parents:["tokens"]
    ~get:[("login", login); ("password", password)] () in
  Api.go ~rtype:POST url from_json

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let logout token =
  Api.noop ~rtype:DELETE (Api.url ~parents:["tokens"; token.token] ())

(* ************************************************************************** *)
(* Get information about a token                                              *)
(* ************************************************************************** *)

let get_token token_id =
  Api.go (Api.url ~parents:["tokens"; token_id] ()) from_json

(* ************************************************************************** *)
(* Get your current active connection tokens                                  *)
(*   Info: To get the tokens of another user, use ApiUser.get_tokens          *)
(* ************************************************************************** *)

let get ?(index = None) ?(limit = None) auth =
  let url = Api.url ~parents:["tokens"] ~auth:(Some auth)
    ~get:(Api.option_filter
	    [("index", Option.map string_of_int index);
	     ("limit", Option.map string_of_int limit)]) () in
  Api.go ~auth:(Some auth) url (ApiTypes.List.from_json from_json)
