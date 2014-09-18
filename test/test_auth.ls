
require! {
  assert
  '../message'.create-auth-password-hash
}

let expected-hash = "d5d5b5013b5d7f8cef97397e06d6d4e9a4b967d0"
  pass-hash = create-auth-password-hash "XXXXXXXX", "anon"
  assert.equal expected-hash, pass-hash.to-string "hex"
  assert.ok pass-hash.length == 20
