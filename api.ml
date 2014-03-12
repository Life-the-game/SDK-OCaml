(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

include ApiTypes

(* ************************************************************************** *)
(* Curl Connection                                                            *)
(* ************************************************************************** *)

let connection = ref None

let writer accum data =
  Buffer.add_string accum data;
  String.length data
let result = Buffer.create 4096
let error_buffer = ref ""

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

let reconnect () =
  disconnect ();
  connect ()

(* ************************************************************************** *)
(* Curl Method handling                                                       *)
(* ************************************************************************** *)

type code = int

exception InvalidFileFormat
exception FileNotFound

(* Return a text from a url using Curl and HTTP Auth (if needed).
   Error handling with exceptions to catch                                    *)
let curl_perform ~path ~get ~post ~rtype () : (code * string) =

  let parameters_to_string parameters =
    let str =
      let f = (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) in
      List.fold_left  f "" parameters in
    if (String.length str) = 0 then str
    else Str.string_after str 1 (* remove last & *) in

  let c =
    (match !connection with
      | None -> connect () (* may throw exceptions *)
      | Some c ->
	let open Network in
	(match post with
	  | PostMultiPart _ -> reconnect ()
	  | _ -> c)) in

  let url =
    let path = List.fold_left (fun f s -> f ^ "/" ^ s) "" path
    and get =
      let str = parameters_to_string get in
      if (String.length str) = 0 then str else "?" ^ str in
     !ApiConf.base_url ^ path ^ get in

  Curl.set_postfieldsize c 0;
  let post_string str =
    ApiDump.verbose (" ## POST data: " ^ str);
    Curl.set_postfieldsize c (String.length str);
    Curl.set_postfields c str in
  let post_list l = post_string (parameters_to_string l)
  and post_multipart (parameters, files, checker) =
    ApiDump.verbose " ## POST multi-part data:";
    let parameter (name, value) =
      ApiDump.verbose (name ^ "=" ^ value);
      Curl.CURLFORM_CONTENT (name, value, Curl.DEFAULT)
    and file (name, (path, contenttype)) =
      if checker contenttype
      then
        let path = path_to_string path in
        ApiDump.verbose ("FILE " ^ name ^ "=" ^ path
           ^ "(" ^ contenttype ^ ")");
	if Sys.file_exists path
        then
	  (Curl.CURLFORM_FILE
             (name, path, Curl.CONTENTTYPE contenttype))
	else raise FileNotFound
      else raise InvalidFileFormat in
    let l = (List.map parameter parameters)
      @ (List.map file files)
      @ [parameter ("padding", "padding")] in
    Curl.set_httppost c l in
  let open Network in
  (match post with
    | PostEmpty  -> ()
    | PostText s -> post_string s
    | PostList l -> post_list l
    | PostMultiPart (p, f, c) -> if List.length f = 0
      then post_list p else post_multipart (p, f, c));

    Buffer.reset result;
    Curl.set_customrequest c (Network.to_string rtype);
    Curl.set_url c url;
    Curl.perform c;

    let text = Buffer.contents result in
    (Curl.get_responsecode c, text)

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
    | None                    -> parameters
    | Some (Auth a)           -> (auth_parameters a)::parameters
    | Some (Lang l)           -> (lang_parameters l)::parameters
    | Some (Auto (Some a, _)) -> (auth_parameters a)::parameters
    | Some (Auto (None, l))   -> (lang_parameters l)::parameters
    | Some (Both (a, l))      ->
      (auth_parameters a)::(lang_parameters l)::parameters

let page_parameters (parameters : parameters) (page : Page.parameters option)
    : parameters =
  match page with
  | Some (index, limit, sort) ->
    (Network.option_filter
       [("index", Some (string_of_int index));
        ("limit", Some (string_of_int limit));
        ("order", Option.map (fun (order, _) -> Page.order_to_string order) sort);
        ("direction", Option.map (fun (_, direction) -> Page.direction_to_string direction) sort);
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

exception ParseError of string

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
    let (code, result) =
      curl_perform ~path:path
        ~get:get ~post:post ~rtype:rtype () in
    let json = Yojson.Basic.from_string result in
    if code >= 200 && code <= 200
    then Result (from_json json)
    else Error (error_from_json code json)

  with
    | Yojson.Basic.Util.Type_error (msg, tree) ->
      Error (ApiTypes.invalid_json
               (msg ^ "\n" ^ (Yojson.Basic.to_string tree)))
    | Yojson.Json_error msg ->
      Error (ApiTypes.invalid_json msg)
    | Curl.CurlException (_, _, _) -> Error
      (ApiTypes.network !error_buffer)
    | Failure msg -> Error (ApiTypes.network msg)
    | Invalid_argument s -> Error (ApiTypes.invalid_json s)
    | InvalidFileFormat -> Error ApiTypes.invalid_format
    | FileNotFound -> Error ApiTypes.file_not_found
    | ParseError e -> Error (ApiTypes.invalid_json e)
    | _ -> Error ApiTypes.generic

(* ************************************************************************** *)
(* Various Developers tools                                                   *)
(* ************************************************************************** *)

let noop _ = ()

