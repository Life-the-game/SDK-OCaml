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
      in_game_network          : bool option;
      game_network_total       : int;
      other_game_network_total : int;
      url                      : url;
    }

(* ************************************************************************** *)
(* Tools                                                                      *)
(* ************************************************************************** *)

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
       in_game_network = c |> member "in_game_network" |> to_bool_option;
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

let get ~auth ~term ?(page = Page.default_parameters)
    ?(with_avatar = None) ?(genders = [])
    ?(lang = []) ?(min_score = None) ?(max_score = None)
    ?(min_level = None) ?(max_level = None)
    ?(is_in_network = None) () =
  Api.go
    ~path:["users"]
    ~req:(Some (Auth auth))
    ~page:(Some page)
    ~get:(Network.option_filter
            [("term", Some (Network.list_parameter term));
             ("with_avatar", Option.map string_of_bool with_avatar);
             ("genders", Some (Network.list_parameter
                                 (List.map Gender.to_string genders)));
             ("lang", Some (Network.list_parameter
                              (List.map Lang.to_string lang)));
             ("min_score", Option.map string_of_int min_score);
             ("max_score", Option.map string_of_int max_score);
             ("min_level", Option.map string_of_int min_level);
             ("max_level", Option.map string_of_int max_level);
             ("is_in_network", Option.map string_of_bool is_in_network);
            ])
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
  let post =
    Network.PostMultiPart
      (post_parameters,
       Network.files_filter [("avatar", avatar)],
       ApiMedia.Picture.path_to_contenttype) in
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
