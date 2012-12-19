(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Type Auth                                                                  *)
(* ************************************************************************** *)

type auth =
    {
      login  : string;
      token  : string;
      expire : ApiTypes.DateTime.t;
      logged : bool;
    }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Login                                                                      *)
(* ************************************************************************** *)
(* Get an authentication token from the API.                                  *)

(* string -> string -> (auth, Api.errors) Api.result                          *)
(* Authenticate using a login and a password                                  *)
let login login password =
  let tree =
    let url = Api.url ~parents:["auth"; "login"]
                ~get:[("login", login);
                      ("password", password);
                     ] () in
    Api.curljson url in
  match Api.get_content tree with
    | Api.Failure e -> Api.Failure e
    | Api.Success tree ->
      let open Yojson.Basic.Util in
          Api.Success
            {
              login  = login;
              token  = tree |> member "token"  |> to_string;
              expire = ApiTypes.DateTime.of_string
                (tree |> member "expire" |> to_string);
              logged = tree |> member "logged" |> to_bool;
            }

(* ************************************************************************** *)
(* Logout                                                                     *)
(* ************************************************************************** *)
(* Invalidate the given token                                                 *)

(* string -> string -> (auth, Api.errors) Api.result                          *)
let logout_from_login_token login token =
  let tree =
    let url = Api.url ~parents:["auth"; "logout"]
                ~get:[("login", login);
                      ("token", token);
                     ] () in
    Api.curljson url in
  match Api.get_content tree with
    | Api.Failure e -> Api.Failure e
    | Api.Success tree ->
      let open Yojson.Basic.Util in
          Api.Success
            {
              login  = login;
              token  = tree |> member "token"  |> to_string;
              expire = ApiTypes.DateTime.of_string
                (tree |> member "expire" |> to_string);
              logged = tree |> member "logged" |> to_bool;
            }

(* auth -> Api.errors                                                         *)
let logout auth =
  logout_from_login_token auth.login auth.token
