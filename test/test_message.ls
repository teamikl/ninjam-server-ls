

require! {
  assert
  jasmine
  message: '../message'
}
global import all message

assert.ok verify-keep-alive(-10) is 0
assert.ok verify-keep-alive(0) is 0
assert.ok verify-keep-alive(255) is 255
