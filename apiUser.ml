(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: tools to get/edit users                                       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml   *)
(* ************************************************************************** *)

open ApiTypes
open Network

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type t =
    {
      info                     : Info.t;
      login                    : login;
      firstname                : string option;
      lastname                 : string option;
      name                     : string option;
      avatar                   : ApiMedia.Picture.t option;
      gender                   : Gender.t;
      birthday                 : Date.t option;
      lang                     : Lang.t;
(* PRIVATE *)
      email                    : email option;
(* /PRIVATE *)
      score                    : int;
      level                    : int;
      is_friend                : bool option;
      game_network_total       : int;
      other_game_network_total : int;
      url                      : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

(* Take a json tree representing a user and return an object user             *)
let from_json c =
  let open Yojson.Basic.Util in
  let open ApiMedia in
      {
        info        = Info.from_json c;
        login       = c |> member "login" |> to_string;
        firstname   = c |> member "firstname" |> to_string_option;
        lastname    = c |> member "lastname" |> to_string_option;
        name        = c |> member "name" |> to_string_option;
        avatar      = c |> member "avatar" |> to_option Picture.from_json;
        gender      = Gender.of_string (c |> member "gender" |> to_string);
        birthday    = c |> member "birthday" |> to_option
            (fun d -> Date.of_string (d |> to_string));
        lang        = Lang.from_string (c |> member "lang" |> to_string);
(* PRIVATE *)
        email       = c |> member "email" |> to_string_option;
(* /PRIVATE *)
        score       = c |> member "score" |> to_int;
        level       = c |> member "level" |> to_int;
        is_friend   = c |> member "is_friend" |> to_bool_option;
        game_network_total = c |> member "game_network_total"
          |> to_int;
        other_game_network_total = c |> member "other_game_network_total"
          |> to_int;
        url         = c |> member "url" |> to_string;
      }

(* ************************************************************************** *)
(* API Methods                                                                *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Get users                                                                  *)
(* ************************************************************************** *)

let get ~auth ~term ?(page = Page.default_parameters) () =
  Api.go
    ~path:["users"]
    ~req:(Some (Auth auth))
    ~page:(Some page)
    ~get:[("term", Network.list_parameter term)]
    (Page.from_json from_json)

(* ************************************************************************** *)
(* Get one user                                                               *)
(* ************************************************************************** *)

let get_one ?(auth = None) id =
  Api.go
    ~path:["users"; id]
    ~req:(opt_auth auth)
    from_json

(* ************************************************************************** *)
(* Create a user                                                              *)
(* ************************************************************************** *)

let create ~login ~password ~email ~lang ?(firstname = "") ?(lastname = "")
    ?(gender = Gender.default) ?(birthday = None) ?(avatar = []) () =
  let post_parameters =
    Network.option_filter
      [("login",     Some login);
       ("email",     Some email);
       ("password",  Some password);
       ("firstname", Some firstname);
       ("lastname",  Some lastname);
       ("gender",    Some (Gender.to_string gender));
       ("birthday",  Option.map Date.to_string birthday);
      ] in
  let post = if List.length avatar != 0
    then Network.PostMultiPart (post_parameters, [("avatar", avatar)])
    else Network.PostList post_parameters in
  Api.go
    ~rtype:POST
    ~path:["users"]
    ~req:(Some (Lang lang))
    ~post:post
    from_json

(* (\* ************************************************************************** *\) *)
(* (\* Delete a user                                                              *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete ~auth id = *)
(*   let url = Api.url ~parents:["users"; id] ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)

(* (\* ************************************************************************** *\) *)
(* (\* Edit (put) a user                                                          *\) *)
(* (\* ************************************************************************** *\) *)

(* let edit ~auth ?(email = None) ?(password = None) ?(firstname = None) *)
(*     ?(lastname = None) ?(gender = None) ?(birthday = None) id = *)
(*   let url = Api.url ~parents:["users"; id] ~auth:(Some auth) *)
(*     ~get:(Api.option_filter *)
(*             [("email", email); *)
(*              ("password", password); *)
(*              ("firstname", firstname); *)
(*              ("lastname", lastname); *)
(*              ("gender", Option.map Gender.to_string gender); *)
(*              ("birthday", Option.map Date.to_string birthday); *)
(*             ]) () in *)
(*   Api.go ~auth:(Some auth) ~rtype:PUT url from_json *)

(* (\* ************************************************************************** *\) *)
(* (\* Get user's friends                                                         *\) *)
(* (\* ************************************************************************** *\) *)

(* let get_friends ?(auth = None) ?(lang = None) *)
(*     ?(index = None) ?(limit = None) user_id = *)
(*   let url = Api.url ~parents:["users"; user_id; "friends"] ~auth:auth ~lang:lang *)
(*     ~get:(Api.pager index limit []) () in *)
(*   Api.any ~auth:auth ~lang:lang url (List.from_json from_json) *)

(* (\* ************************************************************************** *\) *)
(* (\* The authenticated user request a friendship with a user                    *\) *)
(* (\*   Note: The src_user is for administrative purpose only                    *\) *)
(* (\* ************************************************************************** *\) *)

(* let be_friend_with ~auth ?(src_user = None) user_id = *)
(*   let url = *)
(*     Api.url ~parents:["users"; user_id; "friends"] ~auth:(Some auth) () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:POST *)
(*     ~post:(PostList (Api.option_filter [("src_user_id", src_user)])) url *)

(* (\* ************************************************************************** *\) *)
(* (\* The authenticated user delete a friendship with a user                     *\) *)
(* (\* ************************************************************************** *\) *)

(* let dont_be_friend_with ~auth user_id = *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE *)
(*     (Api.url ~parents:["users"; user_id; "friends"] ~auth:(Some auth) ()) *)

(* (\* ************************************************************************** *\) *)
(* (\* Delete a friendship between a user and another user                        *\) *)
(* (\*   Note: This method is for administrative purpose only                     *\) *)
(* (\* ************************************************************************** *\) *)

(* let delete_friendship ~auth user_id user_in_list_id = *)
(*   let url = Api.url ~auth:(Some auth) *)
(*     ~parents:["users"; user_id; "friends"; user_in_list_id] () in *)
(*   Api.noop ~auth:(Some auth) ~rtype:DELETE url *)
