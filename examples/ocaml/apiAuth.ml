(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools for authentification                                    *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

open Yojson.Basic.Util
open Api

type auth =
    {
      token  : string;
      expire : ApiTypes.DateTime.t;
    }

let login login password =
  let tree = curljson (ApiConf.base_url ^ "auth/login"
			   ^ "?login=" ^ login
			   ^ "&password=" ^ password) in
  let error = check_error tree in
  match error with
    | Some e -> Failure e
    | None   ->
      Success
	{
	  token  = tree |> member "token"  |> to_string;
	  expire = ApiTypes.DateTime.of_string
	    (tree |> member "expire" |> to_string);
	}
