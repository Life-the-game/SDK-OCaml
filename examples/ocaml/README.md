OCaml API example
=================

This is the example of usage of our API using the [OCaml programming language](http://ocaml.org/).

To test it:
```shell
make
./api_example_ocaml
```

### How does it work?

This short documentation tells you briefly the content of the files.
he full description of the functions are directely in the source code.

###### API Methods

Each part of the API has its own module.
For instance, the API methods that handle User requests are in the `ApiUser` module (`apiUser.ml` and `apiUser.mli`).

###### Errors handling

Most of the requests return a data of type Api.result, which is defined as the following:
```ocaml
type ('a, 'b) result = Success of 'a | Failure of 'b
```
It allows you to handle errors on your requests.
To better understand how to use the methods, have a look at [the `example.ml` file](https://github.com/LaVieEstUnJeu/Public-API/blob/master/examples/ocaml/example.ml).

The list of available errors is in the `ApiRsp` module.

###### Data types

Almost all functions of the modules return a record containing the deserialized JSON object that as been returned by the API.

As you may know, the API use pre-defined custom types like dates or genders. These types are defined in the `ApiTypes` module.

###### More

The `Api` module contain some helpful functions to extend this usage of the API.
For instance, the `url` function helps you generate URL that correspond to the API methods.

The `get_content` and `curljson` functions are the ones that will interest you the most (see `api.mli` for more details).
