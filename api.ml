(* ************************************************************************** *)
(* Project: Life - the game, Official OCaml SDK                               *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/Life-the-game/SDK-OCaml    *)
(* ************************************************************************** *)

include ApiTypes
open Network

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
let curl_perform ?(httpauth = None) ~path ~get ~post ~rtype () : (code * string) =

  let parameters_to_string parameters =
    let str =
      let f = (fun f (s, v) ->
	if s = "" || v = "" then f
	else f ^ "&" ^ s ^ "=" ^ v) in
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
    let path = (List.fold_left (fun f s -> f ^ "/" ^ s) "" path) ^ "/"
    and get =
      let str = parameters_to_string get in
      if (String.length str) = 0 then str else "?" ^ str in
    !ApiConf.base_url ^ path ^ get in
  let _ = ApiDump.verbose (" ## URI: " ^ (Network.to_string rtype) ^ " " ^ url) in

  Curl.set_httpheader c ["Accept-Language: " ^ (Lang.to_string !ApiConf.lang)];
  (match !ApiConf.auth_token with
    | "" -> () | token -> (Curl.set_httpheader c ["Authorization: Bearer " ^ token];
			   ApiDump.verbose (" ## Authentified with: " ^ token)));
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

      (match httpauth with
	| None -> ()
	| Some (login, password) ->
	  Curl.set_httpauth c [Curl.CURLAUTH_BASIC];
	  Curl.set_userpwd c (login ^ ":" ^ password);
	  ApiDump.verbose (" ## HTTPAuth: " ^ login ^ " : " ^ password);
      );

      Curl.set_customrequest c (Network.to_string rtype);
      Curl.set_url c url;
      Curl.perform c;

      let text = Buffer.contents result
      and code = Curl.get_responsecode c in
      let _ = ApiDump.verbose (" ## Response Code: " ^ (string_of_int code)) in
      let _ =
	let str = try (* String.sub text 0 800 *) text
	  with _ -> text in ApiDump.verbose (" ## Response Body: " ^ str) in
      (match httpauth with | None -> () | Some _ -> ignore (reconnect ()));
      (code, text)

(* ************************************************************************** *)
(* Internal tools for extra parameters                                        *)
(* ************************************************************************** *)

let page_parameters (parameters : parameters) (page : Page.parameters option)
    : parameters =
  match page with
    | Some (number, size, order) ->
      (Network.option_filter
	 [("page", match number with 1 -> None
	   | number -> Some (string_of_int number));
          ("page_size", Option.map string_of_int size);
          ("ordering", order);
	 ]) @ parameters
    | None -> parameters

let extra_parameters (parameters : parameters)
    (page : Page.parameters option) : parameters =
  page_parameters parameters page

(* ************************************************************************** *)
(* Make a call to the API                                                     *)
(* ************************************************************************** *)

exception ParseError of string

let go
    ?(httpauth = None)
    ?(auth_required = false)
    ?(rtype = Network.default)
    ?(path = [])
    ?(page = None)
    ?(get = [])
    ?(post = Network.PostEmpty)
    from_json =

  match auth_required, !ApiConf.auth_token with
    | false, token | true, token when token != "" ->

      let get = extra_parameters get page
      and post = match post with
	| Network.PostList l -> Network.PostList (extra_parameters l page)
	| p -> p in

      (try
	 let (code, result) =
	   curl_perform ~path:path ~httpauth:httpauth
             ~get:get ~post:post ~rtype:rtype () in
	 if code >= 200 && code < 300
	 then
	   let json = try Yojson.Basic.from_string result
	     with Yojson.Json_error "Blank input data" -> `Null in
	   Result (from_json json)
	 else Error (error_from_json code result)

       with
	 | Yojson.Basic.Util.Type_error (msg, tree) ->
	   ApiDump.verbose ("Trace [" ^ (Printexc.get_backtrace ()) ^ "]");
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
	 | _ -> Error ApiTypes.generic)
    | _ -> Error ApiTypes.auth_required

(* ************************************************************************** *)
(* Various Developers tools                                                   *)
(* ************************************************************************** *)

let noop _ = ()

let vote resource from_json id vote =
  go
    ~auth_required:true
    ~rtype:POST
    ~path:[resource; id_to_string id; "vote"]
    ~post:(PostList [("vote", Vote.to_string vote)])
    noop

let cancel_vote resource from_json id =
  go
    ~auth_required:true
    ~rtype:DELETE
    ~path:[resource; id_to_string id; "vote"]
    noop
