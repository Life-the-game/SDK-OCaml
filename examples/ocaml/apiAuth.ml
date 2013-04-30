(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type t =
    {
      user   : string;
      token  : string;
      expire : ApiTypes.DateTime.t;
    }

(* ************************************************************************** *)
(* Api Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let login login password =
  let (error, content) =
    Api.curljsoncontent
      (Api.url ~parents:["tokens"]
	 ~get:[("login", login); ("password", password)] ()) in
  match error with
    | Some error -> Api.Error error
    | None       ->
      let open Yojson.Basic.Util in
	  Api.Result
	    {
	      user   = content |> member "user"  |> to_string;
	      token  = content |> member "token" |> to_string; 
	      expire = ApiTypes.DateTime.of_string
		(content |> member "expire" |> to_string);
	    }

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let logout token =
  Api.noop
    (Api.url ~parents:["tokens"; token.token] ())
