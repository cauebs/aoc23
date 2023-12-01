import gleam/dynamic.{type Dynamic}
import gleam/erlang/os.{get_env}
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import simplifile.{type FileError}

fn token() -> String {
  let assert Ok(session) = get_env("AOC_SESSION")
  session
}

fn zero_padded_day(day: Int) -> String {
  int.to_string(day)
  |> string.pad_left(to: 2, with: "0")
}

const inputs_dir = "./inputs"

fn input_path(day: Int) -> String {
  inputs_dir <> "/day" <> zero_padded_day(day) <> ".txt"
}

fn input_from_file(day: Int) -> Result(String, FileError) {
  input_path(day)
  |> simplifile.read()
}

fn download_input(day: Int) -> Result(String, Dynamic) {
  let url =
    "https://adventofcode.com/2023/day/" <> int.to_string(day) <> "/input"
  let assert Ok(req) = request.to(url)

  use response <- result.try(
    req
    |> request.set_cookie("session", token())
    |> httpc.send,
  )

  let input = response.body
  let _ = simplifile.create_directory(inputs_dir)
  let assert Ok(_) = simplifile.write(input, to: input_path(day))
  Ok(input)
}

pub fn get_input(day: Int) -> String {
  let cached =
    input_from_file(day)
    |> result.nil_error

  let fetch = fn() {
    download_input(day)
    |> result.nil_error
  }

  let assert Ok(input) = result.lazy_or(cached, fetch)
  input
}

pub fn debug_apply(fun: fn(a) -> b, value: a) -> b {
  io.debug(fun(io.debug(value)))
}
