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
      user           : ApiUser.t;
(* PRIVATE *)
      (* ip             : ip; *)
      (* user_agent     : string; *)
(* /PRIVATE *)
      token          : token;
      expiration     : DateTime.t;
      (* facebook_token : string option; *)
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

let from_json content =
  let open Yojson.Basic.Util in
      {
        info       = Info.from_json content;
        user       = ApiUser.from_json (content |> member "user");
(* PRIVATE *)
        (* ip         = content |> member "ip" |> to_string; *)
        (* user_agent = content |> member "user_agent" |> to_string; *)
(* /PRIVATE *)
        token      = content |> member "token" |> to_string;
        expiration = DateTime.of_string
          (content |> member "expiration" |> to_string);
        (* facebook_token = content |> member "facebook_token" *)
        (*   |> to_string_option; *)
      }

(* Transform an API object returned by the login function into an api type
   required by most of the API methods                                        *)
let auth_to_api auth =
  Token auth.token

let opt_auth_to_api = function
  | Some auth -> Some (auth_to_api auth)
  | None      -> None

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Login (create token)                                                       *)
(* ************************************************************************** *)

let login
(* PRIVATE *)
    ?(ip = "")
(* /PRIVATE *)
    login password =
  Api.go
    ~rtype:POST
    ~path:["users"; login; "tokens"]
    ~post:(Network.PostList
             (Network.option_filter
                [("password", Some password);
(* PRIVATE *)
                 ("ip", Some ip)
(* /PRIVATE *)
                ]))
    from_json

(* ************************************************************************** *)
(* Logout (delete token)                                                      *)
(* ************************************************************************** *)

let logout auth =
  Api.go
    ~rtype:DELETE
    ~path:["users"; auth.user.ApiUser.info.Info.id;
           "tokens"; auth.token]
    Api.noop

(* (\* ************************************************************************** *\) *)
(* (\* Get information about a token                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_token token_id = *)
(*   Api.go (Api.url ~parents:["tokens"; token_id] ()) from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Get your current active connection tokens                                  *\) *)
(* (\*   Note: To get the tokens of another user, use get_user                    *\) *)
(* (\* ************************************************************************** *\) *)

(* let get ?(index = None) ?(limit = None) auth = *)
(*   let url = Api.url ~parents:["tokens"] ~auth:(Some auth) *)
(*     ~get:(Api.pager index limit []) () in *)
(*   Api.go ~auth:(Some auth) url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* Get user's authentication tokens                                           *\) *)
(* (\*   Note: This method is for administrative purpose only                     *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_user ~auth ?(index = None) ?(limit = None) user_id = *)
(*   let url = Api.url ~parents:["users"; user_id; "tokens"] ~auth:(Some auth) *)
(*     ~get:(Api.pager index limit []) () in *)
(*   Api.go ~auth:(Some auth) url (List.from_json from_json) *)
