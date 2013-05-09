(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Api.RequestType
open ApiTypes

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info   : Info.t;
      user   : ApiUser.t;
      token  : token;
      expire : DateTime.t;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing an auth element and return an auth element   *)
let from_json content =
  let open Yojson.Basic.Util in
      {
	info   = Info.from_json content;
        user   = ApiUser.from_json (content |> member "user");
        token  = content |> member "token" |> to_string;
        expire = DateTime.of_string
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
(*   Note: To get the tokens of another user, use get_user                    *)
(* ************************************************************************** *)

let get ?(index = None) ?(limit = None) auth =
  let url = Api.url ~parents:["tokens"] ~auth:(Some auth)
    ~get:(Api.pager index limit []) () in
  Api.go ~auth:(Some auth) url (List.from_json from_json)

(* ************************************************************************** *)
(* Get user's authentication tokens                                           *)
(*   Note: This method is for administrative purpose only                     *)
(* ************************************************************************** *)

let get_user ~auth ?(index = None) ?(limit = None) user_id =
  let url = Api.url ~parents:["users"; user_id; "tokens"] ~auth:(Some auth)
    ~get:(Api.pager index limit []) () in
  Api.go ~auth:(Some auth) url (List.from_json from_json)
