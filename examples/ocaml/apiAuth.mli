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

(* Get an authentication token from the API.                                  *)
(* Authenticate using a login and a password                                  *)
val login : string -> string -> (auth, Api.errors) Api.result

(* Invalidate the given token                                                 *)
val logout : auth -> (auth, Api.errors) Api.result
val logout_from_login_token : string -> string -> (auth, Api.errors) Api.result
