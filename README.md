# emoji-thief
### _ava fox_

A program that downloads custom emoji from mastodon/pleroma servers

## Installation

Download a binary from the releases page

or

clone this repo and also the repo for [cl-cwd](https://github.com/inaimathi/cl-cwd) into your local projects

run `(asdf:make :emoji-thief)` to build your own

## Usage

`./steal DOMAIN-NAME+`

or

`(ql:quickload :emoji-thief)`

`(thief:get-all-emojis "my.cool.server")`

where "my.cool.server" is a mastodon server 

## License

NPLv1+

