(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/SDK-OCaml    *)
(* ************************************************************************** *)

open ApiTypes

(* ************************************************************************** *)
(* Type                                                                       *)
(* ************************************************************************** *)

type 'a t = 'a response

(* ************************************************************************** *)
(* Curl Connection                                                            *)
(* ************************************************************************** *)

let connection = ref None

let writer accum data =
  Buffer.add_string accum data;
  String.length data
let result = Buffer.create 4096
let error_buffer = ref ""

(* Connect to the API using your username and password on GitHub.             *)
let connect () =
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  let c = Curl.init () in
  connection := Some c;
  Curl.set_errorbuffer c error_buffer;
  Curl.set_writefunction c (writer result);
  Curl.set_followlocation c true;
  Curl.set_useragent c !ApiConf.user_agent;
  c

let disconnect () =
  match !connection with
    | Some c ->
      connection := None;
      Curl.cleanup c;
      Curl.global_cleanup ()
    | _ -> ()

(* ************************************************************************** *)
(* Curl Method handling                                                       *)
(* ************************************************************************** *)

(* Return a text from a url using Curl and HTTP Auth (if needed).
 * Error handling with exceptions to catch                                    *)
let curl_perform ~path ~get ~post ~rtype () =

  let parameters_to_string parameters =
    let str =
      let f = (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) in
      List.fold_left  f "" parameters in
    if (String.length str) = 0 then str
    else Str.string_after str 1 (* remove last & *) in

  let c = match !connection with
    | None -> connect () (* may throw exceptions *)
    | Some c -> c in

  let url =
    let path = List.fold_left (fun f s -> f ^ "/" ^ s) "" path
    and get =
      let str = parameters_to_string get in
      if (String.length str) = 0 then str else "?" ^ str in
     !ApiConf.base_url ^ path ^ get in

  let post =
    let open Network in
        (match post with
          | PostEmpty  -> ""
          | PostText s -> s
          | PostList l -> parameters_to_string l
          | PostMultiPart (parameters, files) ->
            parameters_to_string parameters
            (* todo: files*)
        ) in
    Buffer.clear result;
    Curl.set_customrequest c (Network.to_string rtype);
    Curl.set_postfields c post;
    Curl.set_url c url;
    Curl.perform c;

    let text = Buffer.contents result in
    ApiDump.verbose (" ## URL: " ^ url);
    ApiDump.verbose (" ## POST data: " ^ post);
    ApiDump.verbose (" ## Content received:\n" ^ text);
    text

(* ************************************************************************** *)
(* Internal tools for extra parameters                                        *)
(* ************************************************************************** *)

let req_parameters (parameters : parameters) (req : requirements option)
    : parameters =
  let auth_parameters = function
    | Token t -> ("token", t)
    | _       -> ("todo", "oauth")
  and lang_parameters lang = ("lang", Lang.to_string lang) in
  match req with
    | None               -> parameters
    | Some (Auth a)      -> (auth_parameters a)::parameters
    | Some (Lang l)      -> (lang_parameters l)::parameters
    | Some (Both (a, l)) ->
      (auth_parameters a)::(lang_parameters l)::parameters

let page_parameters (parameters : parameters) (page : Page.parameters option)
    : parameters =
  match page with
  | Some (index, limit, order, direction) ->
    (Network.option_filter
       [("index", Option.map string_of_int index);
        ("limit", Option.map string_of_int limit);
        ("order", Option.map Page.order_to_string order);
        ("direction", Option.map
          Page.direction_to_string direction);
       ]) @ parameters
  | None -> parameters

let extra_parameters
    (parameters : parameters)
    (req : requirements option)
    (page : Page.parameters option)
    : parameters =
  page_parameters (req_parameters parameters req) page

(* ************************************************************************** *)
(* Make a call to the API                                                     *)
(* ************************************************************************** *)

(* Handle an API method completely. Take a function to transform the json.    *)
let go
    ?(rtype = Network.default)
    ?(path = [])
    ?(req = None)
    ?(page = None)
    ?(get = [])
    ?(post = Network.PostEmpty)
    from_json =

  let get = extra_parameters get req page
  and post = match post with
    | Network.PostList l -> Network.PostList (extra_parameters l req page)
    | p -> p in

  try
    (let result =
       curl_perform ~path:path
         ~get:get ~post:post ~rtype:rtype () in
     let json = Yojson.Basic.from_string result in
     let open Yojson.Basic.Util in
     let error_json = json |> member "error"
        |> to_option ApiError.from_json in
     match error_json with
       | Some error -> Error error
       | None ->
         let content = json |> member "element" in
         Result (from_json content))

  with
    | Yojson.Basic.Util.Type_error (msg, tree) ->
      Error (ApiError.invalid_json
                        (msg ^ "\n" ^ (Yojson.Basic.to_string tree)))
    | Yojson.Json_error msg ->
      Error (ApiError.invalid_json msg)
    | Curl.CurlException (_, _, _) -> Error
      (ApiError.network !error_buffer)
    | Failure msg -> Error (ApiError.network msg)
    | Invalid_argument s -> Error (ApiError.invalid_argument s)
    | _ -> Error ApiError.generic

(* ************************************************************************** *)
(* Various Developers tools                                                   *)
(* ************************************************************************** *)

(* Helper function to be used as the from_json parameter when methods does
 * not return anything (unit)                                                 *)
let noop _ = ()
