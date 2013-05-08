(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

type 'a t = 'a ApiTypes.response

(* ************************************************************************** *)
(* Configuration                                                              *)
(* ************************************************************************** *)

(* The URL of the API Web service                                             *)
let base_url = "http://je.peux.pas.venir.ce.week.end.jai.poney.me/eipapi/"

(* ************************************************************************** *)
(* Network                                                                    *)
(* ************************************************************************** *)

module type REQUESTTYPE =
sig
  type t =
    | GET
    | POST
    | PUT
    | DELETE
  val default   : t
  val to_string : t -> string
  val of_string : string -> t
end
module RequestType : REQUESTTYPE =
struct
  type t =
    | GET
    | POST
    | PUT
    | DELETE
  let default = GET
  let to_string = function
    | GET    -> "GET"
    | POST   -> "POST"
    | PUT    -> "PUT"
    | DELETE -> "DELETE"
  let of_string = function
    | "GET"    -> GET
    | "POST"   -> POST
    | "PUT"    -> PUT
    | "DELETE" -> DELETE
    | _        -> default
end

exception MyCurlExn of string

(* Return a text from a url using Curl and HTTP Auth (if needed)              *)
let get_text_form_url ?(auth=None) ?(rtype=RequestType.GET) url =
  let writer accum data =
    Buffer.add_string accum data;
    String.length data in
  let result = Buffer.create 4096
  and errorBuffer = ref "" in
  Curl.global_init Curl.CURLINIT_GLOBALALL;
  let text =
    try
      (let connection = Curl.init () in
       Curl.set_customrequest connection (RequestType.to_string rtype);
       Curl.set_errorbuffer connection errorBuffer;
       Curl.set_writefunction connection (writer result);
       Curl.set_followlocation connection true;
       Curl.set_url connection url;
       
       (match auth with
         | Some (username, password) ->
           (Curl.set_httpauth connection [Curl.CURLAUTH_BASIC];
            Curl.set_userpwd connection (username ^ ":" ^ password))
         | _ -> ());

       Curl.perform connection;
       Curl.cleanup connection;
       Buffer.contents result)
    with
      | Curl.CurlException (_, _, _) ->
        raise (MyCurlExn !errorBuffer)
      | Failure s -> raise (MyCurlExn s) in
  let _ = Curl.global_cleanup () in
  text

(* Generate a formatted URL with get parameters                               *)
let url ?(parents = []) ?(get = [])
    ?(url = base_url) ?(auth = None) ?(lang = None) () =
  let get = match lang with
    | Some lang -> (("lang", ApiTypes.Lang.to_string lang)::get)
    | None      -> get in
  let get = match auth with
    | Some (ApiTypes.Token t) -> (("token", t)::get)
    | _                       -> get (* todo: OAuth stuff *) in
  let parents = List.fold_left (fun f s -> f ^ "/" ^ s) "" parents
  and get =
    let url =
      let f = (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) in
      (List.fold_left  f "" get) in
    if (String.length url) = 0 then url else (String.set url 0 '?'; url) in
  url ^ parents ^ get

(* Handle an API method completely. Take a function to transform the json.    *)
let go ?(auth = None) ?(rtype = RequestType.GET) url f =
  try (let result =
	 get_text_form_url ~rtype:rtype
	   ~auth:(match auth with
	     | Some (ApiTypes.Curl auth) -> Some auth
	     | _                         -> None) url in
       let json = Yojson.Basic.from_string result in
       let open Yojson.Basic.Util in
           (let error_json = json |> member "error"
	       |> to_option ApiError.from_json in
	    match error_json with
	      | Some error -> ApiTypes.Error error
	      | None ->
		let content = json |> member "element" in
		ApiTypes.Result (f content)))
  with
    | Yojson.Basic.Util.Type_error (msg, tree) ->
      ApiTypes.Error (ApiError.invalid_json
			(msg ^ "\n" ^ (Yojson.Basic.to_string tree)))
    | Yojson.Json_error msg ->
      ApiTypes.Error (ApiError.invalid_json msg)
    | MyCurlExn msg ->
      ApiTypes.Error (ApiError.network msg)
    | Invalid_argument s -> ApiTypes.Error (ApiError.invalid_argument s)
    | _ -> ApiTypes.Error ApiError.generic

(* ************************************************************************** *)
(* Various tools                                                              *)
(* ************************************************************************** *)

(* In case the method does not return anything on success, use this to        *)
(* handle the whole request (go + return unit result)                         *)
let noop ?(auth = None) ?(rtype = RequestType.GET) url =
  go ~auth:auth ~rtype:rtype url (fun _ -> ())

(* Check if at least one requirement (auth or lang) has been provided before  *)
(* executing go                                                               *)
let any ?(auth = None) ?(lang = None) ?(rtype = RequestType.GET) url f =
  match (auth, lang) with
    | (None, None) -> ApiTypes.Error ApiError.requirement_missing
    | _            -> go ~auth:auth ~rtype:rtype url f

(* Clean an option list by removing all the "None" elements                   *)
let option_filter l =
  let rec aux acc = function
    | []   -> List.rev acc
    | (k, v)::t ->
      (match v with
	| Some v -> aux ((k, v)::acc) t
	| None   -> aux acc t) in
  aux [] l
