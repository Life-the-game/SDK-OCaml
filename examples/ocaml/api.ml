(* ************************************************************************** *)
(* Project: La Vie Est Un Jeu - Public API, example with OCaml                *)
(* Description: Get a page from a url using curl and return a json tree       *)
(* Author: db0 (db0company@gmail.com, http://db0.fr/)                         *)
(* Latest Version is on GitHub: https://github.com/LaVieEstUnJeu/Public-API   *)
(* ************************************************************************** *)

(* ************************************************************************** *)
(* Types                                                                      *)
(* ************************************************************************** *)

(* Api Response                                                               *)
type 'a t =
  | Result of 'a
  | Error of ApiError.t

type login    = string
type password = string
type url      = string
type curlauth = (login * password)

(* ************************************************************************** *)
(* Configuration                                                              *)
(* ************************************************************************** *)

(* The URL of the API Web service                                             *)
let base_url = "http://life.paysdu42.fr:2000"

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
        raise (Failure ("Error: " ^ !errorBuffer))
      | Failure s -> raise (Failure s) in
  let _ = Curl.global_cleanup () in
  text

(* Generate a formatted URL with get parameters                               *)
let url ?(parents = []) ?(get = []) ?(url = base_url) () =
  let parents = List.fold_left (fun f s -> f ^ "/" ^ s) "" parents
  and get =
    let url = (List.fold_left (fun f (s, v) -> f ^ "&" ^ s ^ "=" ^ v) "" get) in
    if (String.length url) = 0 then url else (String.set url 0 '?'; url) in
  url ^ parents ^ get

(* ************************************************************************** *)
(* Transform content                                                          *)
(* ************************************************************************** *)

(* Take a response tree, check error and return the error and the result      *)
let get_content tree =
  let open Yojson.Basic.Util in
      let error =
        let elt = tree |> member "error" in
        if (elt |> member "code" |> to_int) = 0
        then None
        else
          (let open ApiError in
               Some {
                 message = elt |> member "message" |> to_string;
                 stype   = elt |> member "stype"   |> to_string;
                 code    = elt |> member "code"    |> to_int;
               })
      and element = tree |> member "element" in
      (error, element)

(* ************************************************************************** *)
(* Shortcuts                                                                  *)
(* ************************************************************************** *)

(* Take a url, get the page and return a json tree                            *)
let curljson ?(auth=None) ?(rtype=RequestType.GET) url =
  let result = get_text_form_url url in
  Yojson.Basic.from_string result

(* Take a url, get the pag into json, check and return error and result       *)
let curljsoncontent ?(auth=None) ?(rtype=RequestType.GET) url =
  get_content (curljson url)

(* ************************************************************************** *)
(* Ultimate shortcuts                                                         *)
(* ************************************************************************** *)

(* Handle an API method completely. Take a function to transform the json.    *)
let go ?(auth=None) ?(rtype=RequestType.GET) url f =
  let (error, content) =
    curljsoncontent ~auth:auth ~rtype:rtype url in
  match error with
    | Some error -> Error error
    | None       -> Result (f content)

(* In case the method does not return anything on success, use this to handle *)
(* the whole request (curljsoncontent + return unit result)                   *)
let noop ?(auth=None) ?(rtype=RequestType.GET) url =
  go ~auth:auth ~rtype:rtype url (fun _ -> ())
